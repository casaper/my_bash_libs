#!/usr/bin/env bash
# USE AT YOUR OWN RISK! I don't care if you break your things, or someone breaks in to your system because you did not know what you do
# Unless you know what your doing and understand what this script does you should not use it!

. ./output_utils.sh

while test $# -gt 0; do
  package='setup_chrooted_ssh_home.sh'
  case "$1" in
  -h | --help)
    HELP_INDENT=45

    echo -e $'\n'"${F_BOLD}${package}${F_RESET} - create a user and a home directory the user is chrooted into"$'\n'
    echo -e "${F_BOLD}Usage${F_RESET}: ./$package [options]"
    echo -e $'\n'"This script requires to be run as root or sudo."$'\n'
    echo -e $'\n'"${C_YELLOW}The author takes no responsibility for this to work, and even less for this not to break anything on your machine. You use this at your very own risk! This is only meant for people that know how to create a chroot jail temselves, but are too lazy to do the task repeatadly.${F_RESET}"$'\n'
    echo -e "${F_BOLD}options:${F_RESET}"$'\n'

    display_help_option '--h, --help' "$HELP_INDENT" 'Show this help'
    display_help_option '--user-name' "$HELP_INDENT" 'The users name' 'name'
    display_help_option '--share-dirs' "$HELP_INDENT" 'Paths to bind mount into the choot dir' '/mnt/drives/one,/mnt/drives/another'
    exit 0
    ;;
    # END of help output

  --user-name=*)
    CHROOT_USER_NAME="${1//--user-name=/}"
    shift
    ;;
  --share-dirs=*)
    SHARING_PATHS="${1//--share-dirs=/}"
    shift
    ;;
  *)
    break
    ;;
  esac
done

function user_exists() {
  id "$1" &>/dev/null
}

function extract_deps() {
  ldd "$1" | awk '{$1=$1};1' | cut -d '>' -f 2 | awk '{$1=$1};1' | cut -d ' ' -f 1 | tail -n +2 | awk '{$1=$1};1'
}

function link_executable_with_dependencies_into_chroot() {
  DEPENDENCY_EXECUTABLE=$1
  CHROOT_HOME_DIR=$2
  EXTRACTED_DEPS=$(extract_deps "$DEPENDENCY_EXECUTABLE")
  while read dep; do
    if [ -h "$dep" ]; then
      DEPENDENCY_PATH="$(dirname "$dep")/$(readlink "$dep")"
    else
      DEPENDENCY_PATH="$dep"
    fi
    CHROOT_DEP_PATH="${CHROOT_HOME_DIR}$(dirname "$dep")"
    if ! [ -d "$directory" ]; then
      mkdir -p "$CHROOT_DEP_PATH"
    fi

    CHROOT_DEP_FILE="${CHROOT_DEP_PATH}/$(basename "$dep")"
    if ! [ -f "$CHROOT_DEP_FILE" ]; then
      ln "${DEPENDENCY_PATH}" "$CHROOT_DEP_FILE"
    fi
  done <<<"$EXTRACTED_DEPS"
  # link dependency into chroot
  mkdir -p "${CHROOT_HOME_DIR}$(dirname "$DEPENDENCY_EXECUTABLE")"
  ln "$DEPENDENCY_EXECUTABLE" "${CHROOT_HOME_DIR}${DEPENDENCY_EXECUTABLE}"
}

# needs to be run as root
if [ "$EUID" -ne 0 ]; then
  c_echo "${C_RED}This can only be run as root!"
  exit 1
fi

# cannot run without user name
if [ -z "$CHROOT_USER_NAME" ]; then
  c_echo "${C_RED}The option --user-name= was empty or not passed at all. It is required!"
  exit 1
fi

PATHS_TO_BIND_FOR_SHARE="${SHARING_PATHS}"
CHROOT_HOME_DIR="/home/${CHROOT_USER_NAME}"

draw_char_line '-'
c_echo "Setting up chrooted env with the following options:" ''
indent_left 'User name:' 20 "${F_BOLD}${CHROOT_USER_NAME}${F_RESET}"
indent_left 'Home dir:' 20 "${F_BOLD}${CHROOT_HOME_DIR}${F_RESET}"
indent_left 'Shared Dirs:' 20 "${SHARING_PATHS}"
draw_char_line '-'
c_echo ''

if user_exists "$CHROOT_USER_NAME"; then
  c_echo "${C_RED}A user with the name ${C_YELLOW}${CHROOT_USER_NAME}${C_RED} allready exists!"$'\n' \
    "See the output of 'id ${CHROOT_USER_NAME}':"
  id "$CHROOT_USER_NAME"
  c_echo ''
  exit 1
fi

if [ -d "$CHROOT_HOME_DIR" ]; then
  c_echo "${C_RED}The home directory allready exists"
  exit 1
fi

# create home directory with in future needed sub directories
mkdir -p $CHROOT_HOME_DIR/{dev,bin,etc,shares}

for i in $(cut -d ',' --output-delimiter=' ' -f 1- <<<"$SHARING_PATHS"); do
  if [ -d "$i" ]; then
    CHROOT_SHARE="${CHROOT_HOME_DIR}/shares/$(basename "$i")"
    mkdir -p "$CHROOT_SHARE"

    echo "${i} ${CHROOT_SHARE} none bind" >>/etc/fstab
  fi
done

mount -a

# create hard link of bash binary to chroot bin
ln /etc/passwd "${CHROOT_HOME_DIR}/etc/passwd"
ln /etc/group "${CHROOT_HOME_DIR}/etc/group"

# create required dev files in subshell
$(
  cd "${CHROOT_HOME_DIR}/dev" &&
    mknod -m 666 null c 1 3 &&
    mknod -m 666 tty c 5 0 &&
    mknod -m 666 zero c 1 5 &&
    mknod -m 666 random c 1 8
)

# link bash binary with dependencies into chroot
link_executable_with_dependencies_into_chroot /bin/bash "$CHROOT_HOME_DIR"
# link ls binary with dependencies into chroot
link_executable_with_dependencies_into_chroot /bin/ls "$CHROOT_HOME_DIR"
# link cat binary with dependencies into chroot
link_executable_with_dependencies_into_chroot /bin/cat "$CHROOT_HOME_DIR"
# link passwd binary with dependencies into chroot
link_executable_with_dependencies_into_chroot /usr/bin/passwd "$CHROOT_HOME_DIR"

# create user with dummy password. We do not allow password login with ssh, so it ain't going to be used.
# this is just so the user won't be locked -> can login with pub key auth via ssh
useradd "${CHROOT_USER_NAME}" --password "$(
  tr </dev/urandom -dc _A-Z-a-z-0-9 | head -c${1:-128}
  echo
)"

mkdir -p "${CHROOT_HOME_DIR}/.ssh"
touch "${CHROOT_HOME_DIR}/.ssh/authorized_keys"

echo "# SSH chroot for ${CHROOT_USER_NAME}" >>/etc/ssh/sshd_config
echo "Match User ${CHROOT_USER_NAME}" >>/etc/ssh/sshd_config
echo "ChrootDirectory ${CHROOT_HOME_DIR}" >>/etc/ssh/sshd_config
echo '' >>/etc/ssh/sshd_config
systemctl restart sshd

exit 0
