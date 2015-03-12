	vfldi	f1	10.0	# n
	vfldi	f2	0x3f800000	# f(1) = 1
	fadd	f3	f0	f0	# f(0) = 0
	vfldi	f31	0x3f800000	# 1
:loop
	fcmp	f1	f0
	jle	:end
	fsub	f1	f1	f31	# n = n-1
	fadd	f4	f2	f3	# f(n+1) = f(n) + f(n-1)
	fadd	f3	f2	f0
	fadd	f2	f4	f0
	j	:loop
:end
	fst	f3	r0	-1
	j	0
