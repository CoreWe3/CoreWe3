{
(* lexer�����Ѥ����ѿ����ؿ������ʤɤ���� *)
open Parser
open Type
let line_no = ref 1
let end_of_previousline = ref 0
let get_range lexbuf = ((!line_no, (Lexing.lexeme_start lexbuf) - (!end_of_previousline) + 1)
		       ,(!line_no, (Lexing.lexeme_end lexbuf) - (!end_of_previousline) + 1))
}

(* ����ɽ����ά�� *)
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
    { comment lexbuf; (* �ͥ��Ȥ��������ȤΤ���Υȥ�å� *)
      token lexbuf }
| '('
    { LPAREN(get_range lexbuf) }
| ')'
    { RPAREN(get_range lexbuf) }
| "true"
    { BOOL(get_range lexbuf, true) }
| "false"
    { BOOL(get_range lexbuf, false) }
| "not"
    { NOT(get_range lexbuf) }
| digit+ (* �����������Ϥ���롼�� (caml2html: lexer_int) *)
    { INT(get_range lexbuf, int_of_string (Lexing.lexeme lexbuf)) }
| digit+ ('.' digit*)? (['e' 'E'] ['+' '-']? digit+)?
    { FLOAT(get_range lexbuf, float_of_string (Lexing.lexeme lexbuf)) }
| '-' (* -.����󤷤ˤ��ʤ��Ƥ��ɤ�? ��Ĺ����? *)
    { MINUS(get_range lexbuf) }
| '+' (* +.����󤷤ˤ��ʤ��Ƥ��ɤ�? ��Ĺ����? *)
    { PLUS(get_range lexbuf) }
| '*'
    { AST(get_range lexbuf) }
| '/'
    { SLASH(get_range lexbuf) }
| "xor"
    { XOR(get_range lexbuf) }
| "lsl"
    { LSL(get_range lexbuf) }
| "lsr"
    { LSR(get_range lexbuf) }
| "-."
    { MINUS_DOT(get_range lexbuf) }
| "+."
    { PLUS_DOT(get_range lexbuf) }
| "*."
    { AST_DOT(get_range lexbuf) }
| "/."
    { SLASH_DOT(get_range lexbuf) }
| '='
    { EQUAL(get_range lexbuf) }
| "<>"
    { LESS_GREATER(get_range lexbuf) }
| "<="
    { LESS_EQUAL(get_range lexbuf) }
| ">="
    { GREATER_EQUAL(get_range lexbuf) }
| '<'
    { LESS(get_range lexbuf) }
| '>'
    { GREATER(get_range lexbuf) }
| "if"
    { IF (get_range lexbuf)}
| "then"
    { THEN(get_range lexbuf) }
| "else"
    { ELSE(get_range lexbuf) }
| "let"
    { LET (get_range lexbuf)}
| "in"
    { IN(get_range lexbuf) }
| "rec"
    { REC(get_range lexbuf) }
| ','
    { COMMA(get_range lexbuf) }
| '_'
    { IDENT(get_range lexbuf, Id.gentmp Type.Unit) }
| "Array.create" (* [XX] ad hoc *)
    { ARRAY_CREATE(get_range lexbuf)}
| '.'
    { DOT(get_range lexbuf) }
| "<-"
    { LESS_MINUS(get_range lexbuf) }
| ';'
    { SEMICOLON(get_range lexbuf) }
| eof
    { EOF }
| lower (digit|lower|upper|'_')* (* ¾�Ρ�ͽ���פ���Ǥʤ��Ȥ����ʤ� *)
    { IDENT(get_range lexbuf, Lexing.lexeme lexbuf) }
| _
    { failwith
	(Printf.sprintf "unknown token %s near characters %d-%d"
	   (Lexing.lexeme lexbuf)
	   (Lexing.lexeme_start lexbuf)
	   (Lexing.lexeme_end lexbuf)) }
and comment = parse
| newline
    { end_of_previousline := (Lexing.lexeme_end lexbuf);
      line_no := !line_no+1;
      comment lexbuf}
| "*)"
    { () }
| "(*"
    { comment lexbuf;
      comment lexbuf }
| eof
    { Format.eprintf "warning: unterminated comment@." }
| _
    { comment lexbuf }
