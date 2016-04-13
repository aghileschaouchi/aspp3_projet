#include "../test.h"

void test(void) {
    FILE* f = NULL;

    //on attend que la lecture de ce fichier NE RENVOIE PAS d'erreur -> donc ca PASS
    f = fopen("lex_test/foret.txt", "r");
    expect_ok(scan_file(f));
    fclose(f);

    //on attend que la lecture de ce fichier NE RENVOIE PAS d'erreur -> donc ca PASS
    f = fopen("lex_test/letinwhere.txt", "r");
    expect_ok(scan_file(f));
    fclose(f);

    //on attend que la lecture de cette chaine renvoie une erreur -> donc ca PASS
    expect_err(scan_string("mauvaise chaine"));
}