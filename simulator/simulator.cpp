#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <limits.h>
#include <math.h>
#include "isa.h"

void ld(unsigned int ra, unsigned int rb, unsigned int cx);
void st(unsigned int ra, unsigned int rb, unsigned int cx);
void lda(unsigned int ra,unsigned int cx);
void sta(unsigned int ra, unsigned int cx);
void ldih(unsigned int ra, unsigned int cx);
void ldil(unsigned int ra, unsigned int cx);
void add(unsigned int ra, unsigned int rb, unsigned int rc);
void sub(unsigned int ra, unsigned int rb, unsigned int rc);
void fneg(unsigned int ra, unsigned int rb);
void addi(unsigned int ra, unsigned int rb, unsigned int cx);
void _and(unsigned int ra, unsigned int rb, unsigned int rc);
void _or(unsigned int ra, unsigned int rb, unsigned int rc);
void _xor(unsigned int ra, unsigned int rb, unsigned int rc);
void shl(unsigned int ra, unsigned int rb, unsigned int rc);
void shr(unsigned int ra, unsigned int rb, unsigned int rc);
void shli(unsigned int ra, unsigned int rb, unsigned int cx);
void shri(unsigned int ra, unsigned int rb, unsigned int cx);
void beq(unsigned int ra, unsigned int rb, unsigned int cx);
void ble(unsigned int ra, unsigned int rb, unsigned int cx);
void blt(unsigned int ra, unsigned int rb, unsigned int cx);
void bfle(unsigned int ra, unsigned int rb, unsigned int cxZ);
void jsub(unsigned int cx);
void fx86(unsigned int cx);
void ret();
void push(unsigned int ra);
void pop(unsigned int ra);

const char* op2name(unsigned int op);
const char* reg2name(unsigned int reg);

FILE* iofpr = NULL;
FILE* iofpw = NULL;
FILE* ramout = NULL;

//Debugger
unsigned long long d_insnum = 0;
unsigned int counter[ISANUM] = {0};

void debuginfo(){

	printf("pc:%d, sp:%x\n", pc, sp);

	for(int i = 0; i < REGNUM; i++){
		printf("%s:%d (0x%x), ", reg2name(i), reg[i].d, reg[i].u);
	}
	printf("\n");
	for(int i = 0; i < ISANUM; i++){
		printf("%s:%u, ", names[i], counter[i]);
	}
	printf("\nNumber of Instruction : %lld\n",d_insnum);
	
	//Dump RAM
	if(ramout!=NULL){
		for(unsigned int i = 0; i < RAMSIZE; i++){
			if(fwrite(&ram[i],sizeof(unsigned int),1,ramout) <= 0){
				printf("File Write Error\n");
				debuginfo();
				exit(1);
			}
		}
		fclose(ramout);
	}
}

void initram(char* filename){
	FILE *fp = fopen(filename, "rb");
	int tmp;
	for(int i = 0; i < RAMSIZE; i++){
		if(fread(&tmp,sizeof(int),1,fp) > 0){
			ram[i] = tmp;
		}
	}
	fclose(fp);
}


int main(int argc, char* argv[])
{
	FILE *fpr;
	unsigned long long limit = ULLONG_MAX;
	unsigned long long breakpoint = ULLONG_MAX;
	char result;
	
	for(int i=0; i< REGNUM; i++){
		reg[i].u = 0;
	}


	while((result=getopt(argc,argv,"i:o:l:b:r:s:"))!=-1){
		switch(result){
			case 'i':
				iofpr = fopen(optarg,"rb");
				if (iofpr == NULL){
					printf("Can't open %s\n",optarg);
					return 1;
				}
				break;
			case 'o':
				iofpw = fopen(optarg,"wb");
				if (iofpw == NULL){
					printf("Can't open %s\n",optarg);
					return 1;
				}
				break;
			case 'r':
				ramout = fopen(optarg,"wb");
				if (ramout == NULL){
					printf("Can't open %s\n",optarg);
					return 1;
				}
				break;
			case 's':
				initram(optarg);
				break;
			case 'l':
				limit = atoi(optarg);
				break;
			case 'b':
				breakpoint = atoi(optarg);
				break;
			case ':':
				fprintf(stdout,"%c needs value\n",result);
				return 1;
			case '?':
				fprintf(stdout,"unknown\n");
				return 1;
		}
	}

	if(optind < argc){
		fpr = fopen(argv[optind++],"rb");
		if (fpr == NULL){
			printf("Can't open %s\n",optarg);
			return 1;
		}
	}else{
		return 1;
	}

	if(fpr == NULL){
		printf("No Assembly File\n");
		return 0;
	}


	//READ INSTRUCTIONS
	unsigned int tmp;
	unsigned int num = 0;
	while(fread(&tmp,sizeof(unsigned int),1,fpr) > 0){
		rom[num] = tmp;
		num++;
	}
	fclose(fpr);

	//MAIN ROUTINE
	INS ins;


	bool flag = true;

	while(flag){
		if(pc >= num){
			printf("The program successfully done.\n");
			break;
		}
		if(d_insnum >= limit){
			printf("The program reached limit instruction process : %lld\n", limit);
			break;
		}
		if(breakpoint == pc){
			printf("The program reached break point. : %d\n", pc);
			break;
		}
		
		ins.data = rom[pc];
		pcflag = 1;
		counter[ins.A.op]++;
		switch(ins.A.op){
			case LD:
				ld(ins.L.ra,ins.L.rb,ins.L.cx);
				break;
			case ST:
				st(ins.L.ra,ins.L.rb,ins.L.cx);
				break;
			case LDA:
				lda(ins.X.ra,ins.X.cx);
				break;
			case STA:
				sta(ins.X.ra,ins.X.cx);
				break;
			case LDIH:
				ldih(ins.X.ra, ins.X.cx);
				break;
			case LDIL:
				ldil(ins.X.ra, ins.X.cx);
				break;
			case ADD:
				add(ins.A.ra,ins.A.rb,ins.A.rc);
				break;
			case SUB:
				sub(ins.A.ra,ins.A.rb,ins.A.rc);
				break;
			case FNEG:
				fneg(ins.A.ra,ins.A.rb);
				break;
			case ADDI:
				addi(ins.L.ra,ins.L.rb,ins.L.cx);
				break;
			case AND:
				_and(ins.A.ra,ins.A.rb,ins.A.rc);
				break;
			case OR:
				_or(ins.A.ra,ins.A.rb,ins.A.rc);
				break;
			case XOR:
				_xor(ins.A.ra,ins.A.rb,ins.A.rc);
				break;
			case SHL:
				shl(ins.A.ra,ins.A.rb,ins.A.rc);
				break;
			case SHR:
				shr(ins.A.ra,ins.A.rb,ins.A.rc);
				break;
			case SHLI:
				shli(ins.L.ra,ins.L.rb,ins.L.cx);
				break;
			case SHRI:
				shri(ins.L.ra,ins.L.rb,ins.L.cx);
				break;
			case BEQ:
				if(ins.L.cx == 0){
					printf("Detect Halt\n");
					goto HALT;
					flag = false;
				}
				beq(ins.L.ra,ins.L.rb,ins.L.cx);
				break;
			case BLE:
				ble(ins.L.ra,ins.L.rb,ins.L.cx);
				break;
			case BLT:
				blt(ins.L.ra,ins.L.rb,ins.L.cx);
				break;
			case BFLE:
				bfle(ins.L.ra,ins.L.rb,ins.L.cx);
				break;
			case JSUB:
				jsub(ins.J.cx);
				break;
			case RET:
				ret();
				break;
			case PUSH:
				push(ins.A.ra);
				break;
			case POP:
				pop(ins.A.ra);
				break;
			case FX86:
				fx86(ins.J.cx);
				break;
			default:
				printf("no such instruction \"%d\" : PC = %d\n",ins.A.op,pc);
				flag = false;
		}
		reg[0].u = 0;
		pc+=pcflag;
		d_insnum++;
	}
 HALT:

	if(iofpr!=NULL) fclose(iofpr);
	if(iofpw!=NULL) fclose(iofpw);
	
	debuginfo();


	return 0;
}

const char* op2name(unsigned int op){
	return names[op];
}
const char* reg2name(unsigned int reg){
	return rnames[reg];
}

void ld(unsigned int ra, unsigned int rb, unsigned int cx){
	unsigned int tmp = (reg[rb].d + cx) & 0xFFFFF;
	if(tmp != IOADDR ){
		reg[ra].u = ram[tmp];
	}else{
		if(iofpr == NULL){
			printf("WARN: NO INPUT FILE\n");
			reg[ra].u = 0;
			return;
		}
		unsigned char iotmp;
		if(fread(&iotmp,sizeof(unsigned char),1,iofpr) > 0){
			reg[ra].u = iotmp;
		}else{
			printf("File Read Error\n");
			debuginfo();
			exit(1);
		}
	}
}
void st(unsigned int ra, unsigned int rb, unsigned int cx){
	unsigned int tmp = (reg[rb].d + cx) & 0xFFFFF;
	if(tmp != IOADDR ){
		ram[tmp] = reg[ra].u;
	}else{
		unsigned char iotmp = reg[ra].u & 0xFF;
		if(iofpw!=NULL && fwrite(&iotmp,sizeof(unsigned char),1,iofpw) <= 0){
			printf("File Write Error\n");
			debuginfo();
			exit(1);
		}
	}
}
void lda(unsigned int ra, unsigned int cx){
	unsigned int tmp = cx & 0xFFFFF;
	if(tmp != IOADDR ){
		reg[ra].u = ram[tmp];
	}else{
		if(iofpr == NULL){
			printf("WARN: NO INPUT FILE\n");
			reg[ra].u = 0;
			return;
		}
		unsigned char iotmp;
		if(fread(&iotmp,sizeof(unsigned char),1,iofpr) > 0){
			reg[ra].u = iotmp;
		}else{
			printf("File Read Error\n");
			debuginfo();
			exit(1);
		}
	}
}
void sta(unsigned int ra, unsigned int cx){
	unsigned int tmp = cx & 0xFFFFF;
	if(tmp != IOADDR ){
		ram[tmp] = reg[ra].u;
	}else{
		unsigned char iotmp = reg[ra].u & 0xFF;
		if(iofpw!=NULL && fwrite(&iotmp,sizeof(unsigned char),1,iofpw) <= 0){
			printf("File Write Error\n");
			debuginfo();
			exit(1);
		}
	}
}
void ldih(unsigned int ra, unsigned int cx){
	reg[ra].u = (cx << 16) + (reg[ra].u & 0xFFFF);
}
void ldil(unsigned int ra, unsigned int cx){
	reg[ra].u = cx ;
}
void add(unsigned int ra, unsigned int rb, unsigned int rc){
	reg[ra].d = reg[rb].d + reg[rc].d;
}
void sub(unsigned int ra, unsigned int rb, unsigned int rc){
	reg[ra].d = reg[rb].d - reg[rc].d;
}
void fneg(unsigned int ra, unsigned int rb){
	reg[ra].f = -reg[rb].f;
}
void addi(unsigned int ra, unsigned int rb, unsigned int cx){
	reg[ra].d = reg[rb].d + cx;
}
void _and(unsigned int ra, unsigned int rb, unsigned int rc){
	reg[ra].u = reg[rb].u & reg[rc].u;
}
void _or(unsigned int ra, unsigned int rb, unsigned int rc){
	reg[ra].u = reg[rb].u | reg[rc].u;
}
void _xor(unsigned int ra, unsigned int rb, unsigned int rc){
	reg[ra].u = reg[rb].u ^ reg[rc].u;
}
void shl(unsigned int ra, unsigned int rb, unsigned int rc){
	if ( reg[rc].u < 32 ){
		reg[ra].u = reg[rb].u << reg[rc].u;
	}else{
		reg[ra].u = 0;
	}
}
void shr(unsigned int ra, unsigned int rb, unsigned int rc){
	if ( reg[rc].u < 32 ){
		reg[ra].u = reg[rb].u >> reg[rc].u;
	}else{
		reg[ra].u = 0;
	}
}
void shli(unsigned int ra, unsigned int rb, unsigned int cx){
	if ( cx < 32 ){
		reg[ra].u = reg[rb].u << cx;
	}else{
		reg[ra].u = 0;
	}
}
void shri(unsigned int ra, unsigned int rb, unsigned int cx){
	if ( cx < 32 ){
		reg[ra].u = reg[rb].u >> cx;
	}else{
		reg[ra].u = 0;
	}
}
void beq(unsigned int ra, unsigned int rb, unsigned int cx){
	if(reg[ra].d == reg[rb].d){ 
		pc = pc + cx;
		pcflag = 0;
	}
}
void ble(unsigned int ra, unsigned int rb, unsigned int cx){
	if(reg[ra].d <= reg[rb].d){
		pc = pc + cx;
		pcflag = 0;
	}
}
void blt(unsigned int ra, unsigned int rb, unsigned int cx){
	if(reg[ra].d < reg[rb].d){
		pc = pc + cx;
		pcflag = 0;
	}
}
void bfle(unsigned int ra, unsigned int rb, unsigned int cx){
	if(reg[ra].f <= reg[rb].f){
		pc = pc + cx;
		pcflag = 0;
	}
}
void jsub(unsigned int cx){
	sp--;
	ram[sp] = pc + 1;
	pc = pc + cx;
	pcflag = 0;
}
void ret(){
	pc = ram[sp];
	pcflag = 0;
	sp++;
}
void push(unsigned int ra){
	sp--;
	ram[sp] = reg[ra].u;
	if(sp<STACKLIMIT){
		printf("Stack Pointer is out of range\n");
		exit(1);
	}
}
void pop(unsigned int ra){
	reg[ra].u = ram[sp];
	sp++;
	if(sp>=RAMSIZE){
		printf("Stack Pointer is out of range\n");
		exit(1);
	}
}
void fx86(unsigned int cx){

	switch (cx){
	/*0から順にfadd,fsub,fmul,fdiv,finv,fsqrt,sin,cos,atan,itof,ftoi,floor*/
		case 0:
			reg[3].f=(reg[3].f)+(reg[4].f);
			break;
		case 1:
			reg[3].f=(reg[3].f)-(reg[4].f);
			break;
		case 2:
			reg[3].f=(reg[3].f)*(reg[4].f);
			break;
		case 3:
			reg[3].f=(reg[3].f)/(reg[4].f);
			break;
		case 4:
			reg[3].f=(1)/(reg[4].f);
			break;
		case 5:
			reg[3].f=sqrt(reg[3].f);
			break;
		case 6:
			reg[3].f=sin(reg[3].f);
			break;
		case 7:
			reg[3].f=cos(reg[3].f);
			break;
		case 8:
			reg[3].f=atan(reg[3].f);
			break;
		case 9:
			reg[3].f=static_cast<float>(reg[3].u);
			break;
		case 10:
			reg[3].u= static_cast<int>(reg[3].f);
			break;
		case 11:
			reg[3].f= floor(reg[3].f);
			break;
	}


}

