:main
	ADDI	r1	r0	1	# r1 = 1 = f(x-1)
	ADDI	r2	r0	1	# r2 = 1 = f(x)
	ADDI	r4	r0	0	# r4 = 0 = x
	ADDI	r5	r0	9	# r5 = 9
:loop
	BEQ	r4	r5	:end	# if x == 9
	ADD	r3	r2	r1	# r3 = f(x+1) = f(x) + f(x-1)
	ADDI	r1	r2	0	# r1 = f(x)
	ADDI	r2	r3	0	# r2 = f(x+1)
	ADDI	r4	r4	1	# r4 = x = x+1
	BEQ	r0	r0	:loop	# loop
:end
	ST	r2	r0	0xffff
