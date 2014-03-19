%{
#include <stdio.h>

typedef struct Token_ {
   int value;
} Token;

#define YYSTYPE Token

%}

%token DIGIT;

%left '+' '-'
%left '*' '/'

%%

line : expr '\n'            { printf("%d\n", $1); }
     ;

expr : expr '+' expr        { $$.value = $1.value + $3.value; }
     | expr '*' expr        { $$.value = $1.value * $3.value; }
     | expr '-' expr        { $$.value = $1.value - $3.value; }
     | expr '/' expr        { $$.value = $1.value / $3.value; }
     | factor
     ;

factor : '(' expr ')'       { $$.value = $2.value; }
       | DIGIT
       ;

%%

int yyerror(const char* s) {
   printf("Error! %s\n", s);
   
}

int yylex() {
   int c = getchar();
   if (isdigit(c)) {
      yylval.value = c - '0';
      return DIGIT;
   }
   return c;
}

int main() {
   yyparse();
   return 0;
}