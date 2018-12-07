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
  return;
endfunction

function [node, known_nodes] = add_child(node, c, known_nodes)
  child = get_node(c, known_nodes);
  if child.id == "<nope>"
    child = new_node(c);
    child.root = false;
    known_nodes = [known_nodes; child];
    printf(" ::: append child -> %s (parent %s)\n", child.id, node.id);
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
      printf(" :: set not root to %s (parent %s)\n", c, node.id);
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
    printf(" [%s]\n", inputlines{i});   
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
            n.root = true
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
  disp(nodes);
  while length(nodes) > 0
    [node, nodes] = get_next(nodes, true);
    path = strcat(path, node.id);
    printf("----------------------");
    disp(nodes);
  endwhile
  
  return
endfunction


% ------------- part 2 -------------------
function [node, nodes] = next_workable(nodes, queue)
  node.id = "<none>"
  [next, nodes] = get_next(nodes, false);
  if next.available
    node = next
    get_next(nodes, true);
  endif
  return
endfunction

function [nodes, done] = do_work(nodes)
  done = 0;
  result = {};
  for i = 1:length(nodes)
    n = nodes{i};
    if n.time == 0
      done = done + 1;
      continue
    endif
    if n.in_progress
      n.timer = n.timer - 1;
    endif
    result = [result; n];
  endfor
  nodes = result;
  return
endfunction



nodes = load_deps( load_input( "input" ) );

tasks = traverse(nodes);
printf("Part 1: [%s]\n", tasks);