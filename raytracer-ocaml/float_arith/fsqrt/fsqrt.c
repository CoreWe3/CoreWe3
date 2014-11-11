//fsqrt.s
//正の正規化数及び、ゼロに対して基準を満たす平方根を返します。
//それ以外については未定義としておきます。


#include<stdio.h>
#include<stdint.h>
#include"float_arith.h"
#define PUSH(n) push((n), r, s, &sp)
#define POP(n) pop((n), r, s, &sp)

extern uint32_t fadd(uint32_t, uint32_t);

uint32_t div2(uint32_t a){
  uint32_t r[16];
  r[0] = 0;
  r[3] = a;
  r[15] = 0xff;
  r[14] = 23;
  r[15] = r[15] << r[14];
  r[4] = r[3] & r[15];
  if(r[4] > r[0]){
    r[15] = 1;
    r[15] = r[15] << r[14];
    r[3] = r[3] - r[15];
  }
  return r[3];
}

uint32_t myfdiv(uint32_t a, uint32_t b){
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
  uint32_t r[16], s[100];
  int sp = 0;
  r[0] = 0;
  r[3] = a;
  r[15] = 0xffffffff;
  r[14] = 1;
  r[15] = r[15] >> r[14]; //r15 = 0x7fffffff
  r[3] = r[3] & r[15]; //r3 = |a|
  if(r[3] == r[0]){ //|a| == 0
    return r[3];
  }
  //a = b * 2^m, 1<=b<4 normalize
  r[15] = 0xfe;
  r[14] = 23;
  r[15] = r[15] << r[14]; // [30:24]
  r[13] = 0x7e;
  r[13] = r[13] << r[14]; //b[30:24];
  r[4] = r[3] & r[15]; // a[30:24]
  r[4] = r[4] - r[13]; // a[30:24] - b[30:24]  m above
  r[14] = 1;
  r[4] = r[4] >> r[14]; // m/2
  PUSH(4); //m/2
  
  r[15] = r[0] - r[15];
  r[15] = r[15] - 1; // [31, 23:0]
  r[3] = r[3] & r[15]; //a[31, 23:0]
  r[3] = r[3] | r[13]; // b

  //printf("b: %x\n", r[3]);
  PUSH(3); //b

  r[3] = div2(r[3]);
  r[15] = r[3]; //r15 is b/2
  POP(3);  //r3 = x0 = b
  r[14] = 4; //r14 is iterator

  while(1){
    //printf("%x\n", r[3]);
    if(r[14] == r[0]) break;
    r[14] = r[14] - 1;
    PUSH(14);  //iterator
    PUSH(15); // b/2
    PUSH(3);  // xn
    r[3] = div2(r[3]);
    POP(4); // xn
    POP(5); // b/2;
    PUSH(5); // b/2;
    PUSH(3); // xn/2
    r[3] = r[5];
    r[3] = myfdiv(r[3], r[4]);
    r[2] = r[3];
    POP(1); // xn/2
    r[1] = fadd(r[1], r[2]); //x(n+1)
    r[3] = r[1];
    POP(15); //b/2
    POP(14); //iterator
  }

  POP(4); //m/2
  r[3] = r[3] + r[4];
  r[15] = 0xffffffff;
  r[14] = 1;
  r[15] = r[15] >> r[14];
  r[3] = r[3] & r[15];
  
  return r[3];
}
