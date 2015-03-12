:init_gobals_117	
	ADDI	r2	r2	-13	#make stack frame
	ST	r31	r2	13	#save link register
	LDI	r3	1
	LDI	r28	0
	ST	r28	r2	2	#Save
	ST	r3	r2	1	#Save
	ADDI	r3	r3	0	#Nop
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global0		#r0 := min_caml_print_global0(r3)
	VFLDI	f1	0.000000e+00	#0x0
	FST	f1	r2	3	#FSave
	LD	r28	r2	2	#Restore
	ADDI	r3	r28	0	#Mr
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	LDI	r29	60
	ADDI	r4	r1	0	#Mr
	ST	r3	r4	10
	ST	r3	r4	9
	ST	r3	r4	8
	ST	r3	r4	7
	LD	r28	r2	2	#Restore
	ST	r28	r4	6
	ST	r3	r4	5
	ST	r3	r4	4
	ST	r28	r4	3
	ST	r28	r4	2
	ST	r28	r4	1
	ST	r28	r4	0
	ADDI	r1	r1	11
	ST	r29	r2	4	#Save
	ADDI	r3	r29	0	#Mr
	ADDI	r4	r4	0	#Nop
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global1		#r0 := min_caml_print_global1(r3)
	LDI	r3	3
	ST	r3	r2	5	#Save
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global2		#r0 := min_caml_print_global2(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global3		#r0 := min_caml_print_global3(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global4		#r0 := min_caml_print_global4(r3)
	VFLDI	f1	2.550000e+02	#0x437f0000
	LD	r3	r2	1	#Restore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global5		#r0 := min_caml_print_global5(r3)
	LDI	r3	50
	LDI	r4	-1
	ST	r3	r2	6	#Save
	LD	r3	r2	1	#Restore
	ADDI	r3	r3	0	#Nop
	ADDI	r4	r4	0	#Nop
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r4	r3	0	#Mr
	LD	r3	r2	6	#Restore
	ADDI	r3	r3	0	#Nop
	ADDI	r4	r4	0	#Nop
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r3	r3	0	#Nop
	ST	r3	r2	7	#Save
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global6		#r0 := min_caml_print_global6(r3)
	LD	r3	r2	7	#Restore
	LD	r28	r2	2	#Restore
	ADD	r29	r3	r28
	LD	r4	r29	0
	LD	r3	r2	1	#Restore
	ADDI	r3	r3	0	#Nop
	ADDI	r4	r4	0	#Nop
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r4	r3	0	#Mr
	LD	r3	r2	1	#Restore
	ADDI	r3	r3	0	#Nop
	ADDI	r4	r4	0	#Nop
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global7		#r0 := min_caml_print_global7(r3)
	LD	r3	r2	1	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global8		#r0 := min_caml_print_global8(r3)
	LD	r28	r2	2	#Restore
	LD	r3	r2	1	#Restore
	ADDI	r3	r3	0	#Nop
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global9		#r0 := min_caml_print_global9(r3)
	VFLDI	f1	1.000000e+09	#0x4e6e6b28
	LD	r3	r2	1	#Restore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global10		#r0 := min_caml_print_global10(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global11		#r0 := min_caml_print_global11(r3)
	LD	r28	r2	2	#Restore
	LD	r3	r2	1	#Restore
	ADDI	r3	r3	0	#Nop
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global12		#r0 := min_caml_print_global12(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global13		#r0 := min_caml_print_global13(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global14		#r0 := min_caml_print_global14(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global15		#r0 := min_caml_print_global15(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global16		#r0 := min_caml_print_global16(r3)
	LDI	r3	2
	ST	r3	r2	8	#Save
	LD	r28	r2	2	#Restore
	ADDI	r3	r3	0	#Nop
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global17		#r0 := min_caml_print_global17(r3)
	LD	r3	r2	8	#Restore
	LD	r28	r2	2	#Restore
	ADDI	r3	r3	0	#Nop
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global18		#r0 := min_caml_print_global18(r3)
	LD	r3	r2	1	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global19		#r0 := min_caml_print_global19(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global20		#r0 := min_caml_print_global20(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global21		#r0 := min_caml_print_global21(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global22		#r0 := min_caml_print_global22(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global23		#r0 := min_caml_print_global23(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global24		#r0 := min_caml_print_global24(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global25		#r0 := min_caml_print_global25(r3)
	LD	r28	r2	2	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r28	0	#Mr
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r4	r3	0	#Mr
	ST	r4	r2	9	#Save
	LD	r28	r2	2	#Restore
	ADDI	r3	r28	0	#Mr
	ADDI	r4	r4	0	#Nop
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r3	r3	0	#Nop
	ADDI	r29	r1	0	#Mr
	ST	r3	r29	1
	LD	r4	r2	9	#Restore
	ST	r4	r29	0
	ADDI	r1	r1	2
	LD	r28	r2	2	#Restore
	ADDI	r3	r28	0	#Mr
	ADDI	r4	r29	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r4	r3	0	#Mr
	LDI	r3	5
	ADDI	r3	r3	0	#Nop
	ADDI	r4	r4	0	#Nop
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global26		#r0 := min_caml_print_global26(r3)
	LD	r28	r2	2	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r28	0	#Mr
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r4	r3	0	#Mr
	ST	r4	r2	10	#Save
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r3	0	#Nop
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r3	r3	0	#Nop
	ST	r3	r2	11	#Save
	LD	r4	r2	10	#Restore
	LD	r29	r2	4	#Restore
	ADDI	r3	r29	0	#Mr
	ADDI	r4	r4	0	#Nop
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r3	r3	0	#Nop
	ADDI	r29	r1	0	#Mr
	ST	r3	r29	1
	LD	r3	r2	11	#Restore
	ST	r3	r29	0
	ADDI	r1	r1	2
	ADDI	r3	r29	0	#Mr
	JSUB	:min_caml_print_global27		#r0 := min_caml_print_global27(r3)
	LD	r28	r2	2	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r28	0	#Mr
	FADD	f1	f1	f0	#Nop
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r4	r3	0	#Mr
	ST	r4	r2	12	#Save
	LD	r28	r2	2	#Restore
	ADDI	r3	r28	0	#Mr
	ADDI	r4	r4	0	#Nop
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r3	r3	0	#Nop
	ADDI	r29	r1	0	#Mr
	ST	r3	r29	1
	LD	r4	r2	12	#Restore
	ST	r4	r29	0
	ADDI	r1	r1	2
	LDI	r3	180
	ADDI	r4	r1	0	#Mr
	FLD	f1	r2	3	#FRestore
	FST	f1	r4	2
	ST	r29	r4	1
	LD	r28	r2	2	#Restore
	ST	r28	r4	0
	ADDI	r1	r1	3
	ADDI	r3	r3	0	#Nop
	ADDI	r4	r4	0	#Nop
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	JSUB	:min_caml_print_global28		#r0 := min_caml_print_global28(r3)
	LD	r28	r2	2	#Restore
	LD	r3	r2	1	#Restore
	ADDI	r3	r3	0	#Nop
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r3	r3	0	#Nop
	ADDI	r3	r3	0	#Nop
	LD	r31	r2	13	#restore link register
	ADDI	r2	r2	13	#delete stack frame
	J	:min_caml_print_global29		#r0 := min_caml_print_global29(r3)
:_min_caml_start # main entry point
	ADDI	r0	r0	0	#Nop
	JSUB	:init_gobals_117		#r0 := init_gobals_117()
	J	0	#halt
