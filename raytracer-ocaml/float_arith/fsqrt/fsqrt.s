:div2
	ADDI	r15	r0	0xff
	ADDI	r14	r0	23
	SHL	r15	r15	r14
	AND	r4	r3	r15
	BLT	r4	r0	:return_div2
	ADDI	r15	r0	1
	SHL	r15	r15	r14
	SUB	r3	r3	r15
:return_div2
	ret
:fsqrt
	ADDI	r15	r0	0xffff # not tested yet!!!
	ADDI	r14	r0	1
	SHR	r15	r15	r14
	AND	r3	r3	r15
	BEQ	r3	r0	:return_fsqrt
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
	JSUB	:div2
	ADD	r15	r3	r0
	POP	r3
	ADDI	r14	r0	4
:loop_fsqrt
	BEQ	r14	r0	:break_loop_fsqrt	#newton methods loop
	ADDI	r14	r14	-1
	PUSH	r14
	PUSH	r15
	PUSH	r3
	JSUB	:div2
	POP	r4
	POP	r5
	PUSH	r5
	PUSH	r3
	ADDI	r3	r5	r0
	JSUB	:fdiv
	ADDI	r2	r3	r0
	POP	r1
	JSUB	:fadd
	ADDI	r3	r1	r0
	POP	r15
	POP	r14
	BEQ	r0	r0	:loop_fsqrt
:break_loop_fsqrt
	POP	r4
	ADD	r3	r3	r4
	ADDI	r15	r0	0xffff
	ADDI	r14	r0	1
	SHR	r15	r15	r14
	AND	r3	r3	r15
:return_fsqrt
	ret
