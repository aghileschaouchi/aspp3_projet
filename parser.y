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

%right SPACETAB EOL
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
                |       LET Affect_func
		;

Decl_in:                Decl_global SPACETAB IN Blanks Expr
                ;

Decl_where:             Expr SPACETAB WHERE Blanks Affect
                ;

Affect:                 SPACETAB Id_var '=' Expr
                ;

Affect_func:            SPACETAB Rec_maybe Id_var Suite_args SPACETAB '=' SPACETAB FUN SPACETAB Suite_args SPACETAB FLECHE Expr
                ;

Suite_args:             Suite_args_req
                |       {}
                ;

Suite_args_req:         Suite_args SPACETAB Id_var
                |       SPACETAB Id_var
                ;

Rec_maybe:              REC SPACETAB
                |       {}
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

A_contenu:		A_contenu Foret_id '=' Quoted_text Blanks
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
