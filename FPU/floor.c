#include <stdio.h>
#include <stdint.h>

uint32_t getbits(uint32_t a,uint32_t x,uint32_t y){
  a=a<<(31-x);
  a=a>>(y+31-x);
  return a;  
}

uint32_t  myfloor(uint32_t a){
  uint32_t exp,sign;
  uint32_t tmp,flag,flag2,x;
  x=a;
  sign=getbits(a,31,31);
  exp=getbits(a,30,23);
  if (exp==149){


    if (getbits(a,0,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<1;
      if (getbits(a,22,1)==(1<<22)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,1)<<1;

  } else if(exp==148){
    
    if (getbits(a,1,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<2;
      if (getbits(x,22,2)==(1<<21)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,2)<<2;

  }else if(exp==147){


    if (getbits(a,2,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<3;
      if (getbits(x,22,3)==(1<<20)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,3)<<3;

  } else if(exp==146){


    if (getbits(a,3,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<4;
      if (getbits(x,22,4)==(1<<19)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,4)<<4;

  } else if(exp==145){


    if (getbits(a,4,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<5;
      if (getbits(x,22,5)==(1<<18)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,5)<<5;

  } else if(exp==144){
    
    
    if (getbits(a,5,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<6;
      if (getbits(x,22,6)==(1<<17)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,6)<<6;

  }else if(exp==143){

    if (getbits(a,6,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<7;
      if (getbits(x,22,7)==(1<<16)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,7)<<7;

  } else if(exp==142){


    if (getbits(a,7,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<8;
      if (getbits(x,22,8)==(1<<15)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,8)<<8;

  } else if(exp==141){


    if (getbits(a,8,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<9;
      if (getbits(x,22,9)==(1<<14)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,9)<<9;

  } else if(exp==140){


    if (getbits(a,9,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<10;
      if (getbits(x,22,10)==(1<<13)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,10)<<10;

  } else if(exp==139){

    if (getbits(a,10,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<11;
      if (getbits(x,22,11)==(1<<12)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,11)<<11;


  } else if(exp==138){

    if (getbits(a,11,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<12;
      if (getbits(x,22,12)==(1<<11)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,12)<<12;

  } else if(exp==137){
    
    if (getbits(a,12,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<13;
      if (getbits(x,22,13)==(1<<10)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,13)<<13;

  } else if(exp==136){


    if (getbits(a,13,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<14;
      if (getbits(x,22,14)==(1<<9)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,14)<<14;


  } else if(exp==135){


    if (getbits(a,14,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<15;
      if (getbits(x,22,15)==(1<<8)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,15)<<15;


  } else if(exp==134){

    if (getbits(a,15,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<16;
      if (getbits(x,22,16)==(1<<7)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,16)<<16;


  } else if(exp==133){

    if (getbits(a,16,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<17;
      if (getbits(x,22,17)==(1<<6)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,17)<<17;

  } else if(exp==132){
    if (getbits(a,17,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<18;
      if (getbits(x,22,18)==(1<<5)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,18)<<18;
  } else if(exp==131){

    if (getbits(a,18,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<19;
      if (getbits(x,22,19)==(1<<4)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }

    tmp=getbits(a,31,19)<<19;
  } else if(exp==130){

    if (getbits(a,19,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<20;
      if (getbits(x,22,20)==(1<<3)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,20)<<20;
  } else if(exp==129){
    if (getbits(a,20,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<21;
      if (getbits(x,22,21)==(1<<2)-1 ){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,21)<<21;
  } else if(exp==128){
    if (getbits(a,21,0)==0){
      flag=0;
      flag2=0;
    }else{
      flag=1<<22;
      if (getbits(x,22,22)==1){
	flag2=1;
      }else{
	flag2=0;	
      }
    }
    tmp=getbits(a,31,22)<<22;

  } else if(exp==127){

    if (getbits(a,22,0)==0){
      flag2=0;
    }else{
      flag2=1;
    }
    flag=0;
    tmp=getbits(a,31,23)<<23;

  } else if(127>exp){

	flag=0;
	flag2=0;
    if (sign==1){
      if (getbits(a,30,0)==0){
	tmp=sign<<31;
      }else{
	tmp=(sign<<31) + (127<<23);
      }
    }else{
    tmp=0;
    }
  }else{
    tmp=a; 
    flag=0;
    flag2=0;
  }

  if (tmp>>31==1){
    if (flag2==1){

      return ((getbits(tmp,31,23)+1)<<23);
    }else{
      return tmp + flag;
    }
    
  }else{
    return tmp;

  }

}
