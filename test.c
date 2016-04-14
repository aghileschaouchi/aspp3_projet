#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include "test.h"

char* read_file(FILE* fp) {
    long lSize;
    char *buffer;

    fseek(fp, 0L, SEEK_END);
    lSize = ftell(fp);
    rewind(fp);

    /* allocate memory for entire content */
    buffer = calloc(1, lSize + 1);
    if (!buffer) fclose(fp), fputs("memory alloc fails", stderr), exit(1);

    /* copy the file into the buffer */
    if (1 != fread(buffer, lSize, 1, fp))
        fclose(fp), free(buffer), fputs("entire read fails", stderr), exit(1);

    return buffer;
}

int scan_string(char* str) {
    freopen(OUTPUT_TMP, "w", yyout);
    yylineno = 1;

    YY_BUFFER_STATE buffer = yy_scan_string(str);
    int result = yyparse();
    yy_delete_buffer(buffer);

    return result;
}

int scan_file(FILE* file) {
    freopen(OUTPUT_TMP, "w", yyout);
    yylineno = 1;

    YY_BUFFER_STATE buffer = yy_create_buffer(file, YY_BUF_SIZE);
    yy_switch_to_buffer(buffer);
    int result = yyparse();
    yy_delete_buffer(buffer);

    return result;
}

void expect_ok(int result, char* message) {
    fprintf(yyout, "%s\n", message);
    assert(result == 0);
}

void expect_err(int result, char* message) {
    fprintf(yyout, "%s\n", message);
    assert(result != 0);
}

int main(void) {
    yyout = fopen(OUTPUT_TMP, "w");
    
    test();

    return 0;
}
