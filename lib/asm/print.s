:min_caml_print_char
	ST	r3	r0	0xfffff
	RET
:min_caml_print_int
	JSUB	:min_caml_print_char
	RET
:min_caml_print_int32
	ADDI	r4	r0	24	
	ADDI	r5	r3	0
:min_caml_print_int32_L1
	SHR	r3	r5	r4
	JSUB	:min_caml_print_char
	ADDI	r4	r4	-8
	BLE	r0	r4	:min_caml_print_int32_L1
	RET
