
/*
先に例外処理をして、その後wikiにあるファイルと同じ手順でやりました。
*/


#include <stdio.h>

void printbin(uint32_t x) {
    int i;
    for (i = 31; i >= 0; --i) {
        printf("%d", (x >> i) & 1);
        if (i == 31 || i == 23) printf(" ");
    }
    printf("\n");
}

/*
uint32_t getsign(uint32_t a){
  return a>>31;
}
uint32_t getexp(uint32_t a){
  a= a>>23;
  return a & ((1<<8)-1);
}
uint32_t getfrac(uint32_t a){
  return a & ((1<<23)-1);
}
uint32_t geth(uint32_t a){
  return (1<<12) | ((a>>11) & ((1<<13)-1));
}
uint32_t getl(uint32_t b){
  return a & ((1<<12) -1);
}
引数増やしてまとめた↓*/


#include <stdint.h>

uint32_t getbits(uint32_t a,uint32_t x,uint32_t y){
  /*aのxbit目からybit目を返す
   expなら(a,30,23)と渡す*/
  a=a<<(31-x);
  a=a>>(y+31-x);
  return a;  
}


uint32_t fmul(uint32_t a, uint32_t b){

  uint32_t aexp,afrac,ah,al;
  uint32_t bexp,bfrac,bh,bl;

  uint32_t frac;
  uint32_t exp;
  uint32_t sign=(a>>31)^(b>>31);


  /*NaNのある計算*/

  aexp=getbits(a,30,23);
  afrac=getbits(a,22,0);
  bexp=getbits(b,30,23);
  bfrac=getbits(b,22,0);
  /*∞のある計算*/
  if (aexp==255){
    if (bexp==0 && bfrac==0){
      exp=255;
      frac=1;
      goto END;
    }
    exp=255;
    frac=0;
    goto END;
  }
  if (bexp==255){
    if (aexp==0 && afrac==0){
      exp=255;
      frac=1;
      goto END;
    }
    exp=255;
    frac=0;
    goto END;
  }

  /*0のある計算*/
  if ((aexp==0 && afrac==0) ||(bexp==0 && bfrac==0)){
    exp=0;
    frac=0;
    goto END;
  }
  /*非正規化数のある計算*/
  if (aexp==0 || bexp==0){
    exp=0;
    frac=1;
    goto END;

  }

  /*以下通常*/
  
  ah=getbits(afrac,22,11);
  al=getbits(afrac,10,0);
  bh=getbits(bfrac,22,11);
  bl=getbits(bfrac,10,0);
  exp=aexp+bexp;
  /*ここからaexp,bexp,afrac,bfracは使わない*/
  

  if (127>exp) {
/*本当は非正規化数*/
    frac=0;
    exp=0;
    goto END;
  }
  /*↑符号に注意して訂正する*/
  exp =exp -127;
  if (exp>254) {
    exp=255;
    frac=0;
    goto END;
  }

  ah += 1<<12;
  bh += 1<<12;
  frac= (ah*bh)+((ah*bl)>>11)+((al*bh)>>11)+2;

  if (frac>(1<<25)) {
    /*桁上がりする場合*/
    exp +=1;
    if (exp==255) {
    exp=255;
    frac=0;
    goto END;
    }

    frac=getbits(frac,24,2);
  }else{
    if (exp==0){
  /*本当は非正規化数*/
      frac=0;
      goto END;
    }
    frac=getbits(frac,23,1);
    
  /*この-1がなんなのかわかっていないので考えておく*/
  }

 END:
  return sign<<31| exp<<23|frac;
    

}
