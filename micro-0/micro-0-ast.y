%{
#define YYDEBUG 1

#include "ast.h"

%}

%token ERROR
%token FUN END ID INT NL
%token LITSTRING LITNUM

%%

program		: opt_nl functions	{ $$.node = AST_new(AST_PROGRAM, 1);
					  AST_addChildren($$.node, $2.node); }
                | opt_nl		{ $$.node = AST_new(AST_PROGRAM, 1); }
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
		  END nl		{ $$.node = AST_new(AST_FUN, $1.line);
					  AST_addChild($$.node, AST_newFromToken($2));
					  AST* block = AST_new(AST_BLOCK, $6.line);
					  AST_addChildren(block, $6.node);
					  AST_addChild($$.node, block); }
		;

entries		: declvar nl entries	{ $$.node = AST_prependSibling($3.node, $1.node); }
		| command nl commands	{ $$.node = AST_prependSibling($3.node, $1.node); }
		| /*empty*/		{ $$.node = NULL; }
		;

declvar		: ID ':' INT		{ $$.node = AST_new(AST_DECLVAR, $1.line);
					  AST_addChild($$.node, AST_newFromToken($1));
					  AST_addchild($$.node, AST_new(AST_INT, $3.line));
					}
		;

commands	: command nl commands	{ $$.node = AST_prependSibling($3.node, $1.node); }
		| /*empty*/		{ $$.node = NULL; }
		;

command		: ID '(' ')'		{ $$.node = AST_new(AST_CALL, $1.line);
					  AST_addChild($$.node, AST_newFromToken($1)); }
		| ID '=' LITNUM		{ $$.node = AST_new(AST_ASSIGN, $1.line);
					  AST_addChild($$.node, AST_newFromToken($1));}
					  AST_addChild($$.node, AST_newFromToken($3));}
		;

%%

int yyerror(char* s) {
	printf("****************** Error! %s ****************** \n", s);
}

int main() {
	yydebug = 1;
	yyparse();
}
