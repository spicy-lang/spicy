import gleam/string
import gleam/bit_string
import gleam/list
import gleam/iterator.{Iterator}
import spicy/lexer/token.{Token}
import spicy/utilities/lexer_helper

pub type Position {
  Position(line: Int, column: Int)
}

// The Lexer type keeps track of the current position in the source string,
// as well as the line and column for error reporting.
pub opaque type Lexer {
  Lexer(source: String, position: Int, line: Int, column: Int)
}

pub fn new(source: String) -> Lexer {
  Lexer(source: source, position: 0, line: 1, column: 1)
}

pub fn iterator(lexer: Lexer) -> Iterator(Token) {
  use lexer <- iterator.unfold(from: lexer)

  case next(lexer) {
    #(_lexer, token.EndOfFile) -> iterator.Done
    #(lexer, token) -> iterator.Next(element: token, accumulator: lexer)
  }
}

pub fn lex(lexer: Lexer) -> List(Token) {
  iterator(lexer)
  |> iterator.to_list()
}

// The primary lexing function. It examines the current character (or characters)
// in the source and produces the next token, updating the lexer's position accordingly.
// It handles different kinds of tokens like keywords, operators, identifiers, etc.
pub fn next(lexer: Lexer) -> #(Lexer, Token) {
  case lexer.source {
    //Newline
    "\r\n" <> rest -> newline(lexer, rest, 2)
    "\n" <> rest -> newline(lexer, rest, 1)
    // Whitespace
    " " <> rest | "\t" <> rest -> next(advance(lexer, rest, 1))

    "--" <> rest -> comment(rest, lexer.position, 2, token.Comment)

    "a" <> _
    | "b" <> _
    | "c" <> _
    | "d" <> _
    | "e" <> _
    | "f" <> _
    | "g" <> _
    | "h" <> _
    | "i" <> _
    | "j" <> _
    | "k" <> _
    | "l" <> _
    | "m" <> _
    | "n" <> _
    | "o" <> _
    | "p" <> _
    | "q" <> _
    | "r" <> _
    | "s" <> _
    | "t" <> _
    | "u" <> _
    | "v" <> _
    | "w" <> _
    | "x" <> _
    | "y" <> _
    | "z" <> _ -> {
      let #(name, rest) =
        take_content(lexer.source, "", lexer_helper.is_name_grapheme)

      let as_token = case name {
        "const" -> token.Const
        "external" -> token.External
        "fn" -> token.Fn
        "if" -> token.If
        "import" -> token.Import
        "let" -> token.Let
        "var" -> token.Var
        "opaque" -> token.Opaque
        "pub" -> token.Pub
        "pass" -> token.Pass
        "type" -> token.Type
        "pow" -> token.Pow
        "inc" -> token.Inc
        "dec" -> token.Dec
        "min" -> token.Min
        "max" -> token.Max
        "for" -> token.For
        "foreach" -> token.Foreach
        "while" -> token.While
        "until" -> token.Until
        "repeat" -> token.Repeat
        "match" -> token.Match
        "cond" -> token.Cond
        "macro" -> token.Macro
        "true" -> token.True
        "false" -> token.False
        "void" -> token.Void
        "and" -> token.And
        "or" -> token.Or
        "not" -> token.Not
        "in" -> token.In
        "to" -> token.To
        "do" -> token.Do
        "as" -> token.As
        name -> token.Name(name)
      }

      // Everything else becomes a Name token
      #(Lexer(rest, lexer.position + byte_size(name), 1, 1), as_token)
    }

    "A" <> _
    | "B" <> _
    | "C" <> _
    | "D" <> _
    | "E" <> _
    | "F" <> _
    | "G" <> _
    | "H" <> _
    | "I" <> _
    | "J" <> _
    | "K" <> _
    | "L" <> _
    | "M" <> _
    | "N" <> _
    | "O" <> _
    | "P" <> _
    | "Q" <> _
    | "R" <> _
    | "S" <> _
    | "T" <> _
    | "U" <> _
    | "V" <> _
    | "W" <> _
    | "X" <> _
    | "Y" <> _
    | "Z" <> _ -> {
      let #(name, rest) =
        take_content(lexer.source, "", lexer_helper.is_typename_grapheme)
      let as_token = token.Typename(name)
      #(
        Lexer(rest, lexer.position + byte_size(name), 1, 1),
        token(lexer, as_token),
      )
    }

    // Strings
    "\"" <> rest -> lex_string(rest, "", lexer.position)
    // Integers
    "0b" <> source -> lex_binary(source, "0b", lexer.position)
    "0o" <> source -> lex_octal(source, "0o", lexer.position)
    "0x" <> source -> lex_hexadecimal(source, "0x", lexer.position)

    "0" <> source -> lex_number(source, "0", LexInt, lexer.position)
    "1" <> source -> lex_number(source, "1", LexInt, lexer.position)
    "2" <> source -> lex_number(source, "2", LexInt, lexer.position)
    "3" <> source -> lex_number(source, "3", LexInt, lexer.position)
    "4" <> source -> lex_number(source, "4", LexInt, lexer.position)
    "5" <> source -> lex_number(source, "5", LexInt, lexer.position)
    "6" <> source -> lex_number(source, "6", LexInt, lexer.position)
    "7" <> source -> lex_number(source, "7", LexInt, lexer.position)
    "8" <> source -> lex_number(source, "8", LexInt, lexer.position)
    "9" <> source -> lex_number(source, "9", LexInt, lexer.position)
    // Comparison Operators
    "=" <> rest -> #(advance(lexer, rest, 1), token.Equal)
    "!=" <> rest -> #(advance(lexer, rest, 2), token.NotEqual)
    ">=" <> rest -> #(advance(lexer, rest, 2), token.GreaterEqual)
    "<=" <> rest -> #(advance(lexer, rest, 2), token.LessEqual)
    ">" <> rest -> #(advance(lexer, rest, 1), token.Greater)
    "<" <> rest -> #(advance(lexer, rest, 1), token.Less)

    // Groupings
    "(" <> rest -> #(advance(lexer, rest, 1), token.OpenParen)
    ")" <> rest -> #(advance(lexer, rest, 1), token.CloseParen)
    "[" <> rest -> #(advance(lexer, rest, 1), token.OpenSquare)
    "]" <> rest -> #(advance(lexer, rest, 1), token.CloseSquare)
    "{" <> rest -> #(advance(lexer, rest, 1), token.OpenBrace)
    "}" <> rest -> #(advance(lexer, rest, 1), token.CloseBrace)
    // Punctuation
    "|>" <> rest -> #(advance(lexer, rest, 2), token.PipeOperator)
    ":" <> rest -> #(advance(lexer, rest, 1), token.Colon)
    "->" <> rest -> #(advance(lexer, rest, 2), token.Arrow)
    "_" <> rest -> #(advance(lexer, rest, 1), token.Discard)
    "!" <> rest -> #(advance(lexer, rest, 1), token.Exclamation)
    "," <> rest -> #(advance(lexer, rest, 1), token.Comma)
    ";" <> rest -> #(advance(lexer, rest, 1), token.Semicolon)
    "'" <> rest -> #(advance(lexer, rest, 1), token.SingleQuote)
    "@" <> rest -> #(advance(lexer, rest, 1), token.At)
    "#" <> rest -> #(advance(lexer, rest, 1), token.Dash)
    "&" <> rest -> #(advance(lexer, rest, 1), token.And)
    "." <> rest -> #(advance(lexer, rest, 1), token.Dot)
    // Arithmetic Operators
    "+" <> rest -> #(advance(lexer, rest, 1), token.Plus)
    "-" <> rest -> #(advance(lexer, rest, 1), token.Minus)
    "*" <> rest -> #(advance(lexer, rest, 1), token.Star)
    "/" <> rest -> #(advance(lexer, rest, 1), token.Slash)
    "%" <> rest -> #(advance(lexer, rest, 1), token.Modulo)

    _ -> {
      case string.pop_grapheme(lexer.source) {
        // End Of File
        Error(_) -> #(lexer, token.EndOfFile)
        Ok(#(grapheme, rest)) -> {
          let t = token.UnexpectedGrapheme(grapheme)
          #(advance(lexer, rest, byte_size(grapheme)), token(lexer, t))
        }
      }
    }
  }
}

// Advance the lexer's position by a given number of characters
fn advance(lexer: Lexer, rest: String, number: Int) -> Lexer {
  let new_position = lexer.position + number
  let #(new_line, new_column) = update_line_column(lexer, number)
  Lexer(
    source: rest,
    position: new_position,
    line: new_line,
    column: new_column,
  )
}

// Returns the byte size of a given string. Useful for advancing the lexer's position.
fn byte_size(string: String) -> Int {
  bit_string.byte_size(<<string:utf8>>)
}

// Update line and column based on processed characters
fn update_line_column(lexer: Lexer, number: Int) -> #(Int, Int) {
  let substring = string.slice(lexer.source, lexer.position, number)

  // Split the substring by newlines and count the parts
  let parts = string.split(substring, "\n")
  let newline_count = list.length(parts) - 1

  let new_line = lexer.line + newline_count

  // Extract the last part from the parts list or provide a default value
  let last_part = case list.last(parts) {
    Ok(part) -> part
    Error(_) -> ""
  }

  let new_column = case newline_count {
    0 -> lexer.column + number
    _ -> byte_size(last_part)
  }

  #(new_line, new_column)
}

pub fn take_while(
  source: String,
  predicate: fn(String) -> Bool,
) -> #(String, String) {
  let chars: List(String) = string.to_graphemes(source)
  let taken = list.take_while(chars, predicate)
  let remaining = list.drop_while(chars, predicate)

  let taken_str = list.fold(taken, "", fn(char, acc) { acc <> char })
  let remaining_str = list.fold(remaining, "", fn(char, acc) { acc <> char })

  #(taken_str, remaining_str)
}

// Handles newline characters in the source. Advances the lexer's position
// by the given `skip` amount and increments the line count.
fn newline(lexer: Lexer, src: String, size: Int) -> #(Lexer, Token) {
  let start = lexer.position
  case consume_whitespace(Lexer(src, start + size, 1, 1)) {
    #(lexer, True) -> #(lexer, token.EmptyLine)
    #(lexer, False) -> next(lexer)
  }
}

// Consumes whitespace characters from the lexer's current position
// until a non-whitespace character is encountered.
fn consume_whitespace(lexer: Lexer) -> #(Lexer, Bool) {
  case lexer.source {
    "" | "\n" <> _ | "\r\n" <> _ -> #(lexer, True)
    " " <> rest -> consume_whitespace(Lexer(rest, lexer.position + 1, 1, 1))
    "\t" <> rest -> consume_whitespace(Lexer(rest, lexer.position + 1, 1, 1))
    _ -> #(lexer, False)
  }
}

// Handles comment lines in the source, starting with '--'.
// Advances the lexer's position past the comment.
fn comment(src: String, start: Int, size: Int, token: Token) -> #(Lexer, Token) {
  case src {
    "\n" <> _ -> #(Lexer(src, start + size, 1, 1), token)
    "\r\n" <> _ -> #(Lexer(src, start + size, 1, 1), token)
    _ -> {
      case string.pop_grapheme(src) {
        Error(_) -> #(Lexer(src, start + size, 1, 1), token)
        Ok(#(char, rest)) -> comment(rest, start, size + byte_size(char), token)
      }
    }
  }
}

// Recursively consumes characters from the source based on a predicate function.
// Returns the accumulated string and the remaining source.
pub fn take_content(
  source: String,
  content: String,
  predicate: fn(String) -> Bool,
) -> #(String, String) {
  case string.pop_grapheme(source) {
    Error(_) -> #(content, "")
    Ok(#(grapheme, rest)) -> {
      case predicate(grapheme) {
        True -> take_content(rest, content <> grapheme, predicate)
        False -> #(content, source)
      }
    }
  }
}

fn token(_lexer: Lexer, token: Token) -> Token {
  token
}

// Handles string literals enclosed in double quotes. Accumulates characters 
// until the closing quote is found or an error occurs.
fn lex_string(input: String, content: String, start: Int) -> #(Lexer, Token) {
  case input {
    // A double quote, the string is terminated
    "\"" <> rest -> {
      let lexer = Lexer(rest, start + byte_size(content) + 2, 1, 1)
      #(lexer, token.String(content))
    }

    // A backslash escapes the following character
    "\\" <> rest -> {
      case string.pop_grapheme(rest) {
        Error(_) -> lex_string(rest, content <> "\\", start)
        Ok(#(g, rest)) -> lex_string(rest, content <> "\\" <> g, start)
      }
    }

    // Any other character is content in the string
    _ -> {
      case string.pop_grapheme(input) {
        Ok(#(g, rest)) -> lex_string(rest, content <> g, start)

        // End of input, the string is unterminated
        Error(_) -> {
          let lexer = Lexer("", start + byte_size(content) + 1, 1, 1)
          #(lexer, token.UnterminatedString(content))
        }
      }
    }
  }
}

pub type NumberLexerMode {
  LexInt
  LexFloat
  LexFloatExponent
}

// Handles the lexing of numeric literals, determining their type (integer, float, etc.)
// and accumulating their value.
fn lex_number(
  input: String,
  content: String,
  mode: NumberLexerMode,
  start: Int,
) -> #(Lexer, Token) {
  case input {
    // A dot, the number is a float
    "." <> rest if mode == LexInt ->
      lex_number(rest, content <> ".", LexFloat, start)

    "e-" <> rest if mode == LexFloat ->
      lex_number(rest, content <> "e-", LexFloatExponent, start)
    "e" <> rest if mode == LexFloat ->
      lex_number(rest, content <> "e", LexFloatExponent, start)

    "_" <> source -> lex_number(source, content <> "_", mode, start)
    "0" <> source -> lex_number(source, content <> "0", mode, start)
    "1" <> source -> lex_number(source, content <> "1", mode, start)
    "2" <> source -> lex_number(source, content <> "2", mode, start)
    "3" <> source -> lex_number(source, content <> "3", mode, start)
    "4" <> source -> lex_number(source, content <> "4", mode, start)
    "5" <> source -> lex_number(source, content <> "5", mode, start)
    "6" <> source -> lex_number(source, content <> "6", mode, start)
    "7" <> source -> lex_number(source, content <> "7", mode, start)
    "8" <> source -> lex_number(source, content <> "8", mode, start)
    "9" <> source -> lex_number(source, content <> "9", mode, start)

    // Anything else and the number is terminated
    source -> {
      let lexer = Lexer(source, start + byte_size(content), 1, 1)
      let token = case mode {
        LexInt -> token.Int(content)
        LexFloat | LexFloatExponent -> token.Float(content)
      }
      #(lexer, token)
    }
  }
}

fn lex_binary(source: String, content: String, start: Int) -> #(Lexer, Token) {
  case source {
    "_" <> source -> lex_binary(source, content <> "_", start)
    "0" <> source -> lex_binary(source, content <> "0", start)
    "1" <> source -> lex_binary(source, content <> "1", start)
    source -> {
      let lexer = Lexer(source, start + byte_size(content), 1, 1)
      #(lexer, token.Int(content))
    }
  }
}

fn lex_octal(source: String, content: String, start: Int) -> #(Lexer, Token) {
  case source {
    "_" <> source -> lex_octal(source, content <> "_", start)
    "0" <> source -> lex_octal(source, content <> "0", start)
    "1" <> source -> lex_octal(source, content <> "1", start)
    "2" <> source -> lex_octal(source, content <> "2", start)
    "3" <> source -> lex_octal(source, content <> "3", start)
    "4" <> source -> lex_octal(source, content <> "4", start)
    "5" <> source -> lex_octal(source, content <> "5", start)
    "6" <> source -> lex_octal(source, content <> "6", start)
    "7" <> source -> lex_octal(source, content <> "7", start)
    source -> {
      let lexer = Lexer(source, start + byte_size(content), 1, 1)
      #(lexer, token.Int(content))
    }
  }
}

fn lex_hexadecimal(
  source: String,
  content: String,
  start: Int,
) -> #(Lexer, Token) {
  case source {
    "_" <> source -> lex_hexadecimal(source, content <> "_", start)
    "0" <> source -> lex_hexadecimal(source, content <> "0", start)
    "1" <> source -> lex_hexadecimal(source, content <> "1", start)
    "2" <> source -> lex_hexadecimal(source, content <> "2", start)
    "3" <> source -> lex_hexadecimal(source, content <> "3", start)
    "4" <> source -> lex_hexadecimal(source, content <> "4", start)
    "5" <> source -> lex_hexadecimal(source, content <> "5", start)
    "6" <> source -> lex_hexadecimal(source, content <> "6", start)
    "7" <> source -> lex_hexadecimal(source, content <> "7", start)
    "8" <> source -> lex_hexadecimal(source, content <> "8", start)
    "9" <> source -> lex_hexadecimal(source, content <> "9", start)
    "A" <> source -> lex_hexadecimal(source, content <> "A", start)
    "B" <> source -> lex_hexadecimal(source, content <> "B", start)
    "C" <> source -> lex_hexadecimal(source, content <> "C", start)
    "D" <> source -> lex_hexadecimal(source, content <> "D", start)
    "E" <> source -> lex_hexadecimal(source, content <> "E", start)
    "F" <> source -> lex_hexadecimal(source, content <> "F", start)
    source -> {
      let lexer = Lexer(source, start + byte_size(content), 1, 1)
      #(lexer, token.Int(content))
    }
  }
}
