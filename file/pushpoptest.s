ADDI	r1	r0	1
ADDI	r2	r0	2
PUSH	r1
PUSH	r2
JSUB :L2
:L1
POP	r3
POP	r4
BEQ	r0	r0	:L3
:L2
RET
:L3
