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

:min_caml_read_int
	LDA	r3	0xfffff
	SHLI	r3	r3	8
	LDA	r4	0xfffff
	OR	r3	r3	r4
	SHLI	r3	r3	8
	LDA	r4	0xfffff
	OR	r3	r3	r4
	SHLI	r3	r3	8
	LDA	r4	0xfffff
	OR	r3	r3	r4
	RET
	
:min_caml_read_float
	JSUB	:min_caml_read_int
	RET

:min_caml_print_char
	STA	r3	0xfffff
	RET

:min_caml_print_int
	ADDI	r4	r0	24	
	ADDI	r5	r3	0
:min_caml_print_int_L1
	SHR	r3	r5	r4
	STA	r3	0xfffff
	ADDI	r4	r4	-8
	BLE	r0	r4	:min_caml_print_int_L1
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
	SHRI	r9	r3	31	#r9(10) = sig
	SHRI	r10	r4	31
	BEQ	r9	r10	:min_caml_fadd_abscmp
	BLT	r5	r6	:min_caml_fadd_abscmp
	BLT	r6	r5	:min_caml_fadd_abscmp
	LDI	r3	0x0
	RET
:min_caml_fadd_abscmp
	SHLI	r5	r3	1
	SHRI	r5	r5	24
	SHLI	r6	r4	1
	SHRI	r6	r6	24
	SUB	r6	r5	r6	#r4 = shift
	SHLI	r7	r3	9	#r5(6) = man
	SHRI	r7	r7	9
	SHLI	r8	r4	9
	SHRI	r8	r8	9
	LDI	r12	0x800000
	OR	r7	r12	r7
	OR	r8	r12	r8
	SHR	r8	r8	r6	#shift man of smaller one
	BEQ	r9	r10	:min_caml_fadd_L2 	
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
	SHRI	r15	r3	31
	SHRI	r16	r4	31
	XOR	r15	r15	r16
	SHLI	r18	r3	1
	SHLI	r19	r4	1
	SHRI	r18	r18	24
	SHRI	r19	r19	24
	SHLI	r20	r3	9
	SHLI	r21	r4	9
	SHRI	r20	r20	20
	SHRI	r21	r21	20
	SHLI	r22	r3	21
	SHLI	r23	r4	21
	SHRI	r22	r22	21
	SHRI	r23	r23	21
	ADD	r16	r18	r19
	ADDI	r20	r20	0x1000
	ADDI	r21	r21	0x1000
	ADD	r3	r20	r0
	ADD	r4	r21	r0
:min_caml_fmul_mul_1
	ADDI	r5	r3	0
	ADDI	r3	r0	0
	ADDI	r6	r0	13
	ADDI	r7	r0	1
:min_caml_mul_loop_1
	AND	r8	r7	r4
	BEQ	r8	r0	:min_caml_mul_X_1
	ADD	r3	r3	r5
:min_caml_mul_X_1
	SUB	r6	r6	r7
	SHR	r4	r4	r7
	SHL	r5	r5	r7
	BLT	r0	r6	:min_caml_mul_loop_1
	ADDI	r17	r3	2
	ADD	r3	r20	r0
	ADD	r4	r23	r0
:min_caml_fmul_mul_2
	ADDI	r5	r3	0
	ADDI	r3	r0	0
	ADDI	r6	r0	13
	ADDI	r7	r0	1
:min_caml_mul_loop_2
	AND	r8	r7	r4
	BEQ	r8	r0	:min_caml_mul_X_2
	ADD	r3	r3	r5
:min_caml_mul_X_2
	SUB	r6	r6	r7
	SHR	r4	r4	r7
	SHL	r5	r5	r7
	BLT	r0	r6	:min_caml_mul_loop_2
	SHRI	r3	r3	11
	ADD	r17	r17	r3
	ADD	r3	r21	r0
	ADD	r4	r22	r0
:min_caml_fmul_mul_3
	ADDI	r5	r3	0
	ADDI	r3	r0	0
	ADDI	r6	r0	13
	ADDI	r7	r0	1
:min_caml_mul_loop_3
	AND	r8	r7	r4
	BEQ	r8	r0	:min_caml_mul_X_3
	ADD	r3	r3	r5
:min_caml_mul_X_3
	SUB	r6	r6	r7
	SHR	r4	r4	r7
	SHL	r5	r5	r7
	BLT	r0	r6	:min_caml_mul_loop_3
	SHRI	r3	r3	11
	ADD	r17	r17	r3
	LDI	r30	0x2000000
	BLE	r30	r17	:min_caml_fmul_keta
	SHLI	r17	r17	8
	SHRI	r17	r17	9
	BEQ	r0	r0	:min_caml_fmul_L2
:min_caml_fmul_keta
	ADDI	r16	r16	1
	SHLI	r17	r17	7
	SHRI	r17	r17	9
:min_caml_fmul_L2
	ADDI	r30	r0	127
	BLE	r16	r30	:min_caml_fmul_zero
	SUB	r16	r16	r30
	BEQ	r0	r0	:min_caml_fmul_L3
:min_caml_fmul_zero
	SHLI	r3	r15	31
	RET
:min_caml_fmul_L3
	SHLI	r3	r15	31
	SHLI	r16	r16	23
	ADD	r3	r3	r16
	ADD	r3	r3	r17
	RET

:min_caml_finv
	ADDI	r16	r0	1
	SHLI	r5	r3	9
	SHRI	r6	r5	22
	SHRI	r5	r5	9
	ADDI	r12	r0	127
	SHLI	r11	r12	23	
	OR	r7	r5	r11
	ADDI	r15	r0	31
	SHRI	r5	r3	31
	SHLI	r5	r5	31
	SHLI	r4	r3	1
	SHRI	r4	r4	1
	SHRI	r4	r4	23
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
	SHLI	r4	r4	23
	PUSH	r4
	PUSH	r5
	LDI	r9	0xEF000
	ADD	r4	r9	r6	# from a.txt
	LD	r4	r4	0
	ADD	r3	r7	r0
	PUSH	r6
	JSUB	:min_caml_fmul
	POP	r6
	ADD	r4	r3	r4
	LDI	r9	0xEF400
	ADD	r3	r9	r6	# from a.txt
	LD	r3	r3	0
	JSUB	:min_caml_fsub
	SHLI	r10	r3	9
	SHRI	r10	r10	9
	POP	r5
	POP	r4
	OR	r3	r4	r5
	OR	r3	r3	r10
	RET

:min_caml_sqrt
	SHLI	r4	r3	1
	BEQ	r4	r0	:min_caml_sqrt_ret0
	SHRI	r4	r3	31
	BEQ	r4	r0	:min_caml_sqrt_norm	#cと比較が逆転してるので注意
	LDI	r3	0xffc00000	#exception return -nan
	RET
:min_caml_sqrt_norm
	LDI	r5	127
	LDI	r6	128
	SHRI	r7	r3	23
	SHLI	r8	r3	8
	SHRI	r9	r8	31
	SHLI	r10	r3	9
	SHRI	r11	r10	9	#よさげ
	BLT	r7	r5	:min_caml_sqrt_l1_else	#Cと逆
	SUB	r20	r7	r5
	SHRI	r20	r20	1
	ADD	r20	r20	r5
	BEQ	r0	r0	:min_caml_sqrt_l1_end
:min_caml_sqrt_l1_else
	SUB	r20	r5	r7
	ADDI	r20	r20	1
	SHRI	r20	r20	1
	SUB	r20	r5	r20	#比較はみてないけどよさそう
:min_caml_sqrt_l1_end
	SHLI	r20	r20	23
	BEQ	r9	r0	:min_caml_sqrt_l2_if
	SHRI	r23	r10	24	#else
	SHLI	r5	r5	23
	OR	r4	r5	r11
	BEQ	r0	r0	:min_caml_sqrt_l2_end
:min_caml_sqrt_l2_if
	LDI	r21	256
	SHRI	r22	r10	23	#なおした
	ADD	r23	r22	r21
	SHLI	r6	r6	23
	OR	r4	r6	r11
:min_caml_sqrt_l2_end
	LDI	r25	0xEF800
	ADD	r25	r25	r23
	LD	r3	r25	r0	#from a_sqrt.txt
	PUSH	r20
	PUSH	r23
	PUSH	r2
	JSUB	:min_caml_fmul
	POP	r2
	POP	r23
	LDI	r25	0xEFC00
	ADD	r25	r25	r23
	LD	r4	r25	r0	#from b_sqrt.txt
	PUSH	r2
	JSUB	:min_caml_fadd
	POP	r2
	POP	r20
	SHLI	r3	r3	9
	SHRI	r3	r3	9
	OR	r3	r3	r20
	RET
:min_caml_sqrt_ret0
	RET	#exception return 0

:min_caml_fdiv
	PUSH	r3
	ADD	r3	r0	r4
	JSUB	:min_caml_finv
	POP	r4
	JSUB	:min_caml_fmul
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

:min_caml_int_of_float
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
