CC = gcc

NASMFLAGS = -f elf64 -F stabs

all: test1 test2 test3

gameoflife.o: gameoflife.asm
	nasm -f elf64 -F dwarf gameoflife.asm

test1: test1.o utils.o gameoflife.o
	gcc $^ -o $@

test2: test2.o utils.o gameoflife.o
	gcc $^ -o $@

test3: test3.o utils.o gameoflife.o
	gcc $^ -o $@

clean:
	rm -rf *.o *~ test1 test2 test3
