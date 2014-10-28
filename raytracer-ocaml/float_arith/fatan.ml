(* let fless a b = a < b *)
(* let fneg a = -1.0 *. a *)
(* let chekc_atan f = *)
(*   let eps = 2. ** (-127.) in *)
(*   let r = 2. ** (-20.) in *)
(*   let a = min_caml_atan f in *)
(*   let b = atan f in *)
(*   let d = abs_float (a -. b) in *)
(*   let bnd = max ((abs_float a) *. r) eps in *)
(*   if d > bnd then *)
(*     (Format.printf "%e %e\n" a b; false) *)
(*   else *)
(*     true *)

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
  f +. ((t3 *. f3) +. ((t5 *. f5) +. ((t7 *. f7) +. ((t9 *. f9) +. ((t11 *. f11) +. (t13 *. f13))))))
	 
let rec min_caml_atan f =
  let s = if fless f 0.0 then 1 else 0 in
  let a = if s = 0 then f else fneg f in
  let a = if fless a 0.4375 then
	    kernel_atan a
	  else if fless a 2.4375 then
	    0.7853981633974483 +. (kernel_atan ((a -. 1.0) /. (a +. 1.0)))
	  else
	    1.5707963267948966 -. (kernel_atan (1.0 /. a)) in
  if s = 0 then a else fneg a
				    
