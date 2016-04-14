#include <assert.h>
#include "parser.h"

#define OUTPUT_TMP "/tmp/aspp3.tmp"

int scan_string(char* str);
int scan_file(FILE* file);

void expect_ok(int result, char* message); //attendre result == 0
void expect_err(int result, char* message); // atendre result != 0

void test(void);
int main(void);