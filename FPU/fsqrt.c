#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>

#define INFILE "new_sqrt_table.txt"
#define TESTS 2000000
#define IS_TIME_RAND 3 // 1ならsrand(time(NULL)) 0でも1でもなければsrand(IS_TIME_RAND)する
//2 仮数部 all 1 だめ

typedef union u2f{
  uint32_t uuu;
  float fff;
}u2f;

uint32_t binarytouint(char *bin){
  uint32_t ret=0;
  uint32_t temp=1u;
  int i=0;
  for(i=0;i<32;i++){
    if(bin[31-i]=='1'){
      ret += temp << i;
    }
  }
  return ret;
}

char *uinttobinary(uint32_t ui){
  char *ret=(char*)malloc(sizeof(char)*50);
  int i;
  for(i=0;i<32;i++){
    if((ui >> i) & 1u){
      ret[31-i]='1';
    }
    else
      ret[31-i]='0';
  }
  ret[32]='\0';
  return ret;
}

char *lluinttobinary(long long unsigned int ui){
  char *ret=(char*)malloc(sizeof(char)*50);
  int i;
  for(i=0;i<36;i++){
    if((ui >> i) & 1u){
      ret[35-i]='1';
    }
    else
      ret[35-i]='0';
  }
  ret[36]='\0';
  return ret;
}

uint32_t downto(uint32_t i,int high,int low){
  int lsh = 31 - high;
  int rsh = lsh + low;
  i <<= lsh;
  i >>= rsh;
  return i;
}

long long unsigned int binarytoullint(char *bin){
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

uint32_t yllui2uint(long long unsigned int i){
  return i>>13;
}

uint32_t lowllui2uint(long long unsigned int i){
  i <<= 32;
  i >>= 32;
  return (uint32_t)i;
}

uint32_t make_ans(uint32_t sign,uint32_t exp,uint32_t mant){
  sign <<= 31;
  exp <<= 23;
  return sign | exp | mant;
}

int tlb_flag = 0;
static char tlb[2048][40];
void init_tlb(){
  int i = 0;
  FILE *fp = fopen(INFILE,"r");
  char str[40];
  while(fscanf(fp,"%s",str) != EOF){
    strcpy(tlb[i],str);
    i++;
  }
  fclose(fp);
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

uint32_t fsqrt0(uint32_t i){
  uint32_t sign = 0;
  uint32_t i_exp = downto(i,30,23);
  uint32_t is_odd = downto(i,23,23);
  uint32_t exp;
  uint32_t index;
  long long unsigned int yd;
  uint32_t ydtemplow,y,ymant,d;
  uint32_t mant;
  uint32_t ans;
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

  exp = (i_exp+127) >> 1;

  if(is_odd == 1){
    index = downto(i,22,15); // 8bit
  }else{
    index = downto(i,22,14) + 256; // 10bit
  }

  yd = binarytoullint(tlb[index]);
  ymant = yllui2uint(yd);
  y = ymant;
  ydtemplow = lowllui2uint(yd);
  d = (1 << 13) | downto(ydtemplow,12,0);
  if(is_odd == 1){
    mant = y - ((d * ((1 << 15) - (downto(i,14,0)))) >> 15);
  }else{
    if(downto(i,22,0) == (1 << 23) - 1){
      mant = downto(i,22,0);
    }else{
      mant = y - ((d * ((1 << 14) - (downto(i,13,0)))) >> 14);
    }
  }
  ans = make_ans(sign,exp,downto(mant,22,0));
  return ans;
}

int main(){
  union {
    uint32_t u;
    float f;
    int32_t i;
  } a, b, c;


  for(a.u=0; a.u<0x7f800000; a.u++){
    if(a.f < 1e-7 || 1e7 < a.f) continue;
    b.u = fsqrt(a.u);
    c.u = fsqrt0(a.u);
    if(abs(b.i - c.i) > 0){
      printf("%08x\t%08x\t%08x\n",a.u,b.u,c.u);
      break;
    }
  }


  a.u = 0x3fffffff;
  b.u = fsqrt(a.u);
  c.f = sqrtf(a.f);
  printf("%08x\t%08x\t%08x\n",a.u,b.u,c.u);

  return 0;
}
