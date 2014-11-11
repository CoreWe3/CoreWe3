BEQ	r0	r0	:main
LDI	r1	111
:hoge
:add
:add2
LDI	r2	222
LDI	r3	333
RET
:main
JSUB	:add

