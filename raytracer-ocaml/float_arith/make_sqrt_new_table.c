#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#define TABLE 8 // [1,4)を2^-TABLE刻みで分割する
#define N (1 << TABLE)
#define DATA "new_sqrt_table.txt"
#define DNUM 12 // 14bit目は1
#define YNUM 22

typedef union u2f{
  uint32_t uuu;
  float fff;
}u2f;
/*
double make_c(){
  double temp = 1.0;
  int i;
  for(i=0;i<TABLE;i++){
    temp /= 2.0;
  }
  return temp;
}
double make_float(int index){
  return 1.0 + index*make_c();
}
*/

double make_a(double index,double next){
  return 1.0/(sqrt(index) + sqrt(next));
}

double make_b(double index,double next){
  double a = make_a(index,next);
  return 0.5*(-a*index + sqrt(index) + 1/(4*a));
}

uint32_t float2uint(float f){
  u2f temp;
  temp.fff = f;
  return temp.uuu;
}


char *uint2binary(uint32_t ui){
  char *ret = (char*)malloc(sizeof(char)*33);
  int i;
  for(i=0;i<32;i++){
    if((ui >> i) & 1u)
      ret[31-i] = '1';
    else
      ret[31-i] = '0';
  }
  ret[32] = '\n';
  return ret;
}

char *high_low_uint2binary(uint32_t ui,int high,int low){
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

uint32_t downto(uint32_t i,int high,int low){
  int lsh = 31 - high;
  int rsh = lsh + low;
  i <<= lsh;
  i >>= rsh;
  return i;
}

double make_y(double a,double b,double x){
  return a * x + b;
}

int main(){
  int i=0;
  int size = 3 * N;
  double c = 1.0 / N;
  double index,next,a,b,y1,y2;
  uint32_t y1_mant,y2_mant,d;
  u2f y1u,y2u;
  FILE *fp = fopen(DATA,"w");
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
    fprintf(fp,"%s\n",str);
  }
  fclose(fp);
  return 0;
}

