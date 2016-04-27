%{
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

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
%type <ast_t> Arbre Foret F_contenu Arbre_accol A_contenu  Quoted_text 
%type <attributes_t> Attrs
%union {
	struct attributes* attributes_t;
	struct ast* ast_t;
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

Foret:                  '{' F_contenu '}' {$$ = $2;afficher_foret($2);}
		|	'{' F_contenu Id_var '}' {$$ = $2;}
		;

F_contenu:		F_contenu Foret {printf("-----> creation de la foret -Foret <------ \n");
                                         $$ = mk_forest(false,NULL,$2);
                                        }
                |       F_contenu Arbre {printf("-----> creation de la foret -Arbe- <------ \n");
                                         $$ = mk_forest(false,$2,NULL);
                                         }
		|	F_contenu Id_var ','
		|	{}
		;

Arbre:                  ID Arbre_accol {printf("-----> id Arbre arbre_accol \n");
                                        $$ = mk_tree($1, false, false, false, NULL, $2);
                                       }
                |       ID '/' {printf("-----> Arbre Foret Attributes arbre accol\n");
                                $$ = mk_tree($1, false, false, false, NULL,NULL);
			}
		|	ID '[' Attrs ']' Arbre_accol {printf("-----> arbreForet Attributes arbre accol\n");
                                                      $$ = mk_tree($1, false, false, false, $3,$5);
			                              }
		|       ID '[' Attrs ']' '/' {printf("-----> arbre Attributes \n");
                                              $$ = mk_tree($1, false, true, false, $3, NULL);
			                      }
		;

Arbre_accol:            '{' A_contenu '}' {printf("----->Arbe_accol A contenu\n");
                                                  $$ = $2;
                                          }
		|	'{' A_contenu Id_var '}' {printf("-----> Arbre_accol A Contenu ID \n");
                                                  $$ = $2;
			                          }
		;

Attrs:          	Attrs ID '=' Quoted_text {printf("-----> Creation de l'attribut \n");
                                                 $$ = make_attribute($2,$4);}
		|	{}
		;

A_contenu:		A_contenu Foret {printf("-----> A contenu Foret\n");
                                         $$ = $2;
                                         }
                |       A_contenu Arbre {printf("-----> A contenu Arbre\n");
                                         $$ = $2;
                                         }
		|	A_contenu Quoted_text {printf("-----> A contenu TEXT\n");
                                               $$ = $2;
                                               }
		|	A_contenu Id_var ','
		|	{}
		;

Quoted_text:            DBL_QUOTES_OPEN TEXT DBL_QUOTES_CLOSE {printf("-----> Creation de TEXT\n");
                                                               $$ = mk_word($2);
                                                               }
		;
