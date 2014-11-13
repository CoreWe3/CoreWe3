(* let rec fless a b = a < b in *)
(* let rec fneg a = -.a in *)

let rec reduction f =
  let rec init_p a p =
    if fless a p then p else init_p a (2.0 *. p)
  in
  let rec reduce a p =
    if fless a 6.283185307179586 then
      a
    else if fless p a then
      reduce (a -. p) (0.5 *. p)
    else
      reduce a (0.5 *. p)
  in
  reduce f (init_p f 6.283185307179586)
in

let rec kernel_sin f = 
  let f2 = f *. f in
  let f3 = f *. f2 in
  let f5 = f3 *. f2 in
  let f7 = f5 *. f2 in
  let s3 = -0.16666668 in
  let s5 =  0.008332824 in
  let s7 = -0.00019587841 in
  f +. ((s3 *. f3) +. ((s5 *. f5) +. (s7 *. f7)))
in

let rec kernel_cos f = 
  let f2 = f *. f in
  let f4 = f2 *. f2 in
  let f6 = f4 *. f2 in
  let c2 = -0.5 in
  let c4 =  0.04166368 in
  let c6 = -0.0013695068 in
  1.0 +. ((c2 *. f2) +. ((c4 *. f4) +. (c6 *. f6)))
in

let rec sin f = 
  let s = if fless f 0.0 then 1 else 0 in
  let a = if s = 0 then f else fneg f in
  let a = reduction a in
  let pi = 3.141592653589793 in
  let (a, s) = if fless a pi then (a, s) else (a -. pi, 1 - s) in
  let pio2 = 1.5707963267948966 in
  let a = if fless a pio2 then a else pi -. a in
  let pio4 = 0.7853981633974483 in
  let a = if fless pio4 a then 
	    kernel_cos (pio2 -. a)
	  else
	    kernel_sin a in
  if s = 0 then 
    if fless a 0.0 then fneg a else a
  else 
    if fless a 0.0 then a else fneg a 
in

let rec cos f = 
  let s = 0 in
  let a = if s = 0 then f else fneg f in
  let a = reduction a in
  let pi = 3.141592653589793 in
  let (a, s) = if fless a pi then (a, s) else (a -. pi, 1 - s) in
  let pio2 = 1.5707963267948966 in
  let (a, s) = if fless a pio2 then (a, s) else (pi -. a, 1 - s) in
  let pio4 = 0.7853981633974483 in
  let a = if fless pio4 a then 
	    kernel_sin (pio2 -. a)
	  else
	    kernel_cos a in
  if s = 0 then
    if fless a 0.0 then fneg a else a
  else 
    if fless a 0.0 then a else fneg a
in
print_int32 (sin 0.1);
print_int32 (sin 0.3);
print_int32 (cos 0.1);
print_int32 (cos 0.3)
