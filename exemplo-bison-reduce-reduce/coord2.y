%{
#include <stdio.h>

%}

%token NUM ID COOR RECT

%%

start : RECT ID '=' rect ';' '\n'                     { printf("start 1\n"); }
      | COOR ID '=' coor ';' '\n'                     { printf("start 2\n"); }
      ;

num : NUM                                             { printf("num 1 \n"); }
    | ID                                              { printf("num 2 \n"); }
    ;

coor : COOR '(' num ',' num ')'                       { printf("coor 1 \n"); }
     ;

coor_id : coor                                        { printf("coor_id 1 \n"); }
        | ID                                          { printf("coor_id 2\n"); }
        ;

rect_or_close : ')'                                   { printf(") 1 \n"); }
              | ',' num ',' num ')'                   { printf(",) 2 \n"); }
              ;

rect : RECT '(' NUM ',' num ',' num ',' num ')'       { printf("r1 \n"); }
     | RECT '(' coor ',' coor_id ')'                  { printf("r2 \n"); }
     | RECT '(' ID ',' coor ')'                       { printf("r3 \n"); }
     | RECT '(' ID ',' num rect_or_close              { printf("r4 \n"); }
     | ID                                             { printf("r5 \n"); }
     ;

%%

int yyerror(const char* s) {
   printf("Error! %s\n", s);
   
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
   yyparse();
   return 0;
}