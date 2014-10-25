#include<stdio.h>
#include<stdint.h>
#include<math.h>
#include"float_arith.h"

extern uint32_t fadd(uint32_t, uint32_t);
extern uint32_t fsqrt(uint32_t);
extern uint32_t myfabs(uint32_t);
extern uint32_t myfdiv(uint32_t, uint32_t);
extern uint32_t div2(uint32_t);

int normal_pos(uint32_t a){
  uint32_t exp = 0x7f800000;
  uint32_t sig = 0x80000000;
  
  return ((a & exp) != 0) && ((a & exp) != exp) && ((a & sig) == 0);
}

int main(){
  union {
    uint32_t i;
    float f;
  } ua, ub, uc;
  
  uint32_t diff;
  ua.i = 0x00800010;
  for(ua.i = 0; ua.i<=0x8fffffff; ua.i++){
    if((ua.i & 0xfffff) == 0) printf("%x\n", ua.i);
    if(normal_pos(ua.i)){
      ub.f = sqrtf(ua.f);
      uc.i = fsqrt(ua.i);
      diff = ub.i > uc.i ? ub.i - uc.i : uc.i - ub.i;
      if(diff > 4){ 
	printf("%x\n", ua.i);
	printf("sqrtf: 0x%x %e\n", ub.i, ub.f);
	printf("fsqrt: 0x%x %e\n", uc.i, uc.f);
	printf("diff: %x\n", diff);
      }
    }
  }

  /*
  ua.f = 2.0;
  ub.f = sqrtf(ua.f);
  uc.i = fsqrt(ua.i);
  printf("%x sqrtf:%x fsqrt:%x diff:", ua.i, ub.i, uc.i);
  if(ub.i > uc.i){
    printf("%x\n", ub.i - uc.i);
  }
  else if(ub.i < uc.i){
    printf("%x\n", uc.i - ub.i);
  }
  */
  return 0;

}  

