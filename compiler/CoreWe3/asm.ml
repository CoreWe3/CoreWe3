
type id_or_imm = V of Id.t | C of int

let pp_id_or_imm ii = 
    match ii with
    | V id -> 
            Format.sprintf "%s" (Id.pp_t id)
    | C i ->
            Format.sprintf "%d" i


type t = (* 命令の列 *)
  | Ans of exp
  | Let of (Id.t * Type.t) * exp * t
and exp = (* 一つ一つの命令に対応する式 *)
  | Nop
  | Li of int
  | FLi of Id.l
  | SetL of Id.l
  | Mr of Id.t
  | Neg of Id.t
  | Add of Id.t * id_or_imm
  | Sub of Id.t * id_or_imm
  | Slw of Id.t * id_or_imm
  | Srw of Id.t * id_or_imm
  | Lwz of Id.t * id_or_imm
  | Stw of Id.t * Id.t * id_or_imm
  | Comment of string
  (* virtual instructions *)
  | IfEq of Id.t * Id.t * t * t
  | IfLE of Id.t * Id.t * t * t
  | IfGE of Id.t * Id.t * t * t
  (* closure address, integer arguments, and float arguments *)
  | CallCls of Id.t * Id.t list
  | CallDir of Id.l * Id.t list
  | Save of Id.t * Id.t (* レジスタ変数の値をスタック変数へ保存 *)
  | Restore of Id.t (* スタック変数から値を復元 *)
type fundef =
    { name : Id.l; args : Id.t list; body : t; ret : Type.t }
(* プログラム全体 = 浮動小数点数テーブル + トップレベル関数 + メインの式 *)
type prog = Prog of (Id.l * float) list * fundef list * t

(* shorthand of Let for float *)
(* fletd : Id.t * exp * t -> t *)
let fletd (x, e1, e2) = Let ((x, Type.Float), e1, e2)
(* shorthand of Let for unit *)
(* seq : exp * t -> t *)
let seq (e1, e2) = Let ((Id.gentmp Type.Unit, Type.Unit), e1, e2)

let regs = [| "%r3"; "%r4"; "%r5"; "%r6"; "%r7"; "%r8"; "%r9"; "%r10"; "%r11"; "%r12"; "%r13"; "%r14";|]
(* let regs = Array.init 27 (fun i -> Printf.sprintf "_R_%d" i) *)
let allregs = Array.to_list regs
let reg_cl = regs.(Array.length regs - 1) (* closure address *)
let reg_sw = regs.(Array.length regs - 2) (* temporary for swap *)
let reg_hp = "r2"
let reg_sp = "r1"
let reg_tmp = "r15"
(* is_reg : Id.t -> bool *)
let is_reg x = x.[0] = '%'

(* remove_and_uniq : S.t -> Id.t list -> Id.t list *)
let rec remove_and_uniq xs = function 
  | [] -> []
  | x :: ys when S.mem x xs -> remove_and_uniq xs ys
  | x :: ys -> x :: remove_and_uniq (S.add x xs) ys

(* free variables in the order of use (for spilling) *)
(* fv_id_or_imm : id_or_imm -> Id.t list *)
let fv_id_or_imm = function V (x) -> [x] | _ -> []
(* fv_exp : Id.t list -> t -> S.t list *)
let rec fv_exp = function
  | Nop | Li (_) | FLi (_) | SetL (_) | Comment (_) | Restore (_) -> []
  | Mr (x) | Neg (x) | Save (x, _) -> [x]
  | Add (x, y') | Sub (x, y') | Slw (x, y') | Srw (x, y') | Lwz (x, y') -> 
      x :: fv_id_or_imm y'
  | Stw (x, y, z') -> x :: y :: fv_id_or_imm z'
  | IfEq (x, y, e1, e2) | IfLE (x, y, e1, e2) | IfGE (x, y, e1, e2) -> 
      x :: y :: remove_and_uniq S.empty (fv e1 @ fv e2)
  | CallCls (x, ys) -> x :: ys
  | CallDir (_, ys) -> ys 
and fv = function 
  | Ans (exp) -> fv_exp exp
  | Let ((x, t), exp, e) ->
      fv_exp exp @ remove_and_uniq (S.singleton x) (fv e)

(* fv : t -> Id.t list *)
let fv e = remove_and_uniq S.empty (fv e)

(* concat : t -> Id.t * Type.t -> t -> t *)
let rec concat e1 xt e2 = match e1 with
  | Ans (exp) -> Let (xt, exp, e2)
  | Let (yt, exp, e1') -> Let (yt, exp, concat e1' xt e2)

(* align : int -> int *)
let align i = if i mod 8 = 0 then i else i + 4


let rec indent n =
    match n with 
    | 0 -> ""
    | x -> " " ^ (indent (n-1))

let rec pp_t t i=
    match t with
    | Ans exp -> pp_exp exp i
    | Let ((id, ty), exp, ta) ->
            Format.sprintf "%sLet %s\n%s\n%s" (indent i) (Id.pp_t id) (pp_exp exp (i+1)) (pp_t ta i)
and pp_exp e i =
    match e with
    | Nop -> ""
    | Li im ->
            Format.sprintf "%sLi %d" (indent i) im
    | FLi (Id.L(id)) ->
            Format.sprintf "%sFLi %s" (indent i) id
    | SetL (Id.L(id)) ->
            Format.sprintf "%sSetL %s" (indent i) id
    | Mr id ->
            Format.sprintf "%sMr %s" (indent i) (Id.pp_t id)
    | Neg id ->
            Format.sprintf "%sNeg %s" (indent i) (Id.pp_t id)
    | Add (id, ii) ->
            Format.sprintf "%sAdd %s %s" (indent i) (Id.pp_t id) (pp_id_or_imm ii)
    | Sub (id, ii) ->
            Format.sprintf "%sSub %s %s" (indent i) (Id.pp_t id) (pp_id_or_imm ii)
    | Slw (id, ii) ->
            Format.sprintf "%sSlw %s %s" (indent i) (Id.pp_t id) (pp_id_or_imm ii)
    | Srw (id, ii) ->
            Format.sprintf "%sSrw %s %s" (indent i) (Id.pp_t id) (pp_id_or_imm ii)
    | Lwz (id, ii) ->
            Format.sprintf "%sLwz %s %s" (indent i) (Id.pp_t id) (pp_id_or_imm ii)
    | Stw (id1, id2, ii) ->
            Format.sprintf "%sStw %s %s %s" (indent i) (Id.pp_t id1) (Id.pp_t id2) (pp_id_or_imm ii)
    | Comment s -> ""
    | IfEq (id1, id2, t1, t2) -> 
            Format.sprintf "%sIfEq %s %s\n%s\n%sElse\n%s\n%sEndif\n" (indent i) (Id.pp_t id1) (Id.pp_t id2) (pp_t t1 (i+1)) (indent i) (pp_t t2 (i+1)) (indent i)
    | IfLE (id1, id2, t1, t2) -> 
            Format.sprintf "%sIfLE %s %s\n%s\n%sElse\n%s\n%sEndif\n" (indent i) (Id.pp_t id1) (Id.pp_t id2) (pp_t t1 (i+1)) (indent i) (pp_t t2 (i+1)) (indent i)
    | IfGE (id1, id2, t1, t2) ->
            Format.sprintf "%sIfGE %s %s\n%s\n%sElse\n%s\n%sEndif\n" (indent i) (Id.pp_t id1) (Id.pp_t id2) (pp_t t1 (i+1)) (indent i) (pp_t t2 (i+1)) (indent i)
    | CallCls (id, ids) ->
            Format.sprintf "%sCallCls %s %s" (indent i) (Id.pp_t id) (String.concat ", " (List.map (fun m -> Id.pp_t m) ids))
    | CallDir (Id.L(id), ids) ->
            Format.sprintf "%sCallDIr %s %s" (indent i) id (String.concat ", " (List.map (fun m -> Id.pp_t m) ids))
    | Save (id1, id2) ->
          Format.sprintf "%sSave %s %s" (indent i) (Id.pp_t id1) (Id.pp_t id2)
    | Restore id ->
          Format.sprintf "%sRestore %s" (indent i) (Id.pp_t id)

let pp_fundef f i =
    let Id.L(name) = f.name in
    let args = f.args in
    let body = f.body in
    let ret = f.ret in
    Format.sprintf "%s %s\n%s\n" name  (String.concat ", " (List.map (fun t -> Id.pp_t t) args)) (pp_t body (i+1))

let pp_prog p = 
    let Prog(_, funs, t) = p in
    Format.sprintf "%s\n%s\n" (String.concat "\n" (List.map (fun f -> pp_fundef f 0) funs)) (pp_t t 0) 


