#!/bin/bash

usage() {
  echo "usage"
  echo "  $0 [OPTION...]"
  echo ""
  echo "parameter"
  echo "  -e, --editor=EDITOR editor path"
  echo "  -h, --help          show this help"
  echo "  -v, --version       verbose output"
  echo ""
}

err() {
  echo "[ERROR] $@" >/dev/stderr
}

VERBOSE=N
EDITOR_PATH=

while [ -n "$1" ]; do
  case "$1" in
  -e|--editor)
    shift
    EDITOR_PATH=$1
    ;;
  --editor=*)
    EDITOR_PATH=${1#*=}
    ;;
  -h|--help)
    usage
    exit 1
    ;;
  -v|--verbose)
    VERBOSE=Y
    ;;
  *)
    err "Unknown option $1"
    usage
    exit 2
  esac
  shift
done

set -u
if [ -z "$EDITOR_PATH" ]; then
  err "--editor=EDITOR is required"
  usage
  exit 3
elif [ ! -x "$EDITOR_PATH" ]; then
  err "editor is not executable: $EDITOR_PATH"
  exit 4
fi

MKTEMP_OPT="--suffix .txt stdin.XXXXXXXXXX"
if [ -w . ]; then
  MKTEMP_OPT="-p . $MKTEMP_OPT"
fi
TEMPNAME=$(mktemp $MKTEMP_OPT)

on_exit() {
  sleep 5
  if [ "$VERBOSE" == "Y" ]; then
    rm -v "$TEMPNAME"
  else
    rm "$TEMPNAME"
  fi
}
trap 'on_exit' EXIT

if [ "$VERBOSE" == "Y" ]; then
  tee "$TEMPNAME"
  echo "--> $TEMPNAME"
else
  cat > "$TEMPNAME"
fi

if [ $? -eq 0 ]; then
  echo "starting $EDITOR_PATH $TEMPNAME ..."
  "$EDITOR_PATH" "$TEMPNAME" 1>/dev/null 2>/dev/null &
fi
