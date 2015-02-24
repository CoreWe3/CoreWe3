	ldi	r2	0xfdfff
	ldi	r3	0x50	# 'P'
	ldi	r4	0x36	# '6'
	ldi	r5	0x20	# ' '
	ldi	r6	0x31	# '1'
	ldi	r7	0x32	# '2'
	ldi	r8	0x38	# '8'
	ldi	r10	0xa	# '\n'
	st	r3	r0	0xffff	# 'P'
	st	r4	r0	0xffff	# '6'
	st	r5	r0	0xffff	# ' '
	st	r6	r0	0xffff	# '1'
	st	r7	r0	0xffff	# '2'
	st	r8	r0	0xffff	# '8'
	st	r5	r0	0xffff	# ' '
	st	r6	r0	0xffff	# '1'
	st	r7	r0	0xffff	# '2'
	st	r8	r0	0xffff	# '8'
	st	r5	r0	0xffff	# ' '
	st	r6	r0	0xffff	# '1'
	st	r7	r0	0xffff	# '2'
	st	r8	r0	0xffff	# '8'
	st	r10	r9	0xffff	# '\n'
	ldi	r3	0x7f	# x
	ldi	r4	0x7f	# y
:loop
	st	r3	r0	0xffff
	st	r4	r0	0xffff
	st	r0	r0	0xffff
	cmp	r3	r0
	jeq	:xend
	addi	r3	r3	-1
	j	:loop
:xend
	ldi	r3	0x7f
	cmp	r4	r0
	jeq	:yend
	addi	r4	r4	-1
	j	:loop
:yend
	j	0
