
#ifndef IR_H
#define IR_H

#include "ast.h"

typedef struct IR_ IR;

struct IR_ {
   int temps;
};

IR* IR_gen(AST* program);

#endif
