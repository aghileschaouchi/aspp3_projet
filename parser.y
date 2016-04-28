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

%token NUM
%left _NOT
%left _OR _AND
%left _GEQ _GE _LEQ _LE _EQ _NEQ
%left '+' '-'
%left '*' '/'
%left _NEG
%left ')' '('

%right IF THEN ELSE

%left '{' '}'

%token	<string_t>		TEXT
%union {
	char* string_t;
}
%start Document												
%%

Document:		Document Arbre
                |       Document Foret
                |       Document Let_rec Decl ';'
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
                |       Quoted_text
                |       NUM
                |       Args /*var ou sequence de vars*/
                |       Parentheses
                |       Add
                |       Sub
                |       Mult
                |       Div
                |       Geq
                |       Ge
                |       Leq
                |       Le
                |       Eq
                |       Neq
                |       Or
                |       And
                |       Not
                |       If_then
                |       Let_rec Decl IN Expr
                |       Expr WHERE Decl
                |       _FUN Args FLECHE Expr
		;

Let_rec:                LET | LET REC
                ;

Decl:                   Id_var '=' Expr
                |       Id_var Args '=' Expr
                ;

Args:                   Args Id_var
                |       Id_var
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

Geq:                    Expr _GEQ Expr
                ;

Ge:                     Expr _GE Expr
                ;

Leq:                    Expr _LEQ Expr
                ;

Le:                     Expr _LE Expr
                ;

Eq:                     Expr _EQ Expr
                ;

Neq:                    Expr _NEQ Expr
                ;

Or:                     Expr _OR Expr
                ;

And:                    Expr _AND Expr
                ;

Not:                    Expr _NOT Expr
                ;

If_then:                IF Expr THEN Expr ELSE Expr
                ;

/***
 * Foret & Arbre
 */

Arbre:                  ID Foret
                |       ID '/'
                |	ID '[' Attrs ']' Foret
		|       ID '[' Attrs ']' '/'
		;

Foret:                  '{' '}'
                |       '{' A_contenu
		;

A_contenu:		Foret A_contenu
                |       Arbre A_contenu 
		|	Quoted_text A_contenu 
		|	Expr ',' A_contenu 
		|	Expr '}'
		;

Attrs:          	Attrs ID '=' Quoted_text
		|	{}
		;

Quoted_text:            DBL_QUOTES_OPEN TEXT DBL_QUOTES_CLOSE
		;