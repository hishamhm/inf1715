
#ifndef TOKEN_H
#define TOKEN_H

#include "ir.h"

typedef struct Token_ {
   int type;
   int line;
   int asInteger;
   char* asString;
   
   /* Fields used in the grammar to pass information around: */
   String* strs;
   Variable* vars;
   Function* fun;
   Instr* ins;
   Addr addr;
   Opcode op;
} Token;

#define YYSTYPE Token

#endif
