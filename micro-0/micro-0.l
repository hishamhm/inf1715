%{

#include "micro-0.tab.h"

int done = 0;

%}

%%

"/*"([^*]|"*"[^/])*"*"?"*/" {}

\"([^\n"\\]|\\[nt"])*\" { return LITSTRING; }
0x[0-9]+ { return LITNUM; }
[0-9]+ { return LITNUM; }

int	{ return INT; }
end	{ return END; }
fun	{ return FUN; }
":"	{ return ':'; }
"("	{ return '('; }
")"	{ return ')'; }
"="	{ return '='; }

[A-Za-z_][A-Za-z_0-9]* { return ID; }

([ \t]*\n)+[ \t]*	{ return NL; }

([ \t]*)	{ }

.	{ return ERROR; }

%%

int yywrap() {
}
