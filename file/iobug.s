:main
	ADDI	r3	r0	0
	ADDI	r4	r0	0x7000 #overflow when 0x8000
:loop
	LD	r1	r0	0xFFFF
	LD	r2	r0	0xFFFF
	PUSH	r4
	PUSH	r3
	ST	r1	r0	0xFFFF
	POP	r3
	POP	r4
	ADDI	r3	r3	1	
	BLT	r3	r4	:loop
