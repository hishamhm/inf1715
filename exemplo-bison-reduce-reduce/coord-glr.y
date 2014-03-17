%{
#include <stdio.h>

%}

%glr-parser
%expect-rr 1

%token NUM ID COOR RECT

%%

start : RECT ID '=' rect ';' '\n'
      | COOR ID '=' coor ';' '\n'
      ;

num : NUM                                           
    | ID
    ;

coor : COOR '(' num ',' num ')'
     | ID
     ;

rect : RECT '(' coor ',' coor ')'
     | RECT '(' num ',' num ',' num ',' num ')'
     | ID
     ;

%%

int yyerror(const char* s) {
   printf("************** Error! %s ************** \n", s);
   
}

int yylex() {
   int c = getchar();
   switch (c) {
   case '0': return NUM;
   case 'x': return ID;
   case 'C': return COOR;
   case 'R': return RECT;
   default: return c;
   }
}

int main() {
   yydebug = 1;
   yyparse();
   return 0;
}