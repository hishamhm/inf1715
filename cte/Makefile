
CC=gcc
CFLAGS=-std=c99 -D_GNU_SOURCE -g

all: cte

cte: cte.tab.c cte.lex.c 
	$(CC) $(CFLAGS) -o cte cte.tab.c cte.lex.c 

cte.png: cte.dot
	dot -Tpng cte.dot > cte.png

cte.tab.c: cte.y
	bison -g -t -v cte.y --defines=cte.tab.h

cte.lex.c: cte.l cte.tab.c
	flex -o cte.lex.c cte.l

clean:
	rm -f *.tab.* *.lex.* *.output *.gch *.dot cte

