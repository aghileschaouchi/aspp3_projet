#include "parser.h"

void yyerror(const char *s) {
    fprintf(yyout, "Line %d : %s\n", yylineno, s);
}


//gestion des attributs

struct attributes * mk_attribute(struct ast * key, struct ast * value) {
    struct attributes * a = malloc(sizeof (struct attributes));
    a -> key = key;
    a -> value = value;
    return a;
}

void afficher_foret(struct ast * foret) {
    static int i = 1;
    if (foret != NULL) {
        printf("---------Foret n° %d ----------\n", i);
        if (foret->node->forest->head != NULL)
            printf("/HEAD/ \n");
        if (foret->node->forest->tail != NULL)
            printf("\\Tail\\ \n");
        i++;
    }
}

struct path * mk_path(int n, struct dir * dir) {
    struct path * p = malloc(sizeof(struct path));
    p->n = n;
    p->dir = dir;
    
    return p;
}

struct dir * mk_dir(char * str, enum descr descr, struct dir * dir) {
    struct dir * d = malloc(sizeof(struct dir));
    d->str = str;
    d->descr = descr;
    d->dir = dir;
    
    return d;
}