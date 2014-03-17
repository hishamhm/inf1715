
coord: coord.tab.c
	gcc -o coord coord.tab.c

coord.tab.c: coord.y
	bison -v -t coord.y

coord2: coord2.tab.c
	gcc -o coord2 coord2.tab.c

coord2.tab.c: coord2.y
	bison -v -t coord2.y

coord-glr: coord-glr.tab.c
	gcc -o coord-glr coord-glr.tab.c

coord-glr.tab.c: coord-glr.y
	bison -v -t coord-glr.y

clean:
	rm -f *.o coord coord.output coord.tab.c 

