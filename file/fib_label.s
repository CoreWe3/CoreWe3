ADDI	r1	r0	1 
ADDI	r2	r0	1
ADDI	r4	r0	0
ADDI	r5	r0	9
:L1
BEQ	r4	r5	:L2	#loop
ADD	r3	r2	r1
ADDI	r1	r2	0
ADDI	r2	r3	0
ADDI	r4	r4	1
BEQ	r0	 r0	    :L1
:L2
