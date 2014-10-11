#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "isa.h"

void ld(unsigned int ra, unsigned int rb, int cx);
void st(unsigned int ra, unsigned int rb, int cx);
void add(unsigned int ra, unsigned int rb, unsigned int rc);
void sub(unsigned int ra, unsigned int rb, unsigned int rc);
void addi(unsigned int ra, unsigned int rb, int cx);
void and(unsigned int ra, unsigned int rb, unsigned int rc);
void or(unsigned int ra, unsigned int rb, unsigned int rc);
void shl(unsigned int ra, unsigned int rb, unsigned int rc);
void shr(unsigned int ra, unsigned int rb, unsigned int rc);
void beq(unsigned int ra, unsigned int rb, int cx);
void ble(unsigned int ra, unsigned int rb, int cx);
void blt(unsigned int ra, unsigned int rb, int cx);
void jsub(int cx);
void ret();
void push(unsigned int ra);
void pop(unsigned int ra);

char* op2name(unsigned int op);
char* reg2name(unsigned int reg);


//Debugger
unsigned int d_insnum = 0;


int main(int argc, char* argv[])
{
	if(argc < 2){
		printf("Need Binary filename\n");
		return 1;
	}

	//READ INSTRUCTIONS
	FILE *fpr = fopen(argv[1],"rb");
	if (fpr == NULL){
		printf("Can't open %s\n",argv[1]);
		return 1;
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
		ins.data = rom[pc];
		pcflag = 1;
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
				add(ins.A.ra,ins.A.rb,ins.A.rc);
				break;
			case OR:
				sub(ins.A.ra,ins.A.rb,ins.A.rc);
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
		pc+=pcflag;


		d_insnum++;
	}

	
	for(int i = 0; i < REGNUM; i++){
		printf("%s = %u\n", reg2name(i), reg[i]);
	}
	printf("Number of Instruction : %d\n",d_insnum);

	return 0;
}

char* op2name(unsigned int op){
	return names[op];
}
char* reg2name(unsigned int reg){
	return rnames[reg];
}

void ld(unsigned int ra, unsigned int rb, int cx){
	ra = ram[reg[rb]+cx];
}
void st(unsigned int ra, unsigned int rb, int cx){
	ram[reg[rb]+cx] = ra;
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
void and(unsigned int ra, unsigned int rb, unsigned int rc){
	reg[ra] = reg[rb] & reg[rc];
}
void or(unsigned int ra, unsigned int rb, unsigned int rc){
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
	lr = pc;
	pc = pc + cx;
	pcflag = 0;
}
void ret(){
	pc = lr;
}
void push(unsigned int ra){
	sp--;
	ram[sp] = reg[ra];
}
void pop(unsigned int ra){
	reg[ra] = ram[sp];
	sp++;
}

