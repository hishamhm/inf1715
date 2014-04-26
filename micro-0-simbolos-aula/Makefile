
CC=gcc
CFLAGS=-std=c99 -D_GNU_SOURCE -ggdb

all: micro-0 micro-0.png

ast_print.o: ast_print.c ast_print.h ast.h token.h
	$(CC) $(CFLAGS) -c ast_print.c

ast.o: ast.c ast.h token.h
	$(CC) $(CFLAGS) -c ast.c

symboltable.o: symboltable.c ast.h
	$(CC) $(CFLAGS) -c symboltable.c

symbols.o: symbols.c symboltable.h ast.h
	$(CC) $(CFLAGS) -c symbols.c

micro-0: main.c micro-0.tab.c micro-0.lex.c token.h ast.o ast_print.o symbols.o symboltable.o
	$(CC) $(CFLAGS) -o micro-0 main.c micro-0.tab.c micro-0.lex.c ast.o ast_print.o symbols.o symboltable.o

micro-0.png: micro-0.dot
	dot -Tpng micro-0.dot > micro-0.png

micro-0.tab.c: micro-0.y
	bison -g -t -v micro-0.y --defines=micro-0.tab.h

micro-0.lex.c: micro-0.l micro-0.tab.c
	flex -o micro-0.lex.c micro-0.l

clean:
	rm -f *.tab.* *.lex.* *.output *.gch *.o micro-0
