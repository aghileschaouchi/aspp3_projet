#include "test.h"

int scan_string(char* str) {
    YY_BUFFER_STATE buffer = yy_scan_string(str);
    int result = yyparse();
    yy_delete_buffer(buffer);

    return result;
}

int scan_file(FILE* file) {
    YY_BUFFER_STATE buffer = yy_create_buffer(file, YY_BUF_SIZE);
    yy_switch_to_buffer(buffer);
    int result = yyparse();
    yy_delete_buffer(buffer);

    return result;
}

void expect_ok(int result) {
    assert(result == 0);
}

void expect_err(int result) {
    assert(result != 0);
}

int main(void) {
    freopen("/dev/null", "w", stdout);
    
    test();
    
    return 0;
}
