:main
	LDI	r1	15
	ADD	r2	r1	r0
:load
	LDA	r3	0xfffff
	ST	r3	r1	0
	ADDI	r1	r1	-1
	BEQ	r1	r0 	:store
	BEQ	r0	r0	:load
:store
	LD	r3	r2	0
	STA	r3	0xfffff
	ADDI	r2	r2	-1
	BEQ	r2	r0	:end
	BEQ	r0	r0	:store
:end
	BEQ	r0	r0	0	
