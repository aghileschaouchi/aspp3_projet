%{
#include <stdlib.h>
#include <stdio.h>

extern int yylex(void);
extern void yyerror(const char* s);

%}
%define parse.error verbose

%token ERR DBL_QUOTES_CLOSE DBL_QUOTES_OPEN
%left   <string_t>  ID ID_XML

%token REC
%right FLECHE LET _FUN
%right WHERE
%right IN
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

Document:		Document Arbre
                |       Document Foret
                |       Document LET Id_var '=' Expr ';'
		|	Document Expr ';'
		|	{}
		;

/***
 * Variables & Expressions
 */

Id_var:			ID | ID_XML
		;

Expr:			Foret
                |       Arbre
                |       NUM
                |       Id_var
                |       Parentheses
                |       Add
                |       Sub
                |       Mult
                |       Div
                |       If_then
                |       LET Id_var '=' Expr IN Expr
                |       Expr WHERE Id_var '=' Expr
		;

Parentheses:            '(' Expr ')'
                ;

Add:                    Expr '+' Expr
                ;

Sub:                    Expr '-' Expr
                ;

Mult:                   Expr '*' Expr
                ;

Div:                    Expr '/' Expr
                ;

If_then:                IF Expr THEN Expr ELSE Expr
                ;

/***
 * Foret & Arbre
 */

Foret:                  '{' F_contenu '}'
		|	'{' F_contenu Id_var '}'
		;

F_contenu:		F_contenu Foret
                |       F_contenu Arbre
		|	F_contenu Id_var ','
		|	{}
		;

Arbre:                  ID Arbre_accol
                |       ID '/'
                |	ID '[' Attrs ']' Arbre_accol
		|       ID '[' Attrs ']' '/'
		;

Arbre_accol:            '{' A_contenu '}'
		|	'{' A_contenu Id_var '}'
		;

Attrs:          	Attrs ID '=' Quoted_text
		|	{}
		;

A_contenu:		A_contenu Foret
                |       A_contenu Arbre
		|	A_contenu Quoted_text
		|	A_contenu Id_var ','
		|	{}
		;

Quoted_text:            DBL_QUOTES_OPEN TEXT DBL_QUOTES_CLOSE
		;