:main
	LDIH	r3	0x0080
	LDIL	r3	0x0000 # loop iterator
	LDIH	r4	0x7f7f
	LDIL	r4	0xffff # end
:loop_main
	PUSH	r3
	PUSH	r4
	JSUB	:fsqrt
	ADDI	r4	r0	8
	ST	r3	r0	-1
	SHR	r3	r3	r4
	ST	r3	r0	-1
	SHR	r3	r3	r4
	ST	r3	r0	-1
	SHR	r3	r3	r4
	ST	r3	r0	-1
	POP	r4
	POP	r3
	ADDI	r3	r3	1
	BEQ	r3	r4	:end_main
	BEQ	r0	r0	:loop_main
:end_main
	ADD	r0	r0	r0
