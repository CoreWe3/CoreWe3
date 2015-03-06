(* I/O functions *)
let rec read_int _ =
  let a = read_char ()in
  let a = a + ((read_char ()) lsl 8) in
  let a = a + ((read_char ()) lsl 16) in
  let a = a + ((read_char ()) lsl 24) in
  a in

let rec print_int x =
  print_char x;
  print_char (x lsr 8);
  print_char (x lsr 16);
  print_char (x lsr 24) in

(*floating-point operation*)
let rec fhalf x = 0.5 *. x in
let rec fsqr x = x *. x in
let rec fless x y = x < y in
let rec fiszero x = x = 0.0 in
let rec fispos x = x > 0.0 in
let rec fisneg x = x < 0.0 in 

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

let rec floor x =
  if 8388608.0 <= fabs x then x
  else
    let y = float_of_int (int_of_float x) in
    if x < y then y -. 1.0 else y in

(*other*)
let rec xor x y = 
  if x then 
    if y then false else true
  else
    if y then true else false in
