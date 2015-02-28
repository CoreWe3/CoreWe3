#include <stdio.h>


#include <stdint.h>
uint32_t getbits(uint32_t a,uint32_t x,uint32_t y){
  a=a<<(31-x);
  a=a>>(y+31-x);
  return a;  
}
uint32_t ftoui(float a) {
    uint32_t *p;
    p = (uint32_t *) &a;
    return *p;
}

float uitof(uint32_t a) {
    float *p;
    p = (float *) &a;
    return *p;
}

int uitoi(uint32_t a) {
    int *p;
    p = (int *) &a;
    return *p;
}


uint32_t itoui(int a) {
    uint32_t *p;
    p = (uint32_t *) &a;
    return *p;
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

int itof_judge(uint32_t a) {
    int ia, ia_abs;
    uint32_t ans, exp;
    double bnd, err;
    ia = uitoi(a);
    ia_abs = abs(ia);
    if (ia_abs < (1 << 24)) {
	bnd = 0.0; // >2^24まではexact
    } else {
	for (exp = 30; exp > 23; exp--) { if (ia_abs >> exp != 0) break; }
	exp += 103;
	bnd = (double) uitof(exp << 23);//<=2^24以降は、最下位bitの半分以内の誤差(0捨1入)
    }
    ans = itof(a);
    err = fabs((double) ia - (double) uitof(ans));
    if(err > bnd) {
	printf("%08x %d\n", a, ia);
	exit(1);
	return 0;
    }
    return 1;
}

int ftoi_judge(uint32_t a) {
    double bnd = 1.0, err;
    float fa;
    uint32_t ans;
    ans = ftoi(a);
    fa = uitof(a);
    err = fabs((double)fa - (double)uitoi(ans));
    if(err > bnd) {
	printf("%08x %e\n", a, fa);
	exit(1);
	return 0;
    }
    return 1;
}

void printbin2(uint32_t x) {
    int i;
    for (i = 31; i >= 0; --i) {
        printf("%d", (x >> i) & 1);
        if (i == 31 || i == 23) printf(" ");
    }
    printf("\n");
}
int main(){
  union F{uint32_t u;float f;}x,y,z;
  uint32_t k;
    uint32_t a, a_max;
 
    printf("itof\n"); 
     itof_judge(0); 
     a_max = 0x80000000; 
     for(a = 1; a < a_max; a++) { 
     	itof_judge(a); 
     	itof_judge(itoui(-uitoi(a))); 
     } 

  printf("%d\n",k);
  return 0;
}
