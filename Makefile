LEX = flex
YACC = bison -d -v
LDLIBS = -lfl
CFLAGS = -Wall -Wextra -Wshadow -Wpointer-arith -Wcast-qual -Wstrict-prototypes -Wmissing-prototypes
CC = gcc
EXEC = parser

$(EXEC): lex.o $(EXEC).tab.o $(EXEC).o main.c
	${CC} ${CFLAGS} $^ -o $@ $(LDLIBS)

$(EXEC).o: $(EXEC).tab.h
	${CC} -c ${CFLAGS} $(EXEC).c -o $@ $(LDLIBS)

lex.o: $(EXEC).tab.h lex.yy.c
	${CC} -c ${CFLAGS} lex.yy.c -o $@ $(LDLIBS)

$(EXEC).tab.o: $(EXEC).tab.h $(EXEC).tab.c
	${CC} -c ${CFLAGS} $(EXEC).tab.c -o $@ $(LDLIBS)

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

build-tests: lex.o $(EXEC).tab.o $(EXEC).o test.o
	for fname in tests/*.c ; do \
		${CC} ${CFLAGS} $^ $$fname -o $${fname%.c} $(LDLIBS); \
	done
