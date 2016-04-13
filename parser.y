%{
#include <stdlib.h>
#include <stdio.h>

extern int yylex(void);
extern void yyerror(const char* s);

%}
%define parse.error verbose

%token ERR ID ID_XML DBL_QUOTES_CLOSE DBL_QUOTES_OPEN
%token LET FUNC IN WHERE
%token SPACETAB EOL
%token	<string_t>		TEXT
%union {
	char* string_t;
}
%start Document												
%%

Document:	   	Document Doc_elem Blanks
		|		Blanks {}
		;

Doc_elem:		ID_VAR SpaceTabs ';'
		|		Expr
		;

Expr:			Foret
		|		Declaration
		;

Declaration:	LET SpaceTabs ID_VAR SpaceTabs '=' SpaceTabs Foret SpaceTabs Decl_in ';'
		;

ID_VAR:			ID
		|		ID_XML
		;

Decl_in:		IN SpaceTabs Expr SpaceTabs
		|		{}
		;

Foret:			Foret_id Attributs Foret_accol
		|	    Foret_id Attributs '/'
		|		Foret_accol
		;

Foret_accol:	'{' F_contenu '}'
		|		'{' F_contenu ID Blanks '}'
		;

Foret_id:		ID | LET | IN | WHERE
		;

Attributs:		'[' A_contenu ']' Blanks
		|		{}
		;

A_contenu:		A_contenu Foret_id SpaceTabs '=' SpaceTabs Quoted_text Blanks
		|		Blanks {}
		;

F_contenu:		F_contenu Foret Blanks
		|		F_contenu Quoted_text Blanks
		|		F_contenu ID Blanks ',' Blanks
		|		Blanks {}
		;

Quoted_text:	DBL_QUOTES_OPEN TEXT DBL_QUOTES_CLOSE
		;

Blanks:			Blanks SPACETAB
		|		Blanks EOL
		|		{}
		;

SpaceTabs:		SpaceTabs SPACETAB
		|		{}
		;