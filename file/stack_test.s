:main
ADDI	r1	r0	0x41
ADDI	r2	r0	0x5B
ADDI	r3	r1	0
:loop1
PUSH	r3
ADDI	r3	r3	1
BEQ	r3	r2	:loop2
BEQ	r0	r0	:loop1
:loop2
POP	r3
ST	r3	r0	0xffff
BEQ	r3	r1	:main
BEQ	r0	r0	:loop2

