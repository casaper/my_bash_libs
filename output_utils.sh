#!/usr/bin/env bash
# Since bash doesn't have dependency management, show origin:
# File Origin: https://github.com/casaper/my_bash_libs/blob/master/output_utils.sh
# This is not a copyright notice. Its just for practical reasons.

if [ -z "$F_RESET" ]; then
  SCRIPTPATH=$(dirname $(realpath $0))
  echo "$SCRIPTPATH"
fi

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

function display_help_option() {
  OPTION="$1"
  INDENT=$2
  TEXT=$3
  EXAMPLE_VALUE=$4
  if [ -n "$EXAMPLE_VALUE" ]; then
    indent_left "${C_YELLOW}${OPTION}${F_RESET}=${EXAMPLE_VALUE}" \
      "$INDENT" \
      "$TEXT"
  else
    indent_left "${C_YELLOW}${OPTION}${F_RESET}" "$INDENT" "$TEXT"
  fi
}
