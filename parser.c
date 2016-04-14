#include "parser.h"

void yyerror(const char *s) {
    fprintf(yyout, "Line %d : %s\n", yylineno, s);
}