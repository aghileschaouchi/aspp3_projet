LEX = flex
YACC = bison -d -v
LDLIBS = -lfl
CFLAGS = -Wall -Wextra -Wshadow -Wpointer-arith -Wcast-qual -Wstrict-prototypes -Wmissing-prototypes
CC = gcc -g
EXEC = parser

$(EXEC): lex.o $(EXEC).tab.o $(EXEC).o pattern.o ast.o machine.o pattern_matching.o import.o main.c
	${CC} ${CFLAGS} $^ -o $@ $(LDLIBS)

$(EXEC).o: $(EXEC).tab.h
	${CC} -c ${CFLAGS} $(EXEC).c -o $@ $(LDLIBS)

lex.o: $(EXEC).tab.h lex.yy.c
	${CC} -c ${CFLAGS} lex.yy.c -o $@ $(LDLIBS)

$(EXEC).tab.o: $(EXEC).tab.h $(EXEC).tab.c
	${CC} -c ${CFLAGS} $(EXEC).tab.c -o $@ $(LDLIBS)

import.o: import.h import.c
	${CC} -c ${CFLAGS} import.c -o $@ $(LDLIBS)

machine.o: ast.o machine.c machine.h
	${CC} -c ${CFLAGS} machine.c -o $@ $(LDLIBS)

pattern_matching.o: machine.o pattern_matching.c pattern_matching.h
	${CC} -c ${CFLAGS} pattern_matching.c -o $@ $(LDLIBS)

ast.o: pattern.o ast.c ast.h chemin.h
	${CC} -c ${CFLAGS} ast.c -o $@ $(LDLIBS)

pattern.o: pattern.c pattern.h
	${CC} -c ${CFLAGS} pattern.c -o $@ $(LDLIBS)

$(EXEC).tab.h $(EXEC).tab.c: $(EXEC).y
	${YACC} $(EXEC).y

lex.yy.c: $(EXEC).l
	${LEX} $(EXEC).l

test.o: test.c test.h $(EXEC).tab.h
	${CC} -c ${CFLAGS} test.c -o $@ $(LDLIBS)

.PHONY: clean
clean: clean-tests
	rm -f *.o core *.tab.c *.tab.h* lex.yy.c $(EXEC) $(EXEC).output *~

clean-tests:
	for fname in tests/* ; do \
		rm -rf ./$${fname%.c} ; \
	done

test: build-tests
	for fname in tests/*.c ; do \
		if ./$${fname%.c} ; then \
			echo -e "$${fname%.c}: \033[0;32mPASS\033[0m"; \
		else \
			echo -e "$${fname%.c}: \033[0;31mFAIL\033[0m"; \
			cat /tmp/aspp3.tmp; \
		fi \
	done

build-tests: lex.o $(EXEC).tab.o $(EXEC).o ast.o pattern.o pattern_matching.o import.o machine.o test.o
	for fname in tests/*.c ; do \
		${CC} ${CFLAGS} $^ $$fname -o $${fname%.c} $(LDLIBS); \
	done
