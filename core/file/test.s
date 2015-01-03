	LDI	r1	0x12345678
	STA	r1	0xef000
	LDA	r2	0xef000
	STA	r2	0xfffff
	SHRI	r2	r2	8
	STA	r2	0xfffff
	SHRI	r2	r2	8
	STA	r2	0xfffff
	SHRI	r2	r2	8
	STA	r2	0xfffff
	BEQ	r0	r0	0
