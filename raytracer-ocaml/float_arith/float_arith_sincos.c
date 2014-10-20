#include <stdio.h>
#include <stdint.h>

extern uint32_t fadd(uint32_t a, uint32_t b);
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

    s1 = r2;//[a]
    r3 = r2;//r3 = a
    r2 = fmul(r2, r3);//r2 = a^2
    r3 = s1; //r3 = a, []
    
    s1 = r3;//[a]
    s2 = r2;//[a^2,a]
    r2 = fmul(r2, r3);//r2 = a^3
    r3 = s2;//r3 = a^2, [a]

    s2 = r2;//[a^3,a]
    s3 = r3;//[a^2,a^3,a]
    r2 = fmul(r2, r3);//r2 = a^5
    r3 = s3;//r3 = a^2, [a^3,a]
    
    s3 = r2;//[a^5,a^3,a]
    r2 = fmul(r2, r3);//r2 = a^7

    //r3 = 0xb94d64b6
    r15 = 16;
    r3 = 0xb94d;
    r3 = r3 << r15;
    r14 = 0x64b6;
    r14 = r14 << r15;
    r14 = r14 >> r15;
    r3 = r3 | r14;
    r2 = fmul(r2, r3);//r2 = S7 * a^7
    r3 = s3;//r3 = a^5, [a^3, a]
    
    s3 = r2;//[S7 * a^7, a^3, a]
    //r2 = 0x3c088666
    r15 = 16;
    r2 = 0x3c08;
    r2 = r2 << r15;
    r14 = 0x8666;
    r14 = r14 << r15;
    r14 = r14 >> r15;
    r2 = r2 | r14;
    r2 = fmul(r2, r3);//r2 = S5 * a^5
    
    r3 = s3;//r3 = S7 * a^7, [a^3, a]
    r2 = fsub(r2, r3);//r2 = S5 * a^5 - S7 * a^7
    r3 = s2;//r3 = a^3, [a]
    s2 = r2;//[S5 * a^5 - S7 * a^7, a]
    
    //r2 = 0xbe2aaaac
    r15 = 16;
    r2 = 0xbe2a;
    r2 = r2 << r15;
    r14 = 0xaaac;
    r14 = r14 << r15;
    r14 = r14 >> r15;
    r2 = r2 | r14;
    r2 = fmul(r2, r3);//r2 = S3 * a^3
    r3 = r2;
    r2 = s2;//r2 = S5 * a^5 - S7 * a^7, [a]
    r2 = fsub(r2, r3);//r2 = -S3 * a^3 + S5 * a^5 - S7 * a^7
    r3 = s1;//r3 = a, []
    r2 = fadd(r2, r3);

    return r2;
}

uint32_t kernel_cos(uint32_t a){
    uint32_t r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;
    uint32_t s1, s2, s3, s4;
    r2 = a;

    r3 = r2;//r3 = a
    r2 = fmul(r2, r3);//r2 = a^2
    
    s1 = r2;//[a^2]
    s2 = r2;//[a^2, a^2]
    r3 = r2;//r3 = a^2
    r2 = fmul(r2, r3);//r2 = a^4
    r3 = s2;//r3 = a^2, [a^2]

    s2 = r2;//[a^4, a^2]
    r2 = fmul(r2, r3);//r2 = a^6

    //r3 = 0xbab38106
    r15 = 16;
    r3 = 0xbab3;
    r3 = r3 << r15;
    r14 = 0x8106;
    r14 = r14 << r15;
    r14 = r14 >> r15;
    r3 = r3 | r14;
    r2 = fmul(r2, r3);//r2 = C6 * a^6
    r3 = s2;//r3 = a^4, [a^2]
    
    s2 = r2;//[C6 * a^6, a^2]
    //r2 = 0x3d2aa789
    r15 = 16;
    r2 = 0x3d2a;
    r2 = r2 << r15;
    r14 = 0xa789;
    r14 = r14 << r15;
    r14 = r14 >> r15;
    r2 = r2 | r14;
    r2 = fmul(r2, r3);//r2 = C4 * a^4
    r3 = s2;//r3 = C6 * a^6, [a^2]

    r2 = fsub(r2, r3);//r2 = C4 * a^4 - C6 * a^6
    r3 = s1;//r3 = a^2, []

    r10 = 31; 
    r9 = 1;
    r8 = 24;
    r7 = 23;
    r6 = 9;
    r4 = r3 >> r10;
    r4 = r4 << r10;
    r5 = r3 << r9;
    r5 = r5 >> r8;
    r5 = r5 - r9;
    r5 = r5 << r7;
    r3 = r3 << r6;
    r3 = r3 >> r6;
    r3 = r5 | r3;
    r3 = r4 | r3;
    
    r2 = fsub(r2, r3);//r2 = - 0.5 * a^2 + C4 * a^4 - C6 * a^6

    r14 = 16;
    r3 = 0x3f80;
    r3 = r3 << r14;

    r2 = fadd(r2, r3);
	
    return r2;
}

uint32_t fsin(uint32_t a){
    uint32_t r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;
    uint32_t s1, s2, s3, s4;
    r2 = a;

    r4 = 31;
    r5 = 1;
    r3 = r2 >> r4;
    r2 = r2 << r5;
    r2 = r2 >> r5;
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
