	ADDI	r1	r0	0x41
	ADDI	r2	r0	0x42
	BEQ	r2	r0	:end
	ST	r1	r0	0xffff
	BEQ	r0	r0	0
:end
	ST	r2	r0	0xffff
	BEQ	r0	r0	0
