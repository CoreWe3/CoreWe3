#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "float_arith.h"

extern uint32_t fadd(uint32_t a, uint32_t b);
extern uint32_t fsub(uint32_t a, uint32_t b);

int fadd_check_case(uint32_t a, uint32_t b) {
    float eps, r, fa, fb, err, bnd;
    uint32_t res;
    eps = itof(0x00800000); //2**(-126)
    r = itof(0x34000000);   //2**(-23)
    fa = itof(a);
    fb = itof(b);    
    res = fadd(a, b);
    bnd = fmaxf(fmaxf(fabsf(fa) * r, fabsf(fb) * r), fmaxf(fabsf(fa + fb) * r, eps));
    err = fabsf(itof(res) - (fa + fb));
    if (err > bnd) {
	printf("%08x %08x %08x %08x\n", a, b, ftoi(fa + fb), res);
	return 1;
    }
    return 0;
}

int fadd_valid_case(float a, float b) {
    float upper, res;
    upper = itof(0x7f000000);
    res = fabsf(a + b);
    a = fabsf(a);
    b = fabsf(b);
    return (a < upper) && (b < upper) && (res < upper);
}

void fadd_check(){
    uint32_t a, b;
    uint32_t i, j, k;
    
    for(i = 0; i < 255; i++) {
	for(j = (i < 23)? 0: i - 23; j <= i; j++) {
	    for(k = 0; k < 2; k++) {
		a = ((rand() << 16) | rand()) >> (1 + 8);
		a = a | (i << 23);
		b = ((rand() << 16) | rand()) >> (1 + 8);
		b = b | (i << 23);
		b = b | (k << (23 + 8));
		if (fadd_valid_case(itof(a), itof(b))) {
		    fadd_check_case(a, b);		    
		}
	    }
	}
    }
}

int fsub_valid_case(float a, float b) {
    float upper, res;
    upper = itof(0x7f000000);
    res = fabsf(a - b);
    a = fabsf(a);
    b = fabsf(b);
    return (a < upper) && (b < upper) && (res < upper);
}

int fsub_check_case(uint32_t a, uint32_t b) {
    float eps, r, fa, fb, err, bnd;
    uint32_t res;
    eps = itof(0x00800000); //2**(-126)
    r = itof(0x34000000);   //2**(-23)
    fa = itof(a);
    fb = itof(b);
    res = fsub(a, b);
    bnd = fmaxf(fmaxf(fabsf(fa) * r, fabsf(fb) * r), fmaxf(fabsf(fa - fb) * r, eps));
    err = fabsf(itof(res) - (fa - fb));
    if (err > bnd) {
	printf("%08x %08x %08x %08x\n", a, b, ftoi(fa - fb), res);
	return 1;
    }
    return 0;
}

void fsub_check(){
    uint32_t a, b;
    uint32_t i, j, k;
    
    for(i = 0; i < 255; i++) {
	for(j = (i < 23)? 0: i - 23; j <= i; j++) {
	    for(k = 0; k < 2; k++) {
		a = ((rand() << 16) | rand()) >> (1 + 8);
		a = a | (i << 23);
		b = ((rand() << 16) | rand()) >> (1 + 8);
		b = b | (i << 23);
		b = b | (k << (23 + 8));
		if (fsub_valid_case(itof(a), itof(b))) {
		    fsub_check_case(a, b);
		}
	    }
	}
    }
}

int main() {
    srand((unsigned) time(NULL));
    
    printf("fadd\n");
    fadd_check();
    printf("fsub\n");
    fsub_check();
    return 0;
}
