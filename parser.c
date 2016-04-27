#include "parser.h"

void yyerror(const char *s) {
    fprintf(yyout, "Line %d : %s\n", yylineno, s);
}


//gestion des attributs
struct attributes * make_attribute(struct ast * key, struct ast * value){
    struct attributes * a = malloc(sizeof(struct attributes));
    a -> key = key;
    a -> value = value;
    return a;
}

void push_attribute(struct attributes * a,struct ast * t){
    if(t -> node -> tree -> attributes == NULL)
        t -> node -> tree -> attributes = a;
    else{
        struct attributes * tmp = t -> node -> tree -> attributes;
        while(tmp != NULL)
            tmp = tmp -> next;
        tmp = a;
    }
}