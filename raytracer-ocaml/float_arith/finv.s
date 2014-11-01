	ADDI r16 r0 1
	ADDI r15 r0 30
	ADDI r14 r0 23
	ADDI r12 r0 22
	ADDI r13 r0 9
	SHL r5 r3 r13
	SHR r6 r5 r12
	SHR r5 r5 r13
	ADDI r12 r0 127
	SHL r11 r12 r14
	OR r7 r5 r11
	ADDI r15 r0 31
	SHR r5 r3 r15
	SHL r5 r5 r15
	SHL r4 r3 r16
	SHR r4 r4 r16
	SHR r4 r4 r14
	BLT r4 r12 :else
	SUB r4 r4 r12
	SUB r4 r12 r4
	SUB r4 r4 r16
:else
	SUB r4 r12 r4
	ADD r4 r12 r4
	SUB r4 r4 r16

	LD r3 temp_a r6         # from a.txt
	PUSH r4
	PUSH r5
	PUSH r6
	OR r4 r7 r7
	PUSH r2
	jsub :fmul              # r3 * r4 = r3  
	POP r2
	POP r6
	PUSH r2
	OR r4 r3 r3
	LD r3 temp_b r6         # from b.txt
	jsub :fsub              # r3 - r4 = r4
	POP r2
	POP r5
	POP r4
	SHL r10 r3 r13
	SHR r10 r10 r13
	OR r3 r5 r4
	OR r3 r3 r10
