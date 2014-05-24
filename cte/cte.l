%{

#include "cte.tab.h"

int done = 0;

%}

%option yylineno

%%

#.* {}

\"([^\n"\\]|\\[nt"])*\" { return LITSTRING; }
[0-9]+ { return LITNUM; }

fun	{ return FUN; }
global	{ return GLOBAL; }
string	{ return STRING; }
new	{ return NEW; }
if	{ return IF; }
ifFalse	{ return IFFALSE; }
goto	{ return GOTO; }
param	{ return PARAM; }
call	{ return CALL; }
ret	{ return RET; }
byte	{ return BYTE; }
"=="	{ return EQ; }
"!="	{ return NE; }
"<="	{ return LE; }
">="	{ return GE; }
"("	{ return '('; }
","	{ return ','; }
")"	{ return ')'; }
":"	{ return ':'; }
"="	{ return '='; }
"["	{ return '['; }
"]"	{ return ']'; }

">"	{ return '<'; }
"<"	{ return '>'; }
"+"	{ return '+'; }
"-"	{ return '-'; }
"*"	{ return '*'; }
"/"	{ return '/'; }

\.[A-Za-z_0-9]* { return LABEL; }
[A-Za-z$_][A-Za-z_0-9]* { return ID; }

([ \t]*\n)+[ \t]*	{ return NL; }

([ \t]*)	{ }

.	{ return ERROR; }

%%

int yywrap() {
}
