# mC Scanner - Phase 1

Lexical analyzer for the mC programming language, built with Flex for CS4318 Compiler Constructions.

## Team

**LL(2) Lookaheadz** - Abheek Pradhan, Victoria Castillo

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

- Illegal token (leading-zero integers, digit-leading identifiers)
- Unterminated comment (EOF before `*/`)
- Unterminated string constant (EOF before closing quote)
- String spans multiple lines (newline before closing quote)
- Unrecognized escape character in String (invalid `\` sequence)

## Testing

```bash
make test
```

Compiles and runs the C test harness (`test/test_runner.c`) which executes the scanner on each `.mC` input in `test/cases/` and diffs against the expected output in `test/exp/`.

## Project Structure

```
src/
  scanner.l          Flex scanner specification
  driver.c           Token printer / main entry point
  tokendef.h         Token type definitions (#define constants)
test/
  test_runner.c      C test harness (compiled by make test)
  cases/             Test input files (.mC)
    test0.mC         Keywords and whitespace across lines
    test1.mC         Identifier vs keyword disambiguation
    test2.mC         String escapes and bad escape detection
    test3.mC         Full program with all token types
    test4.mC         Error cases (leading zeros, bad ids, unterminated)
  exp/               Expected output files (.exp)
Makefile             Build and test configuration
writeup.txt          Project writeup (Section 5)
.github/
  workflows/
    build-and-test.yml   CI pipeline (build + test on push)
```
