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

uint32_t fs_binarytouint(char *bin){
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

char *fs_uinttobinary(uint32_t ui){
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

char *fs_lluinttobinary(long long unsigned int ui){
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

uint32_t fs_downto(uint32_t i,int high,int low){
  int lsh = 31 - high;
  int rsh = lsh + low;
  i <<= lsh;
  i >>= rsh;
  return i;
}

long long unsigned int fs_binarytoullint(char *bin){
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

uint32_t fs_yllui2uint(long long unsigned int i){
  return i>>13;
}

uint32_t fs_lowllui2uint(long long unsigned int i){
  i <<= 32;
  i >>= 32;
  return (uint32_t)i;
}

uint32_t fs_make_ans(uint32_t sign,uint32_t exp,uint32_t mant){
  sign <<= 31;
  exp <<= 23;
  return sign | exp | mant;
}

static int tlb_flag = 0;
static char tlb[2048][40];
void fs_init_tlb(){
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
  uint32_t i_exp = fs_downto(i,30,23);
  uint32_t is_odd = fs_downto(i,23,23);
  uint32_t exp;
  uint32_t one = 127;
  if(tlb_flag == 0){
    fs_init_tlb();
    tlb_flag = 1;
  }
  if(fs_downto(i,30,0) == 0){
    return i;
  }
  if(fs_downto(i,31,31) == 1){
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
    index = fs_downto(i,22,15);
  }else{
    index = fs_downto(i,22,14) + 256;
  }
  long long unsigned int yd = fs_binarytoullint(tlb[index]);
  uint32_t ydtemplow,y,ymant,d;
  ymant = fs_yllui2uint(yd);
  y = (1 << 23) | ymant;
  ydtemplow = fs_lowllui2uint(yd);
  d = (1 << 13) | fs_downto(ydtemplow,12,0);
  uint32_t mant;
  if(is_odd == 1){
    mant = y - ((d * ((1 << 15) - (fs_downto(i,14,0)))) >> 15);
  }else{
    if(fs_downto(i,22,0) == (1 << 23) - 1){
      mant = fs_downto(i,22,0);
    }else{
      mant = y - ((d * ((1 << 14) - (fs_downto(i,13,0)))) >> 14);
    }
  }
  uint32_t ans = fs_make_ans(sign,exp,fs_downto(mant,22,0));
  return ans;
}

uint32_t fsqrt1(uint32_t i){
  uint32_t sign = 0;
  uint32_t is_odd = fs_downto(i,23,23);
  uint32_t exp;
  uint32_t index;
  long long unsigned int yd;
  uint32_t ydtemplow;
  uint32_t mant;
  uint32_t constant, grad, stub;
  if(tlb_flag == 0){
    fs_init_tlb();
    tlb_flag = 1;
  }


  if(fs_downto(i,30,0) == 0){
    return i;
  }
  if(fs_downto(i,31,31) == 1){
    return 0xffc00000;
  }

  exp = (fs_downto(i,30,23)+127) >> 1;

  if(is_odd == 1){
    index = fs_downto(i,22,15); // 8bit
  }else{
    index = fs_downto(i,22,14) + 256; // 10bit
  }

  yd = fs_binarytoullint(tlb[index]);
  constant = fs_yllui2uint(yd);
  ydtemplow = fs_lowllui2uint(yd);
  grad = (1 << 13) | fs_downto(ydtemplow,12,0);

  if(is_odd == 1){
    stub = ((grad * ((1 << 15) - (fs_downto(i,14,0)))) >> 15);
    mant = constant - stub;
  }else{
    if(fs_downto(i,22,0) == (1 << 23) - 1){
      stub = 0;
      mant = fs_downto(i,22,0);
    }else{
      stub = ((grad * ((1 << 14) - (fs_downto(i,13,0)))) >> 14);
      mant = constant - stub;
    }
  }

  /*
  printf("index %x\n", index);
  printf("const %x\n", constant);
  printf("stub %x\n", stub);
  */

  return fs_make_ans(sign,exp,fs_downto(mant,22,0));
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
    double da = (index >> 9) ? pow(2.0, 12.0) / x0 : pow(2.0, 14.0) / (2.0 * x0);
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
