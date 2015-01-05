#include<stdint.h>
#include<stdio.h>

uint32_t sign(uint32_t a){
  return a & 0x80000000;
}

uint32_t expo(uint32_t a){
  return a & 0x7f800000;
}

uint32_t frac(uint32_t a){
  return a & 0x007fffff;
}

/*切り捨て*/

uint32_t fadd(uint32_t a, uint32_t b){
  uint32_t calc;
  uint32_t sign_0, exp_dif, exp_0, big_frac, sml_frac;
  uint32_t sign_1, exp_1, frac_1;
  uint32_t lead_zero, tmp;
  uint32_t exp_, frac_;

  calc = sign(a) ^ sign(b);
  if((a & 0x7fffffff) > (b & 0x7fffffff)){
    sign_0 = sign(a);
    exp_dif = (expo(a) - expo(b)) >> 23;
    exp_0 = expo(a);
    big_frac = (0x00800000 | frac(a));
    if(expo(b) != 0){
      if(exp_dif < 32){
	sml_frac = ((0x00800000 | frac(b)) >> exp_dif);
      }
      else{
	sml_frac = 0;
      }
    }
    else{
      sml_frac = 0;
    }
  }
  else{
    sign_0 = sign(b);
    exp_dif = (expo(b) - expo(a)) >> 23;
    exp_0 = expo(b);
    big_frac = 0x00800000 | frac(b);
    if(expo(a) != 0){
      if(exp_dif < 32){
	sml_frac = ((0x00800000 | frac(a)) >> exp_dif);
      }
      else{
	sml_frac = 0;
      }
    }
    else{
      sml_frac = 0;
    }
  }


  if(calc == 0){
    frac_1 = big_frac + sml_frac;
  }
  else{
    frac_1 = big_frac - sml_frac;
  }

  lead_zero = 0;
  tmp = (1 << 24);
  while(tmp > 0){
    if((tmp & frac_1) > 0) break;
    tmp >>= 1;
    lead_zero++;
  }
  sign_1 = sign_0;
  exp_1 = exp_0;

  if(exp_1 != 0x7f800000){
    exp_ = exp_1 - (lead_zero << 23) + 0x00800000;
  }
  else{
    exp_ = exp_1;
  }

  frac_ = (frac_1 << lead_zero);

  /*
  printf("exp_dif   %08x\n", exp_dif);
  printf("exp_0     %08x\n", exp_0);
  printf("big_frac  %08x\n", big_frac);
  printf("sml_frac  %08x\n", sml_frac);
  printf("frac_1    %08x\n", frac_1);
  printf("lead_zero %08x\n", lead_zero);
  printf("exp_      %08x\n", exp_);
  printf("frac_     %08x\n", frac_);
  */

  return sign_1 | exp_ | frac(frac_ >> 1);
}
