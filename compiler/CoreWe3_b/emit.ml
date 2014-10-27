open Asm

external gethi : float -> int32 = "gethi"
external getlo : float -> int32 = "getlo"

let stackset = ref S.empty (* すでに Save された変数の集合 *)
let stackmap = ref [] (* Save された変数のスタックにおける位置 *)
let save x = 
  stackset := S.add x !stackset;
  if not (List.mem x !stackmap) then
    stackmap := !stackmap @ [x]
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
  "\tlis\t" ^ (reg r) ^ ", ha16(" ^ label ^ ")\n" ^
  "\taddi\t" ^ (reg r) ^ ", " ^ (reg r) ^ ", lo16(" ^ label ^ ")\n"

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
      Printf.fprintf oc "ADDI\t%s\tr0\t%d\n" (reg x) i
  | (NonTail(x), Li(i)) ->
      let n = i lsr 16 in
      let m = i lxor (n lsl 16) in
      let r = reg x in
	Printf.fprintf oc "PUSH\tr1\n";
    Printf.fprintf oc "PUSH\tr2\n";
    Printf.fprintf oc "ADDI\tr1\tr0\t16\n";
    Printf.fprintf oc "ADDI\tr2\tr0\t%d\n" n;
    Printf.fprintf oc "ADDI\t%s\tr0\t%d\n" r m;
    Printf.fprintf oc "SHL\t%s\t%s\tr1" r r;
    Printf.fprintf oc "SHR\t%s\t%s\tr1" r r;
    Printf.fprintf oc "ADD\r%s\tr2\t%s" r r;
	Printf.fprintf oc "POP\tr2\n";
    Printf.fprintf oc "POP\tr1\n";
  | (NonTail(x), SetL(Id.L(y))) -> 
      let s = load_label x y in
      Printf.fprintf oc "%s" s
  | (NonTail(x), Mr(y)) when x = y -> ()
  | (NonTail(x), Mr(y)) -> Printf.fprintf oc "ADDI\t%s\tr0\t%s\n" (reg x) (reg y)
  | (NonTail(x), Neg(y)) -> Printf.fprintf oc "SUB\t%s\tr0\t%s\n" (reg x) (reg y)
  | (NonTail(x), Add(y, V(z))) -> 
      Printf.fprintf oc "ADD\t%s\t%s\t%s\n" (reg x) (reg y) (reg z)
  | (NonTail(x), Add(y, C(z))) -> 
      Printf.fprintf oc "ADDI\t%s\t%s\t%d\n" (reg x) (reg y) z
  | (NonTail(x), Sub(y, V(z))) -> 
      Printf.fprintf oc "SUB\t%s\t%s\t%s\n" (reg x) (reg y) (reg z)
  | (NonTail(x), Sub(y, C(z))) -> 
      Printf.fprintf oc "SUB\t%s\tr0\t%s\n" (reg y) (reg y);
      Printf.fprintf oc "ADDI\t%s\t%s\t%d\n" (reg x) (reg y) z;
      Printf.fprintf oc "SUB\t%s\tr0\t%s\n" (reg x) (reg x);
      Printf.fprintf oc "SUB\t%s\tr0\t%s\n" (reg y) (reg y);
  | (NonTail(x), Slw(y, V(z))) -> 
      Printf.fprintf oc "SHL\t%s, %s, %s\n" (reg x) (reg y) (reg z)
  | (NonTail(x), Slw(y, C(z))) -> 
      Printf.fprintf oc "PUSH\tr1\n";
      Printf.fprintf oc "ADDI\tr1\tr0\t%d\n" z;
      Printf.fprintf oc "SHL\t%s\t%s\tr1\n" (reg x) (reg y);
      Printf.fprintf oc "POP\tr1\n";
  | (NonTail(x), Srw(y, V(z))) -> 
      Printf.fprintf oc "SHR\t%s\t%s\t%s\n" (reg x) (reg y) (reg z)
  | (NonTail(x), Srw(y, C(z))) -> 
      Printf.fprintf oc "PUSH\tr1\n";
      Printf.fprintf oc "ADDI\tr1\tr0\t%d\n" z;
      Printf.fprintf oc "SHR\t%s\t%s\tr1\n" (reg x) (reg y);
      Printf.fprintf oc "POP\tr1\n";
  | (NonTail(x), Ld(y, V(z))) ->
      Printf.fprintf oc "PUSH\tr1\n";
      Printf.fprintf oc "ADD\tr1\t%s\t%s\n" (reg y) (reg z);
      Printf.fprintf oc "LD\t%s\tr1\t0\n" (reg x);
      Printf.fprintf oc "POP\tr1\n";
  | (NonTail(x), Ld(y, C(z))) -> 
      Printf.fprintf oc "LD\t%s\t%s\t%d\n" (reg x) (reg y) z
  | (NonTail(_), St(x, y, V(z))) ->
      Printf.fprintf oc "PUSH\tr1\n";
      Printf.fprintf oc "ADD\tr1\t%s\t%s\n" (reg y) (reg z);
      Printf.fprintf oc "ST\t%s\tr1\t0\n" (reg x);
      Printf.fprintf oc "POP\tr1\n";
  | (NonTail(_), St(x, y, C(z))) -> 
      Printf.fprintf oc "ST\t%s\t%s\t%d\n" (reg x) (reg y) z
  | (NonTail(_), Save(x, y))
      when List.mem x allregs && not (S.mem y !stackset) ->
      save y;
	Printf.fprintf oc "PUSH\t%s\n" (reg x)
  | (NonTail(_), Save(x, y)) -> assert (S.mem y !stackset); ()
  | (NonTail(x), Restore(y)) when List.mem x allregs ->
      Printf.fprintf oc "POP\t%s\n" (reg x)
  | (Tail, (Nop | St _ | Save _ as exp)) ->
      g' oc (NonTail(Id.gentmp Type.Unit), exp);
      Printf.fprintf oc "RET\n";
  | (Tail, (Li _ | SetL _ | Mr _ | Neg _ | Add _ | Sub _ | Slw _ | Srw _ |
            Ld _ as exp)) -> 
      g' oc (NonTail(regs.(0)), exp);
      Printf.fprintf oc "RET\n";
  | (Tail, (Restore(x) as exp)) ->
      (match locate x with
	 | [i] -> g' oc (NonTail(regs.(0)), exp)
	 | _ -> assert false);
      Printf.fprintf oc "RET\n";
  | (Tail, IfEq(x, y, e1, e2)) ->
      g'_tail_if oc e1 e2 "BEQ" (reg x)  (reg y)
  | (Tail, IfLE(x, y, e1, e2)) ->
      g'_tail_if oc e1 e2 "BLE" (reg x)  (reg y)
  | (Tail, IfGE(x, y, e1, e2)) ->
      g'_tail_if oc e1 e2 "BLT" (reg y)  (reg x)
  | (NonTail(z), IfEq(x, y, e1, e2)) ->
      g'_non_tail_if oc (NonTail(z)) e1 e2 "BEQ" (reg x) (reg y)
  | (NonTail(z), IfLE(x, y, e1, e2)) ->
      g'_non_tail_if oc (NonTail(z)) e1 e2 "BLE" (reg x) (reg y)
  | (NonTail(z), IfGE(x, y, e1, e2)) ->
      g'_non_tail_if oc (NonTail(z)) e1 e2 "BLT" (reg y) (reg x)
  | (Tail, CallCls(x, ys)) -> (* 末尾呼び出し *)
      g'_args oc [(x, reg_cl)] ys;
      Printf.fprintf oc "LD\t%s\t%s\n" (reg reg_sw) (reg reg_cl);
      Printf.fprintf oc "PUSH\t%s\n" (reg reg_sw);
      Printf.fprintf oc "RET\n";
  | (Tail, CallDir(Id.L(x), ys)) -> (* 末尾呼び出し *)
      g'_args oc [] ys;
      Printf.fprintf oc "BEQ\t%s\n" x
  | (NonTail(a), CallCls(x, ys)) ->
      Printf.fprintf oc "mflr\t\n";
      g'_args oc [(x, reg_cl)] ys;
      let ss = stacksize () in
	Printf.fprintf oc "\tstw\t, %d()\n" (ss - 4) ;
	Printf.fprintf oc "\taddi\t, , %d\n" ss;
	Printf.fprintf oc "\tlwz\t, 0(%s)\n"  (reg reg_cl);
	Printf.fprintf oc "\tmtctr\t\n" ;
	Printf.fprintf oc "\tbctrl\n";
	Printf.fprintf oc "\tsubi\t, , %d\n" ss;
	Printf.fprintf oc "\tlwz\t, %d()\n" (ss - 4);
    Printf.fprintf oc "\tmr\t%s, %s\n" (reg a) (reg regs.(0));
	Printf.fprintf oc "\tmtlr\t\n"
  | (NonTail(a), CallDir(Id.L(x), ys)) -> 
      Printf.fprintf oc "\tmflr\t\n" ;
      g'_args oc [] ys;
      let ss = stacksize () in
	Printf.fprintf oc "\tstw\t, %d()\n" (ss - 4);
	Printf.fprintf oc "\taddi\t, , %d\n" ss;
	Printf.fprintf oc "\tbl\t%s\n" x;
	Printf.fprintf oc "\tsubi\t, , %d\n" ss;
	Printf.fprintf oc "\tlwz\t, %d()\n" (ss - 4);
    Printf.fprintf oc "\tmr\t%s, %s\n" (reg a) (reg regs.(0));
	Printf.fprintf oc "\tmtlr\t\n"
and g'_tail_if oc e1 e2 b x y = 
  let b_true = Id.genid (b ^ "true") in
    Printf.fprintf oc "%s\t%s\t%s\t%s\n" b x y b_true;
    let stackset_back = !stackset in
      g oc (Tail, e1);
      Printf.fprintf oc "%s:\n" b_true;
      stackset := stackset_back;
      g oc (Tail, e2)
and g'_non_tail_if oc dest e1 e2 b x y = 
  let b_true = Id.genid (b ^ "_true") in
  let b_false = Id.genid (b ^ "_false") in
    Printf.fprintf oc "%s\t%s\t%s\t%s\n" b x y b_true;
    let stackset_back = !stackset in
      g oc (dest, e1);
      let stackset1 = !stackset in
	Printf.fprintf oc "BEQ\tr0\tr0\t%s\n" b_false;
	Printf.fprintf oc "%s:\n" b_true;
	stackset := stackset_back;
	g oc (dest, e2);
	Printf.fprintf oc "%s:\n" b_false;
	let stackset2 = !stackset in
	  stackset := S.inter stackset1 stackset2
and g'_args oc x_reg_cl ys = 
  let (i, yrs) = 
    List.fold_left
      (fun (i, yrs) y -> (i + 1, (y, regs.(i)) :: yrs))
      (0, x_reg_cl) ys in
    List.iter
      (fun (y, r) -> Printf.fprintf oc "\tmr\t%s, %s\n" (reg r) (reg y))
      (shuffle reg_sw yrs)

let h oc { name = Id.L(x); args = _; body = e; ret = _ } =
  Printf.fprintf oc "%s:\n" x;
  stackset := S.empty;
  stackmap := [];
  g oc (Tail, e)

let f oc (Prog(data, fundefs, e)) =
  Format.eprintf "generating assembly...@.";
  (if data <> [] then
    (Printf.fprintf oc "\t.data\n\t.literal8\n";
     List.iter
       (fun (Id.L(x), d) ->
	 Printf.fprintf oc "\t.align 3\n";
	 Printf.fprintf oc "%s:\t # %f\n" x d;
	 Printf.fprintf oc "\t.long\t%ld\n" (gethi d);
	 Printf.fprintf oc "\t.long\t%ld\n" (getlo d))
       data));
  Printf.fprintf oc "\t.text\n";
  Printf.fprintf oc "\t.globl  _min_caml_start\n";
  Printf.fprintf oc "\t.align 2\n";
  List.iter (fun fundef -> h oc fundef) fundefs;
  Printf.fprintf oc "_min_caml_start: # main entry point\n";
  Printf.fprintf oc "\tmflr\tr0\n";
  Printf.fprintf oc "\tstmw\tr30, -8(r1)\n";
  Printf.fprintf oc "\tstw\tr0, 8(r1)\n";
  Printf.fprintf oc "\tstwu\tr1, -96(r1)\n";
  Printf.fprintf oc "   # main program start\n";
  stackset := S.empty;
  stackmap := [];
  g oc (NonTail("_R_0"), e);
  Printf.fprintf oc "   # main program end\n";
(*  Printf.fprintf oc "\tmr\tr3, %s\n" regs.(0); *)
  Printf.fprintf oc "\tlwz\tr1, 0(r1)\n";
  Printf.fprintf oc "\tlwz\tr0, 8(r1)\n";
  Printf.fprintf oc "\tmtlr\tr0\n";
  Printf.fprintf oc "\tlmw\tr30, -8(r1)\n";
  Printf.fprintf oc "\tblr\n"
