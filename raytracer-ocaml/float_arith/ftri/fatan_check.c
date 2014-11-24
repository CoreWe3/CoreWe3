#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "float_arith.h"

/* extern uint32_t fsin(uint32_t a); */

float kernel(float f) {
    float f2, fi, c[6] = {-0.3333333, 0.2, -0.142857142, 0.111111104, -0.08976446,  0.060035485};
    int i;
    f2 = f * f;
    fi = f;
    for (i = 0; i < 6; i++){
	fi = fi * f2;
	f += c[i] * fi;
    }
    return f;
}

float fatan(float f) {
    float sig, k;
    sig = 1.0;
    if (f < 0) {
	f = -f;
	sig = -1.0;
    }
    
    if (f < 7.0 / 16.0) {
	k = kernel(f);
    } else if (f < 39.0 / 16.0){
	k = 0.7853981633974483 + kernel((f - 1.0)/(f + 1.0));
    } else {
	k = 1.5707963267948966 - kernel(1.0/f);
    }
    return k * sig;
}

int main() {
    float fa, fans, fanss;
    uint32_t ans;
    int i;
    srand((unsigned) time(NULL));
    
    /* for(i = -100; i <= 100; i++) { */
    /* 	fa = 0.1 * i; */
    /* 	fans = atanf(fa); */
    /* 	fanss = fatan(fa); */
    /* 	printf("%f %f %f %e %08x %08x %08x\n", fa, fans, fanss, fabsf(fans-fanss), ftoui(fans), ftoui(fanss), ftoui(fabsf(fans-fanss))); */
    /* } */
    /* printf("%08x %08x\n", ftoui(fans), ans); */
    printf("%08x %08x\n", ftoui(7.0/16.0), ftoui(39.0/16.0));
    
    return 0;
}
