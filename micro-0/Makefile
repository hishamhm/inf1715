
micro-0: micro-0.tab.c micro-0.lex.c
	gcc -o micro-0 micro-0.tab.c micro-0.lex.c

micro-0.tab.c: micro-0.y
	bison -g -t -v micro-0.y --defines=micro-0.tab.h

micro-0.lex.c: micro-0.l micro-0.tab.c
	flex -o micro-0.lex.c micro-0.l

clean:
	rm -f *.tab.c *.output micro-0
