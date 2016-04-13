#include <assert.h>
#include "parser.h"

int scan_string(char* str);
int scan_file(FILE* file);

void expect_ok(int result); //attendre result == 0
void expect_err(int result); // atendre result != 0

void test(void);
int main(void);