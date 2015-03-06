#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#define TABLE 8 // [1,4)を2^-TABLE刻みで分割する
#define N (1 << TABLE)
#define DNUM 12 // 14bit目は1
#define YNUM 22

typedef union u2f{
  uint32_t uuu;
  float fff;
}u2f;

static double make_a(double index,double next){
  return 1.0/(sqrt(index) + sqrt(next));
}

static double make_b(double index,double next){
  double a = make_a(index,next);
  return 0.5*(-a*index + sqrt(index) + 1/(4*a));
}

static char *high_low_uint2binary(uint32_t ui,int high,int low){
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

static uint32_t downto(uint32_t i,int high,int low){
  int lsh = 31 - high;
  int rsh = lsh + low;
  i <<= lsh;
  i >>= rsh;
  return i;
}

static double make_y(double a,double b,double x){
  return a * x + b;
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

int tlb_flag = 0;
static char tlb[2048][40];
/*void init_tlb(){
  int i = 0;
  FILE *fp = fopen(INFILE,"r");
  char str[40];
  while(fscanf(fp,"%s",str) != EOF){
    strcpy(tlb[i],str);
    i++;
  }
  fclose(fp);
}
*/
static void make_table(){
  int i=0;
  int size = 3 * N;
  double c = 1.0 / N;
  double index,next,a,b,y1,y2;
  uint32_t y1_mant,y2_mant,d;
  u2f y1u,y2u;
  for(i=0;i<size;i++){
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
    d = y2_mant - y1_mant; // huan
    char *y2s,*ds;
    char str[70];
    y2s = high_low_uint2binary(y2_mant,YNUM,0);
    ds = high_low_uint2binary(d,DNUM,0);
    strcpy(str,y2s);
    //strcat(str," "); //
    strcat(str,ds);
    free(y2s);
    free(ds);
    strcpy(tlb[i],str);
  }
}

static void init_tlb(){
  make_table();
}

uint32_t fsqrt(uint32_t i){
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
