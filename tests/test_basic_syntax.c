#include "../test.h"

void test(void) {
    FILE* f = NULL;

    //on attend que la lecture de ce fichier NE RENVOIE PAS d'erreur -> donc ca PASS
    f = fopen("lex_test/basicTestOk.txt", "r");
    expect_ok(scan_file(f), "Parse basicTestOk.txt");
    fclose(f);

    expect_ok(scan_string("div{f arg1 arg2, \"text\"}"),        "Parse a good string, error on ERRtest 11");
    
    //on attend que la lecture de ces chaines renvoient une erreur -> donc ca PASS
    expect_err(scan_string("div{{\"test\"}"), 	           	"Parse a bad string, error on ERRtest 1");
    expect_err(scan_string("_{\"yo\"}"),              	 	"Parse a bad string, error on ERRtest 2");
    expect_err(scan_string("xMLtest{\"..\"}"),            	"Parse a bad string, error on ERRtest 3");
    expect_err(scan_string("123fail{\"...\"}"),       		"Parse a bad string, error on ERRtest 4");
    expect_err(scan_string("avec espace{\"...\"}"),   		"Parse a bad string, error on ERRtest 5");
    expect_err(scan_string("div{a[href=\"...\"test=\"test\"] /}"),  "Parse a bad string, error on ERRtest 6");
    expect_err(scan_string("div\n {\"...\"}"),              "Parse a bad string, error on ERRtest 7");
    expect_err(scan_string("div{a\n[test=\"test\"]}"),      "Parse a bad string, error on ERRtest 8");
    expect_err(scan_string("br\n/"),                     	"Parse a bad string, error on ERRtest 9");
    expect_err(scan_string("div{'contenu'}"),               "Parse a bad string, error on ERRtest 10");
}