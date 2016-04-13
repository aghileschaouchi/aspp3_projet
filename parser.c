#include "parser.h"

void yyerror(const char *s) {
	printf("Line %d : %s\n", yylineno, s);
}