#!/bin/sh

die() { printf "%s\n" "$*" >&2; exit 1; }
fin() { printf "%s\n" "$*"; exit 0; }

usage() {
  printf "Help!!"
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
        printf "Unknown option %s\n" "$1"
        usage
        die
      else
        remaining="$remaining$1"\0
      fi
    ;;
  esac
  shift
done
