#pragma once

#include <vector>
#include <map>
#include <string>

// Instractions

enum IS : unsigned int{
	LD = 0x0, ST = 0x1, FLD= 0x2, FST = 0x3, ITOF = 0x4, FTOI= 0x5,
	ADD = 0x6,  SUB = 0x7, ADDI = 0x8,  SHL = 0x9, SHR = 0xA, SHLI = 0xB, SHRI = 0xC, LDIH= 0xD,
	FADD = 0xE, FSUB = 0xF, FMUL = 0x10, FDIV = 0x11, FSQRT = 0x12, FABS = 0x13, FCMP = 0x14, FLDIL = 0x15, FLDIH = 0x16,
	J = 0x17, JEQ = 0x18, JLE = 0x19, JLT = 0x1A, JSUB = 0x1B, RET = 0x1C,
	VLDI = 0x20, VFLDI = 0x21, VCMP = 0x22, VCMPI = 0x23
};

const std::map<std::string, unsigned int> INAMES {
	{"LD", LD}, {"ST", ST}, {"FLD", FLD}, {"FST", FST}, {"ITOF", ITOF}, {"FTOI", FTOI},
		{"ADD", ADD}, {"SUB", SUB}, {"ADDI", ADDI} , {"SHL", SHL}, {"SHR", SHR}, {"SHLI", SHLI}, {"SHRI", SHRI}, {"LDIH", LDIH},
		{"FADD", FADD}, {"FSUB", FSUB}, {"FMUL", FMUL}, {"FDIV", FDIV}, {"FSQRT", FSQRT}, {"FABS",FABS}, {"FCMP", FCMP}, {"FLDIL", FLDIL}, {"FLDIH", FLDIH},
		{"J", J}, {"JEQ", JEQ}, {"JLE", JLE}, {"JLT", JLT}, {"JSUB", JSUB}, {"RET", RET},
		{"LDI", VLDI}, {"FLDI", VFLDI}, {"CMP", VCMP}, {"CMPI", VCMPI},
	{"@LD", LD}, {"@ST", ST}, {"@FLD", FLD}, {"@FST", FST}, {"@ITOF", ITOF}, {"@FTOI", FTOI},
		{"@ADD", ADD}, {"@SUB", SUB}, {"@ADDI", ADDI} , {"@SHL", SHL}, {"@SHR", SHR}, {"@SHLI", SHLI}, {"@SHRI", SHRI}, {"@LDIH", LDIH},
		{"@FADD", FADD}, {"@FSUB", FSUB}, {"@FMUL", FMUL}, {"@FDIV", FDIV}, {"@FSQRT", FSQRT}, {"@FABS",FABS}, {"@FCMP", FCMP}, {"@FLDIL", FLDIL}, {"@FLDIH", FLDIH},
		{"@J", J}, {"@JEQ", JEQ}, {"@JLE", JLE}, {"@JLT", JLT}, {"@JSUB", JSUB}, {"@RET", RET},
		{"@LDI", VLDI}, {"@FLDI", VFLDI}, {"@CMP", VCMP}, {"@CMPI", VCMPI}
};

const std::vector<std::string> GREGNAMES {
	"r0",  "r1",  "r2",  "r3",  "r4",  "r5",  "r6",  "r7",  "r8",  "r9",
		"r10", "r11", "r12", "r13", "r14", "r15", "r16", "r17", "r18", "r19",
		"r20", "r21", "r22", "r23", "r24", "r25", "r26", "r27", "r28", "r29",
		"r30", "r31" };

const std::vector<std::string> FREGNAMES {
	"f0",  "f1",  "f2",  "f3",  "f4",  "f5",  "f6",  "f7",  "f8",  "f9",
		"f10", "f11", "f12", "f13", "f14", "f15", "f16", "f17", "f18", "f19",
		"f20", "f21", "f22", "f23", "f24", "f25", "f26", "f27", "f28", "f29",
		"f30", "f31"};

typedef union{
	uint32_t data;
	struct {
		int cx:11;
		unsigned int rc:5;
		unsigned int rb:5;
		unsigned int ra:5;
		unsigned int op:5;
		unsigned int fg:1;
	} A;
	struct {
		int cx:16;
		unsigned int rb:5;
		unsigned int ra:5;
		unsigned int op:5;
		unsigned int fg:1;
	} L;
	struct {
		int cx:25;
		unsigned int br:1;
		unsigned int op:5;
		unsigned int fg:1;
	} J;
} FORMAT;


typedef union{
	uint32_t r;
	unsigned int u;
	int d;
	float f;
} REG;

#define RAMSIZE 0x100000
#define IOADDR   0xfffff

