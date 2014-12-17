/*
fmul.vhdと同様の実装で、以前のfmulとは少し違う可能性があります
誤差については、x86とのulp差が1以下に収まっていることを確認しました。

*/

#include <stdio.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
uint32_t getbits(uint32_t a,uint32_t x,uint32_t y){
  a=a<<(31-x);
  a=a>>(y+31-x);
  return a;  
}
uint32_t fmul(uint32_t a,uint32_t b){
  uint32_t exp,exp2,exp3;
  uint32_t aexp,afrac,ah,al;
  uint32_t bexp,bfrac,bh,bl;
  uint32_t sign;
  uint32_t hh;
  uint32_t hl;
  uint32_t lh;
  uint32_t fractmp,frac;
  aexp=getbits(a,30,23);
  bexp=getbits(b,30,23);
  ah=getbits(a,22,11);
  al=getbits(a,10,0);
  bh=getbits(b,22,11);
  bl=getbits(b,10,0);
  ah += 1<<12;
  bh += 1<<12;

  /*stage1*/
  exp= aexp+bexp+129;
  hh=ah*bh;
  hl=ah*bl;
  lh=al*bh;
  sign=(a>>31)^(b>>31);

  /*stage2*/
  fractmp=hh+(hl>>11)+(lh>>11)+2;
  exp2=exp+1;

  /*stage3*/ 
  if (getbits(exp,8,8)==0){
      return (sign<<31);
  }else{    
  if (fractmp>=(1<<25)) {
    frac=getbits(fractmp,24,2);
    exp3=getbits(exp2,7,0);
  }else{
    frac=getbits(fractmp,23,1);
    exp3=getbits(exp,7,0);
  }
  return sign<<31 | exp3<<23 | frac;
  }
}
