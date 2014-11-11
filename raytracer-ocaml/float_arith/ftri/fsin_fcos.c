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

uint32_t reduction(uint32_t a){
    uint32_t r[16], s[16];//, m[16];
    int sp;
    r[0] = r[1] = r[2] = 0; sp = 0;
    r[3] = a;
    
    //r[15] = 0x40c90fdb(2*PI)
    r[14] = 16;
    r[15] = 0x40c9;
    r[15] = r[15] << r[14];
    r[14] = 0x0fdb;
    r[15] = r[15] | r[14];
    if (r[3] < r[15] /*r[15] <= r[3]*/) {} else {
	//r[14] = 0x490fdb(man of PI)
	r[13] = 16;
	r[14] = 0x49;
	r[14] = r[14] << r[13];
	r[13] = 0x0fdb;
	r[14] = r[14] | r[13];

	//r[5] = exp
	r[13] = 23;
	r[5] = r[3] >> r[13];
	while(1) {
	    r[13] = 23;
	    r[4] = r[5] << r[13];
	    r[4] = r[4] | r[14];
	    r[12] = 1;
	    r[5] = r[5] - r[12];
	    if(r[3] < r[4] /*r[3] >= r[4]*/) {} else {
		push(15, r, s, &sp);
		push(14, r, s, &sp);
		push(2, r, s, &sp);
		push(1, r, s, &sp);
		r[3] = fsub(r[3], r[4]);
		pop(1, r, s, &sp);
		pop(2, r, s, &sp);
		pop(14, r, s, &sp);
		pop(15, r, s, &sp);
		if(r[3] < r[15]) break;
	    }
	}
    }
    return r[3];
}

uint32_t kernel_sin(uint32_t a){
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
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = a^7
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);

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

uint32_t kernel_cos(uint32_t a){
    uint32_t r[16], s[16];//, m[16];
    int sp;
    r[0] = r[1] = r[2] = 0; sp = 0;
    r[3] = a;
    
    r[4] = r[3];//r[4] = a
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = a^2
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    
    push(3, r, s, &sp);//[a^2]
    push(3, r, s, &sp);//[a^2, a^2]
    r[4] = r[3];//r[4] = a^2
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = a^4
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);;//r[4] = a^2, [a^2]

    push(3, r, s, &sp);//[a^4, a^2]
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = a^6
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);

    //r[4] = 0xbab38106
    r[15] = 16;
    r[4] = 0xbab3;
    r[4] = r[4] << r[15];
    r[14] = 0x8106;
    r[14] = r[14] << r[15];
    r[14] = r[14] >> r[15];
    r[4] = r[4] | r[14];
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = C6 * a^6
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[4] = a^4, [a^2]    
    push(3, r, s, &sp);//[C6 * a^6, a^2]
    
    //r[3] = 0x3d2aa789
    r[15] = 16;
    r[3] = 0x3d2a;
    r[3] = r[3] << r[15];
    r[14] = 0xa789;
    r[14] = r[14] << r[15];
    r[14] = r[14] >> r[15];
    r[3] = r[3] | r[14];
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fmul(r[3], r[4]);//r[3] = C4 * a^4
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[4] = C6 * a^6, [a^2]

    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fadd(r[3], r[4]);//r[3] = C4 * a^4 - C6 * a^6
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    pop(4, r, s, &sp);//r[4] = a^2, []

    r[11] = 31; 
    r[10] = 1;
    r[9] = 24;
    r[8] = 23;
    r[7] = 9;
    r[5] = r[4] >> r[11];//r[5] = sig(a^2)
    r[5] = r[5] << r[11];
    r[6] = r[4] << r[10];//r[6] = exp
    r[6] = r[6] >> r[9];
    r[6] = r[6] - r[10];//r[6] = r[6] * 0.5
    r[6] = r[6] << r[8];
    r[4] = r[4] << r[7];//r[7] = man(a^2)
    r[4] = r[4] >> r[7];
    r[4] = r[6] | r[4];//r[4] = r[4] * 0.5
    r[4] = r[5] | r[4];
    
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = fsub(r[3], r[4]);//r[3] = - 0.5 * a^2 + C4 * a^4 - C6 * a^6
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);

    r[14] = 16;
    r[4] = 0x3f80;
    r[4] = r[4] << r[14];
    r[3] = fadd(r[3], r[4]);
    return r[3];
}

uint32_t fsin(uint32_t a){
    uint32_t r[16], s[16], m[16];
    int sp;
    r[0] = r[1] = r[2] = 0; sp = 0;
    r[3] = a;
    
    r[5] = 31;
    r[6] = 1;
    r[4] = r[3] >> r[5];//r[4] = sig
    store(4, r[2], r, m);
    r[3] = r[3] << r[6];//r[3] = abs
    r[3] = r[3] >> r[6];
    r[2] = r[2] + 1;
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = reduction(r[3]);
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    
    //r[15] = 0x490fdb(man of PI)
    r[5] = 16;
    r[15] = 0x49;
    r[15] = r[15] << r[5];
    r[6] = 0x0fdb;
    r[15] = r[15] | r[6];
    //r[14] = 0x40490fdb(PI)
    r[5] = 23;
    r[14] = 0x80;
    r[14] = r[14] << r[5];
    r[14] = r[14] | r[15];
    
    if (r[3] < r[14] /*r[3] >= r[14]*/) {} else {
	push(15, r, s, &sp);
	push(14, r, s, &sp);
	push(2, r, s, &sp);
	push(1, r, s, &sp);
	r[4] = r[14];
	r[3] = fsub(r[3], r[4]);//r[3] = r[3] - PI
	pop(1, r, s, &sp);
	pop(2, r, s, &sp);
	pop(14, r, s, &sp);
	pop(15, r, s, &sp);
	
	load(4, r[2] - 1, r, m);
	if(r[4] != 0 /*r[4] == 0*/) {
	    r[4] = 0;
	} else {
	    r[4] = 1;
	}
	store(4, r[2] - 1, r, m);	
    }

    //r[13] = 0x3fc90fdb(PI/2)
    r[5] = 23;
    r[13] = 0x7f;
    r[13] = r[13] << r[5];
    r[13] = r[13] | r[15];    
    if(r[3] < r[13] /*r[3] >= r[13]*/) {} else {
	push(15, r, s, &sp);
	push(13, r, s, &sp);
	push(2, r, s, &sp);
	push(1, r, s, &sp);
	r[4] = r[3];
	r[3] = r[14];
	r[3] = fsub(r[3], r[4]);//r[3] = PI - r[3]
	pop(1, r, s, &sp);
	pop(2, r, s, &sp);
	pop(13, r, s, &sp);
	pop(15, r, s, &sp);
    }

    //r[12] = 0x3f490fdb(PI/4)
    r[5] = 23;
    r[12] = 0x7e;
    r[12] = r[12] << r[5];
    r[12] = r[12] | r[15];
    if(r[12] < r[3] /*r[3] <= r[13]*/) {
	push(2, r, s, &sp);
	push(1, r, s, &sp);
	r[4] = r[3];
	r[3] = r[13];
	r[3] = fsub(r[3], r[4]);
	pop(1, r, s, &sp);
	pop(2, r, s, &sp);
	push(2, r, s, &sp);
	push(1, r, s, &sp);
	r[3] = kernel_cos(r[3]);
    } else {
	push(2, r, s, &sp);
	push(1, r, s, &sp);
	r[3] = kernel_sin(r[3]);
    }
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);

    r[5] = 31;
    load(4, r[2] - 1, r, m);
    r[4] = r[4] << r[5];
    r[3] = r[4] | r[3];
    return r[3];
}

uint32_t fcos(uint32_t a){
    uint32_t r[16], s[16],  m[16];
    int sp;
    r[0] = r[1] = r[2] = 0; sp = 0;
    r[3] = a;
    
    r[6] = 1;
    r[4] = 0;
    store(4, r[2], r, m);
    r[3] = r[3] << r[6];//r[3] = abs
    r[3] = r[3] >> r[6];
    r[2] = r[2] + 1;
    push(2, r, s, &sp);
    push(1, r, s, &sp);
    r[3] = reduction(r[3]);
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);
    
    //r[15] = 0x490fdb(man of PI)
    r[5] = 16;
    r[15] = 0x49;
    r[15] = r[15] << r[5];
    r[6] = 0x0fdb;
    r[15] = r[15] | r[6];
    //r[14] = 0x40490fdb(PI)
    r[5] = 23;
    r[14] = 0x80;
    r[14] = r[14] << r[5];
    r[14] = r[14] | r[15];
    
    if (r[3] < r[14] /*r[3] >= r[14]*/) {} else {
	push(15, r, s, &sp);
	push(14, r, s, &sp);
	push(2, r, s, &sp);
	push(1, r, s, &sp);
	r[4] = r[14];
	r[3] = fsub(r[3], r[4]);//r[3] = r[3] - PI
	pop(1, r, s, &sp);
	pop(2, r, s, &sp);
	pop(14, r, s, &sp);
	pop(15, r, s, &sp);
	
	load(4, r[2] - 1, r, m);
	if(r[4] != 0 /*r[4] == 0*/) {
	    r[4] = 0;
	} else {
	    r[4] = 1;
	}
	store(4, r[2] - 1, r, m);	
    }

    //r[13] = 0x3fc90fdb(PI/2)
    r[5] = 23;
    r[13] = 0x7f;
    r[13] = r[13] << r[5];
    r[13] = r[13] | r[15];    
    if(r[3] < r[13] /*r[3] >= r[13]*/) {} else {
	push(15, r, s, &sp);
	push(13, r, s, &sp);
	push(2, r, s, &sp);
	push(1, r, s, &sp);
	r[4] = r[3];
	r[3] = r[14];
	r[3] = fsub(r[3], r[4]);//r[3] = PI - r[3]
	pop(1, r, s, &sp);
	pop(2, r, s, &sp);
	pop(13, r, s, &sp);
	pop(15, r, s, &sp);
	
	load(4, r[2] - 1, r, m);
	if(r[4] != 0 /*r[4] == 0*/) {
	    r[4] = 0;
	} else {
	    r[4] = 1;
	}
	store(4, r[2] - 1, r, m);
    }

    //r[12] = 0x3f490fdb(PI/4)
    r[5] = 23;
    r[12] = 0x7e;
    r[12] = r[12] << r[5];
    r[12] = r[12] | r[15];
    if(r[12] < r[3] /*r[3] <= r[13]*/) {
	push(2, r, s, &sp);
	push(1, r, s, &sp);
	r[4] = r[3];
	r[3] = r[13];
	r[3] = fsub(r[3], r[4]);
	pop(1, r, s, &sp);
	pop(2, r, s, &sp);
	push(2, r, s, &sp);
	push(1, r, s, &sp);
	r[3] = kernel_sin(r[3]);
    } else {
	push(2, r, s, &sp);
	push(1, r, s, &sp);
	r[3] = kernel_cos(r[3]);
    }
    pop(1, r, s, &sp);
    pop(2, r, s, &sp);

    r[5] = 31;
    load(4, r[2] - 1, r, m);
    r[4] = r[4] << r[5];
    r[3] = r[4] | r[3];
    return r[3];
}
