:main
	ADDI	r1	r0	0x10
	ADDI	r4	r0	0x3
	BEQ	r0	r1	:dest
	ADDI	r2	r0	0x20
	ADDI	r3	r0	0x30
	ADDI	r4	r0	0x40
:dest
	ADD	r5	r1	r4
