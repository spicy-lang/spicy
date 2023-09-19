// The Token type represents the various kinds of tokens that can be produced
// by the lexer. Each variant corresponds to a different syntactic element
// in the source code.
pub type Token {
  // ----------------
  // Literals
  Int(String)
  Float(String)
  String(String)
  Void

  // ----------------
  // Indentifiers
  Typename(String)
  Constname(String)
  Name(String)

  // ----------------
  // Arithmetic Operators
  Plus
  Minus
  Star
  Slash
  Modulo
  Pow
  Inc
  Dec

  // ----------------
  // Comparison Operators
  Equal
  NotEqual
  Greater
  Less
  GreaterEqual
  LessEqual
  Min
  Max

  // ----------------
  // Logical Operators
  And
  Or
  Not

  // ----------------
  // Groupings
  OpenParen
  CloseParen
  OpenBrace
  CloseBrace
  OpenSquare
  CloseSquare

  // ----------------
  // Keywords
  Let
  Var
  Const
  If
  For
  Foreach
  While
  Until
  Repeat
  Match
  Cond
  Pub
  Opaque
  Type
  Fn
  Macro
  External
  Pass
  Import
  As
  In
  To
  Do
  True
  False

  // ----------------
  // Punctuation
  PipeOperator
  Colon
  Arrow
  EndOfFile
  Underscore
  Discard
  Exclamation
  Comma
  Semicolon
  SingleQuote
  At
  Dash
  Dot

  // ----------------
  // Extra
  Comment
  EmptyLine

  // Invalid code tokens
  UnterminatedString(String)
  UnexpectedGrapheme(String)
}
