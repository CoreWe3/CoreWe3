
typedef union{
	unsigned int data;
	struct {
		int cx:12;
		unsigned int rc:4;
		unsigned int rb:4;
		unsigned int ra:4;
		unsigned int op:8;
	} A;
	struct {
		unsigned int cx:12;
		unsigned int rc:4;
		unsigned int rb:4;
		unsigned int ra:4;
		unsigned int op:8;
	} AX;
	struct {
		int cx:16;
		unsigned int rb:4;
		unsigned int ra:4;
		unsigned int op:8;
	} L;
	struct {
		unsigned int cx:16;
		unsigned int rb:4;
		unsigned int ra:4;
		unsigned int op:8;
	} LX;
	struct {
		int cx:24;
		unsigned int op:8;
	} J;
} INS;

typedef union{
	unsigned int u;
	int d;
} REG;

#define ISANUM 0x13

const char* names[] = {"LD","ST","ADD","SUB","ADDI","AND","OR","SHL","SHR","BEQ","BLE","BLT","JSUB","RET","PUSH","POP","XOR","LDIH","LDIL"};

#define LD   0x0
#define ST   0x1
#define ADD  0x2
#define SUB  0x3
#define ADDI  0x4
#define AND  0x5
#define OR  0x6
#define SHL  0x7
#define SHR  0x8
#define BEQ  0x9
#define BLE  0xa
#define BLT  0xb
#define JSUB  0xc
#define RET  0xd
#define PUSH  0xe
#define POP  0xf
#define XOR  0x10
#define LDIH 0x11
#define LDIL 0x12

const char* rnames[] = {"r0","r1","r2","r3","r4","r5","r6","r7","r8","r9","r10","r11","r12","r13","r14","r15"};

#define REGNUM 16
#define RAMSIZE 0x100000
#define ROMSIZE 0x100000
REG reg[REGNUM];
unsigned int pc=0;
unsigned int pcflag;
unsigned int sp=0xF7FFF;
unsigned int ram[RAMSIZE];
unsigned int rom[ROMSIZE];

#define IOADDR 0xfffff
