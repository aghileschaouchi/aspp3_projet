%{
#include <stdlib.h>
#include <stdio.h>
#include "parser.h"

extern int yylex(void);
extern void yyerror(const char* s);

%}
%define parse.error verbose

%token ERR DBL_QUOTES_CLOSE DBL_QUOTES_OPEN
%left   <string_t>  ID ID_XML ID_SLASH ID_ACCOL ID_CROC

%left '{' '}'

%token REC
%right FLECHE LET _FUN
%right WHERE
%right IN
%right '='

%token _MATCH _WITH _END
%token UNDERSCORE UNDERSCORE_SPACE SLASH_ID_SLASH SLASH_UNDERSCORE_SLASH

%right IF THEN ELSE

%token NUM
%right _NOT
%left _OR _AND
%left _GEQ _GE _LEQ _LE _EQ _NEQ
%left '+' '-'
%left '*' '/'
%left _NEG
%left ')' '('

%right APP_FUNC

%token	<string_t>		TEXT

%type <string_t> Id_var Args Args_rec
%type <ast_t> Document Foret Arbre Expr Parentheses Add Sub Mult Div If_then Geq Ge Leq Le Eq Neq Or And Not
%type <int_t> NUM
%union {
	char* string_t;
        struct ast * ast_t;
        int int_t;
}
%start Document												
%%

Document:		Document Arbre {}
                |       Document Foret {}
                |       Document LET Id_var '=' Expr ';' {
                                                          $$=mk_var($3);
                                                          struct env * e = initial_env;
                                                          e = process_binding_instruction($3, $5, e);
                                                          struct closure * my_closure = mk_closure($5, e);
                                                          push_env($3, my_closure, &e);}
                |       Document LET Id_var Args '=' Expr ';' {/*fonction avec arguments*/
                                                          $$ = mk_fun($4, $6);
                                                          struct env * e = initial_env;
                                                          e = process_binding_instruction($3, $6, e);
                                                          struct closure * my_closure = mk_closure($6, e);
                                                          push_env($3, my_closure, &e);
                                                                }
                |       Document LET REC Id_var '=' Expr ';' {/*fonction recursive*/
                                                           $$ = mk_declrec($4, $6);
                                                           struct env * e = initial_env;
                                                           e = process_binding_instruction($4, $6, e);
                                                           struct closure * my_closure = mk_closure($6, e);
                                                           push_env($4, my_closure, &e);
                                                                }
                |       Document LET REC Id_var Args_rec '=' Expr ';' {/*fonction recursive avec arguments*/
                                                           $$ = mk_declrec($5, $7); 
                                                           struct env * e = initial_env;
                                                           e = process_binding_instruction($4, $7, e);
                                                           struct closure * my_closure = mk_closure($7, e);
                                                           push_env($4, my_closure, &e);
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

Expr:			Foret {$$ = $1;}
                |       Arbre {$$ = $1;}
                |       Quoted_text {/*$$ = $1;*/}
                |       NUM {$$ = mk_integer($1);printf("m_num : %d\n", $$-> node -> num);}
                |       Args /*var ou sequence de vars*/ {$$ = $1;}
                |       Parentheses {$$ = $1;}
                |       Add {$$ = $1;}
                |       Sub {$$ = $1;}
                |       Mult {$$ = $1;}
                |       Div {$$ = $1;}
                |       Geq {$$ = $1;}
                |       Ge {$$ = $1;}
                |       Leq {$$ = $1;}
                |       Le {$$ = $1;}
                |       Eq {$$ = $1;}
                |       Neq {$$ = $1;}
                |       Or {$$ = $1;}
                |       And {$$ = $1;}
                |       Not {$$ = $1;}
                |       If_then {$$ = $1;}
                |       LET Id_var '=' Expr IN Expr {$$ = mk_app(mk_fun($2, $6), $4);}
                |       LET REC Id_var '=' Expr IN Expr {$$ = mk_app(mk_fun($3, $7), mk_declrec($3, $5));}
                |       Expr WHERE Id_var '=' Expr {$$ = mk_app(mk_fun($3, $1), $5);}
                |       Expr WHERE REC Id_var '=' Expr {$$ = mk_app(mk_fun($4, $1), mk_declrec($4, $6));}
                |       _FUN Args FLECHE Expr {}
                |       '$' Import FLECHE Id_var
                |       '$' Points Import FLECHE Id_var
                |       Application %prec APP_FUNC
                |       Filtrage
		;

Filtrage:               _MATCH Expr _WITH Filt_body _END
                ;

Filt_body:              '|' Filt_arbre FLECHE Expr Filt_body
                |       '|' UNDERSCORE FLECHE Expr Filt_body
                |       {}
                ;

Filt_arbre:             ID_ACCOL Filt_contenu '}'
                |       UNDERSCORE '{' Filt_contenu '}'
                |       '{' Filt_contenu '}'
                |       UNDERSCORE_SPACE
                ;

Filt_contenu:           Id_var Filt_contenu
                |       Filt_arbre Filt_contenu
                |       '*' UNDERSCORE '*' Filt_contenu
                |       SLASH_UNDERSCORE_SLASH Filt_contenu
                |       '*' Id_var '*' Filt_contenu
                |       SLASH_ID_SLASH Filt_contenu
                |       UNDERSCORE
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

Args:                   Args Id_var {/*Je n'en suis pas sur*/ $$ = mk_fun($1, $2);}
                |       Id_var {$$ = $1;}
                ;

Args_rec:               Args_rec Id_var {/*Je n'en suis pas sur*/ $$ = mk_declrec($1, $2);}
                |       Id_var {$$ = $1;}
                ;

Parentheses:            '(' Expr ')' {$$ = $2;}
                ;

Add:                    Expr '+' Expr {$$ = mk_app(mk_app(mk_binop(PLUS), $1), $3);}
                ;

Sub:                    Expr '-' Expr {$$ = mk_app(mk_app(mk_binop(MINUS), $1), $3);}
                ;

Mult:                   Expr '*' Expr {$$ = mk_app(mk_app(mk_binop(MULT), $1), $3);}
                ;

Div:                    Expr '/' Expr {$$ = mk_app(mk_app(mk_binop(DIV), $1), $3);}
                ;

Geq:                    Expr _GEQ Expr {$$ = mk_app(mk_app(mk_binop(GEQ), $1), $3);}
                ;

Ge:                     Expr _GE Expr {$$ = mk_app(mk_app(mk_binop(GE), $1), $3);}
                ;

Leq:                    Expr _LEQ Expr {$$ = mk_app(mk_app(mk_binop(LEQ), $1), $3);} 
                ;

Le:                     Expr _LE Expr {$$ = mk_app(mk_app(mk_binop(LE), $1), $3);}
                ;

Eq:                     Expr _EQ Expr {$$ = mk_app(mk_app(mk_binop(EQ), $1), $3);}
                ;

Neq:                    Expr _NEQ Expr {$$ = mk_app(mk_app(mk_binop(NEQ), $1), $3);}
                ;

Or:                     Expr _OR Expr {$$ = mk_app(mk_app(mk_binop(OR), $1), $3);}
                ;

And:                    Expr _AND Expr {$$ = mk_app(mk_app(mk_binop(AND), $1), $3);}
                ;

Not:                    Expr _NOT Expr {$$ = mk_app(mk_app(mk_unaryop(NOT), $1), $3);}
                ;

If_then:                IF Expr THEN Expr ELSE Expr {$$ = mk_cond($2, $4, $6);}
                ;

/***
 * Foret & Arbre
 */

Arbre:                  ID_ACCOL '}'
                |       ID_ACCOL A_contenu
                |       ID_SLASH
                |	ID_CROC Attrs ']' Foret
		|       ID_CROC Attrs ']' '/'
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