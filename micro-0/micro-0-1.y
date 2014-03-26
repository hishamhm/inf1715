%{
#define YYDEBUG 1
%}

%token ERROR
%token FUN END ID INT NL
%token LITSTRING LITNUM

%glr-parser

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
			declvars
			commands
		  END nl
		;

declvars	: declvar NL declvars
                |;

declvar		: ID ':' INT

commands	: command NL commands
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
