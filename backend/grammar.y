%{

#include <stdlib.h>
#include <stdio.h>
#include "ir.h"
#include "token.h"

#define YYDEBUG 1

extern int yylex();
extern int yyerror(const char* msg);
extern int yylineno;

IR* ir;
Function* fun;

%}

%define parse.error verbose

%token ERROR
%token FUN GLOBAL STRING BYTE LABEL ID NEW IF IFFALSE GOTO PARAM CALL RET NL 
%token LITSTRING LITNUM
%token EQ NE LE GE

%%
                                                        
program		: opt_nl
                  strings { ir = IR_new(); IR_setStrings(ir, $2.strs); }
		  globals { IR_setGlobals(ir, $4.vars); }
		  functions
                ;

strings		: string strings { $$.strs = String_link($1.strs, $2.strs); }
		| { $$.strs = NULL; }
		;

globals		: global globals { $$.vars = Variable_link($1.vars, $2.vars); }
		| { $$.vars = NULL; }
		;              
		
functions	: function { IR_addFunction(ir, fun); }
		  functions
		|;

nl		: NL opt_nl ;

opt_nl		: NL opt_nl
		|;

string		: STRING ID '=' LITSTRING nl { $$.strs = String_new($2.asString, $4.asString); }

global		: GLOBAL ID nl { $$.vars = Variable_new($2.asString); }

function	: FUN ID '(' args ')' nl { fun = Function_new($2.asString, $4.vars); }
		  commands { fun->code = $8.ins; }
		;

args		: arg more_args { $$.vars = Variable_link($1.vars, $2.vars); }
		| { $$.vars = NULL; }
		;

more_args	: ',' args { $$.vars = $2.vars; }
		| { $$.vars = NULL; }
		;

arg		: ID { $$.vars = Variable_new($1.asString); }
		;

commands	: label command nl commands { $$.ins = Instr_link($1.ins, Instr_link($2.ins, $4.ins)); }
		| { $$.ins = NULL; }
		;

label		: LABEL ':' opt_nl label { $$.ins = Instr_link(Instr_new(OP_LABEL, Addr_label($1.asString)), $4.ins); }
		| { $$.ins = NULL; }
		;

id		: ID { $$.addr = Addr_resolve($1.asString, ir, fun); }
		;

rval		: LITNUM { $$.addr = Addr_litNum($1.asInteger); }
		| id
		;

command		: id '=' rval                   { $$.ins = Instr_new(OP_SET, $1.addr, $3.addr); }
		| id '=' BYTE rval              { $$.ins = Instr_new(OP_SET_BYTE, $1.addr, $4.addr); }
		| id '=' rval binop rval        { $$.ins = Instr_new($4.op, $1.addr, $3.addr, $5.addr); }
		| id '=' unop rval              { $$.ins = Instr_new($3.op, $1.addr, $4.addr); }
		| id '=' id '[' rval ']'        { $$.ins = Instr_new(OP_SET_IDX, $1.addr, $3.addr, $5.addr); }
		| id '[' rval ']' '=' rval      { $$.ins = Instr_new(OP_IDX_SET, $1.addr, $3.addr, $6.addr); }
		| id '=' BYTE id '[' rval ']'   { $$.ins = Instr_new(OP_SET_IDX_BYTE, $1.addr, $4.addr, $6.addr); }
		| id '[' rval ']' '=' BYTE rval { $$.ins = Instr_new(OP_IDX_SET_BYTE, $1.addr, $3.addr, $7.addr); }
		| IF rval GOTO LABEL            { $$.ins = Instr_new(OP_IF, $2.addr, Addr_label($4.asString)); }
		| IFFALSE rval GOTO LABEL       { $$.ins = Instr_new(OP_IF_FALSE, $2.addr, Addr_label($4.asString)); }
		| GOTO LABEL                    { $$.ins = Instr_new(OP_GOTO, Addr_label($2.asString)); }
		| call                          { $$.ins = $1.ins; }
		| RET rval                      { $$.ins = Instr_new(OP_RET_VAL, $2.addr); }
		| RET                           { $$.ins = Instr_new(OP_RET); }
		;

binop		: EQ  { $$.op = OP_EQ; }
		| NE  { $$.op = OP_NE; }
		| '<' { $$.op = OP_LT; }
		| '>' { $$.op = OP_GT; }
		| GE  { $$.op = OP_GE; }
		| LE  { $$.op = OP_LE; }
		| '+' { $$.op = OP_ADD; }
		| '-' { $$.op = OP_SUB; }
		| '*' { $$.op = OP_MUL; }
		| '/' { $$.op = OP_DIV; }
		;

unop		: '-' { $$.op = OP_NEG; }
		| NEW { $$.op = OP_NEW; }
		| NEW BYTE { $$.op = OP_NEW_BYTE; }
		;

call		: params
                  /* In case of functions with a return value,
                     assume that this is stored in special temporary $ret */ 
		  CALL ID { $$.ins = Instr_link($1.ins, Instr_new(OP_CALL, Addr_function($3.asString))); }
                ;

params		: param nl params { $$.ins = Instr_link($1.ins, $3.ins); }
		| { $$.ins = NULL; }
		;

param		: PARAM rval { $$.ins = Instr_new(OP_PARAM, $2.addr); }
		;


%%

int yyerror(const char* s) {
	fprintf(stderr, "*** Error at line %d: %s\n", yylineno, s);
	return 1;
}
