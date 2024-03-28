# Command: "make all" in cmd prompt

all: a5a.o a5aMain.o
	gcc a5aMain.o a5a.o -o a5a 

a5a.o: a5a.asm
	m4 a5a.asm > a5a.s
	as a5a.s -o a5a.o

# Main file: assembly file
a5aMain.o: a5aMain.c
	gcc -c a5aMain.c -o a5aMain.o





