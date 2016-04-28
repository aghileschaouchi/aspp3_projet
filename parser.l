%{
#include <stdlib.h>
#include <stdio.h>
#include "parser.tab.h"

void yyerror(const char*);
%}

%option noinput nounput yylineno

%x TXT
				
NUM [[:digit:]]+		
ID_CHAR [[:alnum:]_\'\.]
ID_XML [xX][mM][lL]{ID_CHAR}*
ID ([[:alpha:]]|_{ID_CHAR}){ID_CHAR}*						
TEXT ([^\"]*(\\\")*)*
SPACE [[:space:]]+

%%
"let"              {return LET;}
"rec"              {return REC;}
"in"               {return IN;}
"where"            {return WHERE;}
"fun"              {return _FUN;}
"if"               {return IF;}
"then"             {return THEN;}
"else"             {return ELSE;}
"match"            {return _MATCH;}
"with"             {return _WITH;}
"end"              {return _END;}

{NUM}              {return NUM;}
{ID_XML}           {return ID_XML;}
{ID}               {yylval.string_t = strdup(yytext); return ID;}

\"                 {BEGIN TXT; return DBL_QUOTES_OPEN;}
<TXT>{
	{TEXT}         {yylval.string_t = strdup(yytext); return TEXT;}
	\"             {BEGIN INITIAL; return DBL_QUOTES_CLOSE;}
}

"_"                {return '_';}
"|"                {return '|';}
"$"                {return '$';}
"."                {return '.';}
"->"               {return FLECHE;}
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
"<"                {return _LE;}
"<="               {return _LEQ;}
">"                {return _GE;}
">="               {return _GEQ;}
"=="               {return _EQ;}
"!="               {return _NEQ;}
"&&"               {return _AND;}
"||"               {return _OR;}
"!"                {return _NOT;}
{SPACE}            ;

({ID}{SPACE}(\/|\[|\{))|({ID}\[[\]]*\]{SPACE}\/) {yyerror("forme illicite"); return ERR;}

.                  {printf("[%c]", yytext[0]); return ERR;}//caractere non reconnu
