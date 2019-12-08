
- [My Bash Libs](#my-bash-libs)
  - [Include in your script](#include-in-your-script)
  - [Files](#files)
  - [Linux Scripts](#linux-scripts)
  - [setup_chrooted_ssh_home.sh](#setupchrootedsshhomesh)

# My Bash Libs

I personally use these from time to time for work or non work purposes.  
I abuse GitHub as my backup solution here. But the general public can either use or copy and paste from these files, if any of this is of any use to someone.

## Include in your script

Place the lib file in the same directory as your script resides.

Then include it to your script like this:

```sh
. ./colours.sh
```

## Files

1. [colours.sh](colours.sh) - a set of variables to colorize bash output
1. [output_utils.sh](output_utils.sh) - utilities to format and output stuff to the user in the shell

## Linux Scripts

## [setup_chrooted_ssh_home.sh](setup_chrooted_ssh_home.sh)

Creates a user with a ssh only access chroot chail, that has one or more directories from the system bound `mount --bind` into its chroot chail.
This has worked on Debian-ish machines (debian, raspbian). Never tested this on any other distro, and I definitly do not take any responsibility for you using this.

Unless you know what your doing and understand what this script does (by reading it) **you shouldn't use it**!
