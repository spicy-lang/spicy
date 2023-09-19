import gleam/io
import spicy/lexer
import spicy/utils
import simplifile

const version = "v0.1.0"

fn print_help() {
  io.println("\n")
  io.println("🌶️ " <> " " <> "Spicy " <> version)
  io.println("- A statically typed general-purpose programming language")
  io.println("\nUsage:")
  io.println("  spicy <subcommand> [ ARGS ] [ FLAGS ]\n")
  io.println("Flags:")
  io.println("  -h,  --help       Print help information")
  io.println("  -v  --version    Print Spicy's version\n")
  io.println("Subcommands:")
  io.println("  lex      Lex the file and output           [ARGS=FILENAME]")
  io.println("  parse    Parse the file and output the AST [ARGS=FILENAME]")
  io.println("\n")
}

fn print_version() {
  io.println("Spicy " <> version)
}

fn lex_file(filename: String) -> Nil {
  case simplifile.read(filename) {
    Ok(contents) -> {
      let tokens =
        contents
        |> lexer.new()
        |> lexer.lex()
      io.debug(tokens)
      Nil
    }
    Error(_err) -> io.println("Error reading file: " <> filename)
  }
}

fn parse_file(filename: String) {
  io.println("Parsing file: " <> filename)
}

fn print_usage() {
  io.println("Invalid usage. Use `spicy --help` for guidance.")
}

pub fn main() {
  case utils.get_args() {
    ["--help"] | ["-h"] -> print_help()
    ["--version"] | ["-v"] -> print_version()
    ["lex", filename] -> lex_file(filename)
    ["parse", filename] -> parse_file(filename)
    _ -> print_usage()
  }
}
