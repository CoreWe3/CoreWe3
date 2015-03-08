#include <stdint.h>

void push(int rn, uint32_t r[], uint32_t s[], int *sp) {
    s[*sp] = r[rn];
    *sp = *sp + 1;
}

void pop(int rn, uint32_t r[], uint32_t s[], int *sp) {
    *sp = *sp - 1;
    r[rn] = s[*sp];
}

void load(int rn, int addr, uint32_t r[], uint32_t m[]){
    r[rn] = m[addr];
}

void store(int rn, int addr, uint32_t r[], uint32_t m[]){
    m[addr] = r[rn];
}

uint32_t ftoui(float a) {
    uint32_t *p;
    p = (uint32_t *) &a;
    return *p;
}

float uitof(uint32_t a) {
    float *p;
    p = (float *) &a;
    return *p;
}

int uitoi(uint32_t a) {
    int *p;
    p = (int *) &a;
    return *p;
}


uint32_t itoui(int a) {
    uint32_t *p;
    p = (uint32_t *) &a;
    return *p;
}
