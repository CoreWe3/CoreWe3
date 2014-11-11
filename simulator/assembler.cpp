#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string>
#include <map>
#include <list>
#include "isa.h"

void ld(unsigned int ra, unsigned int rb, int cx);
void st(unsigned int ra, unsigned int rb, int cx);
void lda(unsigned int ra, unsigned int cx);
void sta(unsigned int ra, unsigned int cx);
void ldih(unsigned int ra, unsigned int cx);
void ldil(unsigned int ra, unsigned int cx);
void ldi(unsigned int ra, unsigned int cx);
void add(unsigned int ra, unsigned int rb, unsigned int rc);
void sub(unsigned int ra, unsigned int rb, unsigned int rc);
void fneg(unsigned int ra, unsigned int rb);
void addi(unsigned int ra, unsigned int rb, int cx);
void _and(unsigned int ra, unsigned int rb, unsigned int rc);
void _or(unsigned int ra, unsigned int rb, unsigned int rc);
void _xor(unsigned int ra, unsigned int rb, unsigned int rc);
void shl(unsigned int ra, unsigned int rb, unsigned int rc);
void shr(unsigned int ra, unsigned int rb, unsigned int rc);
void shli(unsigned int ra, unsigned int rb, int cx);
void shri(unsigned int ra, unsigned int rb, int cx);
void beq(unsigned int ra, unsigned int rb, unsigned int cx);
void ble(unsigned int ra, unsigned int rb, unsigned int cx);
void blt(unsigned int ra, unsigned int rb, unsigned int cx);
void bfle(unsigned int ra, unsigned int rb, unsigned int cxZ);
void jsub(unsigned int cx);
void ret();
void push(unsigned int ra);
void pop(unsigned int ra);

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

void print_L(unsigned int x) {
    int i;
    for (i = 31; i >= 0; --i) {
        printf("%d", (x >> i) & 1);
        if (i == 24  || i == 20  || i== 16) printf(" ");
    }
    printf("\n");
}


FILE *fpw = NULL;

int main(int argc, char* argv[])
{
	if(argc < 2){
		printf("Need output filename\n");
		return 1;
	}

	fpw = fopen(argv[1],"wb");
	if(fpw == NULL){
		printf("Can't open %s\n",argv[1]);
		return 1;
	}

	//Get Data
	char buffer[256];
	char buffer2[256];
	const char *tokens = "\t \n";
	std::list<std::string> data;
	while(fgets(buffer,256,stdin)!=NULL){
		strcpy(buffer2,buffer);
		char* tmp = strtok(buffer2, tokens);
		if(tmp==NULL) continue;
		data.push_back(buffer);
	}

	//Detect Label
	int line = 1;
	std::map<std::string,int> label;
	std::list<std::string>::iterator it = data.begin();
	while(it != data.end()){
		strncpy(buffer,(*it).c_str(),256);
		char* op = strtok(buffer, tokens);
		if(op != NULL){
			if(op[0]==':'){
				label[op] = line;
				printf("%s to %d\n",op,line);
			}else{
				if(name2op(op)==LDI){
					strtok(NULL,tokens);
					//int t = strtol(strtok(NULL,tokens),NULL,0);
					line++;
				}
				line++;
			}
		}else{
			printf("error at line %s\n",buffer);
		}
		it++;
	}

	//Make Assembly
	line = 1;
	it = data.begin();
	while(it != data.end()){
		strcpy(buffer,(*it).c_str());
		int num = 0;
		char* op = strtok(buffer, tokens);
		if(op!=NULL){
			if(op[0]!=':'){
				num = name2op(op);
				char *ra, *rb, *rc, *cx;
				switch(num){
					case LD:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						ld(name2reg(ra),name2reg(rb),strtol(cx,NULL,0));
						break;
					case ST:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						st(name2reg(ra),name2reg(rb),strtol(cx,NULL,0));
						break;
					case LDA:
						ra = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						lda(name2reg(ra),strtol(cx,NULL,0));
						break;
					case STA:
						ra = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						sta(name2reg(ra),strtol(cx,NULL,0));
						break;
					case LDIH:
						ra = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						ldih(name2reg(ra),strtol(cx,NULL,0));
						break;
					case LDIL:
						ra = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						ldil(name2reg(ra),strtol(cx,NULL,0));
						break;
					case LDI:
						ra = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						ldi(name2reg(ra),strtol(cx,NULL,0));
						line++;
						break;
					case ADD:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						rc = strtok(NULL,tokens);
						add(name2reg(ra),name2reg(rb),name2reg(rc));
						break;
					case SUB:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						rc = strtok(NULL,tokens);
						sub(name2reg(ra),name2reg(rb),name2reg(rc));
						break;
					case FNEG:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						fneg(name2reg(ra),name2reg(rb));
						break;
					case ADDI:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						addi(name2reg(ra),name2reg(rb),strtol(cx,NULL,0));
						break;
					case AND:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						rc = strtok(NULL,tokens);
						_and(name2reg(ra),name2reg(rb),name2reg(rc));
						break;
					case OR:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						rc = strtok(NULL,tokens);
						_or(name2reg(ra),name2reg(rb),name2reg(rc));
						break;
					case XOR:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						rc = strtok(NULL,tokens);
						_xor(name2reg(ra),name2reg(rb),name2reg(rc));
						break;
					case SHL:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						rc = strtok(NULL,tokens);
						shl(name2reg(ra),name2reg(rb),name2reg(rc));
						break;
					case SHR:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						rc = strtok(NULL,tokens);
						shr(name2reg(ra),name2reg(rb),name2reg(rc));
						break;
					case SHLI:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						shli(name2reg(ra),name2reg(rb),strtol(cx,NULL,0));
						break;
					case SHRI:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						shri(name2reg(ra),name2reg(rb),strtol(cx,NULL,0));
						break;
					case BEQ:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						if(cx[0] == ':') {
							if(label.count(cx) == 0){
								printf("WARN: Invalid Label\n");
							}
							beq(name2reg(ra),name2reg(rb),label[cx]-line);
						}else{
							beq(name2reg(ra),name2reg(rb),strtol(cx,NULL,0));
						}
						break;
					case BLE:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						if(cx[0] == ':') {
							if(label.count(cx) == 0){
								printf("WARN: Invalid Label\n");
							}
							ble(name2reg(ra),name2reg(rb),label[cx]-line);
						}else{
							ble(name2reg(ra),name2reg(rb),strtol(cx,NULL,0));
						}
						break;
					case BLT:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						if(cx[0] == ':') {
							if(label.count(cx) == 0){
								printf("WARN: Invalid Label\n");
							}
							blt(name2reg(ra),name2reg(rb),label[cx]-line);
						}else{
							blt(name2reg(ra),name2reg(rb),strtol(cx,NULL,0));
						}
						break;
					case BFLE:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						if(cx[0] == ':') {
							if(label.count(cx) == 0){
								printf("WARN: Invalid Label\n");
							}
							bfle(name2reg(ra),name2reg(rb),label[cx]-line);
						}else{
							bfle(name2reg(ra),name2reg(rb),strtol(cx,NULL,0));
						}
						break;
					case JSUB:
						cx = strtok(NULL,tokens);
						if(cx[0] == ':') {
							if(label.count(cx) == 0){
								printf("WARN: Invalid Label\n");
							}
							jsub(label[cx]-line);
						}else{
							jsub(strtol(cx,NULL,0));
						}
						break;
					case RET:
						ret();
						break;
					case PUSH:
						ra = strtok(NULL,tokens);
						push(name2reg(ra));
						break;
					case POP:
						ra = strtok(NULL,tokens);
						pop(name2reg(ra));
						break;
					default:
						printf("no such instruction \"%s\" : line %d\n",op,line);
						return 1;
				}
				line++;
			}}
		it++;
	}
	fclose(fpw);
	return 0;
}

void write(unsigned int code){
	fwrite(&code,sizeof(unsigned int),1,fpw);
}

void ld(unsigned int ra, unsigned int rb, int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = LD; ins.L.ra = ra; ins.L.rb = rb; ins.L.cx = cx;
	write(ins.data);
}
void st(unsigned int ra, unsigned int rb, int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = ST; ins.L.ra = ra; ins.L.rb = rb; ins.L.cx = cx;
	write(ins.data);
}
void lda(unsigned int ra, unsigned int cx){
	INS ins;
	ins.data = 0;
	ins.X.op = LDA; ins.X.ra = ra; ins.X.cx = cx;
	write(ins.data);
}
void sta(unsigned int ra, unsigned int cx){
	INS ins;
	ins.data = 0;
	ins.X.op = STA; ins.X.ra = ra; ins.X.cx = cx;
	write(ins.data);
}
void ldih(unsigned int ra, unsigned int cx){
	INS ins;
	ins.data = 0;
	ins.X.op = LDIH; ins.X.ra = ra; ins.X.cx = cx;
	write(ins.data);
}
void ldil(unsigned int ra, unsigned int cx){
	INS ins;
	ins.data = 0;
	ins.X.op = LDIL; ins.X.ra = ra; ins.X.cx = cx;
	write(ins.data);
}
void ldi(unsigned int ra, unsigned int cx){
	//if(cx >> 14 == 0){
	//	addi(ra,0,cx);
	//}else{
		ldih(ra, cx >> 16);
		ldil(ra, cx << 16 >> 16);
	//}
}
void add(unsigned int ra, unsigned int rb, unsigned int rc){
	INS ins;
	ins.data = 0;
	ins.A.op = ADD; ins.A.ra = ra; ins.A.rb = rb; ins.A.rc = rc;
	write(ins.data);
}
void sub(unsigned int ra, unsigned int rb, unsigned int rc){
	INS ins;
	ins.data = 0;
	ins.A.op = SUB; ins.A.ra = ra; ins.A.rb = rb; ins.A.rc = rc;
	write(ins.data);
}
void addi(unsigned int ra, unsigned int rb, int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = ADDI; ins.L.ra = ra; ins.L.rb = rb; ins.L.cx = cx;
	write(ins.data);
}
void fneg(unsigned int ra, unsigned int rb){
	INS ins;
	ins.data = 0;
	ins.A.op = FNEG; ins.A.ra = ra; ins.A.rb = rb;
	write(ins.data);
}
void _and(unsigned int ra, unsigned int rb, unsigned int rc){
	INS ins;
	ins.data = 0;
	ins.A.op = AND; ins.A.ra = ra; ins.A.rb = rb; ins.A.rc = rc;
	write(ins.data);
}
void _or(unsigned int ra, unsigned int rb, unsigned int rc){
	INS ins;
	ins.data = 0;
	ins.A.op = OR; ins.A.ra = ra; ins.A.rb = rb; ins.A.rc = rc;
	write(ins.data);
}
void _xor(unsigned int ra, unsigned int rb, unsigned int rc){
	INS ins;
	ins.data = 0;
	ins.A.op = XOR; ins.A.ra = ra; ins.A.rb = rb; ins.A.rc = rc;
	write(ins.data);
}
void shl(unsigned int ra, unsigned int rb, unsigned int rc){
	INS ins;
	ins.data = 0;
	ins.A.op = SHL; ins.A.ra = ra; ins.A.rb = rb; ins.A.rc = rc;
	write(ins.data);
}
void shr(unsigned int ra, unsigned int rb, unsigned int rc){
	INS ins;
	ins.data = 0;
	ins.A.op = SHR; ins.A.ra = ra;  ins.A.rb = rb; ins.A.rc = rc;
	write(ins.data);
}
void shli(unsigned int ra, unsigned int rb, int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = SHLI; ins.L.ra = ra; ins.L.rb = rb; ins.L.cx = cx;
	write(ins.data);
}
void shri(unsigned int ra, unsigned int rb, int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = SHRI; ins.L.ra = ra; ins.L.rb = rb; ins.L.cx = cx;
	write(ins.data);
}
void beq(unsigned int ra, unsigned int rb, unsigned int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = BEQ; ins.L.ra = ra; ins.L.rb = rb; ins.L.cx = cx;
	write(ins.data);
}
void ble(unsigned int ra, unsigned int rb, unsigned int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = BLE; ins.L.ra = ra; ins.L.rb = rb; ins.L.cx = cx;
	write(ins.data);
}
void blt(unsigned int ra, unsigned int rb, unsigned int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = BLT; ins.L.ra = ra; ins.L.rb = rb; ins.L.cx = cx;
	write(ins.data);
}
void bfle(unsigned int ra, unsigned int rb, unsigned int cx){
	INS ins;
	ins.data = 0;
	ins.L.op = BFLE; ins.L.ra = ra; ins.L.rb = rb; ins.L.cx = cx;
	write(ins.data);
}
void jsub(unsigned int cx){
	INS ins;
	ins.data = 0;
	ins.J.op = JSUB; ins.J.cx = cx;
	write(ins.data);
}
void ret(){
	INS ins;
	ins.data = 0; ins.J.op = RET;
	write(ins.data);
}
void push(unsigned int ra){
	INS ins;
	ins.data = 0;
	ins.A.op = PUSH; ins.A.ra = ra;
	write(ins.data);
}
void pop(unsigned int ra){
	INS ins;
	ins.data = 0;
	ins.A.op = POP; ins.A.ra = ra;
	write(ins.data);
}
