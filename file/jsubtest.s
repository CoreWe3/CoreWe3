BEQ	r0	r0	:main
LDI	r1	111
:add
:add2
LDI	r2	222
JSUB	:hoge
LDI	r3	333
RET
LDI	r4	444
:hoge
LDI	r5	555
RET
:main
JSUB	:add

