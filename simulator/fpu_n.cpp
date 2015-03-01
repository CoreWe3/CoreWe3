#include <cmath>
#include "fpu.h"

typedef union{
	uint32_t r;
	int d;
	float f;
}FU;

uint32_t FPU::add(uint32_t x, uint32_t y){
	FU xfu, yfu, zfu;
	xfu.r = x; yfu.r = y;
	zfu.f = xfu.f + yfu.f;
	return zfu.r;
}

uint32_t FPU::sub(uint32_t x, uint32_t y){
	FU xfu, yfu, zfu;
	xfu.r = x; yfu.r = y;
	zfu.f = xfu.f - yfu.f;
	return zfu.r;
}

uint32_t FPU::mul(uint32_t x, uint32_t y){
	FU xfu, yfu, zfu;
	xfu.r = x; yfu.r = y;
	zfu.f = xfu.f * yfu.f;
	return zfu.r;
}

int FPU::cmp(uint32_t x, uint32_t y){
	FU xfu, yfu, zfu;
	xfu.r = x; yfu.r = y;
	zfu.f = xfu.f - yfu.f;
	if (zfu.f < 0) return -1;
	else if (zfu.f > 0) return 1;
	else return 0;
}

uint32_t FPU::inv(uint32_t x){
	FU xfu, yfu;
	xfu.r = x;
	yfu.f = 1.0 / xfu.f;
	return yfu.r;
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
