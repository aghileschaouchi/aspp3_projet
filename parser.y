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
%type <ast_t> Document Expr Arbre Arbre_accol A_contenu  Quoted_text 
%type <attributes_t> Attrs
%union {
	struct attributes* attributes_t;
	struct ast* ast_t;
	char* string_t;
}
%start Document												
%%

Document:		Document Arbre {$$ = $2; printf("----------------−>Document Arbre<------------------\n");}
		|	{}
		;

/***
 * Foret & Arbre
 */



Arbre:                  ID Arbre_accol {printf("-----> ID Arbre Arbre_accol \n");
                                        $$ = mk_forest(false,mk_tree($1, false, false, false, NULL, $2),NULL);
                                       }      
                |       ID '/' {printf("-----> Arbre ID / \n");
                                $$ =  mk_forest(false,mk_tree($1, false, false, false, NULL,NULL),NULL);
			}
		|	ID '[' Attrs ']' Arbre_accol {printf("-----> Arbre Attributes Arbre_accol\n");
                                                      $$ =  mk_forest(false,mk_tree($1, false, false, false, $3,$5),NULL);
			                              }
		|       ID '[' Attrs ']' '/' {printf("-----> Arbre Attributes \n");
                                              $$ =  mk_forest(false,mk_tree($1, false, true, false, $3, NULL),NULL);
			                      }
                |       Arbre_accol {printf("-----> Arbre Arbre_accol \n");
                                     $$ =  mk_forest(false,$1,NULL);
			            }
		;

Arbre_accol:            '{' A_contenu '}' {printf("-----> Arbe_accol A contenu\n");
                                                  $$ = $2;
                                          }

		;

Attrs:          	Attrs ID '=' Quoted_text {printf("-----> Creation de l'attribut \n");
                                                 $$ = make_attribute($2,$4);}
		|	{}
		;

A_contenu:	        A_contenu Arbre {printf("-----> A contenu Arbre\n");
                                         $$ = mk_forest(false,NULL,$2);
                                         }
		|	A_contenu Quoted_text {printf("-----> A contenu TEXT\n");
                                               $$ = $2;
                                               }
		|	A_contenu ',' Quoted_text {printf("-----> A contenu , TEXT\n");
                                               $$ = $3;
                                               }

		|	{}
		;

Quoted_text:            DBL_QUOTES_OPEN TEXT DBL_QUOTES_CLOSE {printf("-----> Creation de TEXT\n");
                                                               $$ = mk_word($2);
                                                               }
		;
