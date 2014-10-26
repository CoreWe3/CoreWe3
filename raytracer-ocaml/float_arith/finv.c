#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>


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

uint32_t read_a(int index){
  FILE *fpa;
  fpa = fopen("./a.txt","r");
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
  fpb = fopen("./b.txt","r");
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
  uint32_t utemp;
  float ftemp;
}u2f;

uint32_t finv(uint32_t ui){
  uint32_t r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16;
  r3 = ui;
  r16 = 1;
  r15 = 30;
  r14 = 23;
  r12 = 22;
  r13 = 9;

  r5 = r3 << r13; // sign とexpを0に
  r6 = r5 >> r12; // tableのindex用
  r5 = r5 >> r13; // signとexpを0にしたmantissa

  r12 = 127;
  r11 = r12 << r14; // expの最上位bit以外を立てる tableと合わせるため
  r7 = r5 | r11; //計算用

  r15 = 31; // tuiki
  r5 = r3 >> r15;
  r5 = r5 << r15; // sign bit
  r4 = r3 << r16;
  r4 = r4 >> r16;
  r4 = r4 >> r14; // exp bit

  if(r4 >= r12){
    r4 = r4 - r12;
    r4 = r12 - r4;
    r4 = r4 - r16;
  }else{
    r4 = r12 - r4;
    r4 = r12 + r4;
    r4 = r4 - r16;
  }
  r4 = r4 << r14;


  r8 = read_a(r6);
  r9 = read_b(r6);  // -fmul(r8,ui) + r9

  float a,b,x,ret;
  u2f temp;
  temp.utemp = r8;
  a = temp.ftemp;
  temp.utemp = r9;
  b = temp.ftemp;
  temp.utemp = r7;
  x = temp.ftemp;
  ret = -a*x + b;

  temp.ftemp = ret;
  r10 = temp.utemp; // table計算結果
  
  r10 = r10 << r13;
  r10 = r10 >> r13;  
  r3 = r5 | r4 | r10;
  return r3;
}

char *makebinary(){
  char *ret = (char*)malloc(sizeof(char)*50);
  int i;
  //srand(time(NULL));
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
  return ret;
}

int main(){
  u2f temp,temp2;
  srand(time(NULL));
  char *random = makebinary();
  uint32_t ux = binarytouint(random);
  temp.utemp = ux;
  uint32_t finv_answer = temp2.utemp = finv(ux);
  printf("finv     : %s : %f\n",uinttobinary(finv_answer),temp2.ftemp);
  float fx = temp.ftemp;
  temp.ftemp = 1.0 / fx;
  printf("answer   : %s : %f\n",uinttobinary(temp.utemp),temp.ftemp);
  printf("distance : %d\n",finv_answer - temp.utemp);
  return 0;
}
