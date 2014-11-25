#ifndef _FLOAT_ARITH_H
#define _FLOAT_ARITH_H
#include<stdint.h>

#define SHL(a, b) (b < 32? a << b: 0)
#define SHR(a, b) (b < 32? a >> b: 0)
#define PUSH(n) push((n), r, s, &sp)
#define POP(n) pop((n), r, s, &sp)

void push(int rn, uint32_t r[], uint32_t s[], int *sp);
void pop(int rn, uint32_t r[], uint32_t s[], int *sp);
void load(int rn, int addr, uint32_t r[], uint32_t m[]);
void store(int rn, int addr, uint32_t r[], uint32_t m[]);
uint32_t ftoui(float a);
float uitof(uint32_t a);
int uitoi(uint32_t a);
uint32_t itoui(int a);

#endif
