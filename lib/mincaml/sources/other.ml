let rec xor x y = 
  if x then 
    if y then false else true
  else
    if y then true else false in
