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

uint32_t shift_right_round(uint32_t a, uint32_t n){
  uint32_t shift_r, shift_l;

  if(n < 32) shift_r = a >> n;
  else shift_r = 0;
  if(28 - n < 32) shift_l = (a << (28 - n)) & 0xfffffff;
  else shift_l = 0;

  if(shift_l == 0){
    return shift_r & ~1;
  }
  else{
    return shift_r | 1;
  }

  return 0;
}

uint32_t fadd(uint32_t a, uint32_t b){
  uint32_t calc;
  uint32_t sign_0, exp_dif, exp_0, big_frac, sml_frac;
  uint32_t sign_1, exp_1, frac_1;
  uint32_t lead_zero, tmp;
  uint32_t frac_2;
  uint32_t exp_, frac_;

  calc = sign(a) ^ sign(b);
  if((a & 0x7fffffff) > (b & 0x7fffffff)){
    sign_0 = sign(a);
    exp_dif = (expo(a) - expo(b)) >> 23;
    exp_0 = expo(a);
    big_frac = (0x00800000 | frac(a)) << 3;
    if(expo(b) != 0){
      sml_frac = shift_right_round((0x00800000 | frac(b)) << 3, exp_dif);
    }
    else{
      sml_frac = 0;
    }
  }
  else{
    sign_0 = sign(b);
    exp_dif = (expo(b) - expo(a)) >> 23;
    exp_0 = expo(b);
    big_frac = (0x00800000 | frac(b)) << 3;
    if(expo(a) != 0){
      sml_frac = shift_right_round((0x00800000 | frac(a)) << 3, exp_dif);
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
  tmp = (1 << 27);
  while(tmp > 0){
    if((tmp & frac_1) > 0) break;
    tmp >>= 1;
    lead_zero++;
  }
  sign_1 = sign_0;
  exp_1 = exp_0;



  if(lead_zero > 26){
    exp_ = 0;
  }
  else if(exp_1 != 0x7f800000){
    exp_ = exp_1 - (lead_zero << 23) + 0x00800000;
  }
  else{
    exp_ = exp_1;
  }

  frac_2 = (frac_1 << lead_zero);
  if((frac_2 & 0x18) == 0 | (frac_2 & 0x1f) == 0x8 |
     (frac_2 & 0x18) == 0x10){
    frac_ = frac_2;
  }
  else{
    frac_ = frac_2 + 0x10;
  }


/*  printf("exp_dif   %08x\n", exp_dif);
  printf("exp_0     %08x\n", exp_0);
  printf("big_frac  %08x\n", big_frac);
  printf("sml_frac  %08x\n", sml_frac);
  printf("frac_1    %08x\n", frac_1);
  printf("lead_zero %08x\n", lead_zero);
  printf("exp_      %08x\n", exp_);
  printf("frac_2    %08x\n", frac_2);
  printf("frac_     %08x\n", frac_);
*/
  return sign_1 | exp_ | frac(frac_ >> 4);
}
