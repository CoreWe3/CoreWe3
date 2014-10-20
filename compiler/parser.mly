%{
(* parserが利用する変数、関数、型などの定義 *)
open Syntax
let addtyp x = (x, Type.gentyp ())
let ex_range head tail ast = ((fst head, snd tail), ast)
%}

/* 字句を表すデータ型の定義 (caml2html: parser_token) */
%token <Id.range*bool> BOOL
%token <Id.range*int> INT
%token <Id.range*float> FLOAT
%token <Id.range>NOT
%token <Id.range>MINUS
%token <Id.range>PLUS
%token <Id.range>AST
%token <Id.range>SLASH
%token <Id.range>LSL
%token <Id.range>LSR
%token <Id.range>MINUS_DOT
%token <Id.range>PLUS_DOT
%token <Id.range>AST_DOT
%token <Id.range>SLASH_DOT
%token <Id.range>EQUAL
%token <Id.range>LESS_GREATER
%token <Id.range>LESS_EQUAL
%token <Id.range>GREATER_EQUAL
%token <Id.range>LESS
%token <Id.range>GREATER
%token <Id.range>IF
%token <Id.range>THEN
%token <Id.range>ELSE
%token <Id.range*Id.t> IDENT
%token <Id.range>LET
%token <Id.range>IN
%token <Id.range>REC
%token <Id.range>COMMA
%token <Id.range>ARRAY_CREATE
%token <Id.range>DOT
%token <Id.range>LESS_MINUS
%token <Id.range>SEMICOLON
%token <Id.range>LPAREN
%token <Id.range>RPAREN
%token EOF

/* 優先順位とassociativityの定義（低い方から高い方へ） (caml2html: parser_prior) */
%right prec_let
%right SEMICOLON
%right prec_if
%right LESS_MINUS
%left COMMA
%left EQUAL LESS_GREATER LESS GREATER LESS_EQUAL GREATER_EQUAL
%left PLUS MINUS PLUS_DOT MINUS_DOT
%left AST SLASH AST_DOT SLASH_DOT
%left LSL LSR
%right prec_unary_minus
%left prec_app
%left DOT

/* 開始記号の定義 */
%type <Syntax.t> exp program
%start program

%%

program: 
| exp 
    { 
      print_string "SyntaxTree =======================-\n";
      print_string (pp_t $1);
      $1}

simple_exp: /* 括弧をつけなくても関数の引数になれる式 (caml2html: parser_simple) */
| LPAREN exp RPAREN
    { ex_range $1 $3 (get_ast $2) }
| LPAREN RPAREN
    { ex_range $1 $2 Unit }
| BOOL
    { ex_range (fst $1) (fst $1) (Bool (snd $1)) }
| INT
    { ex_range (fst $1) (fst $1) (Int (snd $1)) }
| FLOAT
    { ex_range (fst $1) (fst $1) (Float (snd $1)) }
| IDENT
    { ex_range (fst $1) (fst $1) (Var (snd $1)) }
| simple_exp DOT LPAREN exp RPAREN
    { ex_range (get_range $1) $5 (Get ($1, $4)) }

exp: /* 一般の式 (caml2html: parser_exp) */
| simple_exp
    { $1 }
| NOT exp
    %prec prec_app
    { ex_range $1 (get_range $2) (Not $2)}
| MINUS exp
    %prec prec_unary_minus
    { match $2 with
    | (r, Float(f)) -> ex_range $1 r (Float (-.f)) (* -1.23などは型エラーではないので別扱い *)
    | (r, e) -> ex_range $1 r (Neg ($2)) }
| exp PLUS exp /* 足し算を構文解析するルール (caml2html: parser_add) */
    { ex_range (get_range $1) (get_range $3) (Add ($1, $3)) }
| exp MINUS exp
    { ex_range (get_range $1) (get_range $3) (Sub ($1, $3)) }
| exp AST exp
    { ex_range (get_range $1) (get_range $3) (Mul ($1, $3)) }
| exp SLASH exp
    { ex_range (get_range $1) (get_range $3) (Div ($1, $3)) }
| exp LSL exp
    { ex_range (get_range $1) (get_range $3) (Lsl ($1, $3)) }
| exp LSR exp
    { ex_range (get_range $1) (get_range $3) (Lsr ($1, $3)) }
| exp EQUAL exp
    { ex_range (get_range $1) (get_range $3) (Eq ($1, $3)) }
| exp LESS_GREATER exp
    { let head = (get_range $1) in
      let tail = (get_range $3) in
      let inner = ex_range head tail (Eq ($1, $3)) in
      ex_range head tail (Not inner) }
| exp LESS exp
    { let head = (get_range $1) in
      let tail = (get_range $3) in
      let inner = ex_range head tail (LE ($3, $1)) in
      ex_range head tail (Not inner) }
| exp GREATER exp
    { let head = (get_range $1) in
      let tail = (get_range $3) in
      let inner = ex_range head tail (LE ($1, $3)) in
      ex_range head tail (Not inner) }
| exp LESS_EQUAL exp
    { ex_range (get_range $1) (get_range $3) (LE ($1, $3)) }
| exp GREATER_EQUAL exp
    { ex_range (get_range $1) (get_range $3) (LE ($3, $1)) }
| IF exp THEN exp ELSE exp
    %prec prec_if
    { ex_range $1 (get_range $6) (If ($2, $4, $6)) }
| MINUS_DOT exp
    %prec prec_unary_minus
    { ex_range $1 (get_range $2) (FNeg ($2)) }
| exp PLUS_DOT exp
    {let fadd = ex_range $2 $2 (Var "fadd") in
     ex_range (get_range $1) (get_range $3) (App (fadd, [$1; $3]))}
| exp MINUS_DOT exp
    {let fsub = ex_range $2 $2 (Var "fsub") in
     ex_range (get_range $1) (get_range $3) (App (fsub, [$1; $3]))}
| exp AST_DOT exp
    {let fmul = ex_range $2 $2 (Var "fmul") in
     ex_range (get_range $1) (get_range $3) (App (fmul, [$1; $3]))}
| exp SLASH_DOT exp
    {let fdiv = ex_range $2 $2 (Var "fdiv") in
     ex_range (get_range $1) (get_range $3) (App (fdiv, [$1; $3]))}
| LET IDENT EQUAL exp IN exp
    %prec prec_let
    { ex_range $1 (get_range $6) (Let (addtyp (snd $2), $4, $6)) }
| LET REC fundef IN exp
    %prec prec_let
    { ex_range $1 (get_range $5) (LetRec ($3, $5)) }
| exp actual_args
    %prec prec_app
    { let tail = get_range (List.hd (List.rev $2)) in
      ex_range (get_range $1) tail (App ($1, $2)) }
| elems
    { let head = get_range (List.hd $1) in
      let tail = get_range (List.hd (List.rev $1)) in
      ex_range head tail (Tuple $1) }
| LET LPAREN pat RPAREN EQUAL exp IN exp
    { ex_range $1 (get_range $8) (LetTuple($3, $6, $8)) }
| simple_exp DOT LPAREN exp RPAREN LESS_MINUS exp
    { ex_range (get_range $1) (get_range $7) (Put($1, $4, $7)) }
| exp SEMICOLON exp
    { ex_range (get_range $1) (get_range $1) (Let((Id.gentmp Type.Unit, Type.Unit), $1, $3)) }
| ARRAY_CREATE simple_exp simple_exp
    %prec prec_app
    { ex_range $1 (get_range $3) (Array($2, $3)) }
| error
    { failwith
	(Printf.sprintf "parse error near characters %d-%d"
	   (Parsing.symbol_start ())
	   (Parsing.symbol_end ())) }

fundef:
| IDENT formal_args EQUAL exp
    { { name = addtyp (snd $1); args = $2; body = $4 } }

formal_args:
| IDENT formal_args
    { addtyp (snd $1) :: $2 }
| IDENT
    { [addtyp (snd $1)] }

actual_args:
| actual_args simple_exp
    %prec prec_app
    { $1 @ [$2] }
| simple_exp
    %prec prec_app
    { [$1] }

elems:
| elems COMMA exp
    { $1 @ [$3] }
| exp COMMA exp
    { [$1; $3] }

pat:
| pat COMMA IDENT
    { $1 @ [addtyp (snd $3)] }
| IDENT COMMA IDENT
    { [addtyp (snd $1); addtyp (snd $3)] }
