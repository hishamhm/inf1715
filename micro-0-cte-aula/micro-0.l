%{

#include "token.h"
#include "micro-0.tab.h"

int line = 1;

static int Token_new(int type) {
   yylval.type = type;
   yylval.line = line;
   yylval.asString = NULL;
   yylval.asInteger = 0;
   return type;
}

static int Token_newString(int type, char* string) {
   Token_new(type);
   yylval.asString = string;
   return type;
}

static int Token_newInteger(int type, int integer) {
   Token_new(type);
   yylval.asInteger = integer;
   return type;
}

static char* convertString(char* text, int len) {
   char* str = malloc(len);
   char* at = text + 1;
   int i = 0;
   while (*at != '"') {
      if (*at != '\\') {
         str[i] = *at;
      } else {
         at++;
         switch (*at) {
            case 'n': str[i] = '\n'; break;
            case 't': str[i] = '\t'; break;
            case '"': str[i] = '"'; break;
            default: {
               free(str);
               return NULL;
            }
         }
      }
      i++;
      at++;
   }
   str[i] = '\0';
   return str;
}

%}

%%

"/*"([^*]|"*"[^/])*"*"?"*/"	{}

\"([^\n"\\]|\\[nt"])*\"		{
				   char* str = convertString(yytext, yyleng);
				   if (str) 
				      return Token_newString(LITSTRING, str);
				   else
				      Token_newString(ERROR, yytext);
				}

0x[0-9A-Fa-f]+			{ return Token_newInteger(LITNUM, strtol(yytext, NULL, 16)); }

[0-9]+				{ return Token_newInteger(LITNUM, strtol(yytext, NULL, 16)); }

int				{ return Token_new(INT); }
end				{ return Token_new(END); }
fun				{ return Token_new(FUN); }
":"				{ return Token_new(':'); }
"("				{ return Token_new('('); }
")"				{ return Token_new(')'); }
"="				{ return Token_new('='); }
"+"				{ return Token_new('+'); }

[A-Za-z_][A-Za-z_0-9]*		{ return Token_newString(ID, strndup(yytext, yyleng)); }

"\n"				{ Token_new(NL); line++; return NL; }

([ \t]*)			{}

.				{ return Token_newString(ERROR,  strndup(yytext, yyleng)); }

%%

int yywrap() {
}
