#include <stdio.h>
#include "parser.tab.h"

#include "pattern_matching.h"
#include "import.h"
#include "ast.h"

#define YY_BUF_SIZE 16384

extern FILE* yyin;
extern FILE* yyout;
extern int yylineno;
extern int yylex(void);
extern void yyerror(const char* s);

typedef struct yy_buffer_state * YY_BUFFER_STATE;
extern YY_BUFFER_STATE yy_scan_string(char * str);
extern void yy_delete_buffer(YY_BUFFER_STATE buffer);
extern YY_BUFFER_STATE yy_create_buffer(FILE* file, int size);
extern void yy_switch_to_buffer(YY_BUFFER_STATE new_buffer);

/**
 * EXTENSION DE L'AST
 */
#ifdef AST
//gestion des atttributs
struct attributes * make_attribute(struct ast * key, struct ast * value);
void push_attribute(struct attributes * a,struct ast * t);
#endif