#include <cmath>
#include "fpu_c.h"
#include "fpu.h"

typedef union{
	uint32_t r;
	int d;
	float f;
}FU;

uint32_t FPU::add(uint32_t x, uint32_t y){
	return fadd(x,y);
}

uint32_t FPU::sub(uint32_t x, uint32_t y){
	FU xfu, yfu, zfu;
	xfu.r = x; yfu.r = y;
	zfu.f = xfu.f - yfu.f;
	return zfu.r;
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
	FU xfu, yfu;
	xfu.r = x;
	yfu.f = std::sqrt(xfu.f);
	return yfu.r;
}

uint32_t FPU::abs(uint32_t x){
	FU xfu, yfu;
	xfu.r = x;
	yfu.f = std::abs(xfu.f);
	return yfu.r;
}

uint32_t FPU::_ftoi(uint32_t x){
	FU xfu, yfu;
	xfu.r = x;
	yfu.d = xfu.f;
	return yfu.r;
}

uint32_t FPU::_itof(uint32_t x){
	FU xfu, yfu;
	xfu.r = x;
	yfu.f = xfu.d;
	return yfu.r;
}
