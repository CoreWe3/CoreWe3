:main
ADDI	r1	r0	1
JSUB	:fib
ST	r1	r0	65535
BEQ	r0	r0	:main
:fib				#fib n
BEQ	r1	r0	:base	#if n == 0
ADDI	r2	r0	1	#r2 = 1
BEQ	r1	r2	:base	#if n == 1
SUB	r1	r1	r2	#else r1 = n-1
SUB	r3	r1	r2	#r3 = n-2
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