%{
#define YYDEBUG 1
%}

%token ERROR
%token FUN END ID INT NL
%token LITSTRING LITNUM

%%

program		: opt_nl functions
                | opt_nl
                ;
                
functions	: function functions;
		| function
		;

nl		: NL opt_nl ;

opt_nl		: NL opt_nl
		|;

function	: FUN ID '(' ')' nl
			entries
		  END nl
		;

entries		: declvar nl entries
		| command nl commands
		|;

declvar		: ID ':' INT

commands	: command nl commands
		|;

command		: ID '(' ')'
		| ID '=' LITNUM
		;

%%

int yyerror(char* s) {
	printf("****************** Error! %s ****************** \n", s);
}

int main() {
	yydebug = 1;
	yyparse();
}
