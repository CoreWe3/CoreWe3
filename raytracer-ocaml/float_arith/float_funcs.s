:min_caml_fhalf
	ADDI	r7	r0	9
	ADDI	r8	r0	23
	ADDI	r9	r0	24
	ADDI	r10	r0	1
	ADDI	r11	r0	31
	SHR	r4	r3	r11	#r4 = sig(a)
	SHL	r4	r4	r11	#r4 = sig(a)
	SHL	r5	r3	r10	#r5 = exp(a)
	SHR	r5	r5	r9
	SUB	r5	r5	r10	#r5 = exp(a) - 1
	SHL	r5	r5	r8
	SHL	r6	r3	r7	#r6 = man(a)
	SHR	r6	r6	r7
	OR 	r3	r4	r5
	OR 	r3	r3	r6
	RET
:min_caml_fsqr
	ADDI 	r4	r3	0
	PUSH	r2
	JSUB	:min_caml_fmul
	POP	r2
	RET
:min_caml_fabs
	ADDI	r15	r0	1
	SHL	r3	r3	r15
	SHR	r3	r3	r15
	RET
:min_caml_fneg
	ADDI	r15	r0	31
	ADDI	r14	r0	1
	SHR	r4	r3	r15
	SUB	r4	r14	r4
	SHL	r4	r4	r15
	SHL	r3	r3	r14
	SHR	r3	r3	r14
	OR	r3	r4	r3
	RET
:min_caml_fless
	ADDI	r15	r0	31
	ADDI 	r14	r0	1
	SHR	r5	r3	r15
	SHR	r6	r4	r15
	BEQ	r5	r6	:min_caml_fless_L1	#符号が等しいか
	BEQ	r5	r0	:min_caml_fless_L2	#r3が正の数か?
	ADDI	r3	r0	1			#r3が負でr4が正
	RET
:min_caml_fless_L2
	ADDI	r3	r0	0			#r3が正でr4が負
	RET	
:min_caml_fless_L1
	SHL	r7	r3	r14
	SHR	r7	r7	r14
	SHL	r8	r3	r14
	SHR	r8	r8	r14
	BLT	r7	r8	:min_caml_fless_L3
	ADDI	r3	r5	0			#|r3| >= |r4|
	RET
:min_caml_fless_L3
	SUB	r3	r14	r5			#|r3| < |r4|
	RET
:min_caml_fiszero
	ADDI	r15	r0	1
	SHL	r3	r3	r15
	SHR	r3	r3	r15
	BEQ	r3	r0	:min_caml_fiszero_L
	ADDI	r3	r0	0
	RET
:min_caml_fiszero_L
	ADDI	r3	r0	1
	RET
:min_caml_fispos
	ADDI	r15	r0	31
	ADDI	r14	r0	1
	SHR	r3	r3	r15
	SUB	r3	r14	r3
	RET
:min_caml_fisneg
	ADDI	r15	r0	31
	SHR	r3	r3	r15
	RET
