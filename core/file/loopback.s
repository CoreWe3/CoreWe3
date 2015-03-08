:loop
	ld	r3	r0	-1
	st	r3	r0	0xffff0
	ld	r4	r0	0xffff0
	st	r4	r0	-1
	j	:loop
