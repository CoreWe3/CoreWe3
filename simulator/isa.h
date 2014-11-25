
typedef union{
	unsigned int data;
	struct {
		int cx:8;
		unsigned int rc:6;
		unsigned int rb:6;
		unsigned int ra:6;
		unsigned int op:5;
		unsigned int fg:1;
	} A;
	struct {
		int cx:14;
		unsigned int rb:6;
		unsigned int ra:6;
		unsigned int op:5;
		unsigned int fg:1;
	} L;
	struct {
		int cx:20;
		unsigned int ra:6;
		unsigned int op:5;
		unsigned int fg:1;
	} X;
	struct {
		int cx:26;
		unsigned int op:5;
		unsigned int fg:1;
	} J;
} INS;


#define ISANUM 0x1A
const char* names[] = {"LD","ST","LDA","STA","LDIH","LDIL","ADD","SUB","FNEG","ADDI","AND","OR","XOR","SHL","SHR","SHLI","SHRI","BEQ","BLE","BLT","BFLE","JSUB","RET","PUSH","POP","LDI"};
#define LD   0x0
#define ST   0x1
#define LDA  0x2
#define STA  0x3
#define LDIH 0x4
#define LDIL 0x5
#define ADD  0x6
#define SUB  0x7
#define FNEG 0x8
#define ADDI 0x9
#define AND  0xA
#define OR   0xB
#define XOR  0xC
#define SHL  0xD
#define SHR  0xE
#define SHLI 0xF
#define SHRI 0x10
#define BEQ  0x11
#define BLE  0x12
#define BLT  0x13
#define BFLE 0x14
#define JSUB 0x15
#define RET  0x16
#define PUSH 0x17
#define POP  0x18
#define LDI  0x19

#define REGNUM 64
const char* rnames[] = {"r0","r1","r2","r3","r4","r5","r6","r7","r8","r9","r10","r11","r12","r13","r14","r15","r16","r17","r18","r19","r20","r21","r22","r23","r24","r25","r26","r27","r28","r29","r30","r31","r32","r33","r34","r35","r36","r37","r38","r39","r40","r41","r42","r43","r44","r45","r46","r47","r48","r49","r50","r51","r52","r53","r54","r55","r56","r57","r58","r59","r60","r61","r62","r63"};
typedef union{
	unsigned int u;
	int d;
	float f;
} REG;
REG reg[REGNUM];


#define RAMSIZE 0x100000
#define ROMSIZE 0x100000
unsigned int pc=0;
unsigned int pcflag;
unsigned int sp=0xffffe;
#define STACKLIMIT 0xf0000
unsigned int ram[RAMSIZE];
unsigned int rom[ROMSIZE];
#define IOADDR 0xfffff

