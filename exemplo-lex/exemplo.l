%{
#define FOO 100
#define BAR 101
#define OP 300
#define CP 301
#define STRING 200
#define ERROR 999999

int done = 0;

%}

%%

\"([^\n"\\]|\\["\\])*\" { return STRING; }

"foo"	{ return FOO; }
bar	{ return BAR; }

"("	{ return OP; }
")"	{ return CP; }


([ \t\n]*)	{ }

.           { return ERROR; }

%%

yywrap() {
	done = 1;
}

int main() {
	while (!done) {
		printf("%d\n", yylex());
		printf("%s\n", yytext);
	}
	return 0;
}
	