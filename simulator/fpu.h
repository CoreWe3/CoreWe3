#pragma once
#include <iostream>
#include <stdint.h>

class FPU{
	public:
		static uint32_t add(uint32_t, uint32_t);
		static uint32_t sub(uint32_t, uint32_t);
		static uint32_t mul(uint32_t, uint32_t);
		static uint32_t inv(uint32_t);
		static int cmp(uint32_t, uint32_t);
		static uint32_t sqrt(uint32_t);
		static uint32_t abs(uint32_t);
		static uint32_t _ftoi(uint32_t);
		static uint32_t _itof(uint32_t);
		static uint32_t floor(uint32_t);

};
