%{
#include <stdlib.h>
#include <stdio.h>

extern int yylex(void);
extern void yyerror(const char* s);

%}
%define parse.error verbose

%token ERR DBL_QUOTES_CLOSE DBL_QUOTES_OPEN
%left   <string_t>  ID ID_XML
%left '{'

%token REC
%right FLECHE LET _FUN
%right WHERE
%left IN
%right '='

%left _GEQ _GE _LEQ _LE _EQ _OR _AND _NOT
%left NUM
%left '+' '-'
%left '*' '/'
%right '('
%left ')'

%right IF THEN ELSE

%token	<string_t>		TEXT
%union {
	char* string_t;
}
%start Document												
%%

Document:	   	Document Doc_elem
		|	{}
		;

Doc_elem:               Arithm_exp ';'
                |       Decl_global ';'
                |       Foret
		;

Expr:			Foret
                |       Arithm_exp
                |       Decl_in
                |       Decl_where
                |       If_then
		;

Id_var:			ID | ID_XML
		;

Decl_global:            LET Affect
		;

Decl_in:                Decl_global IN Expr
                ;

Decl_where:             Expr WHERE Affect
                ;

Affect:                 Id_var Args '=' Expr
                |       REC Id_var Args '=' Func
                |       Id_var Args '=' Func
                ;

Func:                   _FUN Args FLECHE Expr
                ;

Args:                   Args Id_var
                |       {}
                ;

If_then:                IF Expr THEN Expr ELSE Expr
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

Foret:                  ID Foret_accol
                |       ID '/'
                |	ID Attrs Foret_accol
		|       ID Attrs '/'
		|	Foret_accol
		;

Attrs:  		'[' A_contenu ']'
		;

Foret_accol:            '{' F_contenu '}'
		|	'{' F_contenu ID '}'
		;

A_contenu:		A_contenu ID '=' Quoted_text
		|	{}
		;

F_contenu:		F_contenu Foret
		|	F_contenu Quoted_text
		|	F_contenu ID ','
		|	{}
		;

Quoted_text:            DBL_QUOTES_OPEN TEXT DBL_QUOTES_CLOSE
		;