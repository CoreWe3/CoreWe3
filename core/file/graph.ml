(* showing graph *)
let rec yloop x y c =
  if y >= 1.0 then ()
  else (
    if ((y -. 0.015625) <= c) then (
      if (c <= y) then (
	print_char 0;
	print_char 0;
	print_char 0
      )
      else (
      print_char 255;
      print_char 255;
      print_char 255
      )
    )
    else (
      print_char 255;
      print_char 255;
      print_char 255
    );
    yloop x (y +. 0.015625) c
  )
in
let rec xloop x =
  if x >= 1.0 then ()
  else (
    let xx = x *. 6.28 in
    let c = (sqrt xx) /. 6.28 in
    yloop x (-1.0) c;
    xloop (x +. 0.015625)
  )
in
let rec graph _ =
  print_char 80;
  print_char (48+6);
  print_char 32;
  print_char (48+1);
  print_char (48+2);
  print_char (48+8);
  print_char 32;
  print_char (48+1);
  print_char (48+2);
  print_char (48+8);
  print_char 32;
  print_char (48+2);
  print_char (48+5);
  print_char (48+5);
  print_char 10;
  xloop (-1.0)
in
graph ()
