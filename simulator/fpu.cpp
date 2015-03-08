#include <cmath>
#include "fpu.h"

typedef union{
	uint32_t r;
	int d;
	float f;
}FU;


extern "C" uint32_t fadd(uint32_t, uint32_t);
extern "C" uint32_t fmul(uint32_t, uint32_t);
extern "C" uint32_t finv(uint32_t);
extern "C" uint32_t fsqrt(uint32_t);
extern "C" uint32_t _fabs(uint32_t);
extern "C" uint32_t fcmp(uint32_t, uint32_t);
extern "C" uint32_t ftoi(uint32_t);
extern "C" uint32_t itof(uint32_t);

uint32_t FPU::add(uint32_t x, uint32_t y){
	return fadd(x,y);
}

uint32_t FPU::sub(uint32_t x, uint32_t y){
	return fadd(x, y ^ 0x80000000);
}

uint32_t FPU::mul(uint32_t x, uint32_t y){
	return fmul(x,y);
}

int FPU::cmp(uint32_t x, uint32_t y){
	return fcmp(x,y);
}

uint32_t FPU::inv(uint32_t x){
	return finv(x);
}

uint32_t FPU::sqrt(uint32_t x){
	return fsqrt(x);
}

uint32_t FPU::abs(uint32_t x){
	return _fabs(x);
}

uint32_t FPU::_ftoi(uint32_t x){
	return ftoi(x);
}

uint32_t FPU::_itof(uint32_t x){
	return itof(x);
}
