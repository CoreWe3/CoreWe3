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
