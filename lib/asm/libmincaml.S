:min_caml_create_array	#Array construct functions
	ADDI	r5	r3	0	#size
	ADDI	r6	r0	0	#index
	BEQ	r3	r0	:min_caml_create_array_L1
:min_caml_create_array_L2
	ADD	r7	r1	r6	#addr
	ST	r4	r7	0
	ADDI	r6	r6	1
	BLT	r6	r5	:min_caml_create_array_L2
:min_caml_create_array_L1
	ADDI	r3	r1	0
	ADD	r1	r1	r5
	RET

:min_caml_create_float_array
	JSUB	:min_caml_create_array
	RET


:min_caml_read_char	#I/O Functions
	LDA	r3	0xfffff
	RET

:min_caml_print_char
	STA	r3	0xfffff
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

:min_caml_fadd
	SHLI	r5	r3	1	
	SHRI	r5	r5	1	
	SHLI	r6	r4	1
	SHRI	r6	r6	1
	BLE	r6 	r5	:min_caml_fadd_L1
	ADDI	r7	r3	r0
	ADDI	r3	r4	r0
	ADDI	r4	r7	r0
:min_caml_fadd_L1
	SHLI	r5	r3	1
	SHRI	r5	r5	24
	SHLI	r6	r4	1
	SHRI	r6	r6	24
	SUB	r6	r5	r6	#r4 = shift
	SHLI	r7	r3	9	#r5(6) = man
	SHRI	r7	r7	9
	SHLI	r8	r4	9
	SHRI	r8	r8	9
	LDI	r9	0x800000
	OR	r7	r9	r7
	OR	r8	r9	r8
	SHR	r8	r8	r6	#shift man of smaller one
	SHRI	r9	r3	31	#r9(10) = sig
	SHRI	r10	r4	31
	BEQ	r9	r10	:min_caml_fadd_L2 	#r9 = man
	SUB	r11	r7	r8
	BEQ	r0	r0	:min_caml_fadd_L3
:min_caml_fadd_L2
	ADD	r11	r7	r8
:min_caml_fadd_L3
	LDI	r12	25
	LDI	r13	1
:min_caml_fadd_L4
	SHL	r14	r13	r12
	AND	r14	r11	r14
	BEQ	r14	r0	:min_caml_fadd_L4_1
	BEQ	r0	r0	:min_caml_fadd_L5
:min_caml_fadd_L4_1
	ADDI	r12	r12	-1
	BLE	r12	0	:min_caml_fadd_L5	
	BEQ	r0	r0	:min_caml_fadd_L4	#BLE+BEQmatomerareru?
:min_caml_fadd_L5
	LDI	r14	23
	BLE	r14	r12 	:min_caml_fadd_L6
	SUB	r12	r14	r12	#borrow
	BLT	r12	r5	:min_caml_fadd_L8
	LDI	r3	0
	RET
:min_caml_fadd_L8
	SUB	r10	r5	r12
	SHL	r11	r11	r12
	BEQ	r0	r0	:min_caml_fadd_L7
:min_caml_fadd_L6
	SUB	r12	r12	r14	#carry
	ADD	r10	r5	r12
	SHR	r11	r11	r12
:min_caml_fadd_L7
	SHLI	r10	r10	23
	SHLI	r11	r11	9
	SHRI	r11	r11	9
	SHLI	r3	r9	31
	OR	r3	r3	r10
	OR	r3	r3	r11
	RET

:min_caml_fsub
	FNEG	r4	r4
	JSUB	:min_caml_fadd
	RET

:min_caml_fmul
	ADDI	r15	r0	31
	SHR	r13	r3	r15
	SHR	r14	r4	r15
	XOR	r10	r13	r14
	ADDI	r13	r0	1
	ADDI	r14	r0	24
	ADDI	r15	r0	9
	ADDI	r12	r0	255
	SHL	r5	r3	r13
	SHR	r5	r5	r14
	SHL	r6	r3	r15
	SHR	r6	r6	r15
	SHL	r7	r4	r13
	SHR	r7	r7	r14
	SHL	r8	r4	r15
	SHR	r8	r8	r15
	BEQ	r5	r12	:min_caml_fmul_INF
	BEQ	r7	r12	:min_caml_fmul_INF
	BEQ	r5	r0	:min_caml_fmul_ZERO
	BEQ	r7	r0	:min_caml_fmul_ZERO
	ADD	r13	r5	r7
	ADDI	r14	r0	20
	ADDI	r11	r0	21
	SHL	r3	r6	r15
	SHR	r3	r3	r14
	SHL	r4	r6	r11
	SHR	r4	r4	r11
	SHL	r5	r8	r15
	SHR	r5	r5	r14
	SHL	r6	r8	r11
	SHR	r6	r6	r11
	ADDI	r14	r0	6
	ADDI	r8	r0	127
	BLT	r13	r8	:min_caml_fmul_ZERO
	SUB	r13	r13	r8
	ADDI	r11	r0	254
	BLT	r11	r13	:min_caml_fmul_INF
	ADDI	r8	r0	64
	SHL	r8	r8	r14
	ADD	r3	r3	r8
	ADD	r5	r5	r8
	PUSH	r6
	PUSH	r8
	PUSH	r3
	PUSH	r4
	PUSH	r5
	ADD	r4	r5	r0
	JSUB	:min_caml_mul
	ADD	r9	r0	r3
	POP	r3
	POP	r4
	PUSH	r3
	PUSH	r4
	JSUB	:min_caml_mul
	ADD	r7	r0	r3 #70
	POP	r4
	POP	r5
	POP	r3
	POP	r8
	POP	r6
	ADDI	r11	r0	11
	SHR	r7	r7	r11
	ADD	r9	r9	r7
	PUSH	r8
	PUSH	r6
	PUSH	r5
	PUSH	r4
	PUSH	r3
	ADD	r4	r6	r0
	JSUB	:min_caml_mul
	ADD	r7	r3	r0
	POP	r3
	POP	r4
	POP	r5
	POP	r6
	POP	r8
	SHR	r7	r7	r11
	ADD	r9	r9	r7
	ADDI	r9	r9	2
	ADDI	r7	r0	13
	SHL	r8	r8	r7
	BLT	r8	r9	:min_caml_fmul_KETA
	BEQ	r13	r0	:min_caml_fmul_ZERO
	ADDI	r14	r0	8
	ADDI	r15	r0	9
	SHL	r9	r9	r14
	SHR	r9	r9	r15
	BEQ	r0	r0	:min_caml_fmul_END
:min_caml_fmul_KETA
	ADDI	r13	r13	1
	BEQ	r13	r12	:min_caml_fmul_INF
	ADDI	r14	r0	7
	SHL	r9	r9	r14
	SHR	r9	r9	r15
	BEQ	r0	r0	:min_caml_fmul_END
:min_caml_fmul_INF
	ADDI	r13	r0	255
	ADDI	r9	r0	0
	BEQ	r0	r0	:min_caml_fmul_END
:min_caml_fmul_ZERO
	ADDI	r9	r0	0
	ADDI	r13	r0	0
:min_caml_fmul_END
	ADDI	r14	r0	23
	ADDI	r15	r0	31
	SHL	r13	r13	r14
	SHL	r10	r10	r15
	ADD	r3	r13	r10
	ADD	r3	r3	r9
	RET
:min_caml_mul
	ADDI	r5	r3	0
	ADDI	r3	r0	0
	ADDI	r6	r0	13
	ADDI	r7	r0	1
:min_caml_mul_loop
	AND	r8	r7	r4
	BEQ	r8	r0	:min_caml_mul_X
	ADD	r3	r3	r5
:min_caml_mul_X
	SUB	r6	r6	r7
	SHR	r4	r4	r7
	SHL	r5	r5	r7
	BLT	r0	r6	:min_caml_mul_loop
	RET
:min_caml_mul_EMD

:min_caml_finv
	ADDI	r16	r0	1
	ADDI	r15	r0	30
	ADDI	r14	r0	23
	ADDI	r12	r0	22
	ADDI	r13	r0	9
	SHL	r5	r3	r13
	SHR	r6	r5	r12
	SHR	r5	r5	r13
	ADDI	r12	r0	127
	SHL	r11	r12	r14
	OR	r7	r5	r11
	ADDI	r15	r0	31
	SHR	r5	r3	r15
	SHL	r5	r5	r15
	SHL	r4	r3	r16
	SHR	r4	r4	r16
	SHR	r4	r4	r14
	BLT	r4	r12	:min_caml_finvelse
	SUB	r4	r4	r12
	SUB	r4	r12	r4
	SUB	r4	r4	r16
	BEQ	r0	r0	:min_caml_finvend
:min_caml_finvelse
	SUB	r4	r12	r4
	ADD	r4	r12	r4
	SUB	r4	r4	r16
:min_caml_finvend
	SHL	r4	r4	r14
	LDI	r9	0x8000
	LD	r3	r9	r6	# from a.txt
	PUSH	r4
	PUSH	r5
	PUSH	r6
	OR	r4	r7	r7
	PUSH	r2
	JSUB	:min_caml_fmul	# r3 * r4 = r3
	POP	r2
	POP	r6
	PUSH	r2
	OR	r4	r3	r3
	LDI	r9	0x8000
	LD	r3	r9	r6	# from b.txt
	JSUB	:min_caml_fsub	# r3 - r4 = r3
	POP	r2
	POP	r5
	POP	r4
	SHL	r10	r3	r13
	SHR	r10	r10	r13
	OR	r3	r5	r4
	OR	r3	r3	r10
	RET

:min_caml_fdiv
	PUSH	r3
	ADD	r4	r0	r4
	JSUB	:min_caml_finv
	POP	r4
	JSUB	:min_caml_fmul
	RET

:min_caml_div2
	ADDI	r15	r0	0xff
	ADDI	r14	r0	23
	SHL	r15	r15	r14
	AND	r4	r3	r15
	BLT	r4	r0	:min_caml_return_div2
	ADDI	r15	r0	1
	SHL	r15	r15	r14
	SUB	r3	r3	r15
:min_caml_return_div2
	RET
:min_caml_fsqrt
	ADDI	r15	r0	0xffff # not tested yet!!!
	ADDI	r14	r0	1
	SHR	r15	r15	r14
	AND	r3	r3	r15
	BEQ	r3	r0	:min_caml_return_fsqrt
	ADDI	r15	r0	0xfe	#normalize
	ADDI	r14	r0	0
	SHL	r15	r15	r14
	ADDI	r13	r13	r14
	AND	r4	r3	r15
	SUB	r4	r4	r13
	ADDI	r4	r0	1
	SHR	r4	r4	r14
	PUSH	r4
	SUB	r15	r0	r15
	ADDI	r15	r15	-1
	AND	r3	r3	r15
	OR	r3	r3	r13
	PUSH	r3
	JSUB	:min_caml_div2
	ADD	r15	r3	r0
	POP	r3
	ADDI	r14	r0	4
:min_caml_loop_fsqrt
	BEQ	r14	r0	:min_caml_break_loop_fsqrt	#newton methods loop
	ADDI	r14	r14	-1
	PUSH	r14
	PUSH	r15
	PUSH	r3
	JSUB	:min_caml_div2
	POP	r4
	POP	r5
	PUSH	r5
	PUSH	r3
	ADDI	r3	r5	r0
	JSUB	:min_caml_fdiv
	ADDI	r2	r3	r0
	POP	r1
	JSUB	:min_caml_fadd
	ADDI	r3	r1	r0
	POP	r15
	POP	r14
	BEQ	r0	r0	:min_caml_loop_fsqrt
:min_caml_break_loop_fsqrt
	POP	r4
	ADD	r3	r3	r4
	ADDI	r15	r0	0xffff
	ADDI	r14	r0	1
	SHR	r15	r15	r14
	AND	r3	r3	r15
:min_caml_return_fsqrt
	RET

:min_caml_float_of_int
	ADDI	r15	r0	31
	ADDI	r14	r0	1
	ADDI	r13	r0	32
	ADDI	r12	r0	8
	ADDI	r11	r0	23
	SHR	r4	r3	r15			#r4 = sig(a)
	SHL	r4	r4	r15
	BLE	r0	r4	:min_caml_float_of_int_L1
	SUB	r3	r0	r3			#負の数なら反転
:min_caml_float_of_int_L1
	ADDI	r5	r0	30
:min_caml_float_of_int_L2					#r5 = exp(f)
	SHR	r6	r3	r5
	BLT	r0	r6	:min_caml_float_of_int_L3
	SUB	r5	r5	r14
	BLE	r0	r5	:min_caml_float_of_int_L2
	ADDI	r3	r0	0			#0は0に
	RET
:min_caml_float_of_int_L3
	SUB	r6	r13	r5
	SHL	r3	r3	r6
	SHR	r3	r3	r12
	ADDI	r3	r3	1
	SHR	r3	r3	r14
	ADDI	r5	r5	127
	SHL	r5	r5	r11
	ADD	r3	r3	r5
	OR	r3	r3	r4
	RET

:min_caml_ftoi
	ADDI	r15	r0	31
	ADDI	r14	r0	1
	ADDI	r13	r0	24
	ADDI	r12	r0	9
	ADDI	r11	r0	150
	ADDI	r10	r0	149
	ADDI	r9	r0	158
	ADDI	r8	r0	23
	SHR	r5	r3	r15			#r5 = sig(a)
	SHL	r4	r3	r14			#r4 = exp(a)
	SHR	r4	r4	r13
	SHL	r6	r14	r8			#24bit目の1を補完
	SHL	r3	r3	r12			#r3 = man(a)
	SHR	r3	r3	r12
	OR	r3	r6	r3			#ここまでok
	BLE	r11	r4	:min_caml_int_of_float_L1	#73
	SUB	r4	r10	r4
	SHR	r3	r3	r4
	ADDI	r3	r3	1
	SHR	r3	r3	r14
	BEQ	r5	r0	:min_caml_int_of_float_L2
	SUB	r3	r0	r3
:min_caml_int_of_float_L2
	RET
:min_caml_int_of_float_L1
	BLE	r9	r4	:min_caml_int_of_float_L3
	SUB	r4	r4	r11
	SHL	r3	r3	r4
	BEQ	r5	r0	:min_caml_int_of_float_L4
	SUB	r3	r0	r3
:min_caml_int_of_float_L4
	RET
:min_caml_int_of_float_L3
	ADDI	r4	r0	16
	BEQ	r5	r0	:min_caml_int_of_float_L5
	ADDI	r3	r0	0x8000
	SHL	r3	r3	r4
	RET
:min_caml_int_of_float_L5
	ADDI	r3	r0	0x7fff
	SHL	r3	r3	r4
	ADDI	r4	r0	0xffff
	OR	r3	r4	r3
	RET

:min_caml_floor
	ADDI	r15	r0	31
	ADDI	r14	r0	1
	ADDI	r13	r0	24
	ADDI	r12	r0	150
	ADDI	r11	r0	127
	ADDI	r10	r0	32
	SHR	r5	r3	r15
	SHL	r4	r3	r14
	SHR	r4	r4	r13			#modified
	BLT	r4	r12	:min_caml_floor_L1
	RET
:min_caml_floor_L1
	BLE	r11	r4	:min_caml_floor_L2
	BEQ	r5	r0	:min_caml_floor_L4
	ADDI	r4	r0	16
	ADDI	r3	r0	0xbf80
	SHL	r3	r3	r4
	RET						#-1を返す
:min_caml_floor_L4
	ADDI	r3	r0	0			#0を返す
	RET
:min_caml_floor_L2
	SUB	r6	r12	r4
	SHR	r4	r3	r6
	BEQ	r5	r0	:min_caml_floor_L3
	SUB	r9	r10	r6
	SHL	r5	r3	r9
	BEQ	r5	r0	:min_caml_floor_L3
	ADDI	r4	r4	1
:min_caml_floor_L3
	SHL	r3	r4	r6
	RET

:min_caml_fhalf
	ADDI	r7	r0	9
	ADDI	r8	r0	23
	ADDI	r9	r0	24
	ADDI	r10	r0	1
	ADDI	r11	r0	31
	SHR	r4	r3	r11	#r4 = sig(a)
	SHL	r4	r4	r11	#r4 = sig(a)
	SHL	r5	r3	r10	#r5 = exp(a)
	SHR	r5	r5	r9
	BLT	r0	r5	:min_caml_fhalf_L1
	ADDI	r3	r0	0
	RET
:min_caml_fhalf_L1
	SUB	r5	r5	r10	#r5 = exp(a) - 1
	SHL	r5	r5	r8
	SHL	r6	r3	r7	#r6 = man(a)
	SHR	r6	r6	r7
	OR 	r3	r4	r5
	OR 	r3	r3	r6
	RET

:min_caml_fabs
	ADDI	r15	r0	1
	SHL	r3	r3	r15
	SHR	r3	r3	r15
	RET
