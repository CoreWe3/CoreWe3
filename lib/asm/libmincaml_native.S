:min_caml_create_array	#Array construct functions
	ADDI	r5	r3	0	#size
	ADDI	r6	r0	0	#index
	BEQ	r3	r0	:min_caml_create_array_L1
:min_caml_create_array_L2
	ADD	r7	r1	r6	#addr
	ST	r4	r7	0
	ADDI	r6	r6	1
	BLT	r6	r5	:min_caml_create_array_L2
:min_caml_create_array_L1
	ADDI	r3	r1	0
	ADD	r1	r1	r5
	RET

:min_caml_create_float_array
	JSUB	:min_caml_create_array
	RET

:min_caml_read_char	#I/O Functions
	LDA	r3	0xfffff
	RET

:min_caml_read_int
	LDA	r3	0xfffff
	SHLI	r3	r3	8
	LDA	r4	0xfffff
	OR	r3	r3	r4
	SHLI	r3	r3	8
	LDA	r4	0xfffff
	OR	r3	r3	r4
	SHLI	r3	r3	8
	LDA	r4	0xfffff
	OR	r3	r3	r4
	RET
	
:min_caml_read_float
	JSUB	:min_caml_read_int
	RET

:min_caml_print_char
	STA	r3	0xfffff
	RET

:min_caml_print_int
	STA	r3	0xfffff
	RET

:min_caml_print_int32
	ADDI	r4	r0	24	
	ADDI	r5	r3	0
:min_caml_print_int32_L1
	SHR	r3	r5	r4
	STA	r3	0xfffff
	ADDI	r4	r4	-8
	BLE	r0	r4	:min_caml_print_int32_L1
	RET

:min_caml_fadd
	FX86	0
	RET

:min_caml_fsub
	FX86	1
	RET

:min_caml_fmul
	FX86	2
	RET

:min_caml_finv
	FX86	4
	RET

:min_caml_sqrt
	FX86	5
	RET	#exception return 0

:min_caml_fdiv
	FX86	3
	RET

:min_caml_float_of_int
	FX86	9
	RET

:min_caml_int_of_float
	FX86	10
	RET

:min_caml_floor
	FX86	11
	RET

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
	BLT	r0	r5	:min_caml_fhalf_L1
	ADDI	r3	r0	0
	RET
:min_caml_fhalf_L1
	SUB	r5	r5	r10	#r5 = exp(a) - 1
	SHL	r5	r5	r8
	SHL	r6	r3	r7	#r6 = man(a)
	SHR	r6	r6	r7
	OR 	r3	r4	r5
	OR 	r3	r3	r6
	RET

:min_caml_fabs
	ADDI	r15	r0	1
	SHL	r3	r3	r15
	SHR	r3	r3	r15
	RET
