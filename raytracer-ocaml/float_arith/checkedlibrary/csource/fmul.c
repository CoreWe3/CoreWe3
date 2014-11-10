


#include <stdio.h>

#include <stdint.h>

/*
仕様まとめ
NaNは入力として想定していない。

∞*なにか=∞
0や非正規化数*なにか=0

それ以外：
先人の資料通り。

実装要件を読むに、0や∞の処理も必要ないようなのでカットすれば、大分短くなるかも。
*/

uint32_t fmul(uint32_t a, uint32_t b){
  uint32_t r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15;
  uint32_t aexp,afrac,ah,al;
  uint32_t bexp,bfrac,bh,bl;

  uint32_t frac;
  uint32_t exp;
  r10=(a>>31)^(b>>31);


  /*使うのは1,24,9*/
  r13=1;
  r14=24;
  r15=9;
  r12=255;
  r3=a;
  r4=b;
  r5=r3<<r13;
  r5=r5>>r14;
  r6=r3<<r15;
  r6=r6>>r15;

  r7=r4<<r13;
  r7=r7>>r14;
  r8=r4<<r15;
  r8=r8>>r15;
  /*aexp=r5,afrac=r6,bexp=r7,bfrac=r8*/
  /*NaNは入力としてこないはず*/

  /*∞のある計算*/
  if (r5==r12){
 /*
    if (r7==0 && r8==0){
      r13=255;
      r9=1;
      goto END;
    }
  */
    r13=255;
    r9=0;
    goto END;
  }
  if (r7==r12){
 /*
    if (r5==0 && r6==0){
      r13=255;
      r9=1;
      goto END;
    }

 */
    r13 =255;
    r9 =0;
    goto END;
  }

  /*非正規化数や0がある場合*/
  if (r5==0 || r7==0){
    r13=0;
    r9=0;
    goto END;

  }

  /*以下通常*/
  r13=r5+r7;
  /*r13=exp*/

  /*r3,4は使ってよい*/
  r14=20;
  r11=21;
  r3=r6<<r15;
  r3=r3>>r14;
  /*r3=ah*/
  r4=r6<<r11;
  r4=r4>>r11;
  /*r4=al*/
  /*r5,r6も使ってよい*/
  
  r5=r8<<r15;
  r5=r5>>r14;
  r6=r8<<r11;
  r6=r6>>r11;
  /*r5=bh,r6=bl*/
  r14=6;
  r8=127;
  if (r8>r13) {
    r9=0;
    r13=0;
    goto END;
  }

  r13 =r13 - r8;

  r11=254;
  if (r13>r11) {
    r9=0;
    r13=255;
    goto END;
  }
  r8=64;
  r8=r8<<r14;
  /*r13=1<<12*/
  r3 += r8;
  r5 += r8;
  r9=r3*r5;/*ここ*/
  r7=r4*r5;
  r11=11;
  r7=r7>>r11;
  r9=r9+r7;
  r7=r3*r6;
  r7=r7>>r11;
  r9=r9+r7;
  r9=r9+2;
  r7=13;
  r8=r8<<r7;
  if (r9>r8) {
    /*桁上がりする場合*/
    r13 +=1;
    if (r13==r12) {
    r9=0;
    goto END;
    }
    r14=7;
    r9=r9<<r14;
    r9=r9>>r15;

  }else{
    if (r13==0){
  /*本当は非正規化数も考える*/
      r9=0;
      goto END;
    }
    r14=8;
    r9=r9<<r14;
    r9=r9>>r15;
  }

  END:
 
  r14=23;
  r15=31;
  r13=r13<<r14;
  r10=r10<<r15;
  r3=r13+r10;
  r3=r3+r9;
  return r3;
}
