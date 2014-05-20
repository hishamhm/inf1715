
#include "ast_print.h"

#include <stdlib.h>
#include <stdio.h>

const char* AST_NodeTypeNames[] = {
   "PROGRAM",
   "ASSIGN",
   "CALL",
   "DECLVAR",
   "ADD",
   NULL,
};

extern const char* typeToString(int type);

void AST_printIndent(AST* node, int level) {
   for (int i = 0; i < level; i++) {
      printf("   ");
   }
   if (node->stringVal) {
      printf("%s [%s] @%d ", typeToString(node->type), node->stringVal, node->line);
   } else {
      printf("%s @%d ", typeToString(node->type), node->line);
   }
   if (node->firstChild) {
      printf("{\n");
      AST* child = node->firstChild;
      while (child) {
         AST_printIndent(child, level + 1);
         child = child->nextSibling;
      }
      for (int i = 0; i < level; i++) {
         printf("   ");
      }
      printf("}\n");
   } else {
      printf("\n");
   }
}

void AST_print(AST* node) {
   AST_printIndent(node, 0);
}

