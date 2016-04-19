%{
#include <stdlib.h>
#include <stdio.h>

extern int yylex(void);
extern void yyerror(const char* s);

%}
%define parse.error verbose

%token ERR ID_XML DBL_QUOTES_CLOSE DBL_QUOTES_OPEN
%left ID

%token LET FUNC WHERE
%right '='
%left IN

%token NUM GEQ GE LEQ LE EQ OR AND NOT
%left '+' '-'
%left '*' '/'

%token SPACETAB EOL
%token	<string_t>		TEXT
%union {
	char* string_t;
}
%start Document												
%%

Document:	   	Document Doc_elem Blanks
		|	Blanks {}
		;

Doc_elem:               Arithm ';'
                |       Declaration ';'
                |       Foret
		;

Expr:			Foret
                |       Arithm
                |       Declaration
		;

Arithm:                 Arithm_exp
                ;

Arithm_exp:             Id_var | NUM | Add | Sub | Mult | Div | Brackets
                ;

Brackets:               '(' Arithm_exp ')'
                ;

Add:                    Arithm_exp '+' Arithm_exp
                ;

Sub:                    Arithm_exp '-' Arithm_exp
                ;

Mult:                   Arithm_exp '*' Arithm_exp
                ;

Div:                    Arithm_exp '/' Arithm_exp
                ;

Id_var:			ID | ID_XML
		;

Declaration:            LET Id_var '=' Expr
                |       LET Id_var '=' Expr IN Expr
		;

Foret:                  Foret_id Foret_accol
                |       ID '/' | LET '/' | WHERE '/' | IN '/'
                |	Foret_id Attributs Blanks Foret_accol
		|       Foret_id Attributs '/'
		|	Foret_accol
		;

Attributs:		'[' A_contenu ']'
		;

Foret_accol:            '{' F_contenu '}'
		|	'{' F_contenu ID Blanks '}'
		;

Foret_id:		ID | LET | IN | WHERE
		;

A_contenu:		A_contenu Foret_id SpaceTabs '=' SpaceTabs Quoted_text Blanks
		|	Blanks {}
		;

F_contenu:		F_contenu Foret Blanks
		|	F_contenu Quoted_text Blanks
		|	F_contenu ID Blanks ',' Blanks
		|	Blanks {}
		;

Quoted_text:            DBL_QUOTES_OPEN TEXT DBL_QUOTES_CLOSE
		;

Blanks:			Blanks SPACETAB
		|	Blanks EOL
		|	{}
		;

SpaceTabs:		SPACETAB | {}
		;
