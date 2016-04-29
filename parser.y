%{
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include "machine.h"

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
%type <ast_t> Document Arbre Arbre_accol A_contenu  Quoted_text 
%type <attributes_t> Attrs
%union {
	struct attributes* attributes_t;
	struct ast* ast_t;
	char* string_t;
}
%start Document												
%%

Document:		Document Arbre {$$ = $2;emit("test.txt", $2); printf("----------------−>Document Arbre<------------------\n");}
		|	{}
		;

/***
 * Foret & Arbre
 */



Arbre:                  ID Arbre_accol {printf("-----> ID Arbre Arbre_accol \n");
   
                                        $$ = mk_tree($1, false, false, false, NULL, $2);
                                        }     
                |       ID '/' {printf("-----> Arbre ID / \n");
                                $$ =  mk_tree($1, false, true, false, NULL,NULL);
			}
		|	ID '[' Attrs ']' Arbre_accol {printf("-----> Arbre Attributes Arbre_accol\n");
                                                      $$ =  mk_tree($1, false, false , false, $3,$5);
			                              }
		|       ID '[' Attrs ']' '/' {printf("-----> Arbre Attributes \n");
                                              $$ =  mk_tree($1, false, false, false,$3, NULL);
			                      }
                |       Arbre_accol {printf("-----> Arbre Arbre_accol \n");
                                     $$ =  $1;
			            }
		;

Arbre_accol:            '{' A_contenu '}' {printf("-----> Arbe_accol A contenu\n");
                                                  $$ = $2;
                                          }

		;

Attrs:          	Attrs ID '=' Quoted_text {printf("-----> Creation de l'attribut \n");
                                                  if($$ == NULL) {
                                                    $$ = make_attribute(mk_word($2),$4);
                                                  }else{
						    struct attributes *tmp = $$;
						    while(tmp->next != NULL)
						      tmp = tmp->next;
						    tmp->next = make_attribute(mk_word($2),$4);
						    
						       }
                                                  }
                |	{$$ = NULL;}
		;

A_contenu:	        A_contenu Arbre { printf("-----> A contenu Arbre\n");
                                          if($$ == NULL){
                                            $$ = mk_forest(false,$2,NULL);
                                          }else{
					    struct ast* tmp= $$;
					    while(tmp->node->forest->tail != NULL)
					       tmp =tmp->node->forest->tail ;
					    tmp->node->forest->tail = mk_forest(false,$2,NULL);
                                                }   
                                        }

		|	A_contenu Quoted_text {printf("-----> A contenu TEXT\n");
                                                if($$ == NULL){
                                                  $$ = mk_forest(false,$2,NULL);
                                                }else{
						  struct ast* tmp= $$;
						  while(tmp->node->forest->tail != NULL)
						    tmp =tmp->node->forest->tail ;
						  tmp->node->forest->tail = mk_forest(false,$2,NULL);
                                                }
                                               }
		|	A_contenu ',' Quoted_text {  printf("-----> A contenu , TEXT\n");
                                                     if($$ == NULL){
                                                       $$ = mk_forest(false,$3,NULL);
                                                     }else{
						       struct ast* tmp= $$;
						       while(tmp->node->forest->tail != NULL)
						         tmp =tmp->node->forest->tail ;
						       tmp->node->forest->tail = mk_forest(false,$3,NULL);
                                                     }
                                                   }

		|	{ $$ = NULL;}
		;

Quoted_text:            DBL_QUOTES_OPEN TEXT DBL_QUOTES_CLOSE {printf("-----> Creation de TEXT\n");
                                                               $$ = mk_word($2);
                                                               }
		;
