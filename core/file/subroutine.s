:main
	LDI	r1	10
	JSUB	:func
	STA	r1	0xfffff
	BEQ	r0	r0	0
:func
	ADDI	r1	r1	10
	RET
