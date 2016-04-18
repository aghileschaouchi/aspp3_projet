%{
#include <stdlib.h>
#include <stdio.h>

extern int yylex(void);
extern void yyerror(const char* s);

%}
%define parse.error verbose

%token ERR ID ID_XML DBL_QUOTES_CLOSE DBL_QUOTES_OPEN
%token LET FUNC IN WHERE
%token NUM GEQ GE LEQ LE EQ OR AND NOT
%token BRACKET_OPN BRACKET_CLS
%left  PLUS MINUS MULT DIV
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

Doc_elem:		ID_VAR SpaceTabs ';'
                |       Declaration
		|	Expr
		;

Expr:			Foret
                |       Arithm
		;

Arithm:                 Arithm_exp
                ;

Arithm_exp:             NUM | Add | Sub | Mult | Div | Brackets
                ;

Brackets:               BRACKET_OPN Arithm_exp BRACKET_CLS
                ;

Add:                    Arithm_exp PLUS Arithm_exp
                ;

Sub:                    Arithm_exp MINUS Arithm_exp
                ;

Mult:                   Arithm_exp MULT Arithm_exp
                ;

Div:                    Arithm_exp DIV Arithm_exp
                ;

Declaration:            LET SpaceTabs ID_VAR SpaceTabs '=' SpaceTabs Expr SpaceTabs Decl_in ';'
		;

ID_VAR:			ID | ID_XML
		;

Decl_in:		IN SpaceTabs Expr SpaceTabs
		|	{}
		;

Foret:                  Foret_id Foret_accol
                |       Foret_id '/'
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

SpaceTabs:		SpaceTabs SPACETAB
		|	{}
		;
