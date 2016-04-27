%{
#include <stdlib.h>
#include <stdio.h>

extern int yylex(void);
extern void yyerror(const char* s);

struct ast * current_var = NULL;
struct ast * current_binop = NULL;
struct ast * current_unaryop = NULL;
struct ast * current_integer = NULL;
struct ast * current_decl = NULL;
struct ast * current_expr= NULL;

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
%left <int_t> NUM
%left '+' '-'
%left '*' '/'
%right '('
%left ')'

%right IF THEN ELSE

%token	<string_t>		TEXT

%type <string_t> Id_var
%type <ast_t> Document Foret Arbre Expr Parentheses Add Sub Mult Div If_then

%union {
	char* string_t;
        struct ast * ast_t;
        int int_t;
}
%start Document												
%%

Document:		Document Arbre {$$ = $2;}
                |       Document Foret {$$ = $2;}
                |       Document LET Id_var '=' Expr ';' {/*current_var = mk_var($2);*/}
		|	Document Expr ';' {/*current_var = mk_var($2); current_decl = mk_declrec($2, current_expr);*/}
		|	{}
		;

/***
 * Variables & Expressions
 */

Id_var:			ID {$$ = $1;}
                |       ID_XML {$$ = $1;}
		;

Expr:			Foret                                       {$$ = $1;}
                |       Arbre                                       {$$ = $1;}
                |       NUM                                         {$$ = mk_integer($1);printf("m_num : %d\n", $$-> node -> num);}
                |       Id_var                                      {/*$$ = (struct ast*)$1;*/}
                |       Parentheses                                 {$$ = $1;}
                |       Add                                         {$$ = $1;}
                |       Sub                                         {$$ = $1;}
                |       Mult                                        {$$ = $1;}
                |       Div                                         {$$ = $1;}
                |       If_then
                |       LET Id_var '=' Expr IN Expr                 {$$ = mk_app(mk_fun($2, $4), $6);}
                |       Expr WHERE Id_var '=' Expr                  {$$ = mk_app(mk_fun($3, $5), $1);}
		;

Parentheses:            '(' Expr ')'  {$$ = $2;}
                ;

Add:                    Expr '+' Expr { $$ = mk_app(mk_app($1, $3), mk_binop(PLUS));}
                ;

Sub:                    Expr '-' Expr { $$ = mk_app(mk_app($1, $3), mk_binop(MINUS));}
                ;

Mult:                   Expr '*' Expr { $$ = mk_app(mk_app($1, $3), mk_binop(MULT));}
                ;

Div:                    Expr '/' Expr { $$ = mk_app(mk_app($1, $3), mk_binop(DIV));}
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