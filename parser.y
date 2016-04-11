%{
#include <stdlib.h>
#include <stdio.h>

int yylex(void);
void yyerror(const char* s);
%}
%define parse.error verbose

%token ID_XML DBL_QUOTES_CLOSE DBL_QUOTES_OPEN
%token SPACE BLANK
%token	<string_t>		TEXT
%union {
	char* string_t;
}
%start Document												
%%

Document:	   	Document Foret Blanks
		|		Blanks
		;

Foret:			ID_XML Attributs '{' F_contenu '}'
		|		'{' F_contenu '}'
		;

Attributs:		'[' A_contenu ']'
		|		{}
		;

A_contenu:		A_contenu ID_XML '=' Quoted_text Blanks
		|		Blanks
		;

F_contenu:		F_contenu Foret Blanks
		|		F_contenu Quoted_text Blanks
		|		Blanks
		;

Quoted_text:	DBL_QUOTES_OPEN TEXT DBL_QUOTES_CLOSE
		;

Blanks:			Blanks SPACE
		|		Blanks BLANK
		|		{}
		;

%%
void yyerror(const char *s) {
	printf("yyerror : %s\n",s);
}

int main(void) {
	yyparse();
	return 0;
}
