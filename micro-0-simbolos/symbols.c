
#include <stdbool.h>
#include <stdio.h>
#include "assert.h"
#include "ast.h"
#include "symboltable.h"
#include "symbols.h"

static bool fail(const char* msg, const char* name, AST* node) {
   fprintf(stderr, "error: %s - %s at line %d\n", msg, name, node->line);
   return false;
}

static bool Symbols_visitDeclVar(SymbolTable* st, AST* declvar) {
   assert(declvar->firstChild->stringVal);
   const char* name = declvar->firstChild->stringVal;
   Symbol* existing = SymbolTable_get(st, name);
   if (existing && existing->type == SYM_FUNCTION) {
      return fail("Name clashes with a function", name, declvar);
   }
   SymbolTable_add(st, name, SYM_INT);
   return true;
}

static bool Symbols_visitAssign(SymbolTable* st, AST* assign) {
   assert(assign->firstChild->stringVal);
   const char* name = assign->firstChild->stringVal;
   Symbol* existing = SymbolTable_get(st, name);
   if (!existing) {
      return fail("Undeclared variable", name, assign);
   }
   if (existing->type == SYM_FUNCTION) {
      return fail("Not a variable", name, assign);
   }
   return true;
}

static bool Symbols_visitCall(SymbolTable* st, AST* call) {
   assert(call->firstChild->stringVal);
   const char* name = call->firstChild->stringVal;
   Symbol* existing = SymbolTable_get(st, name);
   if (!existing) {
      return fail("Undeclared function", name, call);
   }
   if (existing->type != SYM_FUNCTION) {
      return fail("Not a function", name, call);
   }
   return true;
}

static bool Symbols_visitFunctionEntry(SymbolTable* st, AST* entry) {
   switch (entry->type) {
      case AST_DECLVAR: 
         return Symbols_visitDeclVar(st, entry);
      case AST_ASSIGN:
         return Symbols_visitAssign(st, entry);
      case AST_CALL:
         return Symbols_visitCall(st, entry);
      default:
         return fail("internal compiler error!", "?!", entry);
   }
}

static bool Symbols_visitFunction(SymbolTable* st, AST* function) {
   bool ok;
   // check for redeclared function
   if (SymbolTable_get(st, function->stringVal)) {
      return fail("Redeclared function", function->stringVal, function);
   }
   SymbolTable_add(st, function->stringVal, SYM_FUNCTION);
   SymbolTable_beginScope(st);
   for(AST* child = function->firstChild; child; child = child->nextSibling) {
      ok = Symbols_visitFunctionEntry(st, child);
      if (!ok) return false;
   }
   SymbolTable_endScope(st);
   return true;
}

static bool Symbols_visitProgram(SymbolTable* st, AST* program) {
   bool ok;
   for(AST* child = program->firstChild; child; child = child->nextSibling) {
      ok = Symbols_visitFunction(st, child);
      if (!ok) return false;
   }
   return true;
}

bool Symbols_annotate(AST* ast) {
   SymbolTable* st = SymbolTable_new();
   
   return Symbols_visitProgram(st, ast);
}

