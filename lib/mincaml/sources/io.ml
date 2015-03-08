let rec is_digit ch = 
  if 48 <= ch then
    if ch <= 57 then true
    else false
  else false in

let rec read_int _ =
  let rec read_int_sub ret flag =
    let ch = read_char () in
    if flag = 0 then (*initial state*)
      if ch = 45 then (* - *)
	read_int_sub (-1) 1
      else if is_digit ch then
	read_int_sub (ch - 48) 1
      else
	read_int_sub 0 0
    else (*digit part*)
      if is_digit ch  then
	read_int_sub ((ret lsl 1) + (ret lsl 3) + (ch - 48)) 1
      else
	ret
  in read_int_sub 0 0 in

let rec read_float _ =
  let rec digit2float d = 
    if d = 0 then 0.0 else if d = 1 then 1.0 
    else if d = 2 then 2.0 else if d = 3 then 3.0 
    else if d = 4 then 4.0 else if d = 5 then 5.0 
    else if d = 6 then 6.0 else if d = 7 then 7.0 
    else if d = 8 then 8.0 else if d = 9 then 9.0 
    else 0.0 in
  let rec read_float_dec _ = 
    let ch = read_char () in
    if is_digit ch then
      let d = digit2float (ch - 48) in
      0.1 *. (d +. (read_float_dec ()))
    else
      0.0 in
  let rec read_float_main ret s flag =
    if flag = 0 then (*initial state*)
      let ch = read_char () in
      if ch = 45 then (* - *)
	read_float_main 0.0 false 1
      else if is_digit ch then
	read_float_main (digit2float (ch -48)) true 1
      else
	read_float_main 0.0 true 0
    else if flag = 1 then (*integet part*)
      let ch = read_char () in
      if is_digit ch  then
	let d = digit2float (ch - 48) in
	read_float_main (ret *. 10.0 +. d) s 1
      else if ch = 46 then (*.*)
	read_float_main ret s 2
      else
	if s then ret else -.ret
    else (*decimal part*)
      let abs = ret +. (read_float_dec ()) in
      if s then abs else -.abs in
  read_float_main 0.0 true 0 in
