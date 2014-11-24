#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <math.h>
#include "float_arith.h"
#include "fmul2.c"
#include "fadd_fsub.c"
#define TESTS 10000
#define IS_TIME_RAND 1 // 1ならsrand(time(NULL)) 0でも1でもなければsrand(IS_TIME_RAND)する

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

char *makebinary(){
  char *ret = (char*)malloc(sizeof(char)*50);
  int i;
  for(i=0;i<32;i++){
    int ra=rand()%2;
    if(ra == 1)
      ret[i] = '1';
    else if(ra == 0)
      ret[i] = '0';
  }
  ret[32] = '\n';
  for(i=33;i<50;i++){
    ret[i] = 0;
  }
  char temp[9];
  for(i=0;i<8;i++){
    temp[i] = ret[1+i];
  }
  temp[8] = 0;
  if(strcmp(temp,"00000000") == 0 || strcmp(temp,"11111111") == 0 /*|| strcmp(temp,"11111110") == 0 || strcmp(temp,"11111101") == 0 || strncmp(ret,"1",1) == 0 */){
    free(ret);
    ret = makebinary();
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

uint32_t read_a(int index){
  FILE *fpa;
  fpa = fopen("./a_fsqrt.txt","r");
  int i;
  char a[40];
  for(i=0;i<index;i++){
    fscanf(fpa,"%s",a);
  }
  fscanf(fpa,"%s",a);
  fclose(fpa);
  return (binarytouint(a));
}

uint32_t read_b(int index){
  FILE *fpb;
  fpb = fopen("./b_fsqrt.txt","r");
  int i;
  char b[40];
  for(i=0;i<index;i++){
    fscanf(fpb,"%s",b);
  }
  fscanf(fpb,"%s",b);
  fclose(fpb);
  return (binarytouint(b));
}

typedef union u2f{
  uint32_t uuu;
  float fff;
}u2f;


uint32_t fsqrt(uint32_t ui){
  uint32_t r0 = 0;
  uint32_t r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20,r21,r22,r23,r24,r25,r26,r27,r28;
  r3 = ui;
  r4 = r3 << 1;
  if(r4 == r0){
    return r3;
  }
  r4 = r3 >> 31;
  if(r4 == 1){//負のときはnan
    return 0xffc00000;
  }
  r5 = 127;//exp偶数のときの計算用exp
  r6 = 128;//exp奇数のとき
  r7 = r3 >> 23; // exp の保存
  r8 = r3 << 8; // exp の最下位だけ残して上を消す。
  r9 = r8 >> 31;//expの最下位bitだけにする。expが奇数か偶数かの判別に使う。
  r10 = r3 << 9; // expを消す
  r11 = r10 >> 9; // 仮数部のみ
  if(r7 >= r5){//floatとして1以上
    r20 = r7 - r5;
    r20 = r20 >> 1;
    r20 = r20 + r5;
  }else{//1未満
    r20 = r5 - r7;
    r20 = r20 + 1;
    r20 = r20 >> 1;
    r20 = r5 - r20;
  }
  r20 = r20 << 23;// r20は指数部
  if(r9 == r0){//expは奇数、仮数部は[2,4)
    r21 = 256;//tableの仮数部が[1,2)の分を読み飛ばす
    r22 = r10 >> 23;//仮数部を上9bit残す。
    r23 = r22 + r21; // index
    r6 = r6 << 23;
    r4 = r6 | r11; // 計算用
  }else{//expは偶数、仮数部は[1,2)
    r23 = r10 >> 24;//仮数部上8bitをindex用に
    r5 = r5 << 23;
    r4 = r5 | r11;
  }
  //  printf("r4 : %s\n",uinttobinary(r4));
  r3 = read_a(r23);
  // push r23,r20
  r3 = fmul(r3,r4);
  r4 = read_b(r23);
  r3 = fadd(r3,r4);
  r3 = r3 << 9;
  r3 = r3 >> 9;
  r3 = r3 | r20;
  return r3;
}
/*
int main(){
  u2f ans,temp2;
  if(IS_TIME_RAND == 1){
    srand(time(NULL));
  }else if(IS_TIME_RAND != 0){
    srand((unsigned)IS_TIME_RAND);
  }
  int i;
  int count[17] = {0};
  int distance;
  int max=0,min=0;
  char my_maxstr[50]={0},my_minstr[50]={0};
  char ans_max[50]={0},ans_min[50]={0};
  char quest_max[50]={0},quest_min[50]={0};
  for(i=0;i<TESTS;i++){
    char *random = makebinary();
    uint32_t ux = binarytouint(random);
    ans.uuu = ux;
    uint32_t finv_answer = temp2.uuu = fsqrt(ux);
    //  printf("finv     : %s : %f\n",uinttobinary(finv_answer),temp2.ftemp);
    float fx = ans.fff;
    ans.fff = sqrtf(fx);
    distance = finv_answer - ans.uuu;
    if(distance <= -8){
      count[0]++;
    }
    else if(distance >= 8){
      count[16]++;
    }
    else{
      count[distance+8]++;
    }
    //if(distance > 500 || distance < -500)
    // continue; // exp が0x00または0xffのときおかしくなるので
    if(max < distance){
      max = distance;
      strcpy(my_maxstr,uinttobinary(finv_answer));
      strcpy(ans_max,uinttobinary(ans.uuu));
      strcpy(quest_max,random);
    }
    else if(min > distance){
      min = distance;
      strcpy(my_minstr,uinttobinary(finv_answer));
      strcpy(ans_min,uinttobinary(ans.uuu));
      strcpy(quest_min,random);
    }
    //printf("answer   : %s : %f\n",uinttobinary(temp.utemp),temp.ftemp);
    free(random);
  }
  for(i=0;i<17;i++){
    printf("count[%d] = %d\n",i-8,count[i]);
  }
  printf("指数部が0x00または0xffのとき除外している。\n");
  printf("max = %d\n",max);
  printf("fsqrt : %s\n",my_maxstr);
  printf("ansx  : %s\n",ans_max);
  printf("qmax  : %s",quest_max);
  printf("debug :  EXP     FRA    89\n\n");
  printf("min = %d\n",min);
  printf("fsqrt : %s\n",my_minstr);
  printf("sqrtf : %s\n",ans_min);
  printf("qmin  : %s\n",quest_min);
  printf("debug :  EXP     FRA    89 \n");
  return 0;
}
*/
