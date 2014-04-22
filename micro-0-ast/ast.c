
#include "ast.h"
#include "token.h"

#include <stdlib.h>

AST* AST_new(int type, int line) {
   AST* node = (AST*) calloc(1, sizeof(AST));
   node->type = type;
   node->line = line;
   return node;
}

AST* AST_newFromToken(Token tk) {
   AST* node = AST_new(tk.type, tk.line);
   node->stringVal = tk.asString;
   node->intVal = tk.asInteger;
   return node;
}

void AST_delete(AST* node) {
   AST* child = node->firstChild;
   while (child) {
      AST* nextChild = child->nextSibling;
      AST_delete(child);
      child = nextChild;
   }
   free(node);
}

AST* AST_prependSibling(AST* list, AST* newFirst) {
   if (!list) {
      return newFirst;
   }
   newFirst->nextSibling = list;
   list->prevSibling = newFirst;
   return newFirst;
}

AST* AST_setChildren(AST* node, AST* childrenList) {
   if (!childrenList) {
      return node;
   }
   node->firstChild = childrenList;
   AST* lastChild = childrenList;
   while (lastChild->nextSibling) {
      lastChild = lastChild->nextSibling;
   }
   node->lastChild = lastChild;
   node->firstChild = childrenList;
   return node;
}

AST* AST_addChild(AST* node, AST* child) {
   if (!child) {
      return node;
   }
   if (node->lastChild) {
      node->lastChild->nextSibling = child;
      child->prevSibling = node->lastChild;
      node->lastChild = child;
   } else {
      node->firstChild = child;
      node->lastChild = child;
   }
   return node;
}

