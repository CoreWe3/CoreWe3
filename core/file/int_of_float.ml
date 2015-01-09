let rec int_of_float x =
  let rec my_quot_rem x m =
    if x < 8388608.0 then
      (m, x)
    else
      my_quot_rem (x -. 8388608.0) (m+1)
  in
  let rec unsigned_mul a b r n =
    let s = if (b land 1) > 0 then r + (a lsl n)
	    else r in
    if n < 32 then
      unsigned_mul a (b lsr 1) s (n+1)
    else
      s
  in
  let (m, a) = my_quot_rem x 0 in
  (unsigned_mul m 8388608 0 0) +
    ((fasi (a +. 8388608.0)) - 1258291200)
in
print_char (int_of_float 22.501)
