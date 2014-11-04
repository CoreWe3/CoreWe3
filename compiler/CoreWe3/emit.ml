open Asm

external gethi : float -> int32 = "gethi"
external getlo : float -> int32 = "getlo"

let stackset = ref S.empty (* すでに Save された変数の集合 *)
let stackmap = ref [] (* Save された変数のスタックにおける位置 *)
let save x = 
  stackset := S.add x !stackset;
  if not (List.mem x !stackmap) then
    stackmap := !stackmap @ [x]
let savef x = 
  stackset := S.add x !stackset;
  if not (List.mem x !stackmap) then
    (let pad = 
       if List.length !stackmap mod 2 = 0 then [] else [Id.gentmp Type.Int] in
       stackmap := !stackmap @ pad @ [x; x])
let locate x = 
  let rec loc = function 
    | [] -> []
    | y :: zs when x = y -> 0 :: List.map succ (loc zs)
    | y :: zs -> List.map succ (loc zs) in
    loc !stackmap
let offset x = 4 * List.hd (locate x)
let stacksize () = align ((List.length !stackmap + 1) * 4)

let reg r = 
  if is_reg r 
  then String.sub r 1 (String.length r - 1)
  else r 

let load_label r label =
  "#\tlis\t" ^ (reg r) ^ ", ha16(" ^ label ^ ")\n" ^ 
  "#\taddi\t" ^ (reg r) ^ ", " ^ (reg r) ^ ", lo16(" ^ label ^ ")\n" 

(* 関数呼び出しのために引数を並べ替える (register shuffling) *)
let rec shuffle sw xys = 
  (* remove identical moves *)
  let (_, xys) = List.partition (fun (x, y) -> x = y) xys in
    (* find acyclic moves *)
    match List.partition (fun (_, y) -> List.mem_assoc y xys) xys with
      | ([], []) -> []
      | ((x, y) :: xys, []) -> (* no acyclic moves; resolve a cyclic move *)
	  (y, sw) :: (x, y) :: 
	    shuffle sw (List.map (function 
				    | (y', z) when y = y' -> (sw, z)
				    | yz -> yz) xys)
      | (xys, acyc) -> acyc @ shuffle sw xys

type dest = Tail | NonTail of Id.t (* 末尾かどうかを表すデータ型 *)
let rec g oc = function (* 命令列のアセンブリ生成 *)
  | (dest, Ans (exp)) -> g' oc (dest, exp)
  | (dest, Let((x, t), exp, e)) -> g' oc (NonTail (x), exp); g oc (dest, e)
and g' oc = function (* 各命令のアセンブリ生成 *)
    (* 末尾でなかったら計算結果を dest にセット *)
  | (NonTail(_), Nop) -> ()
  | (NonTail(x), Li(i)) when i >= -32768 && i < 32768 -> 
      Printf.fprintf oc "\tADDI\t%s\tr0\t%d #Li\n" (reg x) i
  | (NonTail(x), Li(i)) ->
      let n = i lsr 16 in
      let m = i lxor (n lsl 16) in
      let r = reg x in
    Printf.fprintf oc "\tPUSH\tr1 #Li\n";
    Printf.fprintf oc "\tPUSH\tr2 #Li\n";
    Printf.fprintf oc "\tADDI\tr1\tr0\t16 #Li\n";
    Printf.fprintf oc "\tADDI\tr2\tr0\t%d #Li\n" n;
    Printf.fprintf oc "\tADDI\t%s\tr0\t%d #Li\n" r m;
    Printf.fprintf oc "\tSHL\t%s\t%s\tr1 #Li\n" r r;
    Printf.fprintf oc "\tSHR\t%s\t%s\tr1 #Li\n" r r;
    Printf.fprintf oc "\tADD\r%s\tr2\t%s #Li\n" r r;
    Printf.fprintf oc "\tPOP\tr2 #Li\n";
    Printf.fprintf oc "\tPOP\tr1 #Li\n";
  | (NonTail(x), FLi(Id.L(l))) ->
      let s = load_label reg_tmp l in
      let n = i lsr 16 in
      let m = i lxor (n lsl 16) in
      let r = reg x in
    Printf.fprintf oc "\tPUSH\tr1 #FLi\n";
    Printf.fprintf oc "\tPUSH\tr2 #FLi\n";
    Printf.fprintf oc "\tADDI\tr1\tr0\t16 #FLi\n";
    Printf.fprintf oc "\tADDI\tr2\tr0\t%d #FLi\n" n;
    Printf.fprintf oc "\tADDI\t%s\tr0\t%d #FLi\n" r m;
    Printf.fprintf oc "\tSHL\t%s\t%s\tr1 #FLi\n" r r;
    Printf.fprintf oc "\tSHR\t%s\t%s\tr1 #FLi\n" r r;
    Printf.fprintf oc "\tADD\r%s\tr2\t%s #FLi\n" r r;
    Printf.fprintf oc "\tPOP\tr2 #FLi\n";
    Printf.fprintf oc "\tPOP\tr1 #FLi\n";
  | (NonTail(x), SetL(Id.L(y))) -> 
      let s = load_label x y in
      Printf.fprintf oc "%s" s
  | (NonTail(x), Mr(y)) when x = y -> ()
  | (NonTail(x), Mr(y)) -> 
      Printf.fprintf oc "\tADD\t%s\tr0\t%s #MR\n" (reg x) (reg y)
  | (NonTail(x), Neg(y)) -> 
      Printf.fprintf oc "\tSUB\t%s\tr0\t%s #NEG\n" (reg x) (reg y)
  | (NonTail(x), Add(y, V(z))) -> 
      Printf.fprintf oc "\tADD\t%s\t%s\t%s #ADD_V\n" (reg x) (reg y) (reg z)
  | (NonTail(x), Add(y, C(z))) -> 
      Printf.fprintf oc "\tADDI\t%s\t%s\t%d #ADD_C\n" (reg x) (reg y) z
  | (NonTail(x), Sub(y, V(z))) -> 
      Printf.fprintf oc "\tSUB\t%s\t%s\t%s #SUB_V\n" (reg x) (reg y) (reg z)
  | (NonTail(x), Sub(y, C(z))) -> 
      Printf.fprintf oc "\tADDI\t%s\t%s\t%d #SUB_C\n" (reg x) (reg y) (-z);
  | (NonTail(x), Slw(y, V(z))) -> 
      Printf.fprintf oc "\tSHL\t%s,\t%s\t%s #SLW_V\n" (reg x) (reg y) (reg z)
  | (NonTail(x), Slw(y, C(z))) -> 
      Printf.fprintf oc "\tPUSH\tr1 #SLW_C\n";
      Printf.fprintf oc "\tADDI\tr1\tr0\t%d #SLW_C\n" z;
      Printf.fprintf oc "\tSHL\t%s\t%s\tr1 #SLW_C\n" (reg x) (reg y);
      Printf.fprintf oc "\tPOP\tr1 #SLW_C\n";
  | (NonTail(x), Srw(y, V(z))) -> 
      Printf.fprintf oc "\tSHR\t%s\t%s\t%s #SRW_V\n" (reg x) (reg y) (reg z)
  | (NonTail(x), Srw(y, C(z))) -> 
      Printf.fprintf oc "\tPUSH\tr1 #SRW_C\n";
      Printf.fprintf oc "\tADDI\tr1\tr0\t%d #SRW_C\n" z;
      Printf.fprintf oc "\tSHR\t%s\t%s\tr1 #SRW_C\n" (reg x) (reg y);
      Printf.fprintf oc "\tPOP\tr1 #SRW_C\n";
  | (NonTail(x), Lwz(y, V(z))) ->
      Printf.fprintf oc "\tPUSH\tr1 #LWZ_V\n";
      Printf.fprintf oc "\tADD\tr1\t%s\t%s #LWZ_V\n" (reg y) (reg z);
      Printf.fprintf oc "\tLD\t%s\tr1\t0\ #LWZ_Vn" (reg x);
      Printf.fprintf oc "\tPOP\tr1 #LWZ_V\n";
  | (NonTail(x), Lwz(y, C(z))) -> 
      Printf.fprintf oc "\tLD\t%s\t%s\t%d #LWZ_C\n" (reg x) (reg y) z
  | (NonTail(_), Stw(x, y, V(z))) ->
      Printf.fprintf oc "\tPUSH\tr1 #STW_V\n";
      Printf.fprintf oc "\tADD\tr1\t%s\t%s #STW_V\n" (reg y) (reg z);
      Printf.fprintf oc "\tST\t%s\tr1\t0 #STW_V\n" (reg x);
      Printf.fprintf oc "\tPOP\tr1 #STW_V\n";
  | (NonTail(_), Stw(x, y, C(z))) -> 
      Printf.fprintf oc "\tST\t%s\t%s\t%d #STW_C\n" (reg x) (reg y) z
  | (NonTail(_), Comment(s)) -> ()
  (* 退避の仮想命令の実装 *)
  | (NonTail(_), Save(x, y))
      when List.mem x allregs && not (S.mem y !stackset) ->
      save y;
	Printf.fprintf oc "\tST\t%s\t%s\t%d #SAVE\n" (reg x) reg_sp (offset y) 
  | (NonTail(_), Save(x, y)) -> assert (S.mem y !stackset); ()
  (* 復帰の仮想命令の実装 *)
  | (NonTail(x), Restore(y)) ->
      Printf.fprintf oc "\tLD\t%s\t%s\t%d #RESTORE\n" (reg x) reg_sp (offset y)
  (* 末尾だったら計算結果を第一レジスタにセット *)
  | (Tail, (Nop | Stw _ | Comment _ | Save _ as exp)) ->
      g' oc (NonTail(Id.gentmp Type.Unit), exp);
      Printf.fprintf oc "\tRET\n";
  | (Tail, (Li _ | FLi _ | SetL _ | Mr _ | Neg _ | Add _ | Sub _ | Slw _ | Srw _ |
            Lwz _ as exp)) -> 
      g' oc (NonTail(regs.(0)), exp);
      Printf.fprintf oc "\tRET\n";
  | (Tail, (Restore(x) as exp)) ->
      (match locate x with
	 | [i] -> g' oc (NonTail(regs.(0)), exp)
	 | [i; j] when (i + 1 = j) -> g' oc (NonTail(regs.(0)), exp)
	 | _ -> assert false);
      Printf.fprintf oc "\tRET\n";
  | (Tail, IfEq(x, y, e1, e2)) ->
      g'_tail_if oc e2 e1 "BEQ" (reg x)  (reg y)
  | (Tail, IfLE(x, y, e1, e2)) ->
      g'_tail_if oc e2 e1 "BLE" (reg x)  (reg y)
  | (Tail, IfGE(x, y, e1, e2)) ->
      g'_tail_if oc e2 e1 "BLT" (reg y)  (reg x)
  | (NonTail(z), IfEq(x, y, e1, e2)) ->
      g'_non_tail_if oc (NonTail(z)) e2 e1 "BEQ" (reg x)  (reg y)
  | (NonTail(z), IfLE(x, y, e1, e2)) ->
      g'_non_tail_if oc (NonTail(z)) e2 e1 "BLE" (reg x)  (reg y)
  | (NonTail(z), IfGE(x, y, e1, e2)) ->
      g'_non_tail_if oc (NonTail(z)) e2 e1 "BLT" (reg y)  (reg x)
  (* 関数呼び出しの仮想命令の実装 *)
  | (Tail, CallCls(x, ys)) -> (* 末尾呼び出し *)
      g'_args oc [(x, reg_cl)] ys;
      Printf.fprintf oc "#\tlwz\t%s, 0(%s) #CALLCLS\n" (reg reg_sw) (reg reg_cl);
      Printf.fprintf oc "#\tmtctr\t%s\n\tbctr #CALLCLS\n" (reg reg_sw);
  | (Tail, CallDir(Id.L(x), ys)) -> (* 末尾呼び出し *)
      g'_args oc [] ys;
      Printf.fprintf oc "\nJSUB\t%s #CALLCLS\n" x
  | (NonTail(a), CallCls(x, ys)) ->
      g'_args oc [(x, reg_cl)] ys;
      let ss = stacksize () in
	Printf.fprintf oc "\tADDI\t%s\t%s\t%d #CALLCLS\n" reg_sp reg_sp ss;
	Printf.fprintf oc "#\tlwz\t%s, 0(%s) #CALLCLS\n" reg_tmp (reg reg_cl);
	Printf.fprintf oc "#\tmtctr\t%s\n #CALLCLS" reg_tmp;
	Printf.fprintf oc "#\tbctrl #CALLCLS\n";
	Printf.fprintf oc "\tADDI\t%s\t%s\t%d #CALLCLS\n" reg_sp reg_sp (-ss);
	(if List.mem a allregs && a <> regs.(0) then 
	   Printf.fprintf oc "\tADD\t%s\tr0\t%s #CALLCLS\n" (reg a) (reg regs.(0)));
  | (NonTail(a), CallDir(Id.L(x), ys)) -> 
      g'_args oc [] ys;
      let ss = stacksize () in
	Printf.fprintf oc "\tADDI\t%s\t%s\t%d #CALLDIR\n" reg_sp reg_sp ss;
	Printf.fprintf oc "\tJSUB\t:%s #CALLDIR\n" x;
	Printf.fprintf oc "\tADDI\t%s\t%s\t%d #CALLDIR\n" reg_sp reg_sp (-ss);
	(if List.mem a allregs && a <> regs.(0) then
	   Printf.fprintf oc "\tADD\t%s\tr0\t%s #CALLDIR\n" (reg a) (reg regs.(0)));
and g'_tail_if oc e1 e2 b x y = 
  let b_true = Id.genid (b ^ "true") in
    Printf.fprintf oc "\t%s\t%s\t%s\t:%s #TAILIF\n" b x y b_true;
    let stackset_back = !stackset in
      g oc (Tail, e1);
      Printf.fprintf oc ":%s\n" b_true;
      stackset := stackset_back;
      g oc (Tail, e2)
and g'_non_tail_if oc dest e1 e2 b x y = 
  let b_true = Id.genid (b ^ "_true") in
  let b_false = Id.genid (b ^ "_false") in
    Printf.fprintf oc "\t%s\t%s\t%s\t:%s #NONTAILIF\n" b x y b_true;
    let stackset_back = !stackset in
      g oc (dest, e1);
      let stackset1 = !stackset in
	Printf.fprintf oc "\tJSUB\t:%s #NONTAILIF\n" b_false;
	Printf.fprintf oc ":%s\n" b_true;
	stackset := stackset_back;
	g oc (dest, e2);
	Printf.fprintf oc ":%s\n" b_false;
	let stackset2 = !stackset in
	  stackset := S.inter stackset1 stackset2
and g'_args oc x_reg_cl ys = 
  let (i, yrs) = 
    List.fold_left
      (fun (i, yrs) y -> (i + 1, (y, regs.(i)) :: yrs))
      (0, x_reg_cl) ys in
    List.iter
      (fun (y, r) -> Printf.fprintf oc "\tADD\t%s\tr0\t%s #ARGS\n" (reg r) (reg y))
      (shuffle reg_sw yrs)

let h oc { name = Id.L(x); args = _; body = e; ret = _ } =
  Printf.fprintf oc ":%s\n" x;
  stackset := S.empty;
  stackmap := [];
  g oc (Tail, e)


let f oc (Prog(data, fundefs, e)) =
  Format.eprintf "generating assembly...@.";
  Printf.fprintf oc "BEQ\tr0\tr0\t:_min_caml_start\n";
  List.iter (fun fundef -> h oc fundef) fundefs;
  Printf.fprintf oc ":_min_caml_start # main entry point\n";
  stackset := S.empty;
  stackmap := [];
  g oc (NonTail("_R_0"), e);
