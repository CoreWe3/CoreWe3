:_min_caml_start # main entry point
	LDIH	r2	0
	LDIL	r2	0
	LDIH	r1	2
	LDIL	r1	32768
	ADDI	r3	r0	30
	ADDI	r4	r0	0
	PUSH	r2
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r4	r0	1
	ADDI	r5	r0	0
	ST	r3	r2	0
	ADDI	r3	r4	0
	ADDI	r4	r5	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	0
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_save_global0
	POP	r2
	ADDI	r3	r0	0
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r4	r0	60
	ADDI	r5	r0	0
	ADDI	r6	r0	0
	ADDI	r7	r0	0
	ADDI	r8	r0	0
	ADDI	r9	r0	0
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
	ADDI	r13	r4	0
	ADDI	r4	r3	0
	ADDI	r3	r13	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	1
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_save_global1
	POP	r2
	ADDI	r3	r0	3
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	2
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_save_global2
	POP	r2
	ADDI	r3	r0	3
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	3
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_save_global3
	POP	r2
	ADDI	r3	r0	3
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	4
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_save_global4
	POP	r2
	ADDI	r3	r0	1
	LDIH	r4	17279
	LDIL	r4	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	5
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	1
	JSUB	:min_caml_save_global5
	POP	r2
	ADDI	r3	r0	50
	ADDI	r4	r0	1
	ADDI	r5	r0	-1
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
	ADDI	r4	r0	6
	LD	r3	r2	0
	ST	r5	r2	2
	PUSH	r2
	ADDI	r2	r2	3
	JSUB	:min_caml_save_global6
	POP	r2
	ADDI	r3	r0	1
	ADDI	r4	r0	1
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
	ADDI	r4	r0	7
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global7
	POP	r2
	ADDI	r3	r0	1
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	8
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global8
	POP	r2
	ADDI	r3	r0	1
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	9
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global9
	POP	r2
	ADDI	r3	r0	1
	LDIH	r4	20078
	LDIL	r4	27432
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	10
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global10
	POP	r2
	ADDI	r3	r0	3
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	11
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global11
	POP	r2
	ADDI	r3	r0	1
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	12
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global12
	POP	r2
	ADDI	r3	r0	3
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	13
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global13
	POP	r2
	ADDI	r3	r0	3
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	14
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global14
	POP	r2
	ADDI	r3	r0	3
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	15
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global15
	POP	r2
	ADDI	r3	r0	3
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	16
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global16
	POP	r2
	ADDI	r3	r0	2
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	17
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global17
	POP	r2
	ADDI	r3	r0	2
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	18
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global18
	POP	r2
	ADDI	r3	r0	1
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	19
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global19
	POP	r2
	ADDI	r3	r0	3
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	20
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global20
	POP	r2
	ADDI	r3	r0	3
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	21
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global21
	POP	r2
	ADDI	r3	r0	3
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	22
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global22
	POP	r2
	ADDI	r3	r0	3
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	23
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global23
	POP	r2
	ADDI	r3	r0	3
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	24
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global24
	POP	r2
	ADDI	r3	r0	3
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	25
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_save_global25
	POP	r2
	ADDI	r3	r0	0
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	4
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r4	r3	0
	ADDI	r3	r0	0
	ST	r4	r2	4
	PUSH	r2
	ADDI	r2	r2	5
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r4	r0	0
	ADDI	r5	r1	0
	ADDI	r1	r1	2
	ST	r3	r5	1
	LD	r3	r2	4
	ST	r3	r5	0
	ADDI	r3	r5	0
	ADDI	r13	r4	0
	ADDI	r4	r3	0
	ADDI	r3	r13	0
	PUSH	r2
	ADDI	r2	r2	5
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r4	r3	0
	ADDI	r3	r0	5
	PUSH	r2
	ADDI	r2	r2	5
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	26
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	5
	JSUB	:min_caml_save_global26
	POP	r2
	ADDI	r3	r0	0
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	5
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r4	r0	3
	ADDI	r5	r0	0
	ST	r3	r2	5
	ADDI	r3	r4	0
	ADDI	r4	r5	0
	PUSH	r2
	ADDI	r2	r2	6
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r4	r0	60
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
	ADDI	r4	r0	27
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	7
	JSUB	:min_caml_save_global27
	POP	r2
	ADDI	r3	r0	0
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	7
	JSUB	:min_caml_create_float_array
	POP	r2
	ADDI	r4	r3	0
	ADDI	r3	r0	0
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
	ADDI	r4	r0	180
	ADDI	r5	r0	0
	ADDI	r6	r0	0
	ADDI	r7	r1	0
	ADDI	r1	r1	3
	ST	r6	r7	2
	ST	r3	r7	1
	ST	r5	r7	0
	ADDI	r3	r7	0
	ADDI	r13	r4	0
	ADDI	r4	r3	0
	ADDI	r3	r13	0
	PUSH	r2
	ADDI	r2	r2	8
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	28
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	8
	JSUB	:min_caml_save_global28
	POP	r2
	ADDI	r3	r0	1
	ADDI	r4	r0	0
	PUSH	r2
	ADDI	r2	r2	8
	JSUB	:min_caml_create_array
	POP	r2
	ADDI	r5	r3	0
	ADDI	r4	r0	29
	LD	r3	r2	0
	PUSH	r2
	ADDI	r2	r2	8
	JSUB	:min_caml_save_global29
	POP	r2
