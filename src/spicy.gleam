import spicy/lexer
import gleam/io

pub fn main() {
  let tokens =
    " -- This is a comment
		  -- Another Comment
		(){}[]+-*/ pow inc dec = != >	
		< >= <= min max let var const if 
		for foreach while  until repeat match cond 
		pub opaque type fn macro 
		external pass |> : -> ! , ; ' @ # and & or not in to do
		1 2 3 4 54 65 232 6565 8787 232 54 23.2 true false void \"string\"
		0b0101 0o123 0xFFAFF3 0x0123456789ABCDEF 1_000_000
		main main-func Natural param3 \"string "
    |> lexer.new()
    |> lexer.lex()

  io.debug(tokens)
}
