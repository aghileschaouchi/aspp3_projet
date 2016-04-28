%{
#include <stdlib.h>
#include <stdio.h>
#include "parser.h"
#include "import.h"
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
%left <int_t> NUM
%left '+' '-'
%left '*' '/'
%right '('
%left ')'

%right IF THEN ELSE

%token	<string_t>		TEXT

%type <string_t> Id_var
%type <ast_t> Document Foret Arbre Expr Parentheses Add Sub Mult Div If_then F_contenu

%union {
	char* string_t;
        struct ast * ast_t;
        int int_t;
}
%start Document												
%%

Document:		Document Arbre {}
                |       Document Foret {}
                |       Document LET Id_var '=' Expr ';' {$$=mk_var($3);
                                                          struct env * e = initial_env;
                                                          e = process_binding_instruction($3, $5, e);
                                                          struct closure * my_closure = mk_closure($5, e);
                                                          push_env($3, my_closure, &e);    
                                                                }
		|	Document Expr ';' {}
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
                |       Id_var                                      {$$ = $1;}
                |       Parentheses                                 {$$ = $1;}
                |       Add                                         {$$ = $1;}
                |       Sub                                         {$$ = $1;}
                |       Mult                                        {$$ = $1;}
                |       Div                                         {$$ = $1;}
                |       If_then                                     {$$ = $1;}
                |       LET Id_var '=' Expr IN Expr                 {/*$$ = mk_app(mk_fun($2, $4), $6);*/
                                                                       $$ = mk_app(mk_fun($2, $6), $4); }
                |       Expr WHERE Id_var '=' Expr                  {/*$$ = mk_app(mk_fun($3, $5), $1);*/
                                                                       $$ = mk_app(mk_fun($3, $1), $5); }
		;

Parentheses:            '(' Expr ')'  {$$ = $2;}
                ;

Add:                    Expr '+' Expr { /*$$ = mk_app(mk_app($1, $3), mk_binop(PLUS));*/
                                        $$ = mk_app(mk_app(mk_binop(PLUS), $1), $3);
                                        }
                ;

Sub:                    Expr '-' Expr { /*$$ = mk_app(mk_app($1, $3), mk_binop(MINUS));*/
                                        $$ = mk_app(mk_app(mk_binop(MINUS), $1), $3);
                                        }
                ;

Mult:                   Expr '*' Expr { /*$$ = mk_app(mk_app($1, $3), mk_binop(MULT));*/
                                        $$ = mk_app(mk_app(mk_binop(MULT), $1), $3);
                                        }
                ;

Div:                    Expr '/' Expr { /*$$ = mk_app(mk_app($1, $3), mk_binop(DIV));*/
                                        $$ = mk_app(mk_app(mk_binop(DIV), $1), $3);
                                        }
                ;

If_then:                IF Expr THEN Expr ELSE Expr {$$ = mk_cond($2, $4, $6);}
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
