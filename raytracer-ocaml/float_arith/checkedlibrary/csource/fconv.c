#include <stdio.h>
#include <stdint.h>
#include "float_arith.h"

uint32_t itof(uint32_t a){
    uint32_t r[16];//, s[16];//, m[16];
//    int sp;
    r[0] = r[1] = r[2] = 0;// sp = 0;
    r[3] = a;

    r[15] = 31;
    r[14] = 1;
    r[13] = 32;
    r[12] = 8;
    r[11] = 23;
    r[4] = SHR(r[3], r[15]);
    r[4] = SHL(r[4], r[15]);
    if (r[4] == 0) {} else {
	r[3] = 0 - r[3];
    }
    r[5] = 30;
    while(1) {
	r[6] = SHR(r[3], r[5]);
	if(0 < r[6]) break;
	r[5] = r[5] - r[14];
	if (0 <= uitoi(r[5])) {} else {
	    r[3] = 0;
	    return r[3];
	}
    }
    r[6] = r[13] - r[5];
    r[3] = SHL(r[3], r[6]);
    r[3] = SHR(r[3], r[12]);
    r[3] = r[3] + 1;
    r[3] = SHR(r[3], r[14]);
    r[5] = r[5] + 127;
    r[5] = SHL(r[5], r[11]);
    r[3] = r[3] + r[5];
    r[3] = r[3] | r[4];
    return r[3];
}

uint32_t ftoi(uint32_t a) {
    uint32_t r[16];//, s[16];//, m[16];
//    int sp;
    r[0] = r[1] = r[2] = 0; //sp = 0;
    r[3] = a;

    r[15] = 31;
    r[14] = 1;
    r[13] = 24;
    r[12] = 9;
    r[11] = 150;
    r[10] = 149;
    r[9] = 158;
    r[8] = 23;

    r[5] = SHR(r[3], r[15]);
    r[4] = SHL(r[3], r[14]);
    r[4] = SHR(r[4], r[13]);
    r[6] = SHL(r[14], r[8]);
    r[3] = SHL(r[3], r[12]);
    r[3] = SHR(r[3], r[12]);
    r[3] = r[6] | r[3];
    if (r[11] <= r[4]) {} else {
	r[4] = r[10] - r[4];
	r[3] = SHR(r[3], r[4]);
	r[3] = r[3] + 1;
	r[3] = SHR(r[3], r[14]);
	if (r[5] == 0) {} else {
	    r[3] = 0 - r[3];
	}
	return r[3];
    }
    if (r[9] <= r[4]) {} else {
	r[4] = r[4] - r[11];
	r[3] = SHL(r[3], r[4]);
	if (r[5] == 0) {} else {
	    r[3] = 0 - r[3];
	}
	return r[3];
    }
    r[4] = 16;
    if (r[5] == 0) {} else {
	r[3] = 0x8000;
	r[3] = r[3] << r[4];
	return r[3];
    }
    r[3] = 0x7fff;
    r[3] = SHL(r[3], r[4]);
    r[4] = 0xffff;
    r[3] = r[3] | r[4];
    return r[3];
}

uint32_t _floor(uint32_t a) {
    uint32_t r[16];//, s[16];//, m[16];
//    int sp;
    r[0] = r[1] = r[2] = 0; //sp = 0;
    r[3] = a;
    
    r[15] = 31;
    r[14] = 1;
    r[13] = 24;
    r[12] = 150;
    r[11] = 127;
    r[10] = 32;
    
    r[5] = SHR(r[3], r[15]);//r[5] = sig(a)
    r[4] = SHL(r[3], r[14]);//r[4] = exp(a)
    r[4] = SHR(r[4], r[13]);
    if (r[4] < r[12]) {} else {
	return r[3];
    }
    if (r[11] <= r[4]) {} else {
	if (r[5] != 0) {
	    r[4] = 16;
	    r[3] = 0xbf80;
	    r[3] = SHL(r[3], r[4]);
	    return r[3];
	} else {
	    r[3] = 0;
	    return r[3];
	}
    }
    r[6] = r[12] - r[4];
    r[4] = SHR(r[3], r[6]);
    if(r[5] == 0) {} else {
	r[9] = r[10] - r[6];
	r[5] = SHL(r[3], r[9]);
	if (r[5] == 0) {} else {
	    r[4] = r[4] + 1;
	}
    }
    r[3] = SHL(r[4], r[6]);
    return r[3];
}
