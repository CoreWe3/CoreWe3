:main
	LDI	r1	0xffffe
	LDI	r2	0xffffe
	LDI	r8	0x0
:store
	ST	r1	r1	0
	ADDI	r1	r1	-1
	BEQ	r8	r1	:load
	BEQ	r0	r0	:store
:load
	LD	r3	r2	0
	BEQ	r2	r3	:true
	BEQ	r0	r0	:false
:true
	ADDI	r2	r2	-1
	BEQ	r8	r2	:end
	BEQ	r0	r0	:load
:false
	STA	r2	0xfffff
	SHRI	r2	r2	8
	STA	r2	0xfffff
	SHRI	r2	r2	8
	STA	r2	0xfffff
	SHRI	r2	r2	8
	STA	r2	0xfffff
	STA	r3	0xfffff
	SHRI	r3	r3	8
	STA	r3	0xfffff
	SHRI	r3	r3	8
	STA	r3	0xfffff
	SHRI	r3	r3	8
	STA	r3	0xfffff
	BEQ	r0	r0	0
:end
	LDI	r4	0x4f
	STA	r4	0xfffff
	LDI	r5	0x4b
	STA	r5	0xfffff
	LDI	r6	0xa
	STA	r6	0xfffff
	BEQ	r0	r0	0
