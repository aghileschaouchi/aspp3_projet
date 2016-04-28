%{
#include <stdlib.h>
#include <stdio.h>

extern int yylex(void);
extern void yyerror(const char* s);

%}
%define parse.error verbose

%token ERR DBL_QUOTES_CLOSE DBL_QUOTES_OPEN
%left   <string_t>  ID ID_XML

%left '{' '}'

%token REC
%right FLECHE LET _FUN
%right WHERE
%right IN
%right '='

%token _MATCH _WITH _END

%right IF THEN ELSE

%token NUM
%left _NOT
%left _OR _AND
%left _GEQ _GE _LEQ _LE _EQ _NEQ
%left '+' '-'
%left '*' '/'
%left _NEG
%left ')' '('

%token	<string_t>		TEXT
%union {
	char* string_t;
}
%start Document												
%%

Document:		Document Arbre
                |       Document Foret
                |       Document LET Decl ';'
                |       Document LET REC Decl ';'
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
                |       Id_var
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
                |       LET Decl IN Expr
                |       LET REC Decl IN Expr
                |       Expr WHERE Decl
                |       Expr WHERE REC Decl
                |       _FUN Args FLECHE Expr
                |       '$' Import FLECHE Id_var
                |       '$' Points Import FLECHE Id_var
                |       Application
                |       Filtrage
		;

Filtrage:               _MATCH Id_var _WITH Filt_body _END
                ;

Filt_body:              Filt_body '|' Filt_arbre FLECHE Expr
                |       {}
                ;

Filt_arbre:             ID '{' Filt_contenu '}'
                |       '_' '{' Filt_contenu '}'
                |       '{' Filt_contenu '}'
                ;

Filt_contenu:           Filt_contenu Filt_arbre
                |       Filt_contenu ID
                |       Filt_contenu '_'
                |       {}
                ;

Application:            Id_var Func_args
                |       Parentheses Func_args
                ;       

Func_args:              Func_args Foret
                |       Func_args Arbre
                |       Func_args Quoted_text
                |       Func_args NUM
                |       Func_args Id_var
                |       Func_args Parentheses
                |       Foret
                |       Arbre
                |       Quoted_text
                |       NUM
                |       Id_var
                |       Parentheses
                ;

Import:                 Import '/' Id_var
                |       Id_var
                ;

Points:                 '.' Points
                |       '/'
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