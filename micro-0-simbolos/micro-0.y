%{

#include <stdlib.h>

#include "ast.h"
#include "token.h"

#define YYDEBUG 1
#define YYPRINT

int yylex();
int yyerror(char*);

AST* program;

%}

%token FUN END ID INT NL
%token LITSTRING LITNUM
%token ERROR

%%


program		: opt_nl functions	{ program = AST_new(AST_PROGRAM, 1); AST_setChildren(program, $2.node); }
                | opt_nl		{ program = AST_new(AST_PROGRAM, 1); }
                ;
                
functions	: function functions	{ $$.node = AST_prependSibling($2.node, $1.node); }
		| function		{ $$.node = $1.node; }
		;

nl		: NL opt_nl		{}
		;

opt_nl		: NL opt_nl		{}
		| /*empty*/		{}
		;

function	: FUN ID '(' ')' nl
			entries
		  END nl		{
					   $$.node = AST_new(FUN, $1.line);
					   $$.node->stringVal = $2.asString;
					   AST_setChildren($$.node, $6.node);
					}
		;

entries		: declvar nl entries	{ $$.node = AST_prependSibling($3.node, $1.node); }
		| command nl commands	{ $$.node = AST_prependSibling($3.node, $1.node); }
		| /*empty*/		{ $$.node = NULL; }
		;

declvar		: ID ':' INT		{
					   $$.node = AST_new(AST_DECLVAR, $1.line);
					   AST_addChild($$.node, AST_newFromToken($1));
					   AST_addChild($$.node, AST_newFromToken($3));
					}
		;

commands	: command nl commands	{ $$.node = AST_prependSibling($3.node, $1.node); }
		| /*empty*/		{ $$.node = NULL; }
		;

command		: ID '(' ')'		{
					   $$.node = AST_new(AST_CALL, $1.line);
					   AST_addChild($$.node, AST_newFromToken($1));
					}
		| ID '=' LITNUM		{
					   $$.node = AST_new(AST_ASSIGN, $1.line);
					   AST_addChild($$.node, AST_newFromToken($1));
					   AST_addChild($$.node, AST_newFromToken($3));
					}
		;

%%

const char* typeToString(int type) {
   if (type >= AST_PROGRAM) {
      return AST_NodeTypeNames[type - 10000];
   }
   for (int i = 0; yytname[i]; i++) {
      if (yytoknum[i] == type) {
         return yytname[i];
      }
   }
   return "?";
}

int yyerror(char* s) {
	printf("****************** Error! %s ****************** \n", s);
}
