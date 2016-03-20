#!/bin/sh

die() { printf "%s\n" "$*" >&2; exit 1; }
fin() { printf "%s\n" "$*"; exit 0; }

usage() {
  fin "Help!!"
}
