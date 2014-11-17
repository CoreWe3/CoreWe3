BEQ	r0	r0	:hoge
LDIL	r1	100
LDIL	r2	200
:s
LDIL	r3	300
LDIL	r4	41248
LDIH	r4	7
BEQ	r0	r0	:end
:hoge
LDIL	r6	10176
LDIH	r6	9
BEQ	r0	r0	:s
:end

