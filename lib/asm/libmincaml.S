:min_caml_create_array	#Array construct functions
	ADDI	r5	r3	0	#size
	LDI	r6	0		#index
	CMP	r3	r0
	JEQ	:min_caml_create_array_break
:min_caml_create_array_loop
	ADD	r7	r1	r6	#addr
	ST	r4	r7	0
	ADDI	r6	r6	1
	CMP	r6	r5
	JLT	:min_caml_create_array_loop
:min_caml_create_array_break
	ADDI	r3	r1	0
	ADD	r1	r1	r5
	RET
	
:min_caml_create_float_array
	ADDI	r5	r3	0	#size
	LDI	r6	0		#index
	CMP	r3	r0
	JEQ	:min_caml_create_float_array_break
:min_caml_create_float_array_loop
	ADD	r7	r1	r6	#addr
	FST	f1	r7	0
	ADDI	r6	r6	1
	CMP	r6	r5
	JLT	:min_caml_create_float_array_loop
:min_caml_create_float_array_break
	ADDI	r3	r1	0
	ADD	r1	r1	r5
	RET
