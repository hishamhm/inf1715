
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

#define FOO 100
#define BAR 101
#define STRING 200
#define ERROR 999999

// ****************************************************************************
// Types
// ****************************************************************************

typedef struct {
   char* buffer;
   int bufSize;
   int bufUsed;
   int ch;
   bool peeked;
} Lexer;

#define LEXER_DEFAULT_BUFSIZE 64

typedef struct {
   int type;
   char* text;
} Token;

// ****************************************************************************
// Token
// ****************************************************************************

Token* Token_new(Lexer* lx, int type) {
   Token* tk = malloc(sizeof(Token));
   tk->type = type;
   tk->text = strdup(lx->buffer);
   lx->bufUsed = 0;
   lx->buffer[0] = '\0';
   return tk;
}

void Token_delete(Token* tk) {
   free(tk->text);
   free(tk);
}

// ****************************************************************************
// Lexer
// ****************************************************************************

Lexer* Lexer_new() {
   Lexer* lx = malloc(sizeof(Lexer));
   lx->bufSize = LEXER_DEFAULT_BUFSIZE;
   lx->bufUsed = 0;
   lx->buffer = malloc(lx->bufSize);
   lx->buffer[0] = '\0';
   return lx;
}

void Lexer_delete(Lexer* lx) {
   free(lx->buffer);
   free(lx);
}

int Lexer_peek(Lexer* lx) {
   if (lx->peeked) {
      return lx->ch;
   }
   int ch = getchar();
   lx->ch = ch;
   lx->peeked = true;
   return ch;
}

int Lexer_get(Lexer* lx) {
   if (lx->peeked) {
      lx->peeked = false;
      return lx->ch;
   }
   int ch = getchar();
   lx->ch = ch;
   return ch;
}

void Lexer_addToBuffer(Lexer* lx, char ch) {
   lx->buffer[lx->bufUsed] = ch;
   lx->bufUsed++;
   if (lx->bufUsed == lx->bufSize) {
      lx->bufSize *= 2;
      lx->buffer = realloc(lx->buffer, lx->bufSize);
   }
   lx->buffer[lx->bufUsed] = '\0';
}

Token* Lexer_getToken(Lexer* lx) {
   for (;;) {
      char ch = Lexer_peek(lx);

      // Whitespace
      // [ \t\n]*
      while (strchr(" \t\n", ch)) {
         ch = Lexer_get(lx);
         ch = Lexer_peek(lx);
      }
      
      // String
      // \"([^\n"\\]|\\["\\])*\"
      if (ch == '"') {
         ch = Lexer_get(lx);
         Lexer_addToBuffer(lx, ch);
         for (;;) {
            ch = Lexer_get(lx);
            if (ch == EOF) {
               return Token_new(lx, ERROR);
            } else if (ch == '\\') {
               ch = Lexer_get(lx);
               if (ch == '\\' || ch == '"') {
                  Lexer_addToBuffer(lx, ch);
               } else {
                  return Token_new(lx, ERROR);
               }
            } else if (ch == '"') {
               Lexer_addToBuffer(lx, ch);
               return Token_new(lx, STRING);
            } else if (ch == '\n') {
               return Token_new(lx, ERROR);
            } else {
               Lexer_addToBuffer(lx, ch);
            }
         }
      }

      if (ch == EOF) {
         return NULL;
      }
      
      // Everything else

      while (!strchr(" \t\n\"", ch)) {
         ch = Lexer_get(lx);
         Lexer_addToBuffer(lx, ch);
         ch = Lexer_peek(lx);
         if (ch == EOF) {
            return NULL;
         }
      }
      
      if (lx->bufUsed > 0) {
         if (strcmp(lx->buffer, "foo") == 0) {
            return Token_new(lx, FOO);
         }
         if (strcmp(lx->buffer, "bar") == 0) {
            return Token_new(lx, BAR);
         }
         return Token_new(lx, ERROR);
      }
   }
}

int main() {

   Lexer* lx = Lexer_new();

   for (;;) {
      Token* tk = Lexer_getToken(lx);
      if (!tk) {
         break;
      }
      
      printf("%d\n", tk->type);
      printf("%s\n", tk->text);
      
      Token_delete(tk);
   }
   
   Lexer_delete(lx);
   
   return 0;

}
