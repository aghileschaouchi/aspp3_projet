LEX = flex 
YACC = bison -d -v
LDLIBS = -lfl
CFLAGS = -Wall -Wextra -Wshadow -Wpointer-arith -Wcast-qual -Wstrict-prototypes -Wmissing-prototypes
CC = gcc
EXEC = parser

$(EXEC): $(EXEC).tab.h $(EXEC).tab.c lex.yy.c
	${CC} ${CFLAGS} $^ -o $@ $(LDLIBS)

$(EXEC).tab.h $(EXEC).tab.c: $(EXEC).y
	${YACC} $(EXEC).y

lex.yy.c: $(EXEC).l
	${LEX} $(EXEC).l

.PHONY: clean
clean:
	rm -f *.o core *.tab.c *.tab.h* lex.yy.c $(EXEC) $(EXEC).output *~

test: $(EXEC)
	if ./$(EXEC) < test.txt ; then \
		echo -e "\033[0;32mPASS\033[0m"; \
	else \
		echo -e "\033[0;31mFAIL\033[0m"; \
	fi \
