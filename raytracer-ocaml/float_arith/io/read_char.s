:read_char
	ADDI	r4	r0	0xffff
	ADDI	r5	r0	16
	SHL	r4	r4	r5
	ADDI	r4	r4	0xf
	LD	r3	r4	0
	RET
	
