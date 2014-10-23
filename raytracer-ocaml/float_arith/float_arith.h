#ifndef _FLOAT_ARITH_H
#define _FLOAT_ARITH_H

void push(int rn, uint32_t r[], uint32_t s[], int *sp);
void pop(int rn, uint32_t r[], uint32_t s[], int *sp);
void load(int rn, int addr, uint32_t r[], uint32_t m[]);
void store(int rn, int addr, uint32_t r[], uint32_t m[]);
uint32_t ftoi(float a);
float itof(uint32_t a);

#endif
