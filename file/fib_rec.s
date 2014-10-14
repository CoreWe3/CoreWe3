:main
ADDI	r1	r0	10
JSUB	:fib
ST	r1	r0	65535
BEQ	r0	r0	:main
:fib				#fib n
BEQ	r1	r0	:base	#base
ADDI	r2	r0	1
BEQ	r1	r2	:base	#base
SUB	r1	r1	r2	#step
SUB	r3	r1	r2
PUSH	r3
JSUB	:fib			#fib n-1
POP	r2
PUSH	r1
ADDI	r1	r2	0
JSUB	:fib			#fib n-2
POP	r2
ADD	r1	r1	r2
RET
:base
RET

