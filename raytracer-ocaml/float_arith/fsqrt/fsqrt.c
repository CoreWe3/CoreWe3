//fsqrt.s
//正の正規化数及び、ゼロに対して基準を満たす平方根を返します。
//それ以外については未定義としておきます。

#include<stdio.h>
#include<stdint.h>
#include"../checkedlibrary/csource/float_arith.h"

extern uint32_t fadd(uint32_t, uint32_t);

uint32_t fhalf(uint32_t a){
  union {
    uint32_t i;
    float f;
  } ua;
  ua.i = a;
  ua.f = ua.f / 2.0;
  return ua.i;
}

uint32_t fdiv(uint32_t a, uint32_t b){
  union {
    uint32_t i;
    float f;
  } ua, ub, uc;
  ua.i = a;
  ub.i = b;
  uc.f = ua.f / ub.f;
  return uc.i;
}

uint32_t fsqrt(uint32_t a){
    uint32_t r[16], s[100], ram[10];
    int sp = 0;
    r[0] = 0;
    r[3] = a;

    r[3] = SHL(r[3], 1);
    r[3] = SHR(r[3], 1);
    if (r[3] == r[0]) {
	return r[3];
    }
    
    PUSH(3);
    PUSH(2);
    r[3] = fhalf(r[3]);// a/2
    POP(2);
    ram[0] = r[3];
    POP(3);
  
    r[4] = 0x3f800000;
    r[3] = r[3] + r[4];
    r[3] = SHR(r[3], 1);
  
    r[5] = 10;
    while(1){
	ram[1] = r[3];//x_n
	ram[2] = r[5];

	PUSH(2);
	r[2] = r[2] + 3;
	r[3] = fhalf(r[3]);// x_n / 2
	POP(2);

	PUSH(3);
	PUSH(2);
	r[3] = ram[0];
	r[4] = ram[1];
	r[2] = r[2] + 3;
	r[3] = fdiv(r[3], r[4]);// a/2 / x_n
	POP(2);
	POP(4);

	PUSH(2);
	r[2] = r[2] + 3;
	r[3] = fadd(r[3], r[4]);
	POP(2);
	
	r[4] = ram[1];
	if (r[4] < r[3]) {
	    r[5] = r[3] - r[4];
	} else {
	    r[5] = r[4] - r[3];	    
	}
	r[6] = 2;
	if (r[5] < r[6]) break;

	r[5] = ram[2];
	r[5] = r[5] - 1;
	if (r[5] <= 0) break;
    }
    if(r[5] > 4){
	printf("%d\n", r[5]);
    }
    return r[3];
}
