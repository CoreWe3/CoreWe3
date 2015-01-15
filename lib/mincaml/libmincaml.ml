(* I/O functions *)
let rec read_int _ = 
  let a = read_char () in
  let a = (a lsl 8) lor (read_char ()) in
  let a = (a lsl 8) lor (read_char ()) in
  let a = (a lsl 8) lor (read_char ()) in
  a in
let rec read_float _ = 
  iasf (read_int ()) in

let rec print_int x =
  print_char (x lsr 24);
  print_char (x lsr 16);
  print_char (x lsr 8);
  print_char x in
let rec print_float x =
  print_int (fasi x) in

(*floating-point operation*)
let rec fabs x =
  let a = fasi x in
  let b = (a lsl 1) lsr 1 in
  iasf b in
let rec fhalf x =
  let a = fasi x in
  let ex = (a lsl 1) lsr 24 in
  if 0 < ex then
    let si = (a lsr 31) lsl 31 in
    let ex = (ex - 1) lsl 23 in
    let ma = (a lsl 9)  lsr 9 in
    iasf (si lor ex lor ma)
  else
    0.0 in
let rec fsqr x = x *. x in
let rec fneg x = -.x in
let rec fless x y = x < y in
let rec fiszero x = x = 0.0 in
let rec fispos x = x > 0.0 in
let rec fisneg x = x < 0.0 in 

let rec fsub x y = 
  x +. (-.y) in

let rec finv x =
  let a = fasi x in
  let idx = (a lsl 9) lsr 22 in
  let ma = (a lsl 9) lsr 9 in
  let si = (a lsr 31) lsl 31 in
  let ex = (a lsl 1) lsr 24 in
  let ex = 253 - ex in (* 2^ex -> 2^(-ex) *)
  let ex = ex lsl 23 in
  let u = iasf ((127 lsl 23) lor ma) in
  let v = finv_table_a.(idx) in
  let w = finv_table_b.(idx) in
  let b = fasi (w -. (u *. v)) in
  let ma = (b lsl 9) lsr 9 in
  iasf (si lor ex lor ma) in
		
let rec fdiv x y =
  x *. (finv y) in

let rec sqrt x =
  if x = 0.0 then
    0.0
  else
    let a = fasi x in
    let si = a lsr 31 in
    let ex = a lsr 23 in
    let oe = (a lsl 8) lsr 31 in (* odd or even *)
    let ma = (a lsl 9) lsr 9 in
    let ex =
      if 127 <= ex then
	((ex - 127) lsr 1) + 127
      else
	127 - (((127 - ex) + 1) lsr 1) in
    let ex = ex lsl 23 in
    let b =
      if oe = 0 then
	let idx = ((a lsl 9) lsr 23) + 256 in
	let u = iasf ((128 lsl 23) lor ma) in
	let v = sqrt_table_a.(idx) in
	let w = sqrt_table_b.(idx) in
	fasi ((v *. u) +. w)
      else
	let idx = (a lsl 9) lsr 24 in
	let u = iasf ((127 lsl 23) lor ma) in
	let v = sqrt_table_a.(idx) in
	let w = sqrt_table_b.(idx) in
	fasi ((v *. u) +. w) in
    let ma = (b lsl 9) lsr 9 in
    iasf (ex lor ma) in

let rec sin_cos_reduction f =
  let rec init_p a p =
    if a < p then p else init_p a (2.0 *. p)
  in
  let rec reduce a p =
    if a < 6.283185307179586 then
      a
    else if p < a then
      reduce (a -. p) (0.5 *. p)
    else
      reduce a (0.5 *. p)
  in
  reduce f (init_p f 6.283185307179586) in
let rec kernel_sin f = 
  let f2 = f *. f in
  let f3 = f *. f2 in
  let f5 = f3 *. f2 in
  let f7 = f5 *. f2 in
  let s3 = -0.16666668 in
  let s5 =  0.008332824 in
  let s7 = -0.00019587841 in
  f +. ((s3 *. f3) +. ((s5 *. f5) +. (s7 *. f7))) in
let rec kernel_cos f = 
  let f2 = f *. f in
  let f4 = f2 *. f2 in
  let f6 = f4 *. f2 in
  let c2 = -0.5 in
  let c4 =  0.04166368 in
  let c6 = -0.0013695068 in
  1.0 +. ((c2 *. f2) +. ((c4 *. f4) +. (c6 *. f6))) in
let rec sin f = 
  let s = if f < 0.0 then 1 else 0 in
  let a = if s = 0 then f else -.f in
  let a = sin_cos_reduction a in
  let pi = 3.141592653589793 in
  let (a, s) = if a < pi then (a, s) else (a -. pi, 1 - s) in
  let pio2 = 1.5707963267948966 in
  let a = if a < pio2 then a else pi -. a in
  let pio4 = 0.7853981633974483 in
  let a = if pio4 < a then 
	    kernel_cos (pio2 -. a)
	  else
	    kernel_sin a in
  if s = 0 then 
    if a < 0.0 then -.a else a
  else 
    if a < 0.0 then a else -.a in

let rec cos f = 
  let s = 0 in
  let a = if f > 0.0 then f else -.f in
  let a = sin_cos_reduction a in
  let pi = 3.141592653589793 in
  let (a, s) = if a < pi then (a, s) else (a -. pi, 1 - s) in
  let pio2 = 1.5707963267948966 in
  let (a, s) = if a < pio2 then (a, s) else (pi -. a, 1 - s) in
  let pio4 = 0.7853981633974483 in
  let a = if pio4 < a then 
	    kernel_sin (pio2 -. a)
	  else
	    kernel_cos a in
  if s = 0 then
    if a < 0.0 then -.a else a
  else
    if a < 0.0 then a else -.a in

let rec atan f =
  let rec kernel_atan f = 
    let f2 = f *. f in
    let f3 = f *. f2 in
    let f5 = f3 *. f2 in
    let f7 = f5 *. f2 in
    let f9 = f7 *. f2 in
    let f11 = f9 *. f2 in
    let f13 = f11 *. f2 in
    let t3 = -0.3333333 in
    let t5 =  0.2 in
    let t7 = -0.142857142 in
    let t9 = 0.111111104 in
    let t11 = -0.08976446 in
    let t13 = 0.060035485 in
    f +. ((t3 *. f3) +. ((t5 *. f5) +. ((t7 *. f7) +. ((t9 *. f9) +. ((t11 *. f11) +. (t13 *. f13)))))) in
  let s = if f < 0.0 then 1 else 0 in
  let a = if s = 0 then f else -.f in
  let a = if a < 0.4375 then
	    kernel_atan a
	  else if a < 2.4375 then
	    0.7853981633974483 +. (kernel_atan ((a -. 1.0) /. (a +. 1.0)))
	  else
	    1.5707963267948966 -. (kernel_atan (1.0 /. a)) in
  if s = 0 then a else -.a in

(* 絶対値の最大ビットの位置(+127)が指数部になる。 *)
(* 切り捨てが発生する際は、最上位を0捨1入。 *)
(* 繰り上がりも考慮して、論理orではなく加算でbodyを作る。 *)
let rec float_of_int a =
  let rec find_largest_bit i a =
    if i < 0 then
      i
    else if 0 < a lsr i then
      i
    else
      find_largest_bit (i - 1) a in
  let si = (a lsr 31) lsl 31 in (* sign bit *)
  let a = if a < 0 then -a else a in (* absolute value*)
  let lb = find_largest_bit 30 a in (* 2^lb <= a < 2^(lb+1) *)
  if lb < 0 then
    0.0 (* all zero *)
  else
    let sft = 32 - lb in 
    let ma = (a lsl sft) lsr 8 in (* make mantissa part *)
    let ma = (ma + 1) lsr 1 in    (* round *)
    let ex = (lb + 127) lsl 23 in (* exponent part *)
    let sgl = si lor (ex + ma) in (* concat all parts (add exponent and mantissa for carry) *)
    iasf sgl in

(* 指数部で場合分けを行う。 *)
(* |x| < 2^23の時、小数点以下を切り捨て(0捨1入) *)
(* 2^23 <= |x| < 2^31の時、仮数部を左シフトして桁合わせ *)
(* 2^31 <= |x|の時、±2^31に丸める *)
let rec int_of_float x =
  let a = fasi x in
  let si = a lsr 31 in (* sign bit *)
  let ex = (a lsl 1) lsr 24 in (* expoent part *)
  let ma = (a lsl 9) lsr 9 in (* mantissa *)
  let ma = (1 lsl 23) lor ma in (* complement hiddeb bit *)
  if ex < 150 then (* x < 2^23 *)
    let sft = 149 - ex in 
    let a = ((ma lsr sft) + 1) lsr 1 in　(* shift and round *)
    if si = 0 then a else -a
  else if ex < 158 then (* 2^23 <= x < 2^31 *)
    let sft = ex - 150 in
    let a = ma lsl sft in (* shift *)
    if si = 0 then a else -a
  else (* 2^31 <= x *)
    if si = 0 then 2147483647 (* 2^31-1 *) else -2147483648 (* -2^31 *) in

let rec floor x =
  let a = fasi x in
  let ex = (a lsl 1) lsr 24 in
  if 150 <= ex then (* 2^23 <= |x| *)
    x
  else if ex < 127 then (* |x| < 1.0 *)
    if x < 0.0 then -1.0 else 0.0
  else
    let sft = 150 - ex in
    let b = a lsr sft in
    let b =
      if 0.0 <= x then
	b
      else
	let sft = 32 - sft in
	let dec = a lsl sft in
	if dec = 0 then (* xxx.0 *)
	  b
	else
	  b + 1 in
    iasf (b lsl sft) in

(*other*)
let rec xor x y = 
  if x then 
    if y then false else true
  else
    if y then true else false in
