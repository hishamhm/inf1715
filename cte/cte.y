%{
#define YYDEBUG 1

extern int yylex();
extern int yyerror(char* msg);

%}

%token ERROR
%token FUN GLOBAL STRING LABEL ID NEW IF IFFALSE GOTO PARAM CALL RET NL
%token LITSTRING LITNUM
%token EQ NE LE GE

%%

program		: strings globals functions
                ;

strings		: string strings
		|;

globals		: global globals
		|;              
		
functions	: function functions
		|;  

nl		: NL opt_nl ;

opt_nl		: NL opt_nl
		|;

function	: FUN ID '(' args ')' nl
		  commands
		;

global		: GLOBAL ID nl

string		: STRING ID '=' LITSTRING nl

args		: arg more_args
		|;

more_args	: ',' args
		|;

arg		: ID
		;

commands	: label command nl commands
		| ;

label		: LABEL ':'
		|;

rval		: LITNUM
		| ID
		;

command		: ID '=' rval
		| ID '=' rval binop rval
		| ID '=' unop rval
		| ID '=' ID '[' rval ']'
		| IF ID GOTO LABEL
		| IFFALSE ID GOTO LABEL
		| GOTO LABEL
		| call
		| RET rval
		| RET
		;

binop		: EQ
		| NE
		| '<'
		| '>'
		| GE
		| LE
		| '+'
		| '-'
		| '*'
		| '/'
		;

unop		: '-'
		| NEW
		;

call		: params
		  CALL ID
		;

params		: param nl params
		|;

param		: PARAM rval
		;


%%

int yyerror(char* s) {
	printf("****************** Error! %s ****************** \n", s);
}

int main() {
	yydebug = 1;
	yyparse();
}
