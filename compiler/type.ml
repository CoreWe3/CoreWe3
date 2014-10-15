type t = (* MinCamlの型を表現するデータ型 (caml2html: type_t) *)
  | Unit
  | Bool
  | Int
  | Float
  | Fun of t list * t (* arguments are uncurried *)
  | Tuple of t list
  | Array of t
  | Var of t option ref

let gentyp () = Var(ref None) (* 新しい型変数を作る *)

let rec pp_t = function
  | Unit -> "()"
  | Bool -> "bool"
  | Int -> "int"
  | Float -> "float"
  | Fun (args, t) -> Format.sprintf "%s -> %s" (pp_t_list args) (pp_t t)
  | Tuple ts -> pp_t_tup ts
  | Array t -> Format.sprintf "%s array" (pp_t t)
  | Var v -> "tvar"
and pp_t_list ts = 
  let rec pp_t_list' = function
    | [] -> ""
    | [s] -> Format.sprintf "%s" (pp_t s)
    | s::ss -> Format.sprintf "%s, %s" (pp_t s) (pp_t_list' ss)
  in
  Format.sprintf "(%s)" (pp_t_list' ts)
and pp_t_tup ts = 
  let rec pp_t_tup' = function
    | [s] -> Format.sprintf "%s" (pp_t s)
    | s::ss -> Format.sprintf "%s * %s" (pp_t s) (pp_t_tup' ss)
  in
  Format.sprintf "(%s)" (pp_t_tup' ts)
