#include <stdio.h>


#include <stdint.h>
uint32_t getbits(uint32_t a,uint32_t x,uint32_t y){
  a=a<<(31-x);
  a=a>>(y+31-x);
  return a;  
}

uint32_t itof(uint32_t a){
  
  
  uint32_t sign,exp,frac;
  sign=getbits(a,31,31);
  if (sign==1){
   a=1+(~a);
	
  }
  if (getbits(a,30,30)==1){
    exp=157;
    frac=(getbits(a,29,0)>>7) +getbits(a,6,6);
    if (getbits(frac,23,23)==1){
      exp=exp+1;
    }
  }else if (getbits(a,29,29)==1){
    exp=156;
    frac=(getbits(a,28,0)>>6) +getbits(a,5,5);
    if (getbits(frac,23,23)==1){
      exp=exp+1;
    }
  }else if (getbits(a,28,28)==1){
    exp=155;
    frac=(getbits(a,27,0)>>5) +getbits(a,4,4);
    if (getbits(frac,23,23)==1){
      exp=exp+1;
    }
  }else if (getbits(a,27,27)==1){
    exp=154;
    frac=(getbits(a,26,0)>>4) +getbits(a,3,3);
    if (getbits(frac,23,23)==1){
      exp=exp+1;
    }
  }else if (getbits(a,26,26)==1){
    exp=153;
    frac=(getbits(a,25,0)>>3) +getbits(a,2,2);
    if (getbits(frac,23,23)==1){
      exp=exp+1;
    }
  }else if (getbits(a,25,25)==1){
    exp=152;
    frac=(getbits(a,24,0)>>2) +getbits(a,1,1);
    if (getbits(frac,23,23)==1){
      exp=exp+1;
    }
  }else if (getbits(a,24,24)==1){
    exp=151;
    frac=getbits(a,23,1) +getbits(a,0,0);
    if (getbits(frac,23,23)==1){
      exp=exp+1;
    }
    /*この辺から上は違ってくるけど偶数丸めか四捨五入かの違いっぽい*/
  }else if (getbits(a,23,23)==1){
    exp=150;
    frac=getbits(a,22,0);
  }else if (getbits(a,22,22)==1){
    exp=149;
    frac=getbits(a,21,0)<<1;   
  }else if (getbits(a,21,21)==1){
    exp=148;
    frac=getbits(a,20,0)<<2;
  }else if (getbits(a,20,20)==1){
    exp=147;
    frac=getbits(a,19,0)<<3;
  }else if (getbits(a,19,19)==1){
    exp=146;
    frac=getbits(a,18,0)<<4;
  }else if (getbits(a,18,18)==1){
    exp=145;
    frac=getbits(a,17,0)<<5;
  }else if (getbits(a,17,17)==1){
    exp=144;
    frac=getbits(a,16,0)<<6;
  }else if (getbits(a,16,16)==1){
    exp=143;
    frac=getbits(a,15,0)<<7;
  }else if (getbits(a,15,15)==1){
    exp=142;
    frac=getbits(a,14,0)<<8;
  }else if (getbits(a,14,14)==1){
    exp=141;
    frac=getbits(a,13,0)<<9;
  }else if (getbits(a,13,13)==1){
    exp=140;
    frac=getbits(a,12,0)<<10;
  }else if (getbits(a,12,12)==1){
    exp=139;
    frac=getbits(a,11,0)<<11;
  }else if (getbits(a,11,11)==1){
    exp=138;
    frac=getbits(a,10,0)<<12;
  }else if (getbits(a,10,10)==1){
    exp=137;
    frac=getbits(a,9,0)<<13;
  }else if (getbits(a,9,9)==1){
    exp=136;
    frac=getbits(a,8,0)<<14;
  }else if (getbits(a,8,8)==1){
    exp=135;
    frac=getbits(a,7,0)<<15;
  }else if (getbits(a,7,7)==1){
    exp=134;
    frac=getbits(a,6,0)<<16;
  }else if (getbits(a,6,6)==1){
    exp=133;
    frac=getbits(a,5,0)<<17;
  }else if (getbits(a,5,5)==1){
    exp=132;
    frac=getbits(a,4,0)<<18;
  }else if (getbits(a,4,4)==1){
    exp=131;
    frac=getbits(a,3,0)<<19;
  }else if (getbits(a,3,3)==1){
    exp=130;
    frac=getbits(a,2,0)<<20;
  }else if (getbits(a,2,2)==1){
    exp=129;
    frac=getbits(a,1,0)<<21;
  }else if (getbits(a,1,1)==1){
    exp=128;
    frac=getbits(a,0,0)<<22;
  }else if (getbits(a,0,0)==1){
    exp=127;
    frac=0;
  }else{
    exp=0;
    frac=0;
  }

  return sign<<31|exp<<23|getbits(frac,22,0);


}

