:fdiv
	PUSH	r3
	ADD	r4	r0	r4
	JSUB	:finv
	POP	r4
	JSUB	:fmul
	RET
