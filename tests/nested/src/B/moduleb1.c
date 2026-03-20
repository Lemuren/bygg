#include "moduleb.h"
#include "modulec.h"

int mult(int a, int b) {
    a += add(1, foo());
    return a * b;
}
