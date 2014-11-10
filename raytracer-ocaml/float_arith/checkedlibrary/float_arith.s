:fadd
	ADDI	r15	r0	1	#frequently used constants
	ADDI	r14	r0	23
	ADDI	r12	r0	31
	ADDI	r11	r0	9	#ok
	SHL	r3	r1	r15	#r1 = larger
	SHL	r4	r2	r15	#19
	BLE	r4 	r3	:fadd_L1
	ADDI	r5	r1	r0
	ADDI	r1	r2	r0
	ADDI	r2	r5	r0
:fadd_L1
	ADDI	r5	r0	24	#r3(4) = exp
	SHL	r3	r1	r15
	SHR	r3	r3	r5	#SRL
	SHL	r4	r2	r15
	SHR	r4	r4	r5	#SRL
	SUB	r4	r3	r4	#r4 = shift

	SHL 	r5	r1	r11	#r5(6) = man
	SHR 	r5	r5	r11
	SHL 	r6	r2	r11
	SHR 	r6	r6	r11
	
	SHL	r7	r15	r14	#r7 = 0x800000
	OR	r5	r5	r7
	OR	r6	r6	r7
	SHR	r6	r6	r4	#shift man of smaller one

	SHR	r7	r1	r12	#r7(8) = sig
	SHR	r8	r2	r12

	BEQ	r7	r8	:fadd_L2 	#r9 = man
	SUB	r9	r5	r6
	BEQ	r0	r0	:fadd_L3
:fadd_L2
	ADD	r9	r5	r6
:fadd_L3
	ADDI	r4	r0	25	#priority encoder modified
:fadd_L4
	SHL	r10	r15	r4
	AND	r10	r9	r10
	BEQ	r10	r0	:fadd_L4_1
	BEQ	r0	r0	:fadd_L5
:fadd_L4_1
	SUB	r4	r4	r15
	BLE	r4	0	:fadd_L5	
	BEQ	r0	r0	:fadd_L4	#BLE+BEQmatomerareru?
:fadd_L5
	BLE	r14	r4 	:fadd_L6
	SUB	r4	r14	r4	#borrow
	SUB	r10	r3	r4
	SHL	r9	r9	r4
	BEQ	r0	r0	:fadd_L7
:fadd_L6
	SUB	r4	r4	r14	#carry
	ADD	r10	r3	r4
	SHR	r9	r9	r4
:fadd_L7
	SHL	r10	r10	r14
	SHL	r9	r9	r11
	SHR	r9	r9	r11
	SHL	r1	r7	r12
	OR	r1	r1	r10
	OR	r1	r1	r9
	RET
:fsub
	ADDI	r15	r0	1	
	ADDI	r14	r0	31
	SHL	r13	r15	r14
	SHR	r3	r2	r14
	BEQ	r3	r0	:fsub_L1
	SUB	r13	r13	r15
	AND	r2	r2	r13
	BEQ	r0	r0	:fsub_L2
:fsub_L1
	OR 	r2	r2	r13
:fsub_L2
	JSUB	:fadd
	RET
