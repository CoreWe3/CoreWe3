:min_caml_finv
	ADDI	r16	r0	1
	SHLI	r5	r3	9
	SHRI	r6	r5	22
	SHRI	r5	r5	9
	ADDI	r12	r0	127
	SHLI	r11	r12	23	
	OR	r7	r5	r11
	ADDI	r15	r0	31
	SHRI	r5	r3	31
	SHLI	r5	r5	31
	SHLI	r4	r3	1
	SHRI	r4	r4	1
	SHRI	r4	r4	23
	BLT	r4	r12	:min_caml_finvelse
	SUB	r4	r4	r12
	SUB	r4	r12	r4
	SUB	r4	r4	r16
	BEQ	r0	r0	:min_caml_finvend
:min_caml_finvelse
	SUB	r4	r12	r4
	ADD	r4	r12	r4
	SUB	r4	r4	r16
:min_caml_finvend
	SHLI	r4	r4	23
	PUSH	r4
	PUSH	r5
	LDI	r9	0xEF000
	ADD	r4	r9	r6	# from a.txt
	LD	r4	r4	0
	ADD	r3	r7	r0
	PUSH	r6
	JSUB	:min_caml_fmul
	POP	r6
	ADD	r4	r3	r4
	LDI	r9	0xEF400
	ADD	r3	r9	r6	# from a.txt
	LD	r3	r3	0
	JSUB	:min_caml_fsub
	SHLI	r10	r3	9
	SHRI	r10	r10	9
	POP	r5
	POP	r4
	OR	r3	r4	r5
	OR	r3	r3	r10
	RET
