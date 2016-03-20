#!/bin/sh

die() { printf "%s\n" "$*" >&2; exit 1; }
fin() { printf "%s\n" "$*"; exit 0; }

usage() {
  fin "Help!!"
}

# Parse opts
# ------------------------------------------------------------------------------
remaining=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -a|--all)        all_flag=1;;
    -A|--almost-all) almost_all_flag=1;;
    --help)          usage;;
    *)               remaining="$remaining$1 ";;
  esac
  shift
done
