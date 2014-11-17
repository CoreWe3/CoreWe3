BEQ	r0	r0	:hoge
LDI	r1	100
LDI	r2	200
:s
LDI	r3	300
LDI	r4	500000
BEQ	r0	r0	:end
:hoge
LDI	r6	600000
BEQ	r0	r0	:s
:end

