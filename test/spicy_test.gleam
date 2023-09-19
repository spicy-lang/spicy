import gleeunit
import gleeunit/should
import spicy/lexer/token
import spicy/lexer

pub fn main() {
  gleeunit.main()
}

// LEXER TESTS
// TEST: Empty
pub fn empty_test() {
  ""
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([])
}

// TEST: Small Code Example
pub fn lex_snippet_test() {
  "(pub fn add-numbers(x: Int y: Int) -> Int
      (+ x y)
   )"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([
    token.OpenParen,
    token.Pub,
    token.Fn,
    token.Name("add-numbers"),
    token.OpenParen,
    token.Name("x"),
    token.Colon,
    token.Typename("Int"),
    token.Name("y"),
    token.Colon,
    token.Typename("Int"),
    token.CloseParen,
    token.Arrow,
    token.Typename("Int"),
    token.OpenParen,
    token.Plus,
    token.Name("x"),
    token.Name("y"),
    token.CloseParen,
    token.CloseParen,
  ])
}

// TEST: Comments
pub fn lex_comments_test() {
  "-- This is a comment\n-- Another Comment"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.Comment, token.Comment])
}

// TEST: Groupings with spaces
pub fn lex_groupings_spaces_test() {
  " ( ) { } [ ] "
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([
    token.OpenParen,
    token.CloseParen,
    token.OpenBrace,
    token.CloseBrace,
    token.OpenSquare,
    token.CloseSquare,
  ])
}

// TEST: Groupings without spaces
pub fn lex_groupings_no_spaces_test() {
  "(){}[]"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([
    token.OpenParen,
    token.CloseParen,
    token.OpenBrace,
    token.CloseBrace,
    token.OpenSquare,
    token.CloseSquare,
  ])
}

// TEST: Arithmetic Operators with spaces
pub fn lex_arithmetic_operators_spaces_test() {
  " + - * / % "
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([
    token.Plus,
    token.Minus,
    token.Star,
    token.Slash,
    token.Modulo,
  ])
}

// TEST: Arithmetic Operators without spaces
pub fn lex_arithmetic_operators_no_spaces_test() {
  "+-*/%"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([
    token.Plus,
    token.Minus,
    token.Star,
    token.Slash,
    token.Modulo,
  ])
}

// TEST: Comparison Operators with spaces
pub fn lex_comparison_operators_spaces_test() {
  " = != > < >= <= "
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([
    token.Equal,
    token.NotEqual,
    token.Greater,
    token.Less,
    token.GreaterEqual,
    token.LessEqual,
  ])
}

// TEST: Punctuation with spaces
pub fn lex_punctuation_spaces_test() {
  " |> : -> _ ! , ; ' @ # & "
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([
    token.PipeOperator,
    token.Colon,
    token.Arrow,
    token.Discard,
    token.Exclamation,
    token.Comma,
    token.Semicolon,
    token.SingleQuote,
    token.At,
    token.Dash,
    token.And,
  ])
}

// TEST: Integers
pub fn lex_integers_test() {
  "1234 5678"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.Int("1234"), token.Int("5678")])
}

// TEST: Underscore Integers
pub fn lex_underscore_integers_test() {
  "1_234 156_780"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.Int("1_234"), token.Int("156_780")])
}

// TEST: Underscore Floats
pub fn lex_underscore_floats_test() {
  "1_234.56 78.900_120"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.Float("1_234.56"), token.Float("78.900_120")])
}

// TEST: Floats
pub fn lex_floats_test() {
  "1234.56 78.9012"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.Float("1234.56"), token.Float("78.9012")])
}

// TEST: Bad Floats Test
pub fn bad_float_test() {
  "1.123.4567.89"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.Float("1.123"), token.Dot, token.Float("4567.89")])
}

// TEST: Binary Integers
pub fn lex_binary_integers_test() {
  "0b0101 0b1010"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.Int("0b0101"), token.Int("0b1010")])
}

// TEST: Octal Integers
pub fn lex_octal_integers_test() {
  "0o123 0o456"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.Int("0o123"), token.Int("0o456")])
}

// TEST: Hexademical Integers
pub fn lex_hexadecimal_integers_test() {
  "0xFFAFF3 0x0123456789ABCDEF"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.Int("0xFFAFF3"), token.Int("0x0123456789ABCDEF")])
}

// TEST: Strings
pub fn lex_strings_test() {
  "\"hello\" \"world\""
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.String("hello"), token.String("world")])
}

// TEST: Empty String
pub fn lex_empty_string_test() {
  "\"\""
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.String("")])
}

// TEST: Lex empty Lines
pub fn can_lex_empty_lines_test() {
  ".
    
    .
    
    "
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([
    token.Dot,
    token.EmptyLine,
    token.Dot,
    token.EmptyLine,
    token.EmptyLine,
  ])
}

// TEST: String Escape Quote
pub fn lex_string_escape_quote_test() {
  "\" \\\" \""
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.String(" \\\" ")])
}

// TEST: String Escape Newline
pub fn lex_string_escape_newline_test() {
  "\"hello\\nworld\""
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.String("hello\\nworld")])
}

// TEST: Unterminated Strings
pub fn lex_unterminated_strings_test() {
  "\"hello"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.UnterminatedString("hello")])
}

// TEST: Unexpected Grapheme
pub fn unexpected_grapheme_test() {
  "~"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.UnexpectedGrapheme("~")])
}

// TEST: Names
pub fn lex_names_test() {
  "hello world"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.Name("hello"), token.Name("world")])
}

// TEST: Typenames
pub fn lex_typenames_test() {
  "Hello World"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.Typename("Hello"), token.Typename("World")])
}

// TEST: Keywords
pub fn lex_keywords_test() {
  "let const"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.Let, token.Const])
}

// TEST: Keywords Prefix 
pub fn lex_keywords_prefix_test() {
  "lets consts"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.Name("lets"), token.Name("consts")])
}

// TEST: Lex Empty Lines
// TEST: Lex Newline
pub fn lex_newline_test() {
  "\n"
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([token.EmptyLine])
}

// TEST: Lex Whitespace
pub fn lex_whitespace_test() {
  "    \t   "
  |> lexer.new()
  |> lexer.lex()
  |> should.equal([])
}
