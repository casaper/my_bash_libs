#!/usr/bin/env bash

## repeat a char to output a line
#
# examples:
# `char_as_line` -> defaults with 72 times `_` and newline
# `char_as_line '%'` -> echos 72  times '%' and newline
# `char_as_line '+' 20` -> echos 20 times `+`
function draw_char_line() {
  CHAR="${1:-_}"
  NUMBER="${2:-72}"
  echo -e "$(printf "%${NUMBER}s" | tr " " "${CHAR}")"
}

## returns number of caracters in string
#
function num_of_chars() {
  echo -e -n "$1" | wc -c
}

## indent to the same
#
# indendt_left 'first text' 30 'Aligned to 30 minus first text length'
function indent_left() {
  BEFORE_WIDTH=$(num_of_chars "$1")
  INDENT_WIDTH=$2
  SPACES=$(("$INDENT_WIDTH" - "$BEFORE_WIDTH"))
  echo -e "$(printf "%s%${SPACES}s" "$1" "$3")"
}
