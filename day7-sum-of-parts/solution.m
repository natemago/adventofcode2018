printf("Day 7, Octave solution\n")

function result = load_input( fname )
  fid = fopen(fname);
  inplines = {};
  line = fgetl(fid);
  inplines = [inplines; line];
  while line != -1 
    line = fgetl(fid);
    if line != -1
      inplines = [inplines; line];
    endif
  endwhile
  fclose(fid);
  result = inplines;
  return;
endfunction


function node = new_node(id)
  node.id = id;
  node.root = true;
  node.children = {};
  node.scheduled = false;
  node.timer = -1;
  return;
endfunction

function [node, known_nodes] = add_child(node, c, known_nodes)
  child = get_node(c, known_nodes);
  if child.id == "<nope>"
    child = new_node(c);
    child.root = false;
    known_nodes = [known_nodes; child];
  endif
  children = node.children;
  children = [children; c];
  child.root = false;
  node.children = sort(children);
  for i = 1:length(known_nodes)
    if known_nodes{i}.id == node.id
      known_nodes{i} = node;
    endif
    if known_nodes{i}.id == c
      child.root = false;
      known_nodes{i} = child;
    endif
  endfor
  return;
endfunction

function node = get_node(id, known_nodes)
  node.id = "<nope>";
  for i = 1:length(known_nodes);
    if known_nodes{i}.id == id 
      node = known_nodes{i};
    endif
  endfor
  return;
endfunction

function all_nodes = load_deps(inputlines)
  all_nodes = {};
  for i = 1:length(inputlines)  
    a = inputlines{i}(6);
    b = inputlines{i}(37);
    na = get_node(a, all_nodes);
    if na.id == "<nope>"
      na = new_node(a);
      all_nodes = [all_nodes; na];
    endif
    % a must be completed before b, so a is root of b
    [nb, all_nodes] = add_child(na, b, all_nodes);
    
  endfor
  return;
endfunction

function deps = get_dependents(nid, nodes)
  deps = {};
  for i = 1:length(nodes)
    for j = 1:length(nodes{i}.children)
      if nodes{i}.children{j} == nid 
        deps = [deps; nodes{i}];
      endif
    endfor
  endfor
  return;
endfunction


function arr = remove_element(el, arr)
  res = {};
  for i = 1:length(arr)
    if el != arr{i}
      res = [res; arr{i}];
    endif
  endfor
  arr = res;
  return
endfunction

function [node, nodes] = get_next(nodes, pop)
  idx = 0;
  for i = 1:length(nodes)
    if nodes{i}.root
      idx = i;
      break;
    endif
  endfor
  
  node = nodes{idx};
  if !pop
    return
  endif
  
  result = {};
  for i = 1:length(nodes)
    if i != idx
      n = nodes{i};
      for j = 1:length(node.children)
        c = node.children{j};
        if c == n.id
          if length(get_dependents(c, nodes)) == 1
            n.root = true;
          endif
        endif
      endfor
      n.children = remove_element(node.id, n.children);
      result = [result; n];
    endif
  endfor
  nodes = result;
  return;
endfunction


function path = traverse(nodes)
  [_i, idxs] = sort(arrayfun(@(n) n{1}.id, nodes, "UniformOutput", false));
  nodes = nodes(idxs);
  
  path = "";
  while length(nodes) > 0
    [node, nodes] = get_next(nodes, true);
    path = strcat(path, node.id);
  endwhile
  
  return
endfunction



% ------------- part 2 -------------------

function [next, nodes] = schedule_next(nodes)
  next.id = "<none>";
  res = {};
  for i = 1:length(nodes)
    n = nodes{i};
    if n.root && !n.scheduled && next.id == "<none>"
      next = n;
      n.scheduled = true;
    endif
    res = [res; n];
  endfor
  nodes = res;
  return
endfunction

function print_nodes(nodes)
  for i = 1:length(nodes)
    n = nodes{i};
    if n.root
      printf("<R");
    else
      printf("__");
    endif
    if n.scheduled
      printf("S]");
    else
      printf("_]");
    endif
    printf("%s [%d](", n.id, n.timer);
    for j = 1:length(n.children)
      printf("%s ", n.children{j});
    endfor
    
    printf("), ");
  endfor
  printf("\n");
endfunction

function nodes = pop_node(node, nodes)
  result = {};
  for i = 1:length(nodes)
    if nodes{i}.id != node.id
      n = nodes{i};
      for j = 1:length(node.children)
        c = node.children{j};
        if c == n.id
          if length(get_dependents(c, nodes)) == 1
            n.root = true;
          endif
        endif
      endfor
      n.children = remove_element(node.id, n.children);
      result = [result; n];
    endif
  endfor
  nodes = result;
  return;
endfunction

function q = remove_at(idx, q)
  res = {};
  for i = 1:length(q)
    if i != idx
      res = [res; q{i}];
    endif
  endfor
  q = res;
  return;
endfunction

function total = part2(nodes, max_workers, overhead)
  total = 0;
  q = {};
  doneq = {};

  while true
    % populate q

    if length(q) == 0 && length(nodes) == 0
      break
    endif

    while length(q) < max_workers
      [n, nds] = schedule_next(nodes);
      nodes = nds;
      if n.id == "<none>"
        break
      endif
      n.timer = (n.id - 'A') + overhead;
      q = [q; n];
    endwhile

    % print_nodes(q);
    rmqidxs = {};
    for i = 1:length(q)
      if q{i}.timer == 0
        doneq = [doneq; q{i}];
        rmqidxs = [rmqidxs;i];
      else
        q{i}.timer = q{i}.timer - 1;
      endif
    endfor

    for i = 1:length(rmqidxs)
      q = remove_at(rmqidxs{i}, q);
    endfor

    for i = 1:length(doneq)
      nds = pop_node(doneq{i}, nodes);
      nodes = nds;
    endfor
    doneq = {};
    total = total + 1;
  endwhile

  return;
endfunction



nodes = load_deps( load_input( "input" ) );

tasks = traverse(nodes);
printf("Part 1: [%s]\n", tasks);
% 5 elfs + myself DUUH!
tot = part2(nodes, 6, 60);
printf("Part 2: %d\n", tot)