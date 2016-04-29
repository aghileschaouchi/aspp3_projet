#include "../test.h"

void test(void) {
	FILE* f = NULL;

    //on attend que la lecture de ce fichier NE RENVOIE PAS d'erreur -> donc ca PASS
    f = fopen("lex_test/film.txt", "r");
    expect_ok(scan_file(f), "Parse film.txt");
    fclose(f);
     //OK
    expect_ok(scan_string("let xml={}in{};let XML={}in{};let xMl={}in{};"),"ID fct or var could start with xml");
    expect_ok(scan_string("let _''''.....xml={}in{};let XML={}in{};let xMl={}in{};"),"ID fct or var could start with xml");
    expect_ok(scan_string("let root={{{}\n{}}};"),"Parse f(v1,v2,v3)");
    expect_ok(scan_string("let root={div{"...."} div{} };"),"Parse f(v1,v2,v3)");
    expect_ok(scan_string("let f v1 v2 v3 = {}in{};"),"Parse f(v1,v2,v3)");
    expect_ok(scan_string("let f = fun v1 v2 v3 -> {}in{};"),"Parse f(v1,v2,v3)");
    expect_ok(scan_string("let f x1 x2 x3 = fun v1 v2 v3 -> {}in{};"),"Parse f(v1,v2,v3)");
    expect_ok(scan_string("let rec f x1 x2 x3 = fun v1 v2 v3 -> {}in{};"),"Parse f(v1,v2,v3)");
    //Fail	
    expect_err(scan_string("let 12err = {}in{};let _ = {}in{};"),"Parse Id ne doit pas commencer par un numérique ou underscore ts seul");
    expect_err(scan_string(""),"");
}
