#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>

#define INFILE "new_sqrt_table.txt"

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

static int tlb_flag = 0;
static char tlb[2048][40];
static void init_tlb(){
  int i = 0;
  FILE *fp = fopen(INFILE,"r");
  char str[40];
  while(fscanf(fp,"%s",str) != EOF){
    strcpy(tlb[i],str);
    i++;
  }
  fclose(fp);
}

uint32_t fsqrt0(uint32_t i){
  uint32_t sign = 0;
  uint32_t i_exp = downto(i,30,23);
  uint32_t is_odd = downto(i,23,23);
  uint32_t exp;
  uint32_t one = 127;
  if(tlb_flag == 0){
    init_tlb();
    tlb_flag = 1;
  }
  if(downto(i,30,0) == 0){
    return i;
  }
  if(downto(i,31,31) == 1){
    return 0xffc00000;
  }
  if(i_exp >= one){
    exp = i_exp - one;
    exp >>= 1;
    exp += one;
  }else{
    exp = one - i_exp;
    exp += 1;
    exp >>= 1;
    exp = one - exp;
  }
  uint32_t index;
  if(is_odd == 1){
    index = downto(i,22,15);
  }else{
    index = downto(i,22,14) + 256;
  }
  long long unsigned int yd = binarytoullint(tlb[index]);
  uint32_t ydtemplow,y,ymant,d;
  ymant = yllui2uint(yd);
  y = (1 << 23) | ymant;
  ydtemplow = lowllui2uint(yd);
  d = (1 << 13) | downto(ydtemplow,12,0);
  uint32_t mant;
  if(is_odd == 1){
    mant = y - ((d * ((1 << 15) - (downto(i,14,0)))) >> 15);
  }else{
    if(downto(i,22,0) == (1 << 23) - 1){
      mant = downto(i,22,0);
    }else{
      mant = y - ((d * ((1 << 14) - (downto(i,13,0)))) >> 14);
    }
  }
  uint32_t ans = make_ans(sign,exp,downto(mant,22,0));
  return ans;
}

uint32_t fsqrt1(uint32_t i){
  uint32_t sign = 0;
  uint32_t is_odd = downto(i,23,23);
  uint32_t exp;
  uint32_t index;
  long long unsigned int yd;
  uint32_t ydtemplow;
  uint32_t mant;
  uint32_t constant, grad, stub;
  if(tlb_flag == 0){
    init_tlb();
    tlb_flag = 1;
  }


  if(downto(i,30,0) == 0){
    return i;
  }
  if(downto(i,31,31) == 1){
    return 0xffc00000;
  }

  exp = (downto(i,30,23)+127) >> 1;

  if(is_odd == 1){
    index = downto(i,22,15); // 8bit
  }else{
    index = downto(i,22,14) + 256; // 10bit
  }

  yd = binarytoullint(tlb[index]);
  constant = yllui2uint(yd);
  ydtemplow = lowllui2uint(yd);
  grad = (1 << 13) | downto(ydtemplow,12,0);

  if(is_odd == 1){
    stub = ((grad * ((1 << 15) - (downto(i,14,0)))) >> 15);
    mant = constant - stub;
  }else{
    if(downto(i,22,0) == (1 << 23) - 1){
      stub = 0;
      mant = downto(i,22,0);
    }else{
      stub = ((grad * ((1 << 14) - (downto(i,13,0)))) >> 14);
      mant = constant - stub;
    }
  }

  /*
  printf("index %x\n", index);
  printf("const %x\n", constant);
  printf("stub %x\n", stub);
  */

  return make_ans(sign,exp,downto(mant,22,0));
}

/*
uint32_t fsqrt2(uint32_t i){
*/
uint32_t fsqrt(uint32_t i){
  int index = (i >> 14) & 0x3ff; // 10bit
  double a0 = 1 << 9 | index; // 10bit
  double x0 = (index >> 9) ? (sqrt(2.0*a0) + sqrt(2.0*(a0+1.0))) * pow(2.0, -6.0) :
    (sqrt(a0) + sqrt(a0+1.0)) * pow(2.0, -5.0); // 1.0 <= x0 < 2.0
  double da = (index >> 9) ? pow(2.0, 12.0) / x0 : pow(2.0, 14.0) / (2.0 * x0);
  double db = (index >> 9) ? x0 * pow(2.0, 22.0) + a0 / x0 * pow(2.0, 13.0) :
    x0 * pow(2.0, 22.0) + a0 / x0 * pow(2.0, 14.0);
  uint32_t ua = (uint32_t)da & 0x1fff; // 13 bit
  uint32_t ub = (uint32_t)db & 0x7fffff; // 23bit
  uint32_t iexp = (i >> 23) & 0xff; // 8bit
  uint32_t ifrac = i & 0x3fff; //14bit
  uint32_t oexp = iexp == 0 ? 0 : (iexp + 127) >> 1;
  uint32_t ofrac = ((ua*ifrac) >> 13) + ub;

  return oexp << 23 | ofrac;
}

void fsqrt2_table(){
  int index; // 10bit
  FILE *f = fopen("fsqrt_table.dat", "w");

  for(index=0; index<=0x3ff; index++){
    double a0 = 1 << 9 | index; // 10bit
    double x0 = (index >> 9) ? (sqrt(2.0*a0) + sqrt(2.0*(a0+1.0))) * pow(2.0, -6.0) :
      (sqrt(a0) + sqrt(a0+1.0)) * pow(2.0, -5.0); // 1.0 <= x0 < 2.0
    double da = (index >> 9) ? pow(2.0, 13.0) / x0 : pow(2.0, 15.0) / (2.0 * x0);
    double db = (index >> 9) ? x0 * pow(2.0, 22.0) + a0 / x0 * pow(2.0, 13.0) :
      x0 * pow(2.0, 22.0) + a0 / x0 * pow(2.0, 14.0);
    long long int ua = (long long int)da & 0x1fff; // 13 bit
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
