#include <stdio.h>
#include <stdint.h>

extern uint32_t fsub(uint32_t a, uint32_t b);
extern uint32_t fmul(uint32_t a, uint32_t b);

uint32_t reduction(uint32_t a){
    uint32_t r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;
    uint32_t s1, s2;
    r2 = a;

    //r15 = 0x40c90fdb(2*PI)
    r4 = 16;
    r15 = 0x40c9;
    r15 = r15 << r4;
    r14 = 0x0fdb;
    r15 = r15 | r14;
    if (r2 < r15 /*r15 <= r2*/) {} else {
	//r14 = 0x490fdb(man of PI)
	r13 = 16;
	r14 = 0x49;
	r14 = r14 << r13;
	r13 = 0x0fdb;
	r14 = r14 | r13;

	//r4 = exp
	r13 = 23;
	r4 = r2 >> r13;
	while(1) {
	    r13 = 23;
	    r3 = r4 << r13;
	    r3 = r3 | r14;
	    r12 = 1;
	    r4 = r4 - r12;
	    if(r2 < r3 /*r2 >= r3*/) {} else {
		s1 = r15;
		s2 = r14;
		r2 = fsub(r2, r3);
		r14 = s2;
		r15 = s1;
		if(r2 < r15) break;
	    }
	}
    }
    return r2;
}    

uint32_t kernel_sin(uint32_t a){
    uint32_t r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;
    uint32_t s1, s2, s3, s4;
    r2 = a;

    s1 = r2;
    r3 = r2;
    r2 = fmul(r2, r3);//r2 = a^2
    r3 = s1; //r3 = a
    
    s1 = r3;//s1 = a
    s2 = r2;//s2 = a^2
    r2 = fmul(r2, r3);//r2 = a^3
    
    //r3 = 0xbe2aaaac
    r14 = 16;
    r3 = 0xbe2a;
    r3 = r3 << r14;
    r14 = 0xaaac;
    r3 = r3 | r14;
    r2 = fmul(r2, r3);//r2 = S3 * a^3

    r3 = r2;//r3 = S3 * a^3
    r2 = s2;//r2 = a
    r2 = fsub(r2, r3);//r2 = a - S3 * a^3

    
}

uint32_t fsin(uint32_t a){
    uint32_t r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;
    uint32_t s1, s2, s3, s4;
    r2 = a;
    
    r3 = r2 >> 31;
    r2 = r2 << 1;
    r2 = r2 >> 1;
    s1 = r3;
    r2 = reduction(r2);
    r3 = s1;
    
    //r15 = 0x490fdb(man of PI)
    r4 = 16;
    r15 = 0x49;
    r15 = r15 << r4;
    r5 = 0x0fdb;
    r15 = r15 | r5;
    //r14 = 0x40490fdb(PI)
    r4 = 23;
    r14 = 0x80;
    r14 = r14 << r4;
    r14 = r14 | r15;
    
    if (r2 < r14 /*r2 >= r14*/) {} else {
	s1 = r3;
	s2 = r15;
	s3 = r14;
	r3 = r14;
	r2 = fsub(r2, r3);
	r14 = s3;
	r15 = s2;
	r3 = s1;
	if(r3 != 0 /*r3 == 0*/) {
	    r3 = 1;
	} else {
	    r3 = 0;
	}
    }

    //r13 = 0x3fc90fdb(PI/2)    
    r4 = 23;
    r13 = 0x7f;
    r13 = r13 << r3;
    r13 = r13 | r15;    
    if(r2 < r13 /*r2 >= r13*/) {} else {
	s1 = r3;
	s2 = r15;
	s3 = r13;
	r3 = r2;
	r2 = r14;
	r2 = fsub(r2, r3);
	r13 = s3;
	r15 = s2;
    }

    //r12 = 0x3f490fdb(PI/4)
    r4 = 23;
    r12 = 0x7e;
    r12 = r12 << r4;
    r12 = r12 | r15;
    if(r12 < r2 /*r2 <= r13*/) {
	r3 = r2;
	r2 = r13;
	r2 = fsub(r2, r3);
	r2 = kernel_cos(r2);
    } else {
	r2 = kernel_sin(r2);
    }

    r4 = 31;
    r3 = s1;
    r3 = r3 << r3;
    r2 = r3 | r2;
    return r2;
}
