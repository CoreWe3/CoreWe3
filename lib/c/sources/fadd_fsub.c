#include <stdio.h>
#include <stdint.h>
#include "float_arith.h"

uint32_t fadd(uint32_t a, uint32_t b){
    uint32_t r[16];//, s[16], m[16];
//    int sp;
    r[0] = r[1] = r[2] = 0; //sp = 0;
    r[3] = a; r[4] = b;
    
    //r[5](6) = abs
    r[5] = r[3] << 1;
    r[5] = r[5] >> 1;
    r[6] = r[4] << 1;
    r[6] = r[6] >> 1;
    
    if (uitoi(r[6]) <= uitoi(r[5])) {} else {
	r[7] = r[3];
	r[3] = r[4];
	r[4] = r[7];
    }
    
    //r[9](10) = sig
    r[9] = r[3] >> 31;
    r[10] = r[4] >> 31;
    if (r[9] == r[10]) {} else {
	if (r[5] != r[6]) {} else {
	    r[3] = 0;
	    return r[3];
	}
    }
 
    //r[5](6) = exp
    r[5] = r[3] << 1;
    r[5] = r[5] >> 24;
    r[6] = r[4] << 1;
    r[6] = r[6] >> 24;
    //r[6] = shift
    r[6] = r[5] - r[6];
    
    //r[7](8) = man
    r[7] = r[3] << 9;
    r[7] = r[7] >> 9;
    r[8] = r[4] << 9;
    r[8] = r[8] >> 9;
    //r[9] = 0x800000
    r[12] = 0x800000;
    r[7] = r[12] | r[7];
    r[8] = r[12] | r[8];
    //man_b >> shift
    r[8] = r[8] >> r[6];
    
    //r[11] = man_c
    if (r[9] != r[10]) {
	r[11] = r[7] - r[8];
    } else {
	r[11] = r[7] + r[8];	
    }
    
    r[12] = 25;
    r[13] = 1;
    while(1) {
	r[14] = r[13] << r[12];
	r[14] = r[11] & r[14];
	if (r[14] != 0) break;
	r[12] = r[12] - 1;
	if (r[12] <= 0) break;
    }

    r[14] = 23;
    if (r[14] <= r[12]) { //繰り上がり
	r[12] = r[12] - r[14];
	r[10] = r[5] + r[12];
	r[11] = r[11] >> r[12];
    } else { //繰り下がり
	r[12] = r[14] - r[12];
	if (r[12] < r[5] /*r[3]<=r[4]*/) {} else {
	    r[3] = 0;
	    return r[3];
	}
	r[10] = r[5] - r[12];
	r[11] = r[11] << r[12];
    }

    r[10] = r[10] << 23;
    r[11] = r[11] << 9;
    r[11] = r[11] >> 9;
    r[3] = r[9] << 31;
    r[3] = r[3] | r[10];
    r[3] = r[3] | r[11];
    return r[3];
}

uint32_t fsub(uint32_t a, uint32_t b){
    uint32_t r[16];//, s[16], m[16];
//    int sp;
    r[0] = r[1] = r[2] = 0; //sp = 0;
    r[3] = a; r[4] = b;

    r[4] = ftoui(-uitof(r[4]));
    r[3] = fadd(r[3], r[4]);
    return r[3];
}
