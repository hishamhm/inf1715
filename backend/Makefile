
CC=gcc
CFLAGS=-std=c99 -D_GNU_SOURCE -g -Wall -Werror

PROGRAM=backend
OBJECTS=main.o ir.o

all: $(PROGRAM)

$(PROGRAM): grammar.tab.c lexer.lex.c $(OBJECTS)
	$(CC) $(CFLAGS) -o $(PROGRAM) grammar.tab.c lexer.lex.c $(OBJECTS)

grammar.tab.c: grammar.y
	bison -t -v grammar.y --defines=grammar.tab.h

lexer.lex.c: lexer.l grammar.tab.c
	flex -o lexer.lex.c lexer.l

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

ir.o: ir.c
	$(CC) $(CFLAGS) -c ir.c

cov:
	$(MAKE) clean
	$(MAKE) CFLAGS="$(CFLAGS) -fprofile-arcs -ftest-coverage" all

clean:
	rm -f core *.gcov *.gcda *.gcno *.tab.* *.lex.* *.output *.gch *.dot *.o $(PROGRAM)


