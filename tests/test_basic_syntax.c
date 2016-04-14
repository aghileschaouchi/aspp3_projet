#include "../test.h"

void test(void) {
    //basic syntax
    expect_ok(scan_string("div{}"), "Parse {div{}}");
    expect_ok(scan_string("{div{}}"), "Parse {div{}}");
    expect_ok(scan_string("{div{a{}}{{h1{}}}}"), "Parse nested trees");
}