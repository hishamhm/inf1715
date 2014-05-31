%{

#include "token.h"
#include "grammar.tab.h"

static int line = 1;

static int Token_new(int type) {
	yylval.type = type;
	yylval.line = line;
	yylval.asString = NULL;
	yylval.asInteger = 0;
	return type;
}

static int Token_newString(int type, char* string) {
	Token_new(type);
	yylval.asString = string;
	return type;
}

static int Token_newInteger(int type, int integer) {
	Token_new(type);
	yylval.asInteger = integer;
	return type;
}

%}

%option yylineno
%option nounput
%option noinput

%%

#.* {}

\"([^\n"\\]|\\[nt"])*\" { return Token_newString(LITSTRING, strndup(yytext, yyleng)); }
[0-9]+ { return Token_newInteger(LITNUM, strtol(yytext, NULL, 10)); }

fun	{ return Token_new(FUN); }
global	{ return Token_new(GLOBAL); }
string	{ return Token_new(STRING); }
new	{ return Token_new(NEW); }
if	{ return Token_new(IF); }
ifFalse	{ return Token_new(IFFALSE); }
goto	{ return Token_new(GOTO); }
param	{ return Token_new(PARAM); }
call	{ return Token_new(CALL); }
ret	{ return Token_new(RET); }
byte	{ return Token_new(BYTE); }
"=="	{ return Token_new(EQ); }
"!="	{ return Token_new(NE); }
"<="	{ return Token_new(LE); }
">="	{ return Token_new(GE); }
"("	{ return Token_new('('); }
","	{ return Token_new(','); }
")"	{ return Token_new(')'); }
":"	{ return Token_new(':'); }
"="	{ return Token_new('='); }
"["	{ return Token_new('['); }
"]"	{ return Token_new(']'); }

">"	{ return Token_new('>'); }
"<"	{ return Token_new('<'); }
"+"	{ return Token_new('+'); }
"-"	{ return Token_new('-'); }
"*"	{ return Token_new('*'); }
"/"	{ return Token_new('/'); }

\.[A-Za-z_0-9]* { return Token_newString(LABEL, strndup(yytext, yyleng)); }
[A-Za-z$_][A-Za-z_0-9]* { return Token_newString(ID, strndup(yytext, yyleng)); }

([ \t]*\n)+[ \t]*	{ Token_new(NL); line++; return NL; }

([ \t]*)	{ }

.	{ return Token_newString(ERROR, strndup(yytext, yyleng)); }

%%

int yywrap() {
	return 1;
}
