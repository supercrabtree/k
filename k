#!/bin/sh


# Script varibles
# ------------------------------------------------------------------------------
number_of_params=


# Local functions
# ------------------------------------------------------------------------------
die() { printf "%s\n" "$*" >&2; exit 1; }
fin() { printf "%s\n" "$*"; exit 0; }

usage() {
  printf "usage: k [-aA]"
}

is_git_repo() {
  res=" $(builtin cd "$root_dir/$1" && command git rev-parse --is-inside-work-tree 2>/dev/null)"
  [ "$res" = " true" ] && return 0 || return 1
}

list() {
  [ ! -e "$1" ] && die "k: $1: No such file or directory"
  if [ -d "$1" ]; then
    list_dir "$1"
  else
    list_item "$1"
  fi
}

list_dir() {
  [ $number_of_params -ne 1 ] && printf "\n%s:\n" "$1"
}

list_item() {
  echo $1
}


# Parse opts
# ------------------------------------------------------------------------------
while [ "$#" -gt 0 ]; do
  case "$1" in
    -a|--all)        flag_all=1;;
    -A|--almost-all) flag_almost_all=1;;
    --help)          usage; fin;;
    *)
      # if $1 starts with a -
      if [ $(echo "$1" | cut -c-1) = "-" ]; then
        printf "k: illegal option: %s\n" "$1"
        usage
        die
      else
        remaining="$remaining$1"\0
      fi
    ;;
  esac
  shift
done

# reset "$@" to args not caught by the switch case above
IFS=\0
set -- $remaining

# set default param as local dir
[ "$#" -eq 0 ] && set -- .

# used later in local function
number_of_params="$#"

while [ "$#" -gt 0 ]; do
  list "$1"
  shift
done
