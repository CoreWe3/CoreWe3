#include<stdint.h>
#include<stdio.h>

uint32_t ftoi(uint32_t i){
  uint32_t sign1, sign2, flag;
  uint32_t vexp, exp;
  uint32_t manti, vmanti, n_abs, carry;
  uint32_t result;

  // stage 1
  sign1 = i >> 31;
  vexp = (i >> 23) & 0xff;
  manti = 1 << 23 | (i & 0x7fffff);
  if(vexp >= 150){
    flag = 0;
    exp = vexp-150;
  }
  else if(vexp < 126){
    flag = 1;
    exp = 0;
  }
  else{ // 1 <= 150-exp <= 24
    flag = 2;
    exp = 150-vexp;
  }

  //stage 2
  sign2 = sign1;
  if(flag == 0){
    n_abs = manti << (exp & 0xf);
    carry = 0;
  }
  else if(flag == 1){
    n_abs = 0;
    carry = 0;
  }
  else{
    n_abs = manti >> (exp & 0x1f);
    vmanti = manti << ((24-exp) & 0x1f);
    if(((1 << 24) & vmanti) == 0 &&
       ((1 << 23) & vmanti) > 0 &&
       (vmanti & 0x7fffff) > 0){
      carry = 1;
    }
    else if(((1 << 24) & vmanti) > 0 &&
	    ((1 << 23) & vmanti) > 0){
      carry = 1;
    }
    else{
      carry = 0;
    }
  }

  // stage 3
  if(carry == 1) result = n_abs+1;
  else result = n_abs;
  if(sign2 == 1) result = ~result+1;

  /*
  printf("exp\t%d\n", vexp);
  printf("man\t%08x\n", manti);
  printf("abs\t%08x\n", n_abs);
  printf("carry\t%d\n", carry);
  */

  return result;

}
