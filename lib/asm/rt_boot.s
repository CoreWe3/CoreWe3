.min_caml_n_objects 0
.min_caml_objects 12
.min_caml_screen 72
.min_caml_viewpoint 75
.min_caml_light 78
.min_caml_beam 81
.min_caml_and_net 83
.min_caml_or_net 134
.min_caml_solver_dist 135
.min_caml_intsec_rectside 136
.min_caml_tmin 137
.min_caml_intersection_point 138
.min_caml_intersected_object_id 141
.min_caml_nvector 142
.min_caml_texture_color 145
.min_caml_diffuse_ray 148
.min_caml_rgb 151
.min_caml_image_size 154
.min_caml_image_center 156
.min_caml_scan_pitch 158
.min_caml_startp 159
.min_caml_startp_fast 162
.min_caml_screenx_dir 165
.min_caml_screeny_dir 168
.min_caml_screenz_dir 171
.min_caml_ptrace_dirvec 174
.min_caml_dirvecs 179
.min_caml_light_dirvec 247
.min_caml_reflections 251
.min_caml_n_reflections 431
	LDI	r2	0xfdfff	#init sp
	LDI	r1	0	#init hp
	JSUB	:_min_caml_init_gobals
	J	:_min_caml_start
:min_caml_print_global0
:min_caml_print_global1
:min_caml_print_global2
:min_caml_print_global3
:min_caml_print_global4
:min_caml_print_global5
:min_caml_print_global6
:min_caml_print_global7
:min_caml_print_global8
:min_caml_print_global9
:min_caml_print_global10
:min_caml_print_global11
:min_caml_print_global12
:min_caml_print_global13
:min_caml_print_global14
:min_caml_print_global15
:min_caml_print_global16
:min_caml_print_global17
:min_caml_print_global18
:min_caml_print_global19
:min_caml_print_global20
:min_caml_print_global21
:min_caml_print_global22
:min_caml_print_global23
:min_caml_print_global24
:min_caml_print_global25
:min_caml_print_global26
:min_caml_print_global27
:min_caml_print_global28
:min_caml_print_global29
	RET
:_min_caml_init_gobals
	ADDI	r2	r2	-13	#make stack frame
	ST	r31	r2	13	#save link register
	LDI	r3	1
	LDI	r28	0
	ST	r28	r2	2	#Save
	ST	r3	r2	1	#Save
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global0		#r0 := min_caml_print_global0(r3)
	VFLDI	f1	0.000000e+00	#0x0
	FST	f1	r2	3	#FSave
	LD	r28	r2	2	#Restore
	ADDI	r3	r28	0	#Mr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
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
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global1		#r0 := min_caml_print_global1(r3)
	LDI	r3	3
	ST	r3	r2	5	#Save
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global2		#r0 := min_caml_print_global2(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global3		#r0 := min_caml_print_global3(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global4		#r0 := min_caml_print_global4(r3)
	VFLDI	f1	2.550000e+02	#0x437f0000
	LD	r3	r2	1	#Restore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global5		#r0 := min_caml_print_global5(r3)
	LDI	r3	50
	LDI	r4	-1
	ST	r3	r2	6	#Save
	LD	r3	r2	1	#Restore
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r4	r3	0	#Mr
	LD	r3	r2	6	#Restore
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ST	r3	r2	7	#Save
	JSUB	:min_caml_print_global6		#r0 := min_caml_print_global6(r3)
	LD	r3	r2	7	#Restore
	LD	r28	r2	2	#Restore
	ADD	r29	r3	r28
	LD	r4	r29	0
	LD	r3	r2	1	#Restore
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	ADDI	r4	r3	0	#Mr
	LD	r3	r2	1	#Restore
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global7		#r0 := min_caml_print_global7(r3)
	LD	r3	r2	1	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global8		#r0 := min_caml_print_global8(r3)
	LD	r28	r2	2	#Restore
	LD	r3	r2	1	#Restore
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global9		#r0 := min_caml_print_global9(r3)
	VFLDI	f1	1.000000e+09	#0x4e6e6b28
	LD	r3	r2	1	#Restore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global10		#r0 := min_caml_print_global10(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global11		#r0 := min_caml_print_global11(r3)
	LD	r28	r2	2	#Restore
	LD	r3	r2	1	#Restore
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global12		#r0 := min_caml_print_global12(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global13		#r0 := min_caml_print_global13(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global14		#r0 := min_caml_print_global14(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global15		#r0 := min_caml_print_global15(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global16		#r0 := min_caml_print_global16(r3)
	LDI	r3	2
	ST	r3	r2	8	#Save
	LD	r28	r2	2	#Restore
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global17		#r0 := min_caml_print_global17(r3)
	LD	r3	r2	8	#Restore
	LD	r28	r2	2	#Restore
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global18		#r0 := min_caml_print_global18(r3)
	LD	r3	r2	1	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global19		#r0 := min_caml_print_global19(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global20		#r0 := min_caml_print_global20(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global21		#r0 := min_caml_print_global21(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global22		#r0 := min_caml_print_global22(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global23		#r0 := min_caml_print_global23(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global24		#r0 := min_caml_print_global24(r3)
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	JSUB	:min_caml_print_global25		#r0 := min_caml_print_global25(r3)
	LD	r28	r2	2	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r28	0	#Mr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r4	r3	0	#Mr
	ST	r4	r2	9	#Save
	LD	r28	r2	2	#Restore
	ADDI	r3	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
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
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global26		#r0 := min_caml_print_global26(r3)
	LD	r28	r2	2	#Restore
	FLD	f1	r2	3	#FRestore
	ADDI	r3	r28	0	#Mr
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r4	r3	0	#Mr
	ST	r4	r2	10	#Save
	LD	r3	r2	5	#Restore
	FLD	f1	r2	3	#FRestore
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ST	r3	r2	11	#Save
	LD	r4	r2	10	#Restore
	LD	r29	r2	4	#Restore
	ADDI	r3	r29	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
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
	JSUB	:min_caml_create_float_array		#r3 := min_caml_create_float_array(r3, f1)
	ADDI	r4	r3	0	#Mr
	ST	r4	r2	12	#Save
	LD	r28	r2	2	#Restore
	ADDI	r3	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
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
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	JSUB	:min_caml_print_global28		#r0 := min_caml_print_global28(r3)
	LD	r28	r2	2	#Restore
	LD	r3	r2	1	#Restore
	ADDI	r4	r28	0	#Mr
	JSUB	:min_caml_create_array		#r3 := min_caml_create_array(r3, r4)
	LD	r31	r2	13	#restore link register
	ADDI	r2	r2	13	#delete stack frame
	J	:min_caml_print_global29		#r0 := min_caml_print_global29(r3)
