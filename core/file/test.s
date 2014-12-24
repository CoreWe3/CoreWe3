		ADDI	r0	r0	0
		ADDI	r0	r0	0
		ADDI	r0	r0	0
		ADDI	r0	r0	0
		ADDI	r0	r0	0
		ADDI	r1	r0	0x41
		ADDI	r2	r0	0x46
		ADDI	r0	r0	0
:loop
		ADDI	r1	r1	1
		ST		r1	r0	0xfffff
		BEQ	r1	r2	:end
		BEQ	r0	r0	:loop
:end
		BEQ	r0	r0	0
