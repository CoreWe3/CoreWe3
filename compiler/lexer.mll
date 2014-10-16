{
(* lexerが利用する変数、関数、型などの定義 *)
open Parser
open Type
let line_no = ref 1
let end_of_previousline = ref 0
let get_pos lexbuf = (!line_no, (Lexing.lexeme_start lexbuf)-(!end_of_previousline))
}

(* 正規表現の略記 *)
let space = [' ' '\t' '\r']
let newline = ['\n']
let digit = ['0'-'9']
let lower = ['a'-'z']
let upper = ['A'-'Z']

rule token = parse
| space+
    { token lexbuf }
| newline
    { end_of_previousline := (Lexing.lexeme_end lexbuf);
      line_no := !line_no+1;
      token lexbuf}
| "(*"
    { comment lexbuf; (* ネストしたコメントのためのトリック *)
      token lexbuf }
| '('
    { LPAREN }
| ')'
    { RPAREN }
| "true"
    { BOOL(true) }
| "false"
    { BOOL(false) }
| "not"
    { NOT }
| digit+ (* 整数を字句解析するルール (caml2html: lexer_int) *)
    { INT(int_of_string (Lexing.lexeme lexbuf)) }
| digit+ ('.' digit*)? (['e' 'E'] ['+' '-']? digit+)?
    { FLOAT(float_of_string (Lexing.lexeme lexbuf)) }
| '-' (* -.より後回しにしなくても良い? 最長一致? *)
    { MINUS(get_pos lexbuf) }
| '+' (* +.より後回しにしなくても良い? 最長一致? *)
    { PLUS(get_pos lexbuf) }
| "-."
    { MINUS_DOT(get_pos lexbuf) }
| "+."
    { PLUS_DOT(get_pos lexbuf) }
| "*."
    { AST_DOT(get_pos lexbuf) }
| "/."
    { SLASH_DOT(get_pos lexbuf) }
| '='
    { EQUAL(get_pos lexbuf) }
| "<>"
    { LESS_GREATER(get_pos lexbuf) }
| "<="
    { LESS_EQUAL(get_pos lexbuf) }
| ">="
    { GREATER_EQUAL(get_pos lexbuf) }
| '<'
    { LESS(get_pos lexbuf) }
| '>'
    { GREATER(get_pos lexbuf) }
| "if"
    { IF }
| "then"
    { THEN }
| "else"
    { ELSE }
| "let"
    { LET }
| "in"
    { IN }
| "rec"
    { REC }
| ','
    { COMMA }
| '_'
    { IDENT(Id.gentmp Type.Unit) }
| "Array.create" (* [XX] ad hoc *)
    { ARRAY_CREATE }
| '.'
    { DOT }
| "<-"
    { LESS_MINUS }
| ';'
    { SEMICOLON }
| eof
    { EOF }
| lower (digit|lower|upper|'_')* (* 他の「予約語」より後でないといけない *)
    { IDENT(Lexing.lexeme lexbuf, get_pos lexbuf) }
| _
    { failwith
	(Printf.sprintf "unknown token %s in line %d, colmun %d-%d"
	   (!line_no)
	   (Lexing.lexeme lexbuf)
	   (Lexing.lexeme_start lexbuf)
	   (Lexing.lexeme_end lexbuf)) }
and comment = parse
| "*)"
    { () }
| "(*"
    { comment lexbuf;
      comment lexbuf }
| eof
    { Format.eprintf "warning: unterminated comment@." }
| _
    { comment lexbuf }
