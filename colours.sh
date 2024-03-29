#!/usr/bin/env bash
# Since bash doesn't have dependency management, show origin:
# File Origin: https://github.com/casaper/my_bash_libs/blob/master/colours.sh
# This is not a copyright notice. Its just for practical reasons.

set -a # export all defined variables

# Reset any of the following formats, close string with C_SET
F_RESET='\033[0m'
F_BOLD='\033[1m'

# output colours
C_DEFAULT='\033[39m'
C_BLACK='\033[30m'
C_WHITE='\033[97m'
C_RED='\033[31m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_BLUE='\033[34m'
C_MAGENTA='\033[35m'
C_CYAN='\033[36m'
C_DARK_GRAY='\033[90m'
C_LIGHT_GRAY='\033[37m'
C_LIGHT_RED='\033[91m'
C_LIGHT_GREEN='\033[92m'
C_LIGHT_YELLOW='\033[93m'
C_LIGHT_BLUE='\033[94m'
C_LIGHT_MAGENTA='\033[95m'
C_LIGHT_CYAN='\033[96m'

# backgrounds
BG_DEFAULT='\033[49m'
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_LIGHT_GRAY='\033[47m'
BG_DARK_GRAY='\033[100m'
BG_LIGHT_RED='\033[101m'
BG_LIGHT_GREEN='\033[102m'
BG_LIGHT_YELLOW='\033[103m'
BG_LIGHT_BLUE='\033[104m'
BG_LIGHT_MAGENTA='\033[105m'
BG_LIGHT_CYAN='\033[106m'
BG_WHITE='\033[107m'

## outputs all of its parameters with `echo -e`
#
function c_echo() {
  for string in "$@"; do
    echo -e "$string${F_RESET}"
  done
}
