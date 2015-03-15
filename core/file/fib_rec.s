	ldi	r1	0x7fffc
	ldi	r3	3
	jsub	:fib
	st	r3	r0	-1
	j	0
:fib
	addi	r1	r1	-4
	st	r31	r1	0
	cmpi	r3	0
	jeq	:base
	cmpi	r3	1
	jeq	:base
	addi	r3	r3	-1
	st	r3	r1	1
	jsub	:fib
	st	r3	r1	2
	ld	r3	r1	1
	addi	r3	r3	-1
	jsub	:fib
	ld	r4	r1	2
	add	r3	r3	r4
	ld	r31	r1	0
	addi	r1	r1	4
	ret
:base
	ld	r31	r1	0
	addi	r1	r1	4
	ret
