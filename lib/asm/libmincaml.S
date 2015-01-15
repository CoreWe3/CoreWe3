:min_caml_create_array	#Array construct functions
:min_caml_create_float_array
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

