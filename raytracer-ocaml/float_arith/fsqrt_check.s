:main
	LDIH	r3	0x7f7f
	LDIL	r3	0xffff
	ADDI	r4	r0	4
	ST	r3	r0	-1
	SHR	r3	r3	r4
	ST	r3	r0	-1
	SHR	r3	r3	r4
	ST	r3	r0	-1
	SHR	r3	r3	r4
	ST	r3	r0	-1
