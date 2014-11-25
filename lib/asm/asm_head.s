	LDI	r2	489471	#init sp
	LDI	r1	0	#init hp
	JSUB	:_min_caml_start
	BEQ	r0	r0	0
