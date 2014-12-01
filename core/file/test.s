:main
	LDI	r1	0x41
	LDI	r2	0x5a
	LDI	r3	0x60
	LDI	r4	0x7a
:loop
	LDA	r5	0xfffff
	PUSH	r5
	POP	r6
	BLE	r6	r1	:str
	BLE	r4	r6	:str
	BLE	r6	r2	:add
	BLT	r3	r6	:add
	BEQ	r0	r0	:str
:add
	ADDI	r7	r6	1
	STA	r7	0xfffff
	BEQ	r0	r0	:loop
:str
	STA	r6	0xfffff
	BEQ	r0	r0	:loop
