	ldi	r3	0xff014	; start address
	ldi	r8	0xffffffff	; eof
:loop
	ld	r4	r0	0xffff
	ld	r5	r0	0xffff
	ld	r6	r0	0xffff
	ld	r7	r0	0xffff
	shli	r5	r5	8
	shli	r6	r6	16
	shli	r7	r7	24
	add	r4	r4	r5
	add	r6	r6	r7
	add	r4	r4	r6
	cmp	r4	r8
	jeq	:end
	st	r4	r3	0
	addi	r3	r3	1
	j	:loop
:end
	add	r1	r0	r0
