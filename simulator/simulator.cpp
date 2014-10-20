#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "isa.h"

void ld(unsigned int ra, unsigned int rb, int cx);
void st(unsigned int ra, unsigned int rb, int cx);
void add(unsigned int ra, unsigned int rb, unsigned int rc);
void sub(unsigned int ra, unsigned int rb, unsigned int rc);
void addi(unsigned int ra, unsigned int rb, int cx);
void _and(unsigned int ra, unsigned int rb, unsigned int rc);
void _or(unsigned int ra, unsigned int rb, unsigned int rc);
void shl(unsigned int ra, unsigned int rb, unsigned int rc);
void shr(unsigned int ra, unsigned int rb, unsigned int rc);
void beq(unsigned int ra, unsigned int rb, int cx);
void ble(unsigned int ra, unsigned int rb, int cx);
void blt(unsigned int ra, unsigned int rb, int cx);
void jsub(int cx);
void ret();
void push(unsigned int ra);
void pop(unsigned int ra);

const char* op2name(unsigned int op);
const char* reg2name(unsigned int reg);

FILE* iofpr;
FILE* iofpw;

//Debugger
unsigned int d_insnum = 0;
unsigned int counter[ISANUM] = {0};

void debuginfo(){
	for(int i = 0; i < REGNUM; i++){
		printf("%s:%u, ", reg2name(i), reg[i]);
	}
	printf("\n");
	for(int i = 0; i < ISANUM; i++){
		printf("%s:%u, ", names[i], counter[i]);
	}
	printf("\n");
	printf("Number of Instruction : %d\n",d_insnum);
}


int main(int argc, char* argv[])
{
	if(argc < 4){
		printf("Need Binary filenames\n");
		return 1;
	}
	
	//Initilaize IO
	iofpr = fopen(argv[2],"rb");
	if (iofpr == NULL){
		printf("Can't open %s\n",argv[2]);
		return 1;
	}
	iofpw = fopen(argv[3],"wb");
	if (iofpr == NULL){
		printf("Can't open %s\n",argv[3]);
		return 1;
	}

	//READ INSTRUCTIONS
	FILE *fpr = fopen(argv[1],"rb");
	if (fpr == NULL){
		printf("Can't open %s\n",argv[1]);
		return 1;
	}

	unsigned int limit = 0xffffffff;
	if(argc > 4){
		limit = atoi(argv[4]);
	} 


	unsigned int tmp;
	unsigned int num = 0;
	while(fread(&tmp,sizeof(unsigned int),1,fpr) > 0){
		rom[num] = tmp;
		num++;
	}
	fclose(fpr);

	//MAIN ROUTINE
	INS ins;
	while(pc<num){
		if(d_insnum >= limit) break;

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
			case ADD:
				add(ins.A.ra,ins.A.rb,ins.A.rc);
				break;
			case SUB:
				sub(ins.A.ra,ins.A.rb,ins.A.rc);
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
			case SHL:
				shl(ins.A.ra,ins.A.rb,ins.A.rc);
				break;
			case SHR:
				shr(ins.A.ra,ins.A.rb,ins.A.rc);
				break;
			case BEQ:
				beq(ins.L.ra,ins.L.rb,ins.L.cx);
				break;
			case BLE:
				ble(ins.L.ra,ins.L.rb,ins.L.cx);
				break;
			case BLT:
				blt(ins.L.ra,ins.L.rb,ins.L.cx);
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
			default:
				printf("no such instruction \"%d\" : PC = %d\n",ins.A.op,pc);
				break;
		}
		reg[0] = 0;
		pc+=pcflag;
		d_insnum++;
	}

	fclose(iofpr);
	fclose(iofpw);
	
	debuginfo();;


	return 0;
}

const char* op2name(unsigned int op){
	return names[op];
}
const char* reg2name(unsigned int reg){
	return rnames[reg];
}

void ld(unsigned int ra, unsigned int rb, int cx){
	unsigned int tmp = (reg[rb] + cx) & 0xFFFFF;
	if(tmp != IOADDR ){
		reg[ra] = ram[tmp];
	}else{
		int iotmp;
		if(fread(&iotmp,sizeof(int),1,iofpr) > 0){
			reg[ra] = iotmp;
		}else{
			printf("File Read Error");
			debuginfo();
			exit(1);
		}
	}
}
void st(unsigned int ra, unsigned int rb, int cx){
	unsigned int tmp = (reg[rb] + cx) & 0xFFFFF;
	if(tmp != IOADDR ){
		ram[tmp] = reg[ra];
	}else{
		if(fwrite(&reg[ra],sizeof(int),1,iofpw) <= 0){
			printf("File Write Error");
			debuginfo();
			exit(1);
		}
	}
}
void add(unsigned int ra, unsigned int rb, unsigned int rc){
	reg[ra] = reg[rb] + reg[rc];
}
void sub(unsigned int ra, unsigned int rb, unsigned int rc){
	reg[ra] = reg[rb] - reg[rc];
}
void addi(unsigned int ra, unsigned int rb, int cx){
	reg[ra] = reg[rb] + cx;
}
void _and(unsigned int ra, unsigned int rb, unsigned int rc){
	reg[ra] = reg[rb] & reg[rc];
}
void _or(unsigned int ra, unsigned int rb, unsigned int rc){
	reg[ra] = reg[rb] | reg[rc];
}
void shl(unsigned int ra, unsigned int rb, unsigned int rc){
	reg[ra] = reg[rb] << reg[rc];
}
void shr(unsigned int ra, unsigned int rb, unsigned int rc){
	reg[ra] = reg[rb] >> reg[rc];
}
void beq(unsigned int ra, unsigned int rb, int cx){
	if(reg[ra] == reg[rb]){ 
		pc = pc + cx;
		pcflag = 0;
	}
}
void ble(unsigned int ra, unsigned int rb, int cx){
	if(reg[ra] <= reg[rb]){
		pc = pc + cx;
		pcflag = 0;
	}
}
void blt(unsigned int ra, unsigned int rb, int cx){
	if(reg[ra] < reg[rb]){
		pc = pc + cx;
		pcflag = 0;
	}
}
void jsub(int cx){
	ram[sp] = pc + 1;
	sp--;
	pc = pc + cx;
	pcflag = 0;
}
void ret(){
	sp++;
	pc = ram[sp];
	pcflag = 0;
}
void push(unsigned int ra){
	sp--;
	ram[sp] = reg[ra];
}
void pop(unsigned int ra){
	reg[ra] = ram[sp];
	sp++;
}

