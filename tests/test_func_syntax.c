#include "../test.h"

void test(void) {
     //OK
    expect_ok(scan_string("let xml={}in{};let XML={}in{};let xMl={}in{};"),"ID fct or var could start with xml");
    expect_ok(scan_string("let f v1 v2 v3 = {}in{};"),"Parse f(v1,v2,v3)");
    expect_ok(scan_string("let f = fun v1 v2 v3 -> {}in{};"),"Parse f(v1,v2,v3)");
    //~ expect_ok(scan_string("let f x1 x2 x3 = fun v1 v2 v3 -> {}in{};"),"Parse f(v1,v2,v3)");
    //Fail	
}
