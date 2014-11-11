(*

for debug

let fmul f1 f2 = f1 *. f2
let fadd f1 f2 = f1 +. f2

let read_float () =
  let f1 = 1.0 in 
  let f2 = 2.0 in 
  let f3 = 3.0 in 
  let f4 = 4.0 in 
  let f5 = 5.0 in 
  let f6 = 6.0 in 
  let f7 = 7.0 in 
  let f8 = 8.0 in 
  let f9 = 9.0 in 
  let ffun index = 
    if index = 0 then 0.0 else 
      if index = 1 then f1 else 
	if index = 2 then f2 else 
	  if index = 3 then f3 else 
	    if index = 4 then f4 else 
	      if index = 5 then f5 else 
		if index = 6 then f6 else 
		  if index = 7 then f7 else
		    if index = 8 then f8 else 
		      f9 in 
  let rec read_float_sub ret flag level =
    let ch = int_of_char (input_char stdin) in 
    let temp = ch - 48 in 
    if flag = 0 then 
      if ch = 32 || ch = 9 || ch = 10 || ch = 13
      then read_float_sub 0.0 0 0
      else
	let fl = ffun temp in 
	read_float_sub fl 1 0
    else if flag = 1 then 
      let f10 = 10.0 in 
      if ch = 32 || ch = 9 || ch = 10 || ch = 13 
      then ret 
      else if ch = 46 then  (* . *)
	read_float_sub ret 2 1
      else
	let fl = ffun temp in 
	let fmultmp = fmul ret f10 in 
	let faddtmp = fadd fmultmp fl in
	read_float_sub faddtmp 1 0
    else
      if ch = 32 || ch = 9 || ch = 10 || ch = 13
      then ret 
      else 
	let f01 = 0.1 in 	
	let f001 = 0.01 in 
	let f0001 = 0.001 in
	let f00001 = 0.0001 in 
	let f000001 = 0.00001 in 
	let f0000001 = 0.000001 in 
	let rec hfun level ret = 
	  if level = 6 then ret else 
	    hfun (level-1) (fmul ret f01) in 
	let gfun level =
	  if level = 1 then f01 else 
	    if level = 2 then f001 else 
	      if level = 3 then f0001 else 
		if level = 4 then f00001 else 
		  if level = 5 then f000001 else 
		    if level = 6 then f0000001 else 
		      hfun level f0000001 in 
	let fl = ffun temp in 
	let gl = gfun level in 
	let fmultmp = fmul fl gl in 
	let faddtmp = fadd fmultmp ret in 
	read_float_sub faddtmp 2 (level+1) in
  read_float_sub 0.0 0 0 
 *)

let read_float () =
  let f1 = 1065353216 in 
  let f2 = 1073741824 in 
  let f3 = 1077936128 in 
  let f4 = 1082130432 in 
  let f5 = 1084227584 in 
  let f6 = 1086324736 in 
  let f7 = 1088421888 in 
  let f8 = 1090519040 in 
  let f9 = 1091567616 in 
  let ffun index = 
    if index = 0 then 0 else 
      if index = 1 then f1 else 
	if index = 2 then f2 else 
	  if index = 3 then f3 else 
	    if index = 4 then f4 else 
	      if index = 5 then f5 else 
		if index = 6 then f6 else 
		  if index = 7 then f7 else
		    if index = 8 then f8 else 
		      f9 in 
  let rec read_float_sub ret flag level =
    let ch = read_char () in 
    let temp = ch -48 in 
    if flag = 0 then 
      if ch = 32 || ch = 9 || ch = 10 || ch = 13
      then read_float_sub 0 0 0
      else
	let fl = ffun temp in 
	read_float_sub fl 1 0
    else if flag = 1 then 
      let f10 = 1092616192 in 
      if ch = 32 || ch = 9 || ch = 10 || ch = 13 
      then ret 
      else if ch = 46 then  (* . *)
	read_float_sub ret 2 1
      else
	let fl = ffun temp in 
	let fmultmp = fmul ret f10 in 
	let faddtmp = fadd fmultmp fl in
	read_float_sub faddtmp 1 0
    else
      if ch = 32 || ch = 9 || ch = 10 || ch = 13
      then ret 
      else 
	let f01 = 1036831949 in 	
	let f001 = 1008981770 in 
	let f0001 = 981668463 in
	let f00001 = 953267991 in 
	let f000001 = 925353388 in 
	let f0000001 = 897988541 in 
	let rec hfun level ret = 
	  if level = 6 then ret else 
	    hfun (level-1) (fmul ret f01) in 
	let gfun level =
	  if level = 1 then f01 else 
	    if level = 2 then f001 else 
	      if level = 3 then f0001 else 
		if level = 4 then f00001 else 
		  if level = 5 then f000001 else 
		    if level = 6 then f0000001 else 
		      hfun level f0000001 in 
	let fl = ffun temp in 
	let gl = gfun level in 
	let fmultmp = fmul fl gl in 
	let faddtmp = fadd fmultmp ret in 
	read_float_sub faddtmp 2 (level+1) in
  read_float_sub 0 0 0 
 
