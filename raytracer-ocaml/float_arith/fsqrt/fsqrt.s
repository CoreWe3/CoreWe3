:min_caml_sqrt
	SHLI	r3	r3	1
	SHRI	r3	r3	1
	BLT	r0	r3	:min_caml_sqrt_nonzero
	RET
:min_caml_sqrt_nonzero
	PUSH	r3
	PUSH	r2	
	JSUB	:min_caml_fhalf
	POP	r2
	ST	r3	r2	0
	POP	r3
	LDI	r4	0x3f800000
	ADD	r3	r3	r4
	SHRI	r3	r3	1
	LDI	r5	10
:min_caml_sqrt_loop
	ST	r3	r2	1
	ST	r5	r2	2
	PUSH	r2
	ADDI	r2	r2	3
	JSUB	:min_caml_fhalf
	POP	r2
	PUSH	r3
	PUSH	r2
	LD	r3	r2	0
	LD	r4	r2	1
	ADDI	r2	r2	3
	JSUB	:min_caml_fdiv
	POP	r2
	POP	r4
	PUSH	r2
	ADDI	r2	r2	3
	JSUB	:min_caml_fadd
	POP	r2
	LD	r4	r2	1
	BLT	r4	r3	:min_caml_sqrt_loop_BLT_true
	SUB	r5	r4	r3
	BEQ	r0	r0	:min_caml_sqrt_loop_BLT_end
:min_caml_sqrt_loop_BLT_true
	SUB	r5	r3	r4	
:min_caml_sqrt_loop_BLT_end
	LDI	r6	2
	BLT	r5	r6	:min_caml_sqrt_loop_end
	LD	r5	r2	2
	ADDI	r5	r5	-1
	BLT	r0	r5	:min_caml_sqrt_loop
:min_caml_sqrt_loop_end
	RET
