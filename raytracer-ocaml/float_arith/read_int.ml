let read_char () =
  int_of_char (input_char stdin)

let read_int () =
  let rec read_int_sub ret flag =
    let ch = read_char () in
    if flag = 1 then
      if ch = 32 then ret 
      else if ch = 9 then ret 
      else if ch = 10 then ret 
      else if ch = 13 then ret
      else 
	let temp = ch - 48
	in
	read_int_sub ((ret lsl 1) + (ret lsl 3) + temp) 1
    else 
      if ch = 32 then read_int_sub 0 0
      else if ch = 9 then read_int_sub 0 0
      else if ch = 10 then read_int_sub 0 0
      else if ch = 13 then read_int_sub 0 0
      else 
	let temp = ch - 48
	in
	read_int_sub ((ret lsl 1) + (ret lsl 3) + temp) 1
  in read_int_sub 0 0
