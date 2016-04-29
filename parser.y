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

%type   <string_t>  Id_var
%type   <ast_t> Document Foret Arbre Quoted_text
%type   <ast_t> Expr Parentheses Add Sub Mult Div Geq Ge Leq Le Eq Neq Or And Not
%type   <ast_t> If_then Import Application Filtrage Func_args Decl Args
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
                |       Document LET Decl ';' {}  
		|	Document Expr ';' {}
		|	{}
		;

/***
 * Variables & Expressions
 */

Id_var:			ID                          {$$ = $1;}
                |       ID_XML                      {$$ = $1;}
		;

Expr:			Foret                       {$$ = $1;}
                |       Arbre                       {$$ = $1;}
                |       Quoted_text                 {$$ = $1;}
                |       NUM                         {$$ = mk_integer($1);}
                |       Id_var                      {$$ = mk_var($1);}
                |       Parentheses                 {$$ = $1;}
                |       Add                         {$$ = $1;}
                |       Sub                         {$$ = $1;}
                |       Mult                        {$$ = $1;}
                |       Div                         {$$ = $1;}
                |       Geq                         {$$ = $1;}
                |       Ge                          {$$ = $1;}
                |       Leq                         {$$ = $1;}
                |       Le                          {$$ = $1;}
                |       Eq                          {$$ = $1;}
                |       Neq                         {$$ = $1;}
                |       Or                          {$$ = $1;}
                |       And                         {$$ = $1;}
                |       Not                         {$$ = $1;}
                |       If_then                     {$$ = $1;}
                |       LET Decl IN Expr            {   struct ast * f = $2->node->app->fun;
                                                        f->node->fun->body = $4;
                                                        $$ = $2;
                                                    }
                |       Expr WHERE Decl             {   struct ast * f = $3->node->app->fun;
                                                        f->node->fun->body = $1;
                                                        $$ = $3;
                                                    }
                |       _FUN Args FLECHE Expr       {   struct ast * f = $2;
                                                        while (f->node->fun->body != NULL)
                                                            f = f->node->fun->body;
                                                        f->node->fun->body = $4;
                                                        $$ = $2;
                                                    }
                |       Import
                |       Application %prec APP_FUNC  {$$ = $1;}
                |       Filtrage
		;

Decl:                   Id_var '=' Expr             {   $$ = mk_app(mk_fun($1, NULL), $3); }
                |       Id_var Args '=' Expr        {   struct ast * f = $2;
                                                        while (f->node->fun->body != NULL)
                                                            f = f->node->fun->body;
                                                        f->node->fun->body = $4;
                                                        $$ = mk_app(mk_fun($1, NULL), $2);
                                                    }
                |       REC Id_var '=' Expr         {   $$ = mk_app(mk_fun($2, NULL), mk_declrec($2, $4)); }
                |       REC Id_var Args '=' Expr    {   struct ast * f = $3;
                                                        f->type = DECLREC;
                                                        while (f->node->fun->body != NULL){
                                                            f = f->node->fun->body;
                                                            f->type = DECLREC;
                                                        }
                                                        f->node->fun->body = $5;
                                                        $$ = mk_app(mk_fun($2, NULL), $3);
                                                    }
                ;


Args:                   Id_var Args                 {$$ = mk_fun($1, $2);}
                |       Id_var                      {$$ = mk_fun($1, NULL);}
                ;

Filtrage:               _MATCH Expr _WITH Filt_body _END                    {}
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

Application:            Id_var Func_args                            {   struct ast * a = $2;
                                                                        while(a->node->app->fun != NULL)
                                                                            a = a->node->app->fun;
                                                                        a->node->app->fun = mk_var($1);
                                                                        $$ = $2;
                                                                    }
                |       Parentheses Func_args                       {   struct ast * a = $2;
                                                                        while(a->node->app->fun != NULL)
                                                                            a = a->node->app->fun;
                                                                        a->node->app->fun = $1;
                                                                        $$ = $2;
                                                                    }
                ;       

Func_args:              Func_args Id_var                            {$$ = mk_app($1, mk_var($2));}
                |       Func_args Foret                             {$$ = mk_app($1, $2);}
                |       Func_args Arbre                             {$$ = mk_app($1, $2);}
                |       Func_args Quoted_text                       {$$ = mk_app($1, $2);}
                |       Func_args NUM                               {$$ = mk_app($1, mk_integer($2));}
                |       Func_args Parentheses                       {$$ = mk_app($1, $2);}
                |       Foret                                       {$$ = mk_app(NULL, $1);}
                |       Arbre                                       {$$ = mk_app(NULL, $1);}
                |       Quoted_text                                 {$$ = mk_app(NULL, $1);}
                |       NUM                                         {$$ = mk_app(NULL, mk_integer($1));}
                |       Id_var                                      {$$ = mk_app(NULL, mk_var($1));}
                |       Parentheses                                 {$$ = mk_app(NULL, $1);}
                ;

Import:                 '$' Import_path FLECHE Id_var                   {}
                |       '$' Points Import_path FLECHE Id_var            {}
                ;

Import_path:            Import_path '/' Id_var                          {}
                |       Id_var                                          {}
                ;

Points:                 '.' Points                                      {}
                |       '/'                                             {}
                ;

Parentheses:            '(' Expr ')'                                    {$$ = $2;}
                ;

Add:                    Expr '+' Expr                                   {$$ = mk_app(mk_app(mk_binop(PLUS), $1), $3);}
                ;

Sub:                    Expr '-' Expr                                   {$$ = mk_app(mk_app(mk_binop(MINUS), $1), $3);}
                ;

Mult:                   Expr '*' Expr                                   {$$ = mk_app(mk_app(mk_binop(MULT), $1), $3);}
                ;

Div:                    Expr '/' Expr                                   {$$ = mk_app(mk_app(mk_binop(DIV), $1), $3);}
                ;

Geq:                    Expr _GEQ Expr                                  {$$ = mk_app(mk_app(mk_binop(GEQ), $1), $3);}
                ;

Ge:                     Expr _GE Expr                                   {$$ = mk_app(mk_app(mk_binop(GE), $1), $3);}
                ;

Leq:                    Expr _LEQ Expr                                  {$$ = mk_app(mk_app(mk_binop(LEQ), $1), $3);} 
                ;

Le:                     Expr _LE Expr                                   {$$ = mk_app(mk_app(mk_binop(LE), $1), $3);}
                ;

Eq:                     Expr _EQ Expr                                   {$$ = mk_app(mk_app(mk_binop(EQ), $1), $3);}
                ;

Neq:                    Expr _NEQ Expr                                  {$$ = mk_app(mk_app(mk_binop(NEQ), $1), $3);}
                ;

Or:                     Expr _OR Expr                                   {$$ = mk_app(mk_app(mk_binop(OR), $1), $3);}
                ;

And:                    Expr _AND Expr                                  {$$ = mk_app(mk_app(mk_binop(AND), $1), $3);}
                ;

Not:                    _NOT Expr                                       {$$ = mk_app(mk_unaryop(NOT), $2);}
                ;

If_then:                IF Expr THEN Expr ELSE Expr                     {$$ = mk_cond($2, $4, $6);}
                ;

/***
 * Foret & Arbre
 */

Arbre:                  ID_ACCOL '}'                            {}
                |       ID_ACCOL A_contenu                      {}
                |       ID_SLASH                                {}
                |	ID_CROC Attrs ']' Foret                 {}
		|       ID_CROC Attrs ']' '/'                   {}
		;

Foret:                  '{' '}'                                 {}
                |       '{' A_contenu                           {}
		;

A_contenu:		Foret A_contenu                         {}
                |       Arbre A_contenu                         {}
		|	Quoted_text A_contenu                   {}
		|	Expr ',' A_contenu                      {}
		|	Expr '}'                                {}
		;

Attrs:          	Attrs ID '=' Quoted_text                {}
		|	{}
		;

Quoted_text:            DBL_QUOTES_OPEN TEXT DBL_QUOTES_CLOSE   {$$ = mk_word($2);}
		;