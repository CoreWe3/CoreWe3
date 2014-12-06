(* (\*I/O functions*\) *)
(* let rec is_digit ch =  *)
(*   if 48 <= ch then *)
(*     if ch <= 57 then true *)
(*     else false *)
(*   else false in *)

(* let rec read_int _ = *)
(*   let rec read_int_sub ret flag = *)
(*     let ch = read_char () in *)
(*     if flag = 0 then (\*initial state*\) *)
(*       if ch = 45 then (\* - *\) *)
(* 	read_int_sub (-1) 1 *)
(*       else if is_digit ch then *)
(* 	read_int_sub (ch - 48) 1 *)
(*       else *)
(* 	read_int_sub 0 0 *)
(*     else (\*digit part*\) *)
(*       if is_digit ch  then *)
(* 	read_int_sub ((ret lsl 1) + (ret lsl 3) + (ch - 48)) 1 *)
(*       else *)
(* 	ret *)
(*   in read_int_sub 0 0 in *)

(* let rec read_float _ = *)
(*   let rec digit2float d =  *)
(*     if d = 0 then 0.0 else if d = 1 then 1.0  *)
(*     else if d = 2 then 2.0 else if d = 3 then 3.0  *)
(*     else if d = 4 then 4.0 else if d = 5 then 5.0  *)
(*     else if d = 6 then 6.0 else if d = 7 then 7.0  *)
(*     else if d = 8 then 8.0 else if d = 9 then 9.0  *)
(*     else 0.0 in *)
(*   let rec read_float_dec _ =  *)
(*     let ch = read_char () in *)
(*     if is_digit ch then *)
(*       let d = digit2float (ch - 48) in *)
(*       0.1 *. (d +. (read_float_dec ())) *)
(*     else *)
(*       0.0 in *)
(*   let rec read_float_main ret s flag = *)
(*     if flag = 0 then (\*initial state*\) *)
(*       let ch = read_char () in *)
(*       if ch = 45 then (\* - *\) *)
(* 	read_float_main 0.0 false 1 *)
(*       else if is_digit ch then *)
(* 	read_float_main (digit2float (ch -48)) true 1 *)
(*       else *)
(* 	read_float_main 0.0 true 0 *)
(*     else if flag = 1 then (\*integet part*\) *)
(*       let ch = read_char () in *)
(*       if is_digit ch  then *)
(* 	let d = digit2float (ch - 48) in *)
(* 	read_float_main (ret *. 10.0 +. d) s 1 *)
(*       else if ch = 46 then (\*.*\) *)
(* 	read_float_main ret s 2 *)
(*       else *)
(* 	if s then ret else -.ret *)
(*     else (\*decimal part*\) *)
(*       let abs = ret +. (read_float_dec ()) in *)
(*       if s then abs else -.abs in *)
(*   read_float_main 0.0 true 0 in *)

(*floating-point operation*)
let rec fsqr x = x *. x in
let rec fneg x = -.x in
let rec fequal x y = x = y in
let rec fless x y = x < y in
let rec fiszero x = x = 0.0 in
let rec fispos x = x > 0.0 in
let rec fisneg x = x < 0.0 in 

let rec sin_cos_reduction f =
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
  let s = if fless f 0.0 then 1 else 0 in
  let a = if s = 0 then f else fneg f in
  let a = sin_cos_reduction a in
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
    if fless a 0.0 then a else fneg a in
let rec cos f = 
  let s = 0 in
  let a = if s = 0 then f else fneg f in
  let a = sin_cos_reduction a in
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
    if fless a 0.0 then a else fneg a in

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
  let s = if fless f 0.0 then 1 else 0 in
  let a = if s = 0 then f else fneg f in
  let a = if fless a 0.4375 then
	    kernel_atan a
	  else if fless a 2.4375 then
	    0.7853981633974483 +. (kernel_atan ((a -. 1.0) /. (a +. 1.0)))
	  else
	    1.5707963267948966 -. (kernel_atan (1.0 /. a)) in
  if s = 0 then a else fneg a in

(*other*)
let rec xor x y = 
  if x then 
    if y then false else true
  else
    if y then true else false in
