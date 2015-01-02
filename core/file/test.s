	LDI	r1	0x41
	PUSH	r1
	LDI	r1	0x42
	JSUB	:func
	STA	r1	0xfffff
	POP	r1
	STA	r1	0xfffff
	BEQ	r0	r0	0
:func
	ADDI	r1	r1	3
	RET
