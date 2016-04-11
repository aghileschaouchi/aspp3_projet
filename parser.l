%{
#include <stdlib.h>
#include <stdio.h>
#include "parser.tab.h"

void yyerror(const char*);
%}

%option noinput nounput

%x TXT

ID_XML ([[:alpha:]]|_[[:alnum:]_\'\.])[[:alnum:]_\'\.]*						
TEXT ([^\"]*(\\\")*)*

%%
[xX][mM][lL]{ID_XML}   yyerror("Les étiquettes ne doivent pas commencer par une séquence de la forme xml, XML, Xml");
{ID_XML}           {yylval.string_t = strdup(yytext); return ID_XML;}
\"                 {BEGIN TXT; return DBL_QUOTES_OPEN;}
<TXT>{TEXT}        {yylval.string_t = strdup(yytext); return TEXT;}
<TXT>\"            {BEGIN INITIAL; return DBL_QUOTES_CLOSE;}
"["                {return '[';}
"]"                {return ']';}
"{"                {return '{';}
"}"                {return '}';}
"="                {return '=';}
"/"                {return '/';}
[[:blank:]]+       {return BLANK;}
[[:space:]]+       {return SPACE;}
.                  {return yytext[0];}//caractere non reconnu
