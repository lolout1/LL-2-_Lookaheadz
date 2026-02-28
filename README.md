# mC Scanner - Phase 1

Lexical analyzer for the mC programming language, built with Flex for CS4318 Compiler Constructions.

## Team

**LL(2) Lookaheadz**
Abheek Pradhan &middot; Victoria Castillo

## Build

```bash
make clean
make
```

Requires `flex` and `gcc`. Produces `obj/scanner`.

## Usage

```bash
./obj/scanner input.mC
```

Reads from the given file (or stdin if none provided) and prints each token with its type, value, and source position.

## Supported Tokens

| Category    | Examples                                         |
|-------------|--------------------------------------------------|
| Keywords    | `if`, `else`, `while`, `int`, `string`, `char`, `return`, `void` |
| Identifiers | Any letter followed by letters/digits            |
| Integers    | `0`, `42`, `1024` (no leading zeros)             |
| Characters  | `'a'`, `'\n'`, `'\\'`                            |
| Strings     | `"hello"`, `"tab\there"`, `"quote\"inside"`      |
| Operators   | `+` `-` `*` `/` `%` `<` `>` `<=` `>=` `==` `!=` `=` `++` `--` `&&` `\|\|` `!` `@` |
| Punctuation | `[` `]` `{` `}` `(` `)` `,` `;`                 |
| Comments    | `/* block comments */` (silently consumed)        |

## Error Detection

- Illegal tokens (leading-zero integers, digit-leading identifiers, unrecognized characters)
- Unterminated comments (EOF before `*/`)
- Unterminated strings (newline before closing quote)
- Unrecognized escape sequences in strings

## Testing

```bash
make test
```

Test inputs live in `test/cases/*.mC` with expected output in `test/exp/*.exp`.

## Project Structure

```
src/
  scanner.l     Flex scanner specification
  driver.c      Token printer and main entry point
  tokendef.h    Token type definitions
test/
  cases/        Test input files (.mC)
  exp/          Expected output files (.exp)
Makefile        Build configuration
```
