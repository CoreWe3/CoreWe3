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

int dline = 1;

int name2op(char* op){
	if(op==NULL){
		printf("error at line : %d\n",dline);
		exit(1);
	}
	int num = -1;
	for(int i = 0; i < ISANUM; i++){
		if(strcmp(names[i], op)==0){
			num = i;
			break;
		}
	}
	return num;
}

int name2reg(char* reg){
	if(reg==NULL){
		printf("error at line : %d\n",dline);
		exit(1);
	}
	int num = -1;
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


std::map<std::string,int> label;

int getimmediate(char* str, int l){
	if(str==NULL){
		printf("error on %d\n",dline);
		exit(1);
	}
	if(str[0]==':'){
		if(label.count(str) == 0){
			printf("WARN: Invalid Label : %s\n",str);
		}
		return label[str]-l;
	}else if (str[0]=='.'){
		if(label.count(str) == 0){
			printf("WARN: Invalid Label : %s\n",str);
		}
		return label[str];
	}else{
		return strtol(str,NULL,0);
	}
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
	std::list<std::string> fdata;
	while(fgets(buffer,256,stdin)!=NULL){
		strcpy(buffer2,buffer);
		char* tmp = strtok(buffer2, tokens);
		if(tmp==NULL) continue;
		fdata.push_back(buffer);
	}
	
	std::list<std::string>::iterator it;
	std::list<std::string> data;
	
	//Preprocess
	it = fdata.begin();
	while(it != fdata.end()){
		strncpy(buffer,(*it).c_str(),256);
		strcpy(buffer2,buffer);
		int vop = name2op(strtok(buffer, tokens));
		char *ra, *rb, *rc, *cx;
		if(vop == ADDI){
			ra = strtok(NULL,tokens);
			rb = strtok(NULL,tokens);
			cx = strtok(NULL,tokens);
			if (strcmp(rb,"r0")==0){
				sprintf(buffer,"LDI\t%s\t%s\t",ra,cx);
				data.push_back(buffer);
			}else{
				data.push_back(buffer2);
			}
		}else{
			data.push_back(buffer2);
		}
		it++;
	}

	//Detect Label
	int line = 1;
	it = data.begin();
	while(it != data.end()){
		strncpy(buffer,(*it).c_str(),256);
		char* op = strtok(buffer, tokens);
		if(op != NULL){
			if(op[0]==':'){
				label[op] = line;
				printf("%s to %d\n",op,line);
			}else if(op[0]=='.'){
				int t = strtol(strtok(NULL,tokens),NULL,0);
				printf("%s is %d\n",op,t);
				label[op] = t;
			}else{
				if(name2op(op)==LDI){
					strtok(NULL,tokens);
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
			if(op[0]!=':'&&op[0]!='.'){
				num = name2op(op);
				char *ra, *rb, *rc, *cx;
				switch(num){
					case LD:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						ld(name2reg(ra),name2reg(rb),getimmediate(cx,line));
						break;
					case ST:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						st(name2reg(ra),name2reg(rb),getimmediate(cx,line));
						break;
					case LDA:
						ra = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						lda(name2reg(ra),getimmediate(cx,line));
						break;
					case STA:
						ra = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						sta(name2reg(ra),getimmediate(cx,line));
						break;
					case LDIH:
						ra = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						ldih(name2reg(ra),getimmediate(cx,line));
						break;
					case LDIL:
						ra = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						ldil(name2reg(ra),getimmediate(cx,line));
					case LDI:
						ra = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						ldi(name2reg(ra),getimmediate(cx,line));
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
						addi(name2reg(ra),name2reg(rb),getimmediate(cx,line));
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
						shli(name2reg(ra),name2reg(rb),getimmediate(cx,line));
						break;
					case SHRI:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						shri(name2reg(ra),name2reg(rb),getimmediate(cx,line));
						break;
					case BEQ:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						beq(name2reg(ra),name2reg(rb),getimmediate(cx,line));
						break;
					case BLE:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						ble(name2reg(ra),name2reg(rb),getimmediate(cx,line));
						break;
					case BLT:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						blt(name2reg(ra),name2reg(rb),getimmediate(cx,line));
						break;
					case BFLE:
						ra = strtok(NULL,tokens);
						rb = strtok(NULL,tokens);
						cx = strtok(NULL,tokens);
						bfle(name2reg(ra),name2reg(rb),getimmediate(cx,line));
						break;
					case JSUB:
						cx = strtok(NULL,tokens);
						jsub(getimmediate(cx,line));
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
		dline++;
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
	//if((cx & 0xffff0000) == 0){
	//	ldil(ra, cx & 0xffff);
	//}else{
		ldil(ra, cx & 0xffff);
		ldih(ra, cx >> 16);
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
