:min_caml_fdiv
	PUSH	r3
	ADD	r3	r0	r4	#ここ直した
	JSUB	:min_caml_finv
	POP	r4
	JSUB	:min_caml_fmul
	RET
