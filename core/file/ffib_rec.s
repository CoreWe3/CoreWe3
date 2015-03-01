	ldi	r1	0xeefff
	vfldi	f1	0x41200000	# n = 4
	vfldi	f31	0x3f800000	# 1
	jsub	:fib
	fst	f1	r0	0xffff
	j	0
:fib
	addi	r1	r1	-4
	st	r31	r1	0
	fcmp	f1	f0
	jeq	:base
	fcmp	f1	f31
	jeq	:base
	fsub	f1	f1	f31
	fst	f1	r1	1
	jsub	:fib
	fst	f1	r1	2
	fld	f1	r1	1
	fsub	f1	f1	f31
	jsub	:fib
	fld	f2	r1	2
	fadd	f1	f1	f2
:base
	ld	r31	r1	0
	addi	r1	r1	4
	ret
