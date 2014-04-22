
#ifndef TOKEN_H
#define TOKEN_H

#include "ast.h"

struct Token_ {
   int type;
   int line;
   int asInteger;
   char* asString;
   AST* node;
};

#define YYSTYPE Token

#endif
