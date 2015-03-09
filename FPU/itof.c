#include<stdint.h>
#include<stdio.h>

uint32_t itof(uint32_t n){
  uint32_t sign0,absolute0,lead_zero0;
  uint32_t sign1,absolute1, lead_zero1;
  uint32_t top_bit;
  uint32_t full_manti, manti;
  uint32_t exp, frac;
  uint32_t carry, result;
  int i;

  // stage 1
  sign0 = n & 0x80000000;
  absolute0 = sign0 > 0 ? ~n+1 : n;

  //stge2
  sign1 = sign0;
  absolute1 = absolute0;
  lead_zero0 = 0;
  top_bit = 0x80000000;
  for(i=0; i<32; i++){
    if((top_bit & absolute0) > 0){
      break;
    }
    else{
      lead_zero0++;
      top_bit >>= 1;
    }
  }
  lead_zero1 = lead_zero0;
  full_manti = absolute0 << lead_zero0;

  // stage 3
  if(lead_zero1 == 32){
    exp = 0;
  }
  else{
    exp = 158-lead_zero1;
  }

  if(lead_zero1 <= 8){
    if(((full_manti & (1 << 8)) == 0 &&
	(full_manti & (1 << 7)) > 0 &&
	(full_manti & 0x7f) > 0) ||
       ((full_manti & (1 << 8)) > 0 &&
	(full_manti & (1 << 7)) > 0)) carry = 1;
    else carry = 0;
    manti = (absolute1 >> (8 - lead_zero1));
    if(carry > 0){
      frac = (manti+1) & 0x7fffff;
      if((manti & 0x7fffff) == 0x7fffff){
	exp += 1;
      }
    }
    else{
      frac = manti & 0x7fffff;
    }
  }
  else{
    manti = (absolute1 << (lead_zero1 - 8));
    frac = manti & 0x7fffff;
  }

  result = sign1 | (exp << 23) | frac;

  /*
  printf("leading zero: %d\n", lead_zero0);
  printf("exp : 0x%x\n",exp);
  printf("frac: 0x%08x\n", frac);
  printf("result: 0x%08x\n", result);
  */
  return result;
}
