#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "float_arith.h"

extern int ftoi(uint32_t a);
extern uint32_t itof(int a);

int main() {
    float fa, fans;
    int ans, i;
    srand((unsigned) time(NULL));

    i = 0x8f094219;
    fans = uitof(itof(itoui(i)));
    printf("%d %f\n", i, fans);
    fa = 1.0;
    ans = uitoi(ftoi(ftoui(fa)));
    printf("%f %d\n", fa, ans);
    /* printf("%08x %08x\n", ftoi(fans), ans); */
    /* printf("%e %e\n", fans, itof(ans)); */
    
    return 0;
}
