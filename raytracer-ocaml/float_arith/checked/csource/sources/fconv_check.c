#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "float_arith.h"

extern uint32_t ftoi(uint32_t a);
extern uint32_t itof(uint32_t a);
extern uint32_t _floor(uint32_t a);

int itof_judge(uint32_t a) {
    int ia, ia_abs;
    uint32_t ans, exp;
    double bnd, err;
    ia = uitoi(a);
    ia_abs = abs(ia);
    if (ia_abs < (1 << 24)) {
	bnd = 0.0; // >2^24まではexact
    } else {
	for (exp = 30; exp > 23; exp--) { if (ia_abs >> exp != 0) break; }
	exp += 103;
	bnd = (double) uitof(exp << 23);//<=2^24以降は、最下位bitの半分以内の誤差(0捨1入)
    }
    ans = itof(a);
    err = fabs((double) ia - (double) uitof(ans));
    if(err > bnd) {
	printf("%08x %d\n", a, ia);
	exit(1);
	return 0;
    }
    return 1;
}

int ftoi_judge(uint32_t a) {
    double bnd = 1.0, err;
    float fa;
    uint32_t ans;
    ans = ftoi(a);
    fa = uitof(a);
    err = fabs((double)fa - (double)uitoi(ans));
    if(err > bnd) {
	printf("%08x %e\n", a, fa);
	exit(1);
	return 0;
    }
    return 1;
}

int _floor_judge(uint32_t a) {
    double bnd = 1.0;
    float fa, fans;
    uint32_t ans, exp;
    ans = _floor(a); 
    fans = uitof(ans);
    fa = uitof(a);
    exp = (a << 1) >> 24;
    if(exp > 150) {
	bnd = (double) uitof((exp - 23) << 23);
    }
    if(!(fans <= fa && fa < fans + bnd)) {
	printf("%08x %f\n", a, fa);
	exit(1);
	return 0;
    }
    return 1;
}

int main() {
    uint32_t a, a_max;
    srand((unsigned) time(NULL));

    /* printf("itof\n"); */
    /* itof_judge(0); */
    /* a_max = 0x80000000; */
    /* for(a = 1; a < a_max; a++) { */
    /* 	itof_judge(a); */
    /* 	itof_judge(itoui(-uitoi(a))); */
    /* } */

    /* printf("ftoi\n"); */
    /* a_max = 0x4f000000;//abs < 2^31 */
    /* for(a = 0; a < a_max; a++) { */
    /* 	ftoi_judge(a); */
    /* 	ftoi_judge(ftoui(-uitof(a))); */
    /* } */
    
    printf("floor\n");
    a_min = 0x00100000;
    a_max = 0x7f000000;//abs < 2^31
    for(a = 1; a < a_max; a++) {
   	_floor_judge(a);
   	_floor_judge(ftoui(-uitof(a)));
    }
    
    return 0;
}
