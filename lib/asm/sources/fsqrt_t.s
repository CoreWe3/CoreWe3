
:min_caml_fsqrt
	SHLI	r4	r3	1
	BEQ	r4	r0	:min_caml_fsqrt_ret0
	SHRI	r4	r3	31
	BEQ	r4	r0	:min_caml_fsqrt_norm	#cと比較が逆転してるので注意
	LDI	r3	0xffc00000	#exception return -nan
	RET
:min_caml_fsqrt_norm
	LDI	r5	127
	LDI	r6	128
	SHRI	r7	r3	23
	SHLI	r8	r3	8
	SHRI	r9	r8	31
	SHLI	r10	r3	9
	SHRI	r11	r10	9	#よさげ
	BLT	r7	r5	:min_caml_fsqrt_l1_else	#Cと逆
	SUB	r20	r7	r5
	SHRI	r20	r20	1
	ADD	r20	r20	r5
	BEQ	r0	r0	:min_caml_fsqrt_l1_end
:min_caml_fsqrt_l1_else
	SUB	r20	r5	r7
	ADDI	r20	r20	1
	SHRI	r20	r20	1
	SUB	r20	r5	r20	#比較はみてないけどよさそう
:min_caml_fsqrt_l1_end
	SHLI	r20	r20	23
	BEQ	r9	r0	:min_caml_fsqrt_l2_if
	SHRI	r23	r10	24	#else
	SHLI	r5	r5	23
	OR	r4	r5	r11
	BEQ	r0	r0	:min_caml_fsqrt_l2_end
:min_caml_fsqrt_l2_if
	LDI	r21	256
	SHRI	r22	r10	23	#なおした
	ADD	r23	r22	r21
	SHLI	r6	r6	23
	OR	r4	r6	r11
:min_caml_fsqrt_l2_end
	LDI	r25	0xEF800
	ADD	r25	r25	r23
	LD	r3	r25	r0	#from a_fsqrt.txt
	PUSH	r20
	PUSH	r23
	PUSH	r2
	JSUB	:min_caml_fmul
	POP	r2
	POP	r23
	LDI	r25	0xEFC00
	ADD	r25	r25	r23
	LD	r4	r25	r0	#from b_fsqrt.txt
	PUSH	r2
	JSUB	:min_caml_fadd
	POP	r2
	POP	r20
	SHLI	r3	r3	9
	SHRI	r3	r3	9
	OR	r3	r3	r20
	RET
:min_caml_fsqrt_ret0
	RET	#exception return 0

