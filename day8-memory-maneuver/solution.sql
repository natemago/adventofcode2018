-- to run either insert the input in kvstore under key 'raw', or
-- run it with sed:
-- INP=`cat input` && sed "s/\${INPUT}/${INP}/" solution.sql | psql -U postgres

drop table if exists kvstore;
drop table if exists node_children;
drop table if exists nodes;

create table kvstore (
    kk varchar(255) primary key,
    vv text
);

create table nodes (
    id integer primary key,
    num_children integer,
    num_metadata integer,
    consumed integer default 0,
    metadata integer[],
    nvalue integer default -1,
    marked integer default 0
);

create table node_children (
    node_id integer not null,
    child_id integer not null,
    foreign key (node_id) references nodes(id)
    --foreign key (child_id) references nodes(id)
);


insert into kvstore(kk, vv) values ('raw', '${INPUT}');

-- test
--insert into kvstore(kk, vv) values ('raw', '2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2');

do
$body$
declare
    i integer;
    vals integer[];
    stack integer[];
    curr_node integer;
    metadata_count integer;
    children_count integer;
    vals_count integer = 0;
    curr_metadata integer[];
    consumed_chld integer;
    node_id_seq integer = 1;
    curr_node_id integer;
begin
    select regexp_split_to_array(vv, E'\\s+')::integer[] from kvstore where kk = 'raw' into vals;

    stack := array[1]::integer[];
    i := 1;

    loop
        if i >= array_length(vals, 1) then
            exit;
        end if;
        
        --raise notice '%. % :: %', i, vals[i], stack;

        -- pop from stack
        curr_node := stack[array_length(stack, 1)];
        curr_node_id = stack[array_length(stack, 1)];
        stack := stack[1:array_length(stack, 1) - 1];

        select id, num_children, num_metadata, consumed
            into curr_node, children_count, metadata_count, consumed_chld
            from nodes 
            where id = curr_node;
        if curr_node is NULL then
            -- new, consume header
            children_count := vals[i];
            i := i + 1;
            metadata_count := vals[i];
            i := i + 1;
            insert into nodes(id, num_children, num_metadata) values (curr_node_id, children_count, metadata_count);
            --raise notice '   :: node %, num children: %, num metadata: %', stack, children_count, metadata_count;
            stack := array_append(stack, curr_node_id);
        else
            --raise notice '  :: not new. Node[%, %, %, %]', curr_node, children_count, metadata_count, consumed_chld;
            -- popped, consume metadata
            if (children_count - consumed_chld) = 0 then
                -- raise notice '  :: consume metadata';
                curr_metadata := array[]::integer[];
                loop
                    if metadata_count = 0 then
                        exit;
                    end if;
                    curr_metadata := array_append(curr_metadata, vals[i]);
                    i := i + 1;
                    metadata_count := metadata_count - 1;
                end loop;
                -- raise notice '  :: metadata -> %', curr_metadata;
                update nodes set metadata = curr_metadata where id = curr_node;
                --stack := array_append(stack, curr_node_id);
            else
                consumed_chld := consumed_chld + 1;
                update nodes set consumed = consumed_chld where id = curr_node;
                node_id_seq := node_id_seq + 1;
                stack := array_append(array_append(stack, curr_node), node_id_seq);
                insert into node_children(node_id, child_id) values (curr_node, node_id_seq);
            end if;
        end if;
        
    end loop;



end;
$body$
language 'plpgsql';

-- part 1:
select 'PArt 1: ', sum((select sum (s) from unnest(metadata) s)) as total from nodes;
-------------------------------------------------------------------------------------

-- part 2:
do
$body$
declare
    cn_id integer;
    cn_num_children integer;
    cn_metadata integer[];
    cn_value integer;
    total integer;
    sn_id integer;
    sn_num_children integer;
    sn_metadata integer[];
    c_all_nodes cursor for select id, num_children, metadata from nodes order by id;
    sn_children integer[];
    c integer;
    stack integer[];
    found integer;
    tmp_stack integer[];
    cn_is_marked integer;
    N integer;
begin
    -- dfs traversal
    total := 0;
    stack := array[1]::integer[]; -- the root node has id=1
    N := 10;
    loop
        -- N := N-1;
        -- if N = 0 then
        --     exit;
        -- end if;
        
        -- raise notice 'queue=%, len=%', stack, array_length(stack, 1);
        if stack is NULL or array_length(stack, 1) is NULL then
            exit; -- the stack is empty, bail out
        end if;
        
        c := stack[array_length(stack, 1)];
        stack := stack[1:array_length(stack, 1)-1];

        select id, num_children, metadata, nvalue, marked 
            into cn_id, cn_num_children, cn_metadata, cn_value, cn_is_marked
            from nodes
            where id = c;
        
        if cn_value >= 0 then
            continue;
        end if;
        update nodes set marked=1 where id=c;

        select array(select child_id 
                            from node_children 
                            where node_id=cn_id
                            order by child_id) into sn_children;
        -- raise notice ' Calculating node %: nchld=% Meta=% Chld=%', cn_id, cn_num_children, cn_metadata, sn_children;
        update nodes set marked=1 where id=cn_id;
        if cn_num_children > 0 then
            total := 0;
            found := 1; -- calculated
            tmp_stack := array[]::integer[];
            if cn_metadata is not NULL then
                foreach c in array cn_metadata loop
                    if c > 0 and c <= array_length(sn_children, 1) then
                        -- raise notice '      ::: checking child %: %', c, sn_children[c];
                        select nvalue, marked into cn_value, cn_is_marked from nodes where id=sn_children[c];
                        if cn_value is NULL or cn_value = -1 then
                            found := 0;
                            if cn_is_marked = 0 then
                                tmp_stack := array_append(tmp_stack, sn_children[c]);
                            end if;
                        end if;
                        total := total + cn_value;
                    end if;
                end loop;
            end if;
            if found > 0 then
                update nodes set nvalue=total where id = cn_id;
                -- raise notice '   ::: [C] set value to -> %', total;
            else
                stack := array_append(stack, cn_id); -- come back to this later
                stack := array_cat(stack, tmp_stack); -- calculate these first
            end if;
        else
            total := 0;
            if cn_metadata is not NULL then
                foreach c in array cn_metadata loop
                    total := total + c;
                end loop;
            end if;
            update nodes set nvalue=total where id = cn_id;
            -- raise notice '   ::: [N] set value to -> %', total;
        end if;
    end loop;
end;
$body$
language 'plpgsql';

select 'Part 2: ', nvalue from nodes where id=1;

