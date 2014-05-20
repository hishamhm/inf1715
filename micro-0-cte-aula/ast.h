
#ifndef AST_H
#define AST_H

typedef struct Token_ Token;
typedef struct AST_ AST;

typedef enum NodeType_ {
   AST_PROGRAM = 10000,
   AST_ASSIGN,
   AST_CALL,
   AST_DECLVAR,
   AST_ADD,
} NodeType;

struct AST_ {
   int type;
   int line;
   char* stringVal;
   int intVal;
   AST* firstChild;
   AST* lastChild;
   AST* prevSibling;
   AST* nextSibling;
};

extern const char* AST_NodeTypeNames[];

AST* AST_new(int type, int line);
AST* AST_newFromToken(Token tk);
void AST_delete(AST* node);
AST* AST_prependSibling(AST* list, AST* newFirst);
AST* AST_setChildren(AST* node, AST* childrenList);
AST* AST_addChild(AST* node, AST* child);

#endif
