.min_caml_finv_table_a 0xEF000
.min_caml_finv_table_b 0xEF400
.min_caml_sqrt_table_a 0xEF800
.min_caml_sqrt_table_b 0xEFC00
	LDI	r2	489471	#init sp
	LDI	r1	0	#init hp
	JSUB	:_min_caml_start
	J	0
