#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "isa.h"

unsigned int ld(unsigned int ra, unsigned int rb, int cx);
unsigned int st(unsigned int ra, unsigned int rb, int cx);
unsigned int add(unsigned int ra, unsigned int rb, unsigned int rc);
unsigned int sub(unsigned int ra, unsigned int rb, unsigned int rc);
unsigned int addi(unsigned int ra, unsigned int rb, int cx);
unsigned int and(unsigned int ra, unsigned int rb, unsigned int rc);
unsigned int or(unsigned int ra, unsigned int rb, unsigned int rc);
unsigned int shl(unsigned int ra, unsigned int rb, int cx);
unsigned int shr(unsigned int ra, unsigned int rb, int cx);
unsigned int beq(unsigned int ra, unsigned int rb, int cx);
unsigned int ble(unsigned int ra, unsigned int rb, int cx);
unsigned int blt(unsigned int ra, unsigned int rb, int cx);
unsigned int jsub(int cx);
unsigned int ret();
unsigned int push(unsigned int ra);
unsigned int pop(unsigned int ra);

unsigned int name2op(char* op);
unsigned int name2reg(char* reg);

int main(int argc, char* argv[])
{
	if(argc < 2){
		printf("Need output filename\n");
		return 1;
	}

	char buffer[256];
	char *tokens = "\t \n";
	int line = 1;

	FILE *fpw = fopen(argv[1],"wb");
	if(fpw == NULL){
		printf("Can't open %s\n",argv[1]);
		return 1;
	}

	while(fgets(buffer,256,stdin)!=NULL){
		int num = 0;
		char* op = strtok(buffer, tokens);
		if(op==NULL) continue;
		num = name2op(op);
		unsigned int code;
		char *ra, *rb, *rc, *cx;
		switch(num){
			case LD:
				ra = strtok(NULL,tokens);
				rb = strtok(NULL,tokens);
				cx = strtok(NULL,tokens);
				code = ld(name2reg(ra),name2reg(rb),atoi(cx));
				break;
			case ST:
				ra = strtok(NULL,tokens);
				rb = strtok(NULL,tokens);
				cx = strtok(NULL,tokens);
				code = st(name2reg(ra),name2reg(rb),atoi(cx));
				break;
			case ADD:
				ra = strtok(NULL,tokens);
				rb = strtok(NULL,tokens);
				rc = strtok(NULL,tokens);
				code = add(name2reg(ra),name2reg(rb),name2reg(rc));
				break;
			case SUB:
				ra = strtok(NULL,tokens);
				rb = strtok(NULL,tokens);
				rc = strtok(NULL,tokens);
				code = sub(name2reg(ra),name2reg(rb),name2reg(rc));
				break;
			case ADDI:
				ra = strtok(NULL,tokens);
				rb = strtok(NULL,tokens);
				cx = strtok(NULL,tokens);
				code = addi(name2reg(ra),name2reg(rb),atoi(cx));
				break;
			case AND:
				ra = strtok(NULL,tokens);
				rb = strtok(NULL,tokens);
				rc = strtok(NULL,tokens);
				code = and(name2reg(ra),name2reg(rb),name2reg(rc));
				break;
			case OR:
				ra = strtok(NULL,tokens);
				rb = strtok(NULL,tokens);
				rc = strtok(NULL,tokens);
				code = or(name2reg(ra),name2reg(rb),name2reg(rc));
				break;
			case SHL:
				ra = strtok(NULL,tokens);
				rb = strtok(NULL,tokens);
				rc = strtok(NULL,tokens);
				code = shl(name2reg(ra),name2reg(rb),name2reg(rc));
				break;
			case SHR:
				ra = strtok(NULL,tokens);
				rb = strtok(NULL,tokens);
				rc = strtok(NULL,tokens);
				code = shr(name2reg(ra),name2reg(rb),name2reg(rc));
				break;
			case BEQ:
				ra = strtok(NULL,tokens);
				rb = strtok(NULL,tokens);
				cx = strtok(NULL,tokens);
				code = beq(name2reg(ra),name2reg(rb),atoi(cx));
				break;
			case BLE:
				ra = strtok(NULL,tokens);
				rb = strtok(NULL,tokens);
				cx = strtok(NULL,tokens);
				code = ble(name2reg(ra),name2reg(rb),atoi(cx));
				break;
			case BLT:
				ra = strtok(NULL,tokens);
				rb = strtok(NULL,tokens);
				cx = strtok(NULL,tokens);
				code = blt(name2reg(ra),name2reg(rb),atoi(cx));
				break;
			case JSUB:
				cx = strtok(NULL,tokens);
				code = jsub(atoi(cx));
				break;
			case RET:
				code = ret();
				break;
			case PUSH:
				ra = strtok(NULL,tokens);
				code = push(name2reg(ra));
				break;
			case POP:
				ra = strtok(NULL,tokens);
				code = pop(name2reg(ra));
				break;
			default:
				printf("no such instruction \"%s\" : line %d\n",op,line);
				return 1;
		}
		line++;
		fwrite(&code,sizeof(unsigned int),1,fpw);
	}
	fclose(fpw);
	return 0;
}



unsigned int ld(unsigned int ra, unsigned int rb, int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = LD;
	ins.L.ra = ra;
	ins.L.rb = rb;
	ins.L.cx = cx;
	return ins.data;
}
unsigned int st(unsigned int ra, unsigned int rb, int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = ST;
	ins.L.ra = ra;
	ins.L.rb = rb;
	ins.L.cx = cx;
	return ins.data;
}
unsigned int add(unsigned int ra, unsigned int rb, unsigned int rc){
	INS ins;
	ins.data = 0;
	ins.A.op = ADD;
	ins.A.ra = ra;
	ins.A.rb = rb;
	ins.A.rc = rc;
	return ins.data;
}
unsigned int sub(unsigned int ra, unsigned int rb, unsigned int rc){
	INS ins;
	ins.data = 0;
	ins.A.op = SUB;
	ins.A.ra = ra;
	ins.A.rb = rb;
	ins.A.rc = rc;
	return ins.data;
}
unsigned int addi(unsigned int ra, unsigned int rb, int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = ADDI;
	ins.L.ra = ra;
	ins.L.rb = rb;
	ins.L.cx = cx;
	return ins.data;
}
unsigned int and(unsigned int ra, unsigned int rb, unsigned int rc){
	INS ins;
	ins.data = 0;
	ins.A.op = AND;
	ins.A.ra = ra;
	ins.A.rb = rb;
	ins.A.rc = rc;
	return ins.data;
}
unsigned int or(unsigned int ra, unsigned int rb, unsigned int rc){
	INS ins;
	ins.data = 0;
	ins.A.op = OR;
	ins.A.ra = ra;
	ins.A.rb = rb;
	ins.A.rc = rc;
	return ins.data;
}
unsigned int shl(unsigned int ra, unsigned int rb, int cx){
	INS ins;
	ins.data = 0;
	ins.A.op = SHL;
	ins.A.ra = ra;
	ins.A.rb = rb;
	ins.A.cx = cx;
	return ins.data;
}
unsigned int shr(unsigned int ra, unsigned int rb, int cx){
	INS ins;
	ins.data = 0;
	ins.A.op = SHR;
	ins.A.ra = ra;
	ins.A.rb = rb;
	ins.A.cx = cx;
	return ins.data;
}
unsigned int beq(unsigned int ra, unsigned int rb, int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = BEQ;
	ins.L.ra = ra;
	ins.L.rb = rb;
	ins.L.cx = cx;
	return ins.data;
}
unsigned int ble(unsigned int ra, unsigned int rb, int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = BLE;
	ins.L.ra = ra;
	ins.L.rb = rb;
	ins.L.cx = cx;
	return ins.data;
}
unsigned int blt(unsigned int ra, unsigned int rb, int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = BLT;
	ins.L.ra = ra;
	ins.L.rb = rb;
	ins.L.cx = cx;
	return ins.data;
}
unsigned int jsub(int cx){
	INS ins;
	ins.data = 0;
	ins.J.op = JSUB;
	ins.J.cx = cx;
	return ins.data;
}
unsigned int ret(){
	INS ins;
	ins.data = 0;
	ins.J.op = RET;
	return ins.data;
}
unsigned int push(unsigned int ra){
	INS ins;
	ins.data = 0;
	ins.A.op = PUSH;
	ins.A.ra = ra;
	return ins.data;
}
unsigned int pop(unsigned int ra){
	INS ins;
	ins.data = 0;
	ins.A.op = POP;
	ins.A.ra = ra;
	return ins.data;
}


unsigned int name2op(char* op){
	int num = 10000;
	for(int i = 0; i < ISANUM; i++){
		if(strcmp(names[i], op)==0){
			num = i;
			break;
		}
	}
	return num;
}
unsigned int name2reg(char* reg){
	int num = 10000;
	for(int i = 0; i < REGNUM; i++){
		if(strcmp(rnames[i], reg)==0){
			num = i;
			break;
		}
	}
	return num;
}
