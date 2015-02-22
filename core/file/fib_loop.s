	addi	r3	r0	10	# n
	addi	r4	r0	1	# f(1)
	addi	r5	r0	0	# f(0)
:loop
	cmpi	r3	0
	jeq	:end
	addi	r3	r3	-1	#
	add	r6	r5	r4	# f(n+1) = f(n) + f(n-1)
	addi	r5	r4	0
	addi	r4	r6	0
	j	:loop
:end
	st	r5	r0	-1
	j	0
