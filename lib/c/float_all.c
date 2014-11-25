#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

/*
まとめたんですけどコンパイルできるかためしてません
*/

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


uint32_t read_a_sqrt(int index){
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

uint32_t read_b_sqrt(int index){
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

uint32_t read_a_inv(int index){
  FILE *fpa;
  fpa = fopen("./a_inv.txt","r");
  int i;
  char a[40];
  for(i=0;i<index;i++){
    fscanf(fpa,"%s",a);
  }
  fscanf(fpa,"%s",a);
  fclose(fpa);
  return (binarytouint(a));
}

uint32_t read_b_inv(int index){
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


uint32_t fadd(uint32_t a, uint32_t b){
    uint32_t r[16];//, s[16], m[16];
//    int sp;
    r[0] = r[1] = r[2] = 0; //sp = 0;
    r[3] = a; r[4] = b;
    
    //r[5](6) = abs
    r[5] = r[3] << 1;
    r[5] = r[5] >> 1;
    r[6] = r[4] << 1;
    r[6] = r[6] >> 1;
    
    if (uitoi(r[6]) <= uitoi(r[5])) {} else {
	r[7] = r[3];
	r[3] = r[4];
	r[4] = r[7];
    }
 
    //r[5](6) = exp
    r[5] = r[3] << 1;
    r[5] = r[5] >> 24;
    r[6] = r[4] << 1;
    r[6] = r[6] >> 24;
    //r[6] = shift
    r[6] = r[5] - r[6];
    
    //r[7](8) = man
    r[7] = r[3] << 9;
    r[7] = r[7] >> 9;
    r[8] = r[4] << 9;
    r[8] = r[8] >> 9;
    //r[9] = 0x800000
    r[9] = 0x800000;
    r[7] = r[9] | r[7];
    r[8] = r[9] | r[8];
    //man_b >> shift
    r[8] = r[8] >> r[6];
    
    //r[9](10) = sig
    r[9] = r[3] >> 31;
    r[10] = r[4] >> 31;
    //r[11] = man_c
    if (r[9] != r[10]) {
	r[11] = r[7] - r[8];
    } else {
	r[11] = r[7] + r[8];	
    }
    
    r[12] = 25;
    r[13] = 1;
    while(1) {
	r[14] = r[13] << r[12];
	r[14] = r[11] & r[14];
	if (r[14] != 0) break;
	r[12] = r[12] - 1;
	if (r[12] <= 0) break;
    }

    r[14] = 23;
    if (r[14] <= r[12]) { //繰り上がり
	r[12] = r[12] - r[14];
	r[10] = r[5] + r[12];
	r[11] = r[11] >> r[12];
    } else { //繰り下がり
	r[12] = r[14] - r[12];
	if (r[12] < r[5] /*r[3]<=r[4]*/) {} else {
	    r[3] = 0;
	    return r[3];
	}
	r[10] = r[5] - r[12];
	r[11] = r[11] << r[12];
    }

    r[10] = r[10] << 23;
    r[11] = r[11] << 9;
    r[11] = r[11] >> 9;
    r[3] = r[9] << 31;
    r[3] = r[3] | r[10];
    r[3] = r[3] | r[11];
    return r[3];
}

uint32_t fsub(uint32_t a, uint32_t b){
    uint32_t r[16];//, s[16], m[16];
//    int sp;
    r[0] = r[1] = r[2] = 0; //sp = 0;
    r[3] = a; r[4] = b;

    r[4] = ftoui(-uitof(r[4]));
    r[3] = fadd(r[3], r[4]);
    return r[3];
}


uint32_t fmul(uint32_t a,uint32_t b){
/*仕様ややっていることは同ファイル内のfmulv2と同じです*/
  uint32_t r3=a;
  uint32_t r4=b;
  uint32_t r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18;
  uint32_t r19,r20,r21,r22,r23,r24,r25,r26,r27,r28,r29,r30,r31,r32,r33,r34,r35,r36,r37,r38,r39,r40,r41,r42;
  /*r3~r8はmulが使う*/
  r15=r3>>31;
  r16=r4>>31;
  r15=r15^r16; /*r15=sign*/
  	    /*r16=exp,r17=frac*/
  r18=r3<<1;
  r19=r4<<1;
  r18=r18>>24;
  r19=r19>>24;
  r20=r3<<9;
  r21=r4<<9;
  r20=r20>>20;
  r21=r21>>20;
  r22=r3<<21;
  r23=r4<<21;
  r22=r22>>21;
  r23=r23>>21;
  /*r18=aexp,r19=bexp,r20=ah,r21=bh,r22=al,r23=bl*/
  r16=r18+r19;
  r20=r20+(1<<12);
  r21=r21+(1<<12);
  /*ここまでOK*/
  r3=r20;
  r4=r21;
  r3=r3*r4;
  r17=r3+2;
  r3=r20;
  r4=r23;
  r3=r3*r4;
  r3=r3>>11;
  r17=r3+r17;
  r3=r21;
  r4=r22;
  r3=r3*r4;
  r3=r3>>11;
  r17=r17+r3;
  /*ok*/
  r30=(1<<25);
  if (r17>=r30){
  r16=r16+1;
  r17=r17<<7;
  r17=r17>>9;
  }else{
  r17=r17<<8;
  r17=r17>>9;
  }
  r30=127;
  if (r16<=r30){
     r3=r15<<31;
     return r3;
  }else{
     r16=r16-r30;
  }
  r3=r15<<31;
  r16=r16<<23;
  r3=r3+r16;
  r3=r3+r17;
  return r3;

}



uint32_t finv(uint32_t ui){
  uint32_t r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16;
  r3 = ui;
  r16 = 1;

  r5 = r3 << 9; // sign とexpを0に
  r6 = r5 >> 22; // tableのindex用
  r5 = r5 >> 9; // signとexpを0にしたmantissa

  r12 = 127;
  r11 = r12 << 23; // expの最上位bit以外を立てる tableと合わせるため

  r7 = r5 | r11; //計算用
  
  r5 = r3 >> 31;

  r5 = r5 << 31; // sign bit
  r4 = r3 << 1;
  r4 = r4 >> 1;
  r4 = r4 >> 23; // exp bit

  if(r4 >= r12){
    r4 = r4 - r12;
    r4 = r12 - r4;
    r4 = r4 - r16;
  }else{
    r4 = r12 - r4;
    r4 = r12 + r4;
    r4 = r4 - r16;
  }
/*finvend*/

	/*-ax+b*/
  r4 = r4 << 23;

  r16=r4;/*pushがわり*/
  r15=r5;
  r4 = read_a_inv(r6);  //もとr8
  r3=r7;
  /*push r6*/
  r3=fmul(r3,r4);
  /*pop r6*/
  r4=r3;
  r3 = read_b_inv(r6);
  r3=fsub(r3,r4);
  /*pop r4=exp,r5=sign*/
  r5=r15;/*popがわり*/
  r4=r16;
  r10 = r3 << 9;
  r10 = r10 >> 9;  
  r3 = r5 | r4 | r10;
  return r3;
}


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
  r3 = read_a_sqrt(r23);
  // push r23,r20
  r3 = fmul(r3,r4);
  r4 = read_b_sqrt(r23);
  r3 = fadd(r3,r4);
  r3 = r3 << 9;
  r3 = r3 >> 9;
  r3 = r3 | r20;
  return r3;
}
/*

