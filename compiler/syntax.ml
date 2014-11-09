type t = Id.range * ast
and ast = (* MinCamlの構文を表現するデータ型 (caml2html: syntax_t) *)
  | Unit
  | Bool of bool
  | Int of int
  | Float of float
  | Not of t
  | Neg of t
  | Add of t * t
  | Sub of t * t
  | Mul of t * t
  | Div of t * t
  | Xor of t * t
  | Lsl of t * t
  | Lsr of t * t
  | FNeg of t
  | FAdd of t * t
  | FSub of t * t
  | FMul of t * t
  | FDiv of t * t
  | Eq of t * t
  | LE of t * t
  | If of t * t * t
  | Let of (Id.t * Type.t) * t * t
  | Var of Id.t
  | LetRec of fundef * t
  | App of t * t list
  | Tuple of t list
  | LetTuple of (Id.t * Type.t) list * t * t
  | Array of t * t
  | Get of t * t
  | Put of t * t * t
and fundef = { name : Id.t * Type.t; args : (Id.t * Type.t) list; body : t }

let get_range = fst
let get_ast = snd

let rec pp_t t = 
  let indent d = String.make (2 * d) ' ' in
  let rec pp_t' d (r, t) = 
    let sps = indent d in
    let rng = Id.pp_range r in
    match t with
    | Unit ->
       Format.sprintf "%sUnit ()\t#%s\n" sps rng
    | Bool b -> 
       Format.sprintf "%sBool %b\t#%s\n" sps b rng
    | Int i -> 
       Format.sprintf "%sInt %d\t#%s\n" sps i rng
    | Float f -> 
       Format.sprintf "%sFloat %f\t#%s\n" sps f rng
    | Not t -> 
       Format.sprintf "%sNot\t#%s\n%s" sps rng (pp_t' (d + 1) t)
    | Neg t -> 
       Format.sprintf "%sNeg\t#%s\n%s" sps rng (pp_t' (d + 1) t)
    | Add (t1, t2) -> 
       Format.sprintf "%sAdd\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | Sub (t1, t2) -> 
       Format.sprintf "%sSub\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | Mul (t1, t2) -> 
       Format.sprintf "%sMul\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | Div (t1, t2) -> 
       Format.sprintf "%sDiv\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | Xor (t1, t2) -> 
       Format.sprintf "%sXor\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | Lsl (t1, t2) -> 
       Format.sprintf "%sLsl\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | Lsr (t1, t2) -> 
       Format.sprintf "%sLsr\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | FNeg t -> 
       Format.sprintf "%sFNeg\t#%s\n%s" sps rng (pp_t' (d + 1) t)
    | FAdd (t1, t2) -> 
       Format.sprintf "%sFAdd\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | FSub (t1, t2) -> 
       Format.sprintf "%sFSub\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | FMul (t1, t2) -> 
       Format.sprintf "%sFMul\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | FDiv (t1, t2) -> 
       Format.sprintf "%sFDiv\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | Eq (t1, t2) -> 
       Format.sprintf "%sEq\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | LE (t1, t2) -> 
       Format.sprintf "%sLE\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | If (t1, t2, t3) -> 
       Format.sprintf "%sIf\t#%s\n%s%sThen\n%s%sElse\n%s" sps rng (pp_t' (d + 1) t1) sps (pp_t' (d + 1) t2) sps (pp_t' (d + 1) t3)
    | Let ((name, _), t1, t2) -> 
       Format.sprintf "%sLet\t#%s\n%s%s\n%s%sIN\n%s" sps rng (indent (d + 1)) (Id.pp_t name) (pp_t' (d + 1) t1) sps (pp_t' d t2)
    | Var name -> 
       Format.sprintf "%sVar %s\t#%s\n" sps (Id.pp_t name) rng
    | LetRec (fdef, t) -> 
       Format.sprintf "%sLetRec\t#%s\n%s%sIN\n%s" sps rng (pp_fundef (d + 1) fdef) sps (pp_t' d t) 
    | App (t, ts) -> 
       Format.sprintf "%sApp\t#%s\n%s%s" sps rng (pp_t' (d + 1) t) (pp_t_list (d + 1) ts)
    | Tuple ts -> 
       Format.sprintf "%sTuple\t#%s\n%s" sps rng (pp_t_list (d + 1) ts)
    | LetTuple (xs, t1, t2) ->
       let names = String.concat ", " (List.map (fun (name, _) -> Id.pp_t name) xs) in
       Format.sprintf "%sLetTuple\t#%s\n%s(%s)\n%s%sIN\n%s" sps rng (indent (d + 1)) names (pp_t' (d + 1) t1) sps (pp_t' d t2)
    | Array (t1, t2) ->
       Format.sprintf "%sArray\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | Get (t1, t2) ->
       Format.sprintf "%sGet\t#%s\n%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | Put (t1, t2, t3) ->
       Format.sprintf "%sPut\t#%s\n%s%s%s" sps rng (pp_t' (d + 1) t1) (pp_t' (d + 1) t2) (pp_t' (d + 1) t3)
  and pp_fundef d fdef = 
    let sps = indent d in
    let args = String.concat ", " (List.map (fun (name, _) -> Id.pp_t name) fdef.args) in
    let (fname, _) = fdef.name in
    Format.sprintf "%s%s (%s)\n%s" sps (Id.pp_t fname) args (pp_t' d fdef.body)
  and pp_t_list d ts =
    let lines = List.map (fun t -> pp_t' d t) ts in
    String.concat "" lines
  in
  pp_t' 0 t
