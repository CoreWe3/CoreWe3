let read_int () =
  let rec read_int_sub () ret =
    let ch = read_char () in
    if ch = ' ' || ch = '\t' || ch = '\n' || ch = '\r' 
    then ret
    else 
      let temp = if ch = '1' then  1
		 else if ch = '2' then 2
		 else if ch = '3' then 3
		 else if ch = '4' then 4
		 else if ch = '5' then 5
		 else if ch = '6' then 6
		 else if ch = '7' then 7
		 else if ch = '8' then 8
		 else if ch = '9' then 9
		 else 0
      in
      read_int_sub () (ret*10 + temp)
  in read_int_sub () 0
in read_int ()

