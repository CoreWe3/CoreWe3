#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

uint32_t _fabs(uint32_t r){
	return r & 0x7FFFFFFF;
}
