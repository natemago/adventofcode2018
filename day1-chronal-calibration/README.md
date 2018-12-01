Day 1, Assembly Language (NASM)
===============================

Day 1, NASM (x64).

To run, first assemble, then link and run:

Part 1:

```bash
nasm -f elf64 -l part1.lst  part1.asm
gcc -o part1 -no-pie part1.o
./part1
```

Part 2:

```bash
nasm -f elf64 -l part2.lst  part2.asm
gcc -o part2 -no-pie part2.o
./part2
```