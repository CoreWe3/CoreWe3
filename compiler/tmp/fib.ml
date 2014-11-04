let rec fib n =
  if n <= 1 then
      1.0
  else
      fib (n - 1) +. fib (n - 2) in
print_float (fib 1)
