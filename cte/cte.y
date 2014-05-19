%{
#define YYDEBUG 1

extern int yylex();
extern int yyerror(char* msg);

%}

%token ERROR
%token FUN GLOBAL STRING BYTE LABEL ID NEW IF IFFALSE GOTO PARAM CALL RET NL 
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

string		: STRING ID '=' LITSTRING nl

global		: GLOBAL ID nl

function	: FUN ID '(' args ')' nl
		  commands
		;

args		: arg more_args
		|;

more_args	: ',' args
		|;

arg		: ID
		;

commands	: label command nl commands
		| ;

label		: LABEL ':' opt_nl label
		|;

rval		: LITNUM
		| ID
		;

command		: ID '=' rval
		| ID '=' BYTE rval
		| ID '=' rval binop rval
		| ID '=' unop rval
		| ID '=' ID '[' rval ']'
		| ID '[' rval ']' '=' rval
		| ID '=' BYTE ID '[' rval ']'
		| ID '[' rval ']' '=' BYTE rval
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
		| NEW BYTE
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
