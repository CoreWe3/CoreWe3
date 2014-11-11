:min_caml_print_char
	ST	r3	r0	0xfffff
	RET
:min_caml_print_int
	JSUB	:min_caml_print_char
	RET
