#include <stdio.h>
#include "modulea.h"
#include "moduleb.h"

int main() {
    // Here we are using the `add` function from Module A.
    // It also exists in Module C, but that isn't exposed
    // to us here.
    int a = add(1, 2);
    printf("%d\n", a);

    // Let's also use something from Module B.
    int b = mult(1, 2);
    printf("%d\n", b);


    printf("Hello there!\n");
}
