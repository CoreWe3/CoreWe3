#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "isa.h"

const char* op2name(unsigned int op);
const char* reg2name(unsigned int reg);

int main(int argc, char* argv[])
{
	if(argc < 0){
		printf("Need Binary ilename\n");
		return 1;
	}

	int num = 1;
	INS ins;
	FILE *fpr = fopen(argv[1],"rb");
	if (fpr == NULL){
		printf("Can't open %s\n",argv[1]);
		return 1;
	}

	while(fread(&(ins.data),sizeof(unsigned int),1,fpr) > 0){
		switch(ins.A.op){
			case LD:
			case ST:
			case ADDI:
			case BEQ:
			case BLE:
			case BLT:
				printf("%s\t%s\t%s\t%d\n",op2name(ins.L.op),reg2name(ins.L.ra),reg2name(ins.L.rb),ins.L.cx);
				break;
			case ADD:
			case SUB:
			case AND:
			case OR:
			case XOR:
			case SHL:
			case SHR:
				printf("%s\t%s\t%s\t%s\n",op2name(ins.A.op),reg2name(ins.A.ra),reg2name(ins.A.rb),reg2name(ins.A.rc));
				break;
			case JSUB:
				printf("%s\t%d\n",op2name(ins.J.op),ins.L.cx);
				break;
			case RET:
				printf("%s\n",op2name(ins.J.op));
				break;
			case PUSH:
			case POP:
				printf("%s\t%s\n",op2name(ins.A.op),reg2name(ins.A.ra));
				break;
			default:
				printf("no such instruction \"%d\" : line %d\n",ins.A.op,num);
				break;
		}
		num++;
	}
	fclose(fpr);
	return 0;
}




const char* op2name(unsigned int op){
	return names[op];
}
const char* reg2name(unsigned  int reg){
	return rnames[reg];
}
