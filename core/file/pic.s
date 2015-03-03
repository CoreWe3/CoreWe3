	ldi	r2	0xfdfff
	ldi	r3	0x50	# 'P'
	ldi	r4	0x36	# '6'
	ldi	r5	0x20	# ' '
	ldi	r6	0x32	# '2'
	ldi	r7	0x35	# '5'
	ldi	r8	0x36	# '6'
	ldi	r10	0xa	# '\n'
	st	r3	r0	0xffff	# 'P'
	st	r4	r0	0xffff	# '6'
	st	r5	r0	0xffff	# ' '
	st	r6	r0	0xffff	# '2'
	st	r7	r0	0xffff	# '5'
	st	r8	r0	0xffff	# '6'
	st	r5	r0	0xffff	# ' '
	st	r6	r0	0xffff	# '2'
	st	r7	r0	0xffff	# '5'
	st	r8	r0	0xffff	# '6'
	st	r5	r0	0xffff	# ' '
	st	r6	r0	0xffff	# '2'
	st	r7	r0	0xffff	# '5'
	st	r7	r0	0xffff	# '5'
	st	r10	r9	0xffff	# '\n'
	ldi	r16	0xff
	vfldi	f3	-1.0	# x
	vfldi	f4	1.0	# y
	vfldi	f16	0.0078125	# step
	vfldi	f17	1.0	#
	vfldi	f18	-1.0
	vfldi	f19	3.0
	finv	f20	f19	# 1.0/3.0
	fsub	f4	f4	f16
:loop
	jsub	:pixel
	fadd	f3	f3	f16
	fcmp	f17	f3
	jle	:xend	# 1.0 <= x
	j	:loop
:xend
	fsub	f4	f4	f16
	fcmp	f4	f18
	jlt	:yend	# y < -1.0
	vfldi	f3	-1.0
	j	:loop
:yend
	j	0
:pixel
	fmul	f5	f3	f19	# x
	finv	f7	f5	# 1/x
	fmul	f7	f7	f20
	fcmp	f4	f7
	jlt	:white
	fadd	f7	f7	f16
	fcmp	f7	f4
	jle	:white
	st	r0	r0	0xffff
	st	r0	r0	0xffff
	st	r0	r0	0xffff
	ret
:white
	st	r16	r0	0xffff
	st	r16	r0	0xffff
	st	r16	r0	0xffff
	ret
