#!/bin/sh

die() { printf "%s\n" "$*" >&2; exit 2; }
fin() { printf "%s\n" "$*"; exit 0; }
