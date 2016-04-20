%{
#include <stdlib.h>
#include <stdio.h>

extern int yylex(void);
extern void yyerror(const char* s);

%}
%define parse.error verbose

%token ERR ID_XML DBL_QUOTES_CLOSE DBL_QUOTES_OPEN
%left ID

%token LET FUN REC FLECHE
%right '='
%right WHERE
%left IN

%token NUM GEQ GE LEQ LE EQ OR AND NOT
%left '+' '-'
%left '*' '/'

%token	<string_t>		TEXT
%union {
	char* string_t;
}
%start Document												
%%

Document:	   	Document Doc_elem
		|	{}
		;

Doc_elem:               Arithm ';'
                |       Decl_global ';'
                |       Foret
		;

Expr:			Foret
                |       Arithm
                |       Decl_in
                |       Decl_where
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

Decl_global:            LET Affect
		;

Decl_in:                Decl_global IN Expr
                ;

Decl_where:             Expr WHERE Affect
                ;

Affect:                 Id_var '=' Expr
                ;

Foret:                  Foret_id Foret_accol
                |       ID '/' | LET '/' | WHERE '/' | IN '/'
                |	Foret_id Attrs Foret_accol
		|       Foret_id Attrs '/'
		|	Foret_accol
		;

Attrs:  		'[' A_contenu ']'
		;

Foret_accol:            '{' F_contenu '}'
		|	'{' F_contenu ID '}'
		;

Foret_id:		ID | LET | IN | WHERE
		;

A_contenu:		A_contenu Foret_id '=' Quoted_text
		|	{}
		;

F_contenu:		F_contenu Foret
		|	F_contenu Quoted_text
		|	F_contenu ID ','
		|	{}
		;

Quoted_text:            DBL_QUOTES_OPEN TEXT DBL_QUOTES_CLOSE
		;