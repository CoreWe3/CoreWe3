type t = (* MinCamlの構文を表現するデータ型 (caml2html: syntax_t) *)
  | Unit
  | Bool of bool
  | Int of int
  | Float of float
  | Not of t
  | Neg of t
  | Add of t * t
  | Sub of t * t
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

let rec pp_t t = 
  let indent d = String.make (2 * d) ' ' in
  let rec pp_t' d t = 
    let sps = indent d in
    match t with
    | Unit -> "()"
    | Bool b -> 
       Format.sprintf "%sBool %b\n" sps b
    | Int i -> 
       Format.sprintf "%sInt %d\n" sps i
    | Float f -> 
       Format.sprintf "%sFloat %f\n" sps f
    | Not t -> 
       Format.sprintf "%sNot\n%s" sps (pp_t' (d + 1) t)
    | Neg t -> 
       Format.sprintf "%sNeg\n%s" sps (pp_t' (d + 1) t)
    | Add (t1, t2) -> 
       Format.sprintf "%sAdd\n%s%s" sps (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | Sub (t1, t2) -> 
       Format.sprintf "%sSub\n%s%s" sps (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | FNeg t -> 
       Format.sprintf "%sFNeg\n%s" sps (pp_t' (d + 1) t)
    | FAdd (t1, t2) -> 
       Format.sprintf "%sFAdd\n%s%s" sps (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | FSub (t1, t2) -> 
       Format.sprintf "%sFSub\n%s%s" sps (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | FMul (t1, t2) -> 
       Format.sprintf "%sFMul\n%s%s" sps (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | FDiv (t1, t2) -> 
       Format.sprintf "%sFDiv\n%s%s" sps (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | Eq (t1, t2) -> 
       Format.sprintf "%sEq\n%s%s" sps (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | LE (t1, t2) -> 
       Format.sprintf "%sLe\n%s%s" sps (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | If (t1, t2, t3) -> 
       Format.sprintf "%sIf\n%s%sThen\n%s%sElse\n%s" sps (pp_t' (d + 1) t1) sps (pp_t' (d + 1) t2) sps (pp_t' (d + 1) t3)
    | Let ((name, _), t1, t2) -> 
       Format.sprintf "%sLet\n%s%s\n%s%sIN\n%s" sps (indent (d + 1)) (Id.pp_t name) (pp_t' (d + 1) t1) sps (pp_t' (d + 1) t2)
    | Var name -> 
       Format.sprintf "%sVar %s\n" sps (Id.pp_t name)
    | LetRec (fdef, t) -> 
       Format.sprintf "%sLetRec\n%s%sIN\n%s" sps (pp_fundef (d + 1) fdef) sps (pp_t' (d + 1) t) 
    | App (t, ts) -> 
       Format.sprintf "%sApp\n%s%s" sps (pp_t' (d + 1) t) (pp_t_list (d + 1) ts)
    | Tuple ts -> 
       Format.sprintf "%sTuple\n%s" sps (pp_t_list (d + 1) ts)
    | LetTuple (xs, t1, t2) ->
       let names = String.concat ", " (List.map (fun (name, _) -> Id.pp_t name) xs) in
       Format.sprintf "%sLet\n%s(%s)\n%s%sIN\n%s" sps (indent (d + 1)) names (pp_t' (d + 1) t1) sps (pp_t' (d + 1) t2)
    | Array (t1, t2) ->
       Format.sprintf "%sArray\n%s%s" sps (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | Get (t1, t2) ->
       Format.sprintf "%sGet\n%s%s" sps (pp_t' (d + 1) t1) (pp_t' (d + 1) t2)
    | Put (t1, t2, t3) ->
       Format.sprintf "%sPut\n%s%s%s" sps (pp_t' (d + 1) t1) (pp_t' (d + 1) t2) (pp_t' (d + 1) t3)
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

