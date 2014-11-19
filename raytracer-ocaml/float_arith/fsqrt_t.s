:fsqrt
	SHLI	r4	r3	1
	BEQ	r4	r0	:ret0_fsqrt
	SHRI	r4	r3	31
	BEQ	r4	r0	:norm_fsqrt	#cと比較が逆転してるので注意
	LDI	r3	0xffc00000	#exception return -nan
	RET
:norm_fsqrt
	LDI	r5	127
	LDI	r6	128
	SHRI	r7	r3	23
	SHLI	r8	r3	8
	SHRI	r9	r8	31
	SHLI	r10	r3	9
	SHRI	r11	r10	9
	BLT	r7	r5	:l1_else_fsqrt	#Cと逆
	SUB	r20	r7	r5
	SHRI	r20	r20	1
	ADD	r20	r20	r5
	BEQ	r0	r0	:l1_end_fsqrt
:l1_else_fsqrt
	SUB	r20	r5	r7
	ADDI	r20	r20	1
	SHRI	r20	r20	1
	SUB	R20	r5	r20
:l1_end_fsqrt
	SHLI	r20	r20	23
	BEQ	r9	r0	:l2_if_fsqrt
	SHRI	r23	r10	24	#else
	SHLI	r5	r5	23
	OR	r4	r5	r11
	BEQ	r0	r0	:l2_end_fsqrt
:l2_if_fsqrt
	LDI	r21	256
	SHRI	r10	23
	ADD	r23	r22	r21
	SHLI	r6	r6	23
	OR	r4	r6	r11
:l2_end_fsqrt
	LD	r3	temp_a	r23	#from a_fsqrt.txt
	PUSH	r20
	PUSH	r23
	PUSH	r2
	JSUB	:fmul
	POP	r2
	POP	r23
	LD	r4	temp_b	r23	#from b_fsqrt.txt
	PUSH	r2
	JSUB	:fadd
	POP	r2
	POP	r20
	SHLI	r3	r3	9
	SHRI	r3	r3	9
	OR	r3	r3	r20
	RET
:ret0_fsqrt
	RET	#exception return 0
