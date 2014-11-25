:min_caml_fdiv
	PUSH	r3
	ADD	r4	r0	r4
	JSUB	:min_caml_finv
	POP	r4
	JSUB	:min_caml_fmul
	RET
