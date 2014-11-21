:min_caml_fmul	//mulのサブルーチンの呼び出しが規約にそっていないけど、mulをインライン展開すれば大丈夫になってます
	SHRI	r15	r3	31
	SHRI	r16	r4	31
	XOR	r15	r15	r16
	SHLI	r18	r3	1
	SHLI	r19	r4	1
	SHRI	r18	r18	24
	SHRI	r19	r19	24
	SHLI	r20	r3	9
	SHLI	r21	r4	9
	SHRI	r20	r20	20
	SHRI	r21	r21	20
	SHLI	r22	r3	21
	SHLI	r23	r4	21
	SHRI	r22	r22	21
	SHRI	r23	r23	21
	ADD	r16	r18	r19
	ADDI	r20	r20	0x1000
	ADDI	r21	r21	0x1000
	ADD	r3	r20	r0
	ADD	r4	r21	r0
:min_caml_fmul_mul_1
	ADDI	r5	r3	0
	ADDI	r3	r0	0
	ADDI	r6	r0	13
	ADDI	r7	r0	1
:min_caml_mul_loop_1
	AND	r8	r7	r4
	BEQ	r8	r0	:min_caml_mul_X_1
	ADD	r3	r3	r5
:min_caml_mul_X_1
	SUB	r6	r6	r7
	SHR	r4	r4	r7
	SHL	r5	r5	r7
	BLT	r0	r6	:min_caml_mul_loop_1
	ADDI	r17	r3	2
	ADD	r3	r20	r0
	ADD	r4	r23	r0
:min_caml_fmul_mul_2
	ADDI	r5	r3	0
	ADDI	r3	r0	0
	ADDI	r6	r0	13
	ADDI	r7	r0	1
:min_caml_mul_loop_2
	AND	r8	r7	r4
	BEQ	r8	r0	:min_caml_mul_X_2
	ADD	r3	r3	r5
:min_caml_mul_X_2
	SUB	r6	r6	r7
	SHR	r4	r4	r7
	SHL	r5	r5	r7
	BLT	r0	r6	:min_caml_mul_loop_2
	SHRI	r3	r3	11
	ADD	r17	r17	r3
	ADD	r3	r21	r0
	ADD	r4	r22	r0
:min_caml_fmul_mul_3
	ADDI	r5	r3	0
	ADDI	r3	r0	0
	ADDI	r6	r0	13
	ADDI	r7	r0	1
:min_caml_mul_loop_3
	AND	r8	r7	r4
	BEQ	r8	r0	:min_caml_mul_X_3
	ADD	r3	r3	r5
:min_caml_mul_X_3
	SUB	r6	r6	r7
	SHR	r4	r4	r7
	SHL	r5	r5	r7
	BLT	r0	r6	:min_caml_mul_loop_3
	SHRI	r3	r3	11
	ADD	r17	r17	r3
	LDI	r30	0x2000000
	BLE	r30	r17	:min_caml_fmul_keta
	SHLI	r17	r17	8
	SHRI	r17	r17	9
	BEQ	r0	r0	:min_caml_fmul_L2
:min_caml_fmul_keta
	ADDI	r16	r16	1
	SHLI	r17	r17	7
	SHRI	r17	r17	9
:min_caml_fmul_L2
	ADDI	r30	r0	127
	BLE	r16	r30	:min_caml_fmul_zero
	SUB	r16	r16	r30
	BEQ	r0	r0	:min_caml_fmul_L3
:min_caml_fmul_zero
	SHLI	r3	r15	31
	RET
:min_caml_fmul_L3
	SHLI	r3	r15	31
	SHLI	r16	r16	23
	ADD	r3	r3	r16
	ADD	r3	r3	r17
	RET
