#pragma once
#include <iostream>

class FPU{
	public:
		static uint32_t fadd(uint32_t, uint32_t);
		static uint32_t fsub(uint32_t, uint32_t);
		static uint32_t fmul(uint32_t, uint32_t);
		static uint32_t fdiv(uint32_t, uint32_t);
		static int fcmp(uint32_t, uint32_t);
		static uint32_t fsqrt(uint32_t);
		static uint32_t fabs(uint32_t);
		static uint32_t ftoi(uint32_t);
		static uint32_t itof(uint32_t);

};
