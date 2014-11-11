#include <stdio.h>
#include <stdint.h>
#include "float_arith.h"

extern uint32_t fadd(uint32_t a, uint32_t b);
extern uint32_t fsub(uint32_t a, uint32_t b);

uint32_t fmul(uint32_t a, uint32_t b) {
    float *pa, *pb;
    uint32_t *pi;
    pa = (float *) &a;
    pb = (float *) &b;
    *pa = (*pa) * (*pb);
    pi = (uint32_t *) pa;
    return *pi;
}

uint32_t kernel_atan(uint32_t a){
    uint32_t r[16], s[16];//, m[16];
    int sp;
    r[0] = r[1] = r[2] = 0; sp = 0;
    r[3] = a;
    
    push(3, r, s, &sp);//[a]
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[4] = r[3];//r[4] = a
    r[3] = fmul(r[3], r[4]);//r[3] = a^2
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[4] = a, []
    
    push(4, r, s, &sp);//[a]
    push(3, r, s, &sp);//[a^2, a]
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = a^3
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[4] = a^2, [a]
    
    push(3, r, s, &sp);//[a^3,a]
    push(4, r, s, &sp);//[a^2,a^3,a]
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = a^5
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[4] = a^2, [a^3,a]
    
    push(3, r, s, &sp);//[a^5,a^3,a]
    push(4, r, s, &sp);//[a^2,a^5,a^3,a]
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = a^7
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[4] = a^2, [a^5,a^3,a]
    
    push(3, r, s, &sp);//[a^7,a^5,a^3,a]
    push(4, r, s, &sp);//[a^2,a^7,a^5,a^3,a]
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = a^9
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[4] = a^2, [a^7,a^5,a^3,a]
    
    push(3, r, s, &sp);//[a^9,a^7,a^5,a^3,a]
    push(4, r, s, &sp);//[a^2,a^9,a^7,a^5,a^3,a]
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = a^11
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[4] = a^2, [a^9,a^7,a^5,a^3,a]
    
    push(3, r, s, &sp);//[a^11,a^9,a^7,a^5,a^3,a]
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = a^13
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);

    //r[4] = 0x3d75e7c5
    r[15] = 16;
    r[4] = 0x3d75;
    r[4] = r[4] << r[15];
    r[14] = 0xe7c5;
    r[14] = r[14] << r[15];
    r[14] = r[14] >> r[15];
    r[4] = r[4] | r[14];
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = T13 * a^13
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[4] = a^11,[a^9,a^7,a^5,a^3,a]
    push(3, r, s, &sp);//[T13*a^13,a^9,a^7,a^5,a^3,a]

    //r[4] = 0xbdb7d66e
    r[15] = 16;
    r[4] = 0xbdb7;
    r[4] = r[4] << r[15];
    r[14] = 0xd66e;
    r[14] = r[14] << r[15];
    r[14] = r[14] >> r[15];
    r[4] = r[4] | r[14];
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = T11 * a^11
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[4] = a^9,[a^7,a^5,a^3,a]

    //r[4] = 0xb94d64b6
    r[15] = 16;
    r[4] = 0xb94d;
    r[4] = r[4] << r[15];
    r[14] = 0x64b6;
    r[4] = r[4] | r[14];
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = S7 * a^7
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[4] = a^5, [a^3, a]    
    push(3, r, s, &sp);//[S7 * a^7, a^3, a]
    
    //r[3] = 0x3c088666
    r[15] = 16;
    r[3] = 0x3c08;
    r[3] = r[3] << r[15];
    r[14] = 0x8666;
    r[14] = r[14] << r[15];
    r[14] = r[14] >> r[15];
    r[3] = r[3] | r[14];
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = S5 * a^5
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    
    pop(4, r, s, &sp);//r[4] = S7 * a^7, [a^3, a]
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fadd(r[3], r[4]);//r[3] = S5 * a^5 - S7 * a^7
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[4] = a^3, [a]
    push(3, r, s, &sp);//[S5 * a^5 - S7 * a^7, a]
    
    //r[3] = 0xbe2aaaac
    r[15] = 16;
    r[3] = 0xbe2a;
    r[3] = r[3] << r[15];
    r[14] = 0xaaac;
    r[14] = r[14] << r[15];
    r[14] = r[14] >> r[15];
    r[3] = r[3] | r[14];
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = -S3 * a^3
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[3] = S5 * a^5 - S7 * a^7, [a]
    
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fadd(r[3], r[4]);//r[3] = -S3 * a^3 + S5 * a^5 - S7 * a^7
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[4] = a, []
    
    r[3] = fadd(r[3], r[4]);//r[3] = a - S3 * a^3 + S5 * a^5 - S7 * a^7
    return r[3];
}

uint32_t fatan(uint32_t a){
    uint32_t r[16], s[16], m[16];
    int sp;
    r[0] = r[1] = r[2] = 0; sp = 0;
    r[3] = a;
    
    r[5] = 31;
    r[4] = r[3] >> r[5];//r[4] = sig
    push(4, r, s, &sp);
    r[6] = 1;
    r[3] = r[3] << r[6];//r[3] = abs
    r[3] = r[3] >> r[6];

    //r[15] = 0x3ee00000 (7/16)
    r[14] = 16;
    r[15] = 0x3ee0;
    r[15] = r[15] << r[14];
    if (r[3] < r[15]) {
	r[3] = kernel_atan(r[3]);	
    } else {
	r[2] = r[2] + 1;
	store(1, r[2] - 1, r, m);
	//r[15] = 0x401c0000 (39/16)
	r[15] = 0x401c;
	r[15] = r[15] << r[14];
	if (r[3] < r[15]) {
	    //r[4] = 1.0
	    r[4] = 0x3f80;
	    r[4] = r[4] << r[14];
	    push(4, r, s, &sp);
	    push(3, r, s, &sp);
	    push(2, r, s, &sp);
	    r[3] = fadd(r[3], r[4]);
	    pop(2, r, s, &sp);
	    pop(5, r, s, &sp);
	    pop(4, r, s, &sp);

	    push(3, r, s, &sp);
	    load(1, r[2] - 1, r, m);
	    push(2, r, s, &sp);
	    r[3] = r[5];
	    r[3] = fsub(r[3], r[4]);	    
	    pop(2, r, s, &sp);
	    pop(4, r, s, &sp);

	    load(1, r[2] - 1, r, m);
	    push(2, r, s, &sp);
	    r[3] = fdiv(r[3], r[4]);
	    pop(2, r, s, &sp);
	    
	    //r[4] = 0x3f490fdb(PI/4)
	    r[14] = 16;
	    r[4] = 0x3f49;
	    r[4] = r[4] << r[14];
	    r[14] = 0x0fdb;
	    r[4] = r[4] | r[14];
	    load(1, r[2] - 1, r, m);
	    push(2, r, s, &sp);
	    r[3] = fadd(r[3], r[4]);
	    pop(2, r, s, &sp);
	} else {
	    push(2, r, s, &sp);
	    r[3] = finv(r[3]);
	    pop(2, r, s, &sp);
	    
	    load(1, r[2] - 1, r, m);
	    push(2, r, s, &sp);
	    r[3] = kernel_atan(r[3]);	    
	    pop(2, r, s, &sp);
	    
	    r[4] = r[3];
	    //r[3] = 0x3fc90fdb(PI/2)
	    r[14] = 16;
	    r[3] = 0x3fc9;
	    r[3] = r[3] << r[14];
	    r[14] = 0x0fdb;
	    r[3] = r[3] | r[14];
	    load(1, r[2] - 1, r, m);
	    push(2, r, s, &sp);
	    r[3] = fsub(r[3], r[4]);
	    pop(2, r, s, &sp);
	}
    }
    
    pop(4, r, s, &sp);
    if (r[4] != 0) {
	//符号反転
	r[15] = 1;
	r[14] = 31;
	r[13] = r[15] << r[14];
	r[5] = r[3] >> r[14];;
	if (r[5] != 0) {
	    r[13] = r[13] - r[15];
	    r[3] = r[3] & r[13];
	} else {
	    r[3] = r[3] | r[13];
	}
    }

    return r[3];
}
