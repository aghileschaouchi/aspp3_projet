%{
#include <stdlib.h>
#include <stdio.h>
#include "parser.tab.h"

void yyerror(const char*);
int is_xml(const char* yytext, int yyleng);
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
\/(_|{ID})\/       {yylval.string_t = malloc(sizeof(char)*yyleng-1);
                    strncpy(yylval.string_t, yytext+1, yyleng-1);
                    yylval.string_t[yyleng-2] = '\0';
                    if (yyleng == 3 && yytext[1] == '_')
                        return SLASH_UNDERSCORE_SLASH;
                    else
                        return SLASH_ID_SLASH;
                   }

{NUM}              {return NUM;}
{ID_XML}           {return ID_XML;}
{ID}               {yylval.string_t = strdup(yytext); return ID;}
{ID}(\{|\/|\[)     {if (is_xml(yytext, yyleng))
                        return ERR; //XML{}
                    yylval.string_t = malloc(sizeof(char)*yyleng);
                    strncpy(yylval.string_t, yytext, yyleng-1);
                    yylval.string_t[yyleng-1] = '\0';
                    if (yytext[yyleng-1] == '{')
                        return ID_ACCOL;
                    else if (yytext[yyleng-1] == '/')
                        return ID_SLASH;
                    else if (yytext[yyleng-1] == '[')
                        return ID_CROC;
                   }

\"                 {BEGIN TXT; return DBL_QUOTES_OPEN;}
<TXT>{
	{TEXT}         {yylval.string_t = strdup(yytext); return TEXT;}
	\"             {BEGIN INITIAL; return DBL_QUOTES_CLOSE;}
}

"_"                {return UNDERSCORE;}
"_"{SPACE}         {return UNDERSCORE_SPACE;}
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

{ID}\[[^\]]*\]{SPACE}\/ {yyerror(yytext); return ERR;}

.                  {printf("[%c]", yytext[0]); return ERR;}//caractere non reconnu

%%

int is_xml(const char* text, int leng) {
    return leng >= 3 &&
            (text[0] == 'x' || text[0] == 'X') &&
            (text[1] == 'm' || text[1] == 'M') &&
            (text[2] == 'l' || text[2] == 'L');
        
}
