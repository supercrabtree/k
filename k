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
    -a|--all)        flag_all=1;;
    -A|--almost-all) flag_almost_all=1;;
    --help)          usage;;
    *)               remaining="$remaining$1 ";;
  esac
  shift
done
