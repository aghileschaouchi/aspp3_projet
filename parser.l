%{
#include <stdlib.h>
#include <stdio.h>
#include "parser.tab.h"

void yyerror(const char*);
%}

%option noinput nounput yylineno

%x TXT
%s DECL_LEFT DECL_RIGHT DECL_IN
				
NUM [[:digit:]]+		
ID_CHAR [[:alnum:]_\'\.]
ID_XML [xX][mM][lL]{ID_CHAR}*
ID ([[:alpha:]]|_{ID_CHAR}){ID_CHAR}*						
TEXT ([^\"]*(\\\")*)*

%%
"let"              {return LET;}
"in"               {return IN;}
"where"            {return WHERE;}
{NUM}              {return NUM;}
{ID_XML}           {return ID_XML;}
{ID}               {yylval.string_t = strdup(yytext); return ID;}

\"                 {BEGIN TXT; return DBL_QUOTES_OPEN;}
<TXT>{
	{TEXT}         {yylval.string_t = strdup(yytext); return TEXT;}
	\"             {BEGIN INITIAL; return DBL_QUOTES_CLOSE;}
}

"["                {return '[';}
"]"                {return ']';}
"{"                {return '{';}
"}"                {return '}';}
";"                {return ';';}
"="                {return '=';}
","                {return ',';}
"+"                {return '+';}
"-"                {return '-';}
"*"                {return '*';}
"/"                {return '/';}
"("                {return '(';}
")"                {return ')';}
"<"                {return LE;}
"<="               {return LEQ;}
">"                {return GE;}
">="               {return GEQ;}
"=="               {return EQ;}
"&&"               {return AND;}
"||"               {return OR;}
"!"                {return NOT;}
[[:blank:]]+       {return SPACETAB;}
[\n]+              {return EOL;}
.                  {printf("[%c]", yytext[0]); return ERR;}//caractere non reconnu
