

#include <stdio.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <stdint.h>

#define f_max (((1<<7)-1)<<24)
#define f_min (((1<<9)-1)<<24)
#define nom_min (1<<23)
uint32_t getbits(uint32_t a,uint32_t x,uint32_t y){
  aのxbit目からybit目を返す
   expなら(a,30,23)と渡す
  a=a<<(31-x);
  a=a>>(y+31-x);
  return a;  
}
uint32_t fmul(uint32_t a,uint32_t b){
/*仕様ややっていることは同ファイル内のfmulv2と同じです*/
  uint32_t r3=a;
  uint32_t r4=b;
  uint32_t r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18;
  uint32_t r19,r20,r21,r22,r23,r24,r25,r26,r27,r28,r29,r30,r31,r32,r33,r34,r35,r36,r37,r38,r39,r40,r41,r42;
  /*r3~r8はmulが使う*/
  r15=r3>>31;
  r16=r4>>31;
  r15=r15^r16; /*r15=sign*/
  	    /*r16=exp,r17=frac*/
  r18=r3<<1;
  r19=r4<<1;
  r18=r18>>24;
  r19=r19>>24;
  r20=r3<<9;
  r21=r4<<9;
  r20=r20>>20;
  r21=r21>>20;
  r22=r3<<21;
  r23=r4<<21;
  r22=r22>>21;
  r23=r23>>21;
  /*r18=aexp,r19=bexp,r20=ah,r21=bh,r22=al,r23=bl*/
  r16=r18+r19;
  r20=r20+(1<<12);
  r21=r21+(1<<12);
  /*ここまでOK*/
  r3=r20;
  r4=r21;
  r3=r3*r4;
  r17=r3+2;
  r3=r20;
  r4=r23;
  r3=r3*r4;
  r3=r3>>11;
  r17=r3+r17;
  r3=r21;
  r4=r22;
  r3=r3*r4;
  r3=r3>>11;
  r17=r17+r3;
  /*ok*/
  r30=(1<<25);
  if (r17>=r30){
  r16=r16+1;
  r17=r17<<7;
  r17=r17>>9;
  }else{
  r17=r17<<8;
  r17=r17>>9;
  }
  r30=127;
  if (r16<=r30){
     r3=r15<<31;
     return r3;
  }else{
     r16=r16-r30;
  }
  r3=r15<<31;
  r16=r16<<23;
  r3=r3+r16;
  r3=r3+r17;
  return r3;

}
uint32_t fmulv2(uint32_t a, uint32_t b){

  uint32_t aexp,afrac,ah,al;
  uint32_t bexp,bfrac,bh,bl;

  uint32_t frac;
  uint32_t exp;
  uint32_t sign=(a>>31)^(b>>31);

  aexp=getbits(a,30,23);
  bexp=getbits(b,30,23);
  bfrac=getbits(b,22,0);
  afrac=getbits(a,22,0);
  ah=getbits(afrac,22,11);
  al=getbits(afrac,10,0);
  bh=getbits(bfrac,22,11);
  bl=getbits(bfrac,10,0);
  exp=aexp+bexp;
  ah += 1<<12;
  bh += 1<<12;

  frac= (ah*bh)+((ah*bl)>>11)+((al*bh)>>11)+2;
  if (frac>=(1<<25)) {
    exp +=1;
    frac=getbits(frac,24,2);
  }else{
    frac=getbits(frac,23,1);
  }
 if (exp<=127){
	exp=0;
	frac=0;
 }else{
	exp-=127;
 }
 return sign<<31| exp<<23|frac;
    

}

