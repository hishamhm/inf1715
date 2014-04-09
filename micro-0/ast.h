
#ifndef AST_H
#define AST_H

typedef struct AST_ AST;

struct AST_ {
   int type;
   int line;
   int intVal;
   char* stringVal;

   AST* firstChild;
   AST* lastChild;
   AST* parent;
   AST* nextSibling;
   AST* prevSibling;
};

#endif

