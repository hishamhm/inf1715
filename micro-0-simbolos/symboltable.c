
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "symboltable.h"

SymbolTable* SymbolTable_new() {
   SymbolTable* st = calloc(1, sizeof(SymbolTable));
   return st;
}

void SymbolTable_add(SymbolTable* st, const char* name, SymbolType type) {
   Symbol* sym = calloc(1, sizeof(Symbol));
   sym->name = name ? strdup(name) : NULL;
   sym->type = type;
   sym->next = st->symbols;
   st->symbols = sym;
}

Symbol* SymbolTable_get(SymbolTable* st, const char* name) {
   Symbol* sym = st->symbols;
   while (sym) {
      if (sym->name && strcmp(sym->name, name) == 0) {
         return sym;
      }
      sym = sym->next;
   }
   return NULL;
}

void SymbolTable_beginScope(SymbolTable* st) {
   SymbolTable_add(st, NULL, SYM_SCOPE);
}

void Symbol_delete(Symbol* sym) {
   free(sym->name);
   free(sym);
}

void SymbolTable_endScope(SymbolTable* st) {
   Symbol* sym = st->symbols;
   bool quit = false;
   while (sym) {
      Symbol* next = sym->next;
      if (sym->type == SYM_SCOPE) {
         Symbol_delete(sym);
         st->symbols = sym->next;
         return;
      }
      sym = next;
   }
}

void SymbolTable_delete(SymbolTable* st) {
   // Assumes symbols are stored elsewhere.
   free(st);
}
