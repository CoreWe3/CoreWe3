#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define INFILE "finv_table2048.txt"

static char finv_table[2048][40];
static int read_finv_table = 0;

static uint32_t downto(uint32_t i,int high,int low){
  int lsh = 31 - high;
  int rsh = lsh + low;
  i <<= lsh;
  i >>= rsh;
  return i;
}

static void init_tlb(){
  int i;
  FILE *fp = fopen(INFILE,"r");
  char str[40];
  if(fp == NULL){
    printf("cannot open\n");
    exit(1);
  }
  for(i=0;i<2048;i++){
    if (fscanf(fp,"%s",str) != 1) exit(1);
    strcpy(finv_table[i],str);
  }
  fclose(fp);
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
  return (uint32_t)(i & ((1ll << 32) - 1));
}

static uint32_t make_ans(uint32_t sign,uint32_t exp,uint32_t mant){
  sign <<= 31;
  exp <<= 23;
  return sign | exp | mant;
}

uint32_t finv0(uint32_t i){
  int index = downto(i,22,12);
  long long unsigned int yd;
  uint32_t ydtemplow,y,ymant,d;
  if(read_finv_table == 0){
    init_tlb();
  }
  yd = binarytoullint(finv_table[index]);
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
  int index = downto(i,22,12);
  int flag1;
  long long unsigned int yd = binarytoullint(finv_table[index]);
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

/*
uint32_t finv2(uint32_t i){
*/
uint32_t finv(uint32_t i){
  int index = (i >> 12) & 0x7ff; // 11bit
  double a0 = (double)((1 << 11) | index);
  double x0 = pow(2.0, 11.0)/a0 + pow(2.0, 11.0)/(a0+1.0);
  double da = x0 * x0 / 2.0 * pow(2.0, 12.0);
  double db = x0 * pow(2.0, 24.0) - a0 * x0 * x0 * pow(2.0, 11.0);
  uint32_t ua = (uint32_t)da & 0x1fff;// 13bit
  uint32_t ub = (uint32_t)db & 0x7fffff; // 23bit
  uint32_t sig = (i & (1 << 31)); // 1bit
  uint32_t ex = (i >> 23) & 0xff; // 8bit
  uint32_t x = i & 0xfff; // 12bit
  uint32_t frac = ub - ((ua * x) >> 12); // 23bit

  ex = ex > 253 ? 0 : 253-ex;
  return sig | (ex << 23) | (frac & 0x7fffff);
}

void finv2_table(){
  int index; // 11bit
  FILE *f = fopen("finv_table.dat", "w");

  for(index=0; index<=0x7ff; index++){
    double a0 = (double)((1 << 11) | index);
    double x0 = pow(2.0, 11.0)/a0 + pow(2.0, 11.0)/(a0+1.0);
    double da = x0 * x0 / 2.0 * pow(2.0, 12.0);
    double db = x0 * pow(2.0, 24.0) - a0 * x0 * x0 * pow(2.0, 11.0);
    long long int ua = (long long int)da & 0x1fff; // 13bit
    long long int ub = (long long int)db & 0x7fffff; // 23bit
    long long int data = ua << 23 | ub;
    int digit;
    char binary_str[37];
    for(digit=0; digit<36; digit++){
      binary_str[35-digit] = '0' + ((data >> digit) & 1);
    }
    binary_str[36] = '\0';
    fprintf(f, "%s\n", binary_str);
  }
  fclose(f);
}
