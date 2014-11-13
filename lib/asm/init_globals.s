:_min_caml_start # main entry point
	LDI	r3	30
	LDI	r4	0
	PUSH	r2
	JSUB	:min_caml_create_array
	POP	r2
	LDI	r4	1
	LDI	r5	0
	ST	r3	r2	0
	ADDI	r3	r4	0
	ADDI	r4	r5	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	0
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_save_global0
	POP	r2
	LDI	r3	0
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_create_float_array
	POP	r2
	LDI	r4	60
	LDI	r5	0
	LDI	r6	0
	LDI	r7	0
	LDI	r8	0
	LDI	r9	0
	ADDI	r10	r1	0
	ADDI	r1	r1	11
	ST	r3	r10	10
	ST	r3	r10	9
	ST	r3	r10	8
	ST	r3	r10	7
	ST	r9	r10	6
	ST	r3	r10	5
	ST	r3	r10	4
	ST	r8	r10	3
	ST	r7	r10	2
	ST	r6	r10	1
	ST	r5	r10	0
	ADDI	r3	r10	0
	ADDI	r61	r4	0
	ADDI	r4	r3	0
	ADDI	r3	r61	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	1
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_save_global1
	POP	r2
	LDI	r3	3
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	2
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_save_global2
	POP	r2
	LDI	r3	3
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	3
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_save_global3
	POP	r2
	LDI	r3	3
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	4
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_save_global4
	POP	r2
	LDI	r3	1
	LDI	r4	1132396544
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	5
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_save_global5
	POP	r2
	LDI	r3	50
	LDI	r4	1
	LDI	r5	-1
	ST	r3	r2	1
	ADDI	r3	r4	0
	ADDI	r4	r5	0
	PUSH	r2
	ADDI	r2	r2	2
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r4	r3	0
	LD	r3	r2	1
	PUSH	r2
	ADDI	r2	r2	2
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	6
	LD	r3	r2	0
	ST	r5	r2	2
	PUSH	r2
	ADDI	r2	r2	3
	JSUB	:min_caml_save_global6
	POP	r2
	LDI	r3	1
	LDI	r4	1
	LD	r5	r2	2
	ADDI	r5	r5	0
	LD	r5	r5	0
	ST	r3	r2	3
	ADDI	r3	r4	0
	ADDI	r4	r5	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r4	r3	0
	LD	r3	r2	3
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	7
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global7
	POP	r2
	LDI	r3	1
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	8
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global8
	POP	r2
	LDI	r3	1
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	9
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global9
	POP	r2
	LDI	r3	1
	LDI	r4	1315859240
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	10
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global10
	POP	r2
	LDI	r3	3
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	11
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global11
	POP	r2
	LDI	r3	1
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	12
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global12
	POP	r2
	LDI	r3	3
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	13
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global13
	POP	r2
	LDI	r3	3
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	14
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global14
	POP	r2
	LDI	r3	3
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	15
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global15
	POP	r2
	LDI	r3	3
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	16
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global16
	POP	r2
	LDI	r3	2
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	17
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global17
	POP	r2
	LDI	r3	2
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	18
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global18
	POP	r2
	LDI	r3	1
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	19
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global19
	POP	r2
	LDI	r3	3
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	20
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global20
	POP	r2
	LDI	r3	3
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	21
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global21
	POP	r2
	LDI	r3	3
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	22
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global22
	POP	r2
	LDI	r3	3
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	23
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global23
	POP	r2
	LDI	r3	3
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	24
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global24
	POP	r2
	LDI	r3	3
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	25
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global25
	POP	r2
	LDI	r3	0
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r4	r3	0
	LDI	r3	0
	ST	r4	r2	4
	PUSH	r2
	ADDI	r2	r2	5
	JSUB	:min_caml_create_array
	POP	r2
	LDI	r4	0
	ADDI	r5	r1	0
	ADDI	r1	r1	2
	ST	r3	r5	1
	LD	r3	r2	4
	ST	r3	r5	0
	ADDI	r3	r5	0
	ADDI	r61	r4	0
	ADDI	r4	r3	0
	ADDI	r3	r61	0
	PUSH	r2
	ADDI	r2	r2	5
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r4	r3	0
	LDI	r3	5
	PUSH	r2
	ADDI	r2	r2	5
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	26
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	5
	JSUB	:min_caml_save_global26
	POP	r2
	LDI	r3	0
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	5
	JSUB	:min_caml_create_float_array
	POP	r2
	LDI	r4	3
	LDI	r5	0
	ST	r3	r2	5
	ADDI	r3	r4	0
	ADDI	r4	r5	0
	PUSH	r2
	ADDI	r2	r2	6
	JSUB	:min_caml_create_float_array
	POP	r2
	LDI	r4	60
	LD	r5	r2	5
	ST	r3	r2	6
	ADDI	r3	r4	0
	ADDI	r4	r5	0
	PUSH	r2
	ADDI	r2	r2	7
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r4	r1	0
	ADDI	r1	r1	2
	ST	r3	r4	1
	LD	r3	r2	6
	ST	r3	r4	0
	ADDI	r5	r4	0
	LDI	r4	27
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	7
	JSUB	:min_caml_save_global27
	POP	r2
	LDI	r3	0
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	7
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r4	r3	0
	LDI	r3	0
	ST	r4	r2	7
	PUSH	r2
	ADDI	r2	r2	8
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r4	r1	0
	ADDI	r1	r1	2
	ST	r3	r4	1
	LD	r3	r2	7
	ST	r3	r4	0
	ADDI	r3	r4	0
	LDI	r4	180
	LDI	r5	0
	LDI	r6	0
	ADDI	r7	r1	0
	ADDI	r1	r1	3
	ST	r6	r7	2
	ST	r3	r7	1
	ST	r5	r7	0
	ADDI	r3	r7	0
	ADDI	r61	r4	0
	ADDI	r4	r3	0
	ADDI	r3	r61	0
	PUSH	r2
	ADDI	r2	r2	8
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	28
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	8
	JSUB	:min_caml_save_global28
	POP	r2
	LDI	r3	1
	LDI	r4	0
	PUSH	r2
	ADDI	r2	r2	8
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	LDI	r4	29
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	8
	JSUB	:min_caml_save_global29
	POP	r2
