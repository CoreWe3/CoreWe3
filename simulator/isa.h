
typedef union{
	unsigned int data;
	struct {
		unsigned int op:8;
		unsigned int ra:4;
		unsigned int rb:4;
		unsigned int rc:4;
		int cx:12;
	} A;
	struct {
		unsigned int op:8;
		unsigned int ra:4;
		unsigned int rb:4;
		int cx:16;
	} L;
	struct {
		unsigned int op:8;
		unsigned int ra:4;
		int cx:24;
	} J;
} INS;


#define ISANUM 16

char* names[] = {"LD","ST","ADD","SUB","ADDI","AND","OR","SHL","SHR","BEQ","BLE","BLT","JSUB","RET","PUSH","POP"};


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
#define BLE  0x10
#define BLT  0x11
#define JSUB  0x12
#define RET  0x13
#define PUSH  0x14
#define POP  0x15


char* rnames[] = {"r0","r1","r2","r3","r4","r5","r6","r7","r8","r9","r10","r11","r12","r13","r14","r15"};

#define REGNUM 16
#define RAMSIZE 0x100000
#define ROMSIZE 0x100000
unsigned int reg[REGNUM];
unsigned int pc;
unsigned int pcflag;
unsigned int lr;
unsigned int sp;
unsigned int ram[RAMSIZE];
unsigned int rom[ROMSIZE];
