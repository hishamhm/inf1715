%{

#include <stdlib.h>
#include <stdio.h>

#define YYDEBUG 1

extern FILE* yyin;
extern int yylex();
extern int yyerror(const char* msg);
extern int yylineno;

%}

%define parse.error verbose

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
		| IF rval GOTO LABEL
		| IFFALSE rval GOTO LABEL
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
		  CALL ID /* Em caso de funcoes com valor retorno,
		             assuma que este esta na
		             variavel temporaria especial $ret */
                ;

params		: param nl params
		|;

param		: PARAM rval
		;


%%

int yyerror(const char* s) {
	fprintf(stderr, "*** Error at line %d: %s\n", yylineno, s);
}

int main(int argc, char** argv) {
	int err;
	//yydebug = 1;
	if (argc < 2) {
		fprintf(stderr, "Uso: cte arquivo.m0.ir\n");
		exit(1);
	}
	yyin = fopen(argv[1], "r");
	err = yyparse();
	if (err == 0) {
		printf("File is correct!\n");
	}
	fclose(yyin);
	return err;
}