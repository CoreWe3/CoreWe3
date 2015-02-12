	addi	r3	r0	10
	addi	r4	r0	10
	cmp	r3	r4
	jeq	:equal
:not
	addi	r3	r4	0x40
	st	r3	r0	-1
:equal
	addi	r3	r0	0x41
	st	r3	r0	-1
