
coord: coord.tab.c
	gcc -o coord coord.tab.c

coord.tab.c: coord.y
	bison -v coord.y

clean:
	rm -f *.o coord coord.output coord.tab.c 

