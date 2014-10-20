#include <stdio.h>
#include <stdint.h>

uint32_t fadd(uint32_t a, uint32_t b){
    uint32_t r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;
    
    r15 = 1;
    r14 = 23;
    r13 = 16;
    r12 = 31;
    r11 = 9;
    r1 = a;
    r2 = b;
    
    //r3(4) = abs
    r3 = r1 << r15;
    r4 = r2 << r15;
    
    //絶対値の大きい方をr1(r3)とする
    if (r4 <= r3) {} else {
	r5 = r1; r1 = r2; r2 = r5;
	r5 = r3; r3 = r4; r4 = r5;
    }

    //答えが0になる演算
    if (r3 == r4) {
    	r3 = r1 >> r12;
    	r4 = r2 >> r12;
    	if (r3 != r4) {
    	    r1 = 0;
    	    return r1;
    	}
    }

    //r3(4) = exp
    r5 = 24;
    r3 = r1 << r15;
    r3 = r3 >> r5;
    r4 = r2 << r15;
    r4 = r4 >> r5;
    //r4 = shift
    r4 = r3 - r4;
    
    //r5(6) = man
    r11 = 9;
    r5 = r1 << r11;
    r5 = r5 >> r11;
    r6 = r2 << r11;
    r6 = r6 >> r11;
    //r7 = 0x800000
    r7 = r15 << r14;
    r5 = r5 | r7;
    r6 = r6 | r7;
    //man_b >> shift
    r6 = r6 >> r4;

    
    //r7(8) = sig
    r7 = r1 >> r12;
    r8 = r2 >> r12;
    //r9 = man_c
    if (r7 != r8) {
	r9 = r5 - r6;
    } else {
	r9 = r5 + r6;	
    }
    
    r4 = 25;
    while(1) {
	r10 = r15 << r4;
	r10 = r9 & r10;
	if (r10 != 0) break;
	r4 = r4 - r15;
	if (r4 <= 0) break;
    }
    
    if (r14 <= r4) { //繰り上がり
	r4 = r4 - r14;
	r10 = r3 + r4;
	r9 = r9 >> r4;
    } else { //繰り下がり
	r4 = r14 - r4;
	r10 = r3 - r4;
	r9 = r9 << r4;
    }

    r10 = r10 << r14;
    r9 = r9 << r11;
    r9 = r9 >> r11;
    r1 = r7 << r12;
    r1 = r1 | r10;
    r1 = r1 | r9;
    
    return r1;
}

uint32_t fsub(uint32_t a, uint32_t b){
    uint32_t r1, r2, r3;
    
    r1 = a; r2 = b;
    r3 = r2 >> 31;;
    if (r3 != 0) {
	r3 = 0x7fffffff;
	r2 = r2 & r3;
    } else {
	r3 = 0x80000000;
	r2 = r2 | r3;
    }
    r1 = fadd(r1, r2);
    return r1;
}
