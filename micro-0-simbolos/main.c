
#include "micro-0.tab.h"
#include "ast.h"
#include "ast_print.h"
#include "symbols.h"
#include <stdio.h>
#include <stdbool.h>

extern AST* program;

int main() {
	yydebug = 1;
	yyparse();
	printf("--------------------------------------\n");
	if (!program) {
		return 1;
	}
	AST_print(program);
	bool ok = Symbols_annotate(program);
	if (!ok) {
		return 1;
	}
	return 0;
}

