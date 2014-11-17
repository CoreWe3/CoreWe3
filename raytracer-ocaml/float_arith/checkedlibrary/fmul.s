:min_caml_fmul
	ADDI	r15	r0	31
	SHR	r13	r3	r15
	SHR	r14	r4	r15
	XOR	r10	r13	r14
	ADDI	r13	r0	1
	ADDI	r14	r0	24
	ADDI	r15	r0	9
	ADDI	r12	r0	255
	SHL	r5	r3	r13
	SHR	r5	r5	r14
	SHL	r6	r3	r15
	SHR	r6	r6	r15
	SHL	r7	r4	r13
	SHR	r7	r7	r14
	SHL	r8	r4	r15
	SHR	r8	r8	r15
	BEQ	r5	r12	:min_caml_fmul_INF
	BEQ	r7	r12	:min_caml_fmul_INF
	BEQ	r5	r0	:min_caml_fmul_ZERO
	BEQ	r7	r0	:min_caml_fmul_ZERO
	ADD	r13	r5	r7
	ADDI	r14	r0	20
	ADDI	r11	r0	21
	SHL	r3	r6	r15
	SHR	r3	r3	r14
	SHL	r4	r6	r11
	SHR	r4	r4	r11
	SHL	r5	r8	r15
	SHR	r5	r5	r14
	SHL	r6	r8	r11
	SHR	r6	r6	r11
	ADDI	r14	r0	6
	ADDI	r8	r0	127
	BLT	r13	r8	:min_caml_fmul_ZERO
	SUB	r13	r13	r8
	ADDI	r11	r0	254
	BLT	r11	r13	:min_caml_fmul_INF
	ADDI	r8	r0	64
	SHL	r8	r8	r14
	ADD	r3	r3	r8
	ADD	r5	r5	r8
	PUSH	r6
	PUSH	r8
	PUSH	r3
	PUSH	r4
	PUSH	r5
	ADD	r4	r5	r0
	JSUB	:min_caml_mul
	ADD	r9	r0	r3
	POP	r3
	POP	r4
	PUSH	r3
	PUSH	r4
	JSUB	:min_caml_mul
	ADD	r7	r0	r3 #70
	POP	r4
	POP	r5
	POP	r3
	POP	r8
	POP	r6
	ADDI	r11	r0	11
	SHR	r7	r7	r11
	ADD	r9	r9	r7
	PUSH	r8
	PUSH	r6
	PUSH	r5
	PUSH	r4
	PUSH	r3
	ADD	r4	r6	r0
	JSUB	:min_caml_mul
	ADD	r7	r3	r0
	POP	r3
	POP	r4
	POP	r5
	POP	r6
	POP	r8
	SHR	r7	r7	r11
	ADD	r9	r9	r7
	ADDI	r9	r9	2
	ADDI	r7	r0	13
	SHL	r8	r8	r7
	BLT	r8	r9	:min_caml_fmul_KETA
	BEQ	r13	r0	:min_caml_fmul_ZERO
	ADDI	r14	r0	8
	ADDI	r15	r0	9
	SHL	r9	r9	r14
	SHR	r9	r9	r15
	BEQ	r0	r0	:min_caml_fmul_END
:min_caml_fmul_KETA
	ADDI	r13	r13	1
	BEQ	r13	r12	:min_caml_fmul_INF
	ADDI	r14	r0	7
	SHL	r9	r9	r14
	SHR	r9	r9	r15
	BEQ	r0	r0	:min_caml_fmul_END
:min_caml_fmul_INF
	ADDI	r13	r0	255
	ADDI	r9	r0	0
	BEQ	r0	r0	:min_caml_fmul_END
:min_caml_fmul_ZERO
	ADDI	r9	r0	0
	ADDI	r13	r0	0
:min_caml_fmul_END
	ADDI	r14	r0	23
	ADDI	r15	r0	31
	SHL	r13	r13	r14
	SHL	r10	r10	r15
	ADD	r3	r13	r10
	ADD	r3	r3	r9
	RET
:min_caml_mul
	ADDI	r5	r3	0
	ADDI	r3	r0	0
	ADDI	r6	r0	13
	ADDI	r7	r0	1
:min_caml_mul_loop
	AND	r8	r7	r4
	BEQ	r8	r0	:min_caml_mul_X
	ADD	r3	r3	r5
:min_caml_mul_X
	SUB	r6	r6	r7
	SHR	r4	r4	r7
	SHL	r5	r5	r7
	BLT	r0	r6	:min_caml_mul_loop
	RET
:min_caml_mul_EMD
