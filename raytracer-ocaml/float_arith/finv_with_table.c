#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define N 2048

typedef union u2f{
  uint32_t uuu;
  float fff;
}u2f;

static uint32_t downto(uint32_t i,int high,int low){
  int lsh = 31 - high;
  int rsh = lsh + low;
  i <<= lsh;
  i >>= rsh;
  return i;
}


static long long unsigned int binarytoullint(char *bin){
  long long unsigned int ret=0;
  long long unsigned int temp=1;
  int i=0;
  for(i=0;i<36;i++){
    if(bin[35-i]=='1'){
      ret += temp << i;
    }
  }
  return ret;
}

static uint32_t yllui2uint(long long unsigned int i){
  return i>>13;
}

static uint32_t lowllui2uint(long long unsigned int i){
  i <<= 32;
  i >>= 32;
  return (uint32_t)i;
}

static uint32_t make_ans(uint32_t sign,uint32_t exp,uint32_t mant){
  sign <<= 31;
  exp <<= 23;
  return sign | exp | mant;
}

static double make_a(double index,double next){
  return (1.0/index)*(1.0/next);
}

static double make_b(double index,double next){
  return (sqrt(1.0/index) + sqrt(1.0/next))*(sqrt(1.0/index) + sqrt(1.0/next))/2.0;
}

static char *uint2binary(uint32_t ui,int high,int low){
  char *ret = (char*)malloc(sizeof(char)*33);
  int i;
  for(i=0;i<32;i++){
    if((ui >> i) & 1u)
      ret[31-i] = '1';
    else
      ret[31-i] = '0';
  }
  ret[32] = '\0';
  char *temp = (char*)malloc(sizeof(char)*(high - low + 1 + 1));
  for(i=0;i<high-low+1;i++){
    temp[i] = ret[31 - high + i];
  }
  temp[i] = ret[32];
  free(ret);
  return temp;
}

static double make_y(double a,double b,double x){
  return ((-1) * a * x) + b;
}

static char tlb[2048][40];

static void make_table(){
  int i;
  double c = 1.0 / N;
  double index,next,a,b,y1,y2;
  uint32_t y1_mant,y2_mant,d;
  u2f y1u,y2u;
  for(i=0;i<N;i++){
    index = 1.0 + c * i;
    next = index + c;
    a = make_a(index,next);
    b = make_b(index,next);
    y1 = make_y(a,b,index);
    y2 = make_y(a,b,next);
    y1u.fff = (float)y1;
    y2u.fff = (float)y2;
    if(i == 0){
      y1_mant = 1 << 24;
    }
    else{
      y1_mant = (1 << 23) + downto(y1u.uuu,22,0);
    }
    y2_mant = (1 << 23) + downto(y2u.uuu,22,0);
    d = y1_mant - y2_mant;
    char *y2s,*ds;
    char str[70];
    y2s = uint2binary(y2_mant,22,0);
    ds = uint2binary(d,12,0);
    strcpy(str,y2s);
    strcat(str,ds);
    free(y2s);
    free(ds);
    strcpy(tlb[i],str);
  }
}
/*
void init_tlb(){
  int i;
  FILE *fp = fopen(INFILE,"r");
  char str[40];
  if(fp == NULL){
    printf("cannot open\n");
    exit(1);
  }
  for(i=0;i<N;i++){
    fscanf(fp,"%s",str);
    strcpy(tlb[i],str);
  }
  fclose(fp);
}
*/

static void init_tlb(){
  make_table();
}

int init_flag = 0;

uint32_t finv(uint32_t i){
  if(init_flag == 0){
    init_tlb();
    init_flag = 1;
  }
  int index = downto(i,22,12);
  long long unsigned int yd = binarytoullint(tlb[index]);
  uint32_t ydtemplow,y,ymant,d;
  ymant = yllui2uint(yd);
  y = (1 << 23) | ymant;
  ydtemplow = lowllui2uint(yd);
  d = downto(ydtemplow,12,0);
  uint32_t ans;
  uint32_t sign,exp,mant;
  sign = downto(i,31,31);
  if(downto(i,22,0) == 0){
    exp = 254 - downto(i,30,23);
  }else{
    exp = 253 - downto(i,30,23);
  }
  mant = y + ((d * ((1 << 12) - (downto(i,11,0)))) >> 12);
  ans = make_ans(sign,exp,downto(mant,22,0));
  return ans;
}

uint32_t finv1(uint32_t i){
  if(init_flag == 0){
    init_tlb();
    init_flag = 1;
  }
  int index = downto(i,22,12);
  int flag1;
  long long unsigned int yd = binarytoullint(tlb[index]);
  uint32_t manti_const, manti_grad, grad_tmp, d, stub;
  uint32_t sign,exp,frac,ans;
  //stage 1
  if(downto(i,22,0) == 0) flag1 = 0;
  else if(downto(i,11,0) == 0) flag1 = 1;
  else flag1 = 2;
  stub = 4096 - downto(i,11,0);
  //stage 2
  sign = downto(i,31,31);
  manti_const = yllui2uint(yd);
  d = downto(lowllui2uint(yd),12,0);
  if(flag1 == 0){
    exp = 254 - downto(i,30,23);
    manti_grad = d;
  }
  else if(flag1 == 1){
    exp = 253 - downto(i,30,23);
    manti_grad = d;
  }
  else{
    exp = 253 - downto(i,30,23);
    grad_tmp = d * stub;
    manti_grad = downto(grad_tmp,24,12);
  }

  //stage 3
  frac = manti_const + manti_grad;
  ans = make_ans(sign,exp,downto(frac,22,0));

  return ans;
}
