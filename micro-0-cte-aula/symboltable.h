
#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

typedef enum {
   SYM_FUNCTION,
   SYM_INT,
   SYM_SCOPE,
} SymbolType;

typedef struct Symbol_ Symbol;

struct Symbol_ {
   char* name;
   SymbolType type;
   Symbol* next;
};

typedef struct SymbolTable_ {
   Symbol* symbols;
} SymbolTable;

SymbolTable* SymbolTable_new();
void SymbolTable_add(SymbolTable* st, const char* name, SymbolType type);
Symbol* SymbolTable_get(SymbolTable* st, const char* name);
void SymbolTable_beginScope(SymbolTable* st);
void SymbolTable_endScope(SymbolTable* st);
void SymbolTable_delete(SymbolTable* st);
void Symbol_delete(Symbol* sym);

#endif
