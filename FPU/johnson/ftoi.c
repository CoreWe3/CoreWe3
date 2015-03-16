#include <stdio.h>


#include <stdint.h>
uint32_t getbits(uint32_t a,uint32_t x,uint32_t y){
  a=a<<(31-x);
  a=a>>(y+31-x);
  return a;  
}


uint32_t ftoi(uint32_t a){

  uint32_t exp,frac,sign;
  uint32_t keta;
  uint32_t lshift;
  uint32_t rshift;
  uint32_t x;
  exp=getbits(a,30,23);
  frac=getbits(a,22,0);
  sign=getbits(a,31,31);
  frac+=1<<23; 
  if (exp==150){
    x=frac;
  }else if( exp==151){
    x=frac<<1;
  }else if( exp==152){
    x=frac<<2;
  }else if( exp==153){
    x=frac<<3;
  }else if(exp==154){
    x=frac<<4;
  }else if(exp==155){
    x=frac<<5;
  }else if(exp==156){
    x=frac<<6;
  }else if(exp==157){
    x=frac<<7;
  }else if(exp==149){  
    x= (frac>>1)+getbits(frac,0,0);
  }else if(exp==148){    
    x= (frac>>2)+getbits(frac,1,1);
  }else if(exp==147){    
    x= (frac>>3)+getbits(frac,2,2);
  }else if(exp==146){    
  x = (frac>>4)+getbits(frac,3,3);
  }else if(exp==145){    
    x=(frac>>5)+getbits(frac,4,4);
  }else if(exp==144){    
    x=(frac>>6)+getbits(frac,5,5);
  }else if(exp==143){    
    x=(frac>>7)+getbits(frac,6,6);
  }else if(exp==142){    
    x=(frac>>8)+getbits(frac,7,7);
  }else if(exp==141){    
    x=(frac>>9)+getbits(frac,8,8);
  }else if(exp==140){    
    x=(frac>>10)+getbits(frac,9,9);
  }else if(exp==139){    
    x=(frac>>11)+getbits(frac,10,10);
  }else if(exp==138){    
    x=(frac>>12)+getbits(frac,11,11);
  }else if(exp==137){    
    x=(frac>>13)+getbits(frac,12,12);
  }else if(exp==136){  
    x=(frac>>14)+getbits(frac,13,13);
  }else if(exp==135){    
    x=(frac>>15)+getbits(frac,14,14);
  }else if(exp==134){    
    x=(frac>>16)+getbits(frac,15,15);
  }else if(exp==133){    
    x=(frac>>17)+getbits(frac,16,16);
  }else if(exp==132){    
    x=(frac>>18)+getbits(frac,17,17);
  }else if(exp==131){    
    x=(frac>>19)+getbits(frac,18,18);
  }else if(exp==130){    
    x=(frac>>20)+getbits(frac,19,19);
  }else if(exp==129){    
    x=(frac>>21)+getbits(frac,20,20);
  }else if(exp==128){    
    x=(frac>>22)+getbits(frac,21,21);
  }else if(exp==127){ 
    x=(frac>>23)+getbits(frac,22,22);
  }else if(exp==126){
 
    x= getbits(frac,23,23);
  }else{
    x=0;   
  }
  if (sign==0||x==0){
	return x;

  }else{
	return 1+(~x);
  }


}
