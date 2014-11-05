:main
	ADDI	r3	r0	0x50
	ST	r3	r0	-1	#"P"
	ADDI	r3	r0	0x36
	ST	r3	r0	-1	#"6"
	ADDI	r3	r0	0xa
	ST	r3	r0	-1	#"\n"
	ADDI	r4	r0	0x32
	ST	r4	r0	-1	#"2"
	ADDI	r5	r0	0x35
	ST	r5	r0	-1	#"5"
	ST	r5	r0	-1	#"6"
	ST	r3	r0	-1	#"\n"
	ST	r4	r0	-1	#"2"
	ST	r5	r0	-1	#"5"
	ST	r5	r0	-1	#"6"
	ST	r3	r0	-1	#"\n"
	ST	r4	r0	-1	#"2"
	ST	r5	r0	-1	#"5"
	ST	r5	r0	-1	#"5"
	ST	r3	r0	-1	#"\n"
	ADDI	r3	r0	0
	LDIH	r3	1		# r3 = 256 * 256 iteration
	ADDI	r4	r0	255	# r4 = R = 255
	ADDI	r5	r0	0	# r5 = G = 0
	ADDI	r6	r0	0	# r6 = B = 0
:loop
	BEQ	r3	r0	:end
	ST	r4	r0	-1
	ST	r5	r0	-1
	ST	r6	r0	-1
	ADDI	r3	r3	-1
	BEQ	r0	r0	:loop
:end
	BEQ	r0	r0	0
	JSUB	0
