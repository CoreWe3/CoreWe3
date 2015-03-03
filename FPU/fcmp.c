#include<stdint.h>

uint32_t fcmp(uint32_t a, uint32_t b){
  uint32_t sign = 0x80000000;
  uint32_t exp  = 0x7f800000;

  if((a & exp) == 0 && (b & exp) == 0){  //both 0
    return 0;
  }
  else if(a == b){ //equal
    return 0;
  }
  else if((int)a > (int)b){
    if((a & sign) > 0 && (b & sign) > 0){
      return 0xffffffff;
    }
    else{
      return 1;
    }
  }
  else{
    if((a & sign) > 0 && (b & sign) > 0){
      return 1;
    }
    else{
      return 0xffffffff;
    }
  }

  return 0;
}
