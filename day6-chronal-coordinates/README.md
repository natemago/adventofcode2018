Day 6, Rust
===========

To compile & run:

```bash
rustc solution.rs && ./solution
```

For Part 1, I wasn't quite sure about what condition would have to be sufficient to cause 
the area of the region to explode to infinity, so I don't count the regions that are closest to
the Points that have the smallest and largest x and y. 
If drawn this would produce a bounding box (region), and I'm ignoring the areas related to the points
that are toucing the bounding box and I'm only counting the points in the grid within this area:
```
x x x x x x x A x x x x x
x                       x
B                       x
x                       x
x                       x
C                       x
x                       x
x                       x
x                       D
x                       x
x x x x x E x x x x x x x
```

Turns out, this is not quite correct because in my input there was another point that went off to infinity - so I'm 
removing this manually (looking for the second largest region).


