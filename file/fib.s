ADDI	r1	r0	1 
ADDI	r2	r0	1
ADDI	r4	r0	0
ADDI	r5	r0	9
BEQ	r4	r5	6	#loop
ADD	r3	r2	r1
ADDI	r1	r2	0
ADDI	r2	r3	0
ADDI	r4	r4	1
BEQ	r0	r0	-5
ST	r2	r0	0xffff
BEQ	r0	r0	-11
