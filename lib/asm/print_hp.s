:min_caml_print_int32
	ADDI	r4	r0	24	
	ADDI	r5	r3	0
:min_caml_print_int32_L1
	SHR	r3	r5	r4
	JSUB	:min_caml_print_char
	ADDI	r4	r4	-8
	BLE	r0	r4	:min_caml_print_int32_L1
	RET
:min_caml_print_hp1
:min_caml_print_hp2
:min_caml_print_hp3
:min_caml_print_hp4
:min_caml_print_hp5
:min_caml_print_hp6
:min_caml_print_hp7
:min_caml_print_hp8
:min_caml_print_hp9
:min_caml_print_hp10
:min_caml_print_hp11
:min_caml_print_hp12
:min_caml_print_hp13
:min_caml_print_hp14
:min_caml_print_hp15
:min_caml_print_hp16
:min_caml_print_hp17
:min_caml_print_hp18
:min_caml_print_hp19
:min_caml_print_hp20
:min_caml_print_hp21
:min_caml_print_hp22
:min_caml_print_hp23
:min_caml_print_hp24
:min_caml_print_hp25
:min_caml_print_hp26
:min_caml_print_hp27
:min_caml_print_hp28
:min_caml_print_hp29
:min_caml_print_hp30
:min_caml_print_hp
	JSUB	:min_caml_print_int32
	RET

