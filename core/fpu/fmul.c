#include<stdint.h>
#include<stdio.h>

uint32_t fmul(uint32_t a, uint32_t b){
  uint32_t hh, hl, lh, exp_0, sign_0;
  uint32_t frac_, exp_1, exp_2, sign_1;

  hh = (0x1000 | (0xfff & (a >> 11))) * (0x1000 | (0xfff & (b >> 11)));
  hl = (0x1000 | (0xfff & (a >> 11))) * (0x7ff & b);
  lh = (0x7ff & a) * (0x1000 | (0xfff & (b >> 11)));
  exp_0 = (0xff & (a >> 23)) + (0xff & (b >> 23)) + 129;
  sign_0 = (0x80000000 & a) ^ (0x80000000 & b);

  frac_ = hh + (hl >> 11) + (lh >> 11) + 2;
  exp_1 = exp_0;
  exp_2 = exp_0+1;
  sign_1 = sign_0;

  /*
  printf("hh     %x\n", hh);
  printf("hl     %x\n", hl);
  printf("lh     %x\n", lh);
  printf("exp_0  %x\n", exp_0);
  printf("sign_0 %x\n", sign_0);
  printf("frac_  %x\n", frac_);
  printf("exp_1  %x\n", exp_1);
  printf("exp_2  %x\n", exp_2);
  printf("sign_1 %x\n", sign_1);
  */

  if((frac_ & (1 << 25)) == 0){
    if((exp_1 & (1 << 8)) == 0){
      if((exp_1 & (1 << 9)) == 0){
	return sign_1;
      }
      else{
	return sign_1 | 0xff << 23;
      }
    }
    else{
      return sign_1 | ((0xff & exp_1) << 23) |
	(0x7fffff & (frac_ >> 1));
    }
  }
  else{
    if((exp_2 & (1 << 8)) == 0){
      if((exp_2 & (1 << 9)) == 0){
	return sign_1;
      }
      else{
	return sign_1 | 0xff << 23;
      }
    }
    else{
      return sign_1 | ((0xff & exp_2) << 23) |
	(0x7fffff & (frac_ >> 2));
    }
  }
}
