
calc: calc.tab.c
	gcc -o calc calc.tab.c

calc.tab.c: calc.y
	bison -v -t calc.y

clean:
	rm -f *.o calc calc.output calc.tab.c 

