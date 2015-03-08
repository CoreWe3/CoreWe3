:_min_caml_start # main entry point
	ADDI	r2	r2	-5	#make stack frame
	LDI	r3	1
	ADDI	r4	r0	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global0		#r0 := min_caml_print_global0(r3)
	VFLDI	f1	0.000000e+00	#0x0
	ADDI	r28	r0	0	#Mr
	ADDI	r3	r28	0	#Mr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r4	r1	0	#Mr
	ST	r3	r4	10
	ST	r3	r4	9
	ST	r3	r4	8
	ST	r3	r4	7
	ADDI	r28	r0	0	#Mr
	ST	r28	r4	6
	ST	r3	r4	5
	ST	r3	r4	4
	ST	r28	r4	3
	ST	r28	r4	2
	ST	r28	r4	1
	ST	r28	r4	0
	ADDI	r1	r1	11
	LDI	r3	60
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global1		#r0 := min_caml_print_global1(r3)
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global2		#r0 := min_caml_print_global2(r3)
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global3		#r0 := min_caml_print_global3(r3)
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global4		#r0 := min_caml_print_global4(r3)
	VFLDI	f1	2.550000e+02	#0x437f0000
	LDI	r3	1
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global5		#r0 := min_caml_print_global5(r3)
	LDI	r4	-1
	LDI	r3	1
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r4	r3	0	#Mr
	LDI	r3	50
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ST	r3	r2	1	#Save
	JSUB	:min_caml_print_global6		#r0 := min_caml_print_global6(r3)
	LD	r3	r2	1	#Restore
	ADDI	r28	r0	0	#Mr
	ADD	r29	r3	r28
	LD	r4	r29	0
	LDI	r3	1
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r4	r3	0	#Mr
	LDI	r3	1
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global7		#r0 := min_caml_print_global7(r3)
	LDI	r3	1
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global8		#r0 := min_caml_print_global8(r3)
	ADDI	r28	r0	0	#Mr
	LDI	r3	1
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global9		#r0 := min_caml_print_global9(r3)
	VFLDI	f1	1.000000e+09	#0x4e6e6b28
	LDI	r3	1
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global10		#r0 := min_caml_print_global10(r3)
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global11		#r0 := min_caml_print_global11(r3)
	ADDI	r28	r0	0	#Mr
	LDI	r3	1
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global12		#r0 := min_caml_print_global12(r3)
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global13		#r0 := min_caml_print_global13(r3)
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global14		#r0 := min_caml_print_global14(r3)
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global15		#r0 := min_caml_print_global15(r3)
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global16		#r0 := min_caml_print_global16(r3)
	LDI	r3	2
	ADDI	r28	r0	0	#Mr
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global17		#r0 := min_caml_print_global17(r3)
	LDI	r3	2
	ADDI	r28	r0	0	#Mr
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global18		#r0 := min_caml_print_global18(r3)
	LDI	r3	1
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global19		#r0 := min_caml_print_global19(r3)
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global20		#r0 := min_caml_print_global20(r3)
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global21		#r0 := min_caml_print_global21(r3)
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global22		#r0 := min_caml_print_global22(r3)
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global23		#r0 := min_caml_print_global23(r3)
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global24		#r0 := min_caml_print_global24(r3)
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global25		#r0 := min_caml_print_global25(r3)
	ADDI	r28	r0	0	#Mr
	FADD	f1	f0	f0	#FMr
	ADDI	r3	r28	0	#Mr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r4	r3	0	#Mr
	ST	r4	r2	2	#Save
	ADDI	r28	r0	0	#Mr
	ADDI	r3	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r29	r1	0	#Mr
	ST	r3	r29	1
	LD	r4	r2	2	#Restore
	ST	r4	r29	0
	ADDI	r1	r1	2
	ADDI	r28	r0	0	#Mr
	ADDI	r3	r28	0	#Mr
	ADDI	r4	r29	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r4	r3	0	#Mr
	LDI	r3	5
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global26		#r0 := min_caml_print_global26(r3)
	ADDI	r28	r0	0	#Mr
	FADD	f1	f0	f0	#FMr
	ADDI	r3	r28	0	#Mr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r4	r3	0	#Mr
	ST	r4	r2	3	#Save
	LDI	r3	3
	FADD	f1	f0	f0	#FMr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ST	r3	r2	4	#Save
	LD	r4	r2	3	#Restore
	LDI	r3	60
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r29	r1	0	#Mr
	ST	r3	r29	1
	LD	r3	r2	4	#Restore
	ST	r3	r29	0
	ADDI	r1	r1	2
	ADDI	r3	r29	0	#Mr
	JSUB	:min_caml_print_global27		#r0 := min_caml_print_global27(r3)
	ADDI	r28	r0	0	#Mr
	FADD	f1	f0	f0	#FMr
	ADDI	r3	r28	0	#Mr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r4	r3	0	#Mr
	ST	r4	r2	5	#Save
	ADDI	r28	r0	0	#Mr
	ADDI	r3	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r29	r1	0	#Mr
	ST	r3	r29	1
	LD	r4	r2	5	#Restore
	ST	r4	r29	0
	ADDI	r1	r1	2
	LDI	r3	180
	ADDI	r4	r1	0	#Mr
	FST	f0	r4	2
	ST	r29	r4	1
	ADDI	r28	r0	0	#Mr
	ST	r28	r4	0
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global28		#r0 := min_caml_print_global28(r3)
	ADDI	r28	r0	0	#Mr
	LDI	r3	1
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global29		#r0 := min_caml_print_global29(r3)
	J	0	#halt
