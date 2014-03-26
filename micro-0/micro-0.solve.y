%{
#define YYDEBUG 1
%}

%token ERROR
%token FUN ID
%token LITSTRING LITNUM
%token WHILE TRUE STRING RETURN OR NOT NEW NE LOOP LE INT IF GE FALSE AND BOOL CHAR ELSE END NL

%left OR
%left AND
%left '=' NE 
%left '<' LE '>' GE
%left '+' '-'
%left '*' '/'
%right NOT UMINUS

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

function	: FUN ID '(' opt_list_arg ')' return_type nl
			entries
		  END nl
		;

entries		: ID ':' type nl entries
		| ID '(' rest_call nl list_cmd
		| ID '=' rest_assign nl list_cmd
		| not_id_cmd list_cmd
		|;

rest_call	: opt_list_exp ')'
		;
rest_assign	: exp
		;
not_id_cmd	: cmdif | cmdwhile | cmdreturn
		;

return_type	: ':' type
		|;

opt_list_arg	: list_arg
		|;

list_arg	: arg ',' list_arg
		| arg
		;

arg		: ID ':' type

type		: basetype
		| '[' ']' type
		;

basetype	: INT
		| BOOL
		| CHAR
		| STRING
		;

list_cmd	: cmd list_cmd
		|;

cmd		: cmdif | cmdwhile | cmdassign | cmdreturn | cmdcall
		;

cmdif		: IF exp nl
			list_cmd
		  list_else_if
		  opt_else
		  END nl
		;

list_else_if    : else_if list_else_if
                |;

else_if		: ELSE IF exp nl
			list_cmd

opt_else	: ELSE nl
			list_cmd
		|;

cmdwhile	: WHILE exp nl
			list_cmd
		  LOOP nl
		;

cmdassign	: ID '=' exp nl

cmdcall		: ID '(' opt_list_exp ')' nl

cmdreturn	: RETURN exp nl
		| RETURN nl

opt_list_exp	: list_exp
		|;

list_exp	: exp ',' list_exp
		| exp
		;
		;

exp		: LITNUM
		| LITSTRING
		| TRUE
		| FALSE
		| NEW '[' exp ']' type
		| '(' exp ')'
		| cmdcall
		| exp '+' exp
		| exp '-' exp
		| exp '*' exp
		| exp '/' exp
		| exp '>' exp
		| exp '<' exp
		| exp GE exp
		| exp LE exp
		| exp '=' exp
		| exp NE exp
		| exp AND exp
		| exp OR exp
		| exp NOT exp
		| '-' exp %prec UMINUS
		;

%%

int yyerror(char* s) {
	printf("****************** Error! %s ****************** \n", s);
}

int main() {
	yydebug = 1;
	yyparse();
}
