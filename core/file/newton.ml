(***********************************************************************
 * newton.ml (Author: Masaki Hara)
 *
 * Prints out fractal image from complex newton method.
 *
 * solves z^3 - 1 = 0 from several initial values.
 * Meaning of the colors :
 * 1. Hue of the color is determined from the value to which z converges.
 * 2. Brightness of the color is determined from the number of iteraton.
 *    Originally, the number of iteration is integer.
 *    This program uses interpolating and the number of iteration is
 *    real number.
 *
 * It uses one external function:
 *   val print_byte : int -> unit
 *
 * It uses these floating point functions:
 *   fadd
 *   fsub
 *   fmul
 *   fdiv
 *   fcmp
 *   ftoi
 *
 ***********************************************************************
 *)

(* Imprecise log function. used in interpolation. *)

(* let rec print_byte c = print_char (char_of_int c) in *)
let rec print_byte c = print_char c in

let rec imprecise_log f =
  let rec imprecise_log_sum x prod sum nf n =
    if n < 10 then
      imprecise_log_sum x (prod *. x) (sum -. prod /. nf) (nf +. 1.0) (n + 1)
    else sum
  in
  let rec imprecise_log_reduce f k =
    if f < 0.75 then
      imprecise_log_reduce (f *. 2.0) (k -. 1.0)
    else if f > 1.5 then
      imprecise_log_reduce (f *. 0.5) (k +. 1.0)
    else
      let x = 1.0 -. f in
      imprecise_log_sum x x k 1.0 1
  in
  if f <= 1e-36 then
    -1e+36
  else if f >= 1e+36 then
    1e+36
  else
    imprecise_log_reduce f 0.0
in

(* Print floating point value as pixel value. *)
let rec print_floatpixel f =
  let i = int_of_float (f *. 255.0) in
  let i =
    if i < 0 then 0 else if i > 255 then 255 else i
  in
  print_byte i
in
(* do the newton method with initial value z_0 = a + bi. *)
let rec newton_at a b =
  let rec loop cntfactor lastfnorm zr zi =
    (* |z| *)
    let znorm = (zr *. zr) +. (zi *. zi) in
    let small = 0.0000019073486328125 in
    if znorm < small then (
      (* z is too small; print black *)
      print_byte 0;
      print_byte 0;
      print_byte 0
    ) else (
      (* z^2 *)
      let z2r = zr *. zr -. zi *. zi in
      let z2i = 2.0 *. zr *. zi in
      (* z^3 *)
      let z3r = z2r *. zr -. z2i *. zi in
      let z3i = z2r *. zi +. z2i *. zr in
      (* f(z) = z^3 - 1 *)
      let fr = z3r -. 1.0 in
      let fi = z3i in
      (* |f(z)| *)
      let fnorm = (fr *. fr) +. (fi *. fi) in
      (* |z^2| *)
      let z2norm = znorm *. znorm in
      (* z^-2 *)
      let zm2r = z2r /. z2norm in
      let zm2i = -. (z2i /. z2norm) in
      (* next z = (z^-2 - z)/3 *)
      let nzr = (zr +. zr +. zm2r) /. 3.0 in
      let nzi = (zi +. zi +. zm2i) /. 3.0 in
      let nextcntfactor = cntfactor *. 0.95 in
      if fnorm < small then (
        (* Do interpolation.
         * Alternatively, you can replace avg_cntfactor with cntfactor.
         * Then it produces a different image. *)
        let w1 = imprecise_log (small /. fnorm) in
        let w2 = imprecise_log (lastfnorm /. small) in
        let avg_cntfactor =
          (cntfactor *. w1 +. nextcntfactor *. w2) /. (w1 +. w2)
        in
        (* Saturation of the color is determined from this value. *)
        let colorfactor = 0.8 in
        if zr > 0.0 then (
          (* Print red *)
          print_floatpixel avg_cntfactor;
          print_floatpixel (avg_cntfactor *. colorfactor);
          print_floatpixel (avg_cntfactor *. colorfactor)
        ) else if zi > 0.0 then (
          (* Print blue *)
          print_floatpixel (avg_cntfactor *. colorfactor);
          print_floatpixel avg_cntfactor;
          print_floatpixel (avg_cntfactor *. colorfactor)
        ) else (
          (* Print green *)
          print_floatpixel (avg_cntfactor *. colorfactor);
          print_floatpixel (avg_cntfactor *. colorfactor);
          print_floatpixel avg_cntfactor
        )
      ) else (
        (* go to next iteration *)
        loop nextcntfactor fnorm nzr nzi
      )
    )
  in
  loop 1.0 1.0 a b
in
(* toplevel function *)
let rec newton _ =
  (* Print PPM Image header. *)
  print_byte 80; (* 'P' *)
  print_byte (48 + 6); (* '6' *)
  print_byte 32; (* ' ' *)
  print_byte (48 + 1);
  print_byte (48 + 0);
  print_byte (48 + 2);
  print_byte (48 + 5);
  print_byte 32;
  print_byte (48 + 1);
  print_byte (48 + 0);
  print_byte (48 + 2);
  print_byte (48 + 5);
  print_byte 32;
  print_byte (48 + 2);
  print_byte (48 + 5);
  print_byte (48 + 5);
  print_byte 10; (* '\n' *)
  (* Iterate over pixels. *)
  let rec loop2 a b =
    if a > 1.0 then
      ()
    else (
      newton_at a b;
      loop2 (a +. 0.001953125) b
    )
  in
  let rec loop1 b =
    if b > 1.0 then
      ()
    else (
      loop2 (-1.0) b;
      loop1 (b +. 0.001953125)
    )
  in
  loop1 (-1.0)
in
newton ()
