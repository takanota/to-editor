#!/bin/bash
set -u

VERBOSE=N
EDITOR_PATH=

usage() {
  echo "usage"
  echo "  $0 [-e EDITOR] [-h] [-v]"
  echo ""
  echo "parameter"
  echo "  -e EDITOR : editor path"
  echo "  -h        : show this help"
  echo "  -v        : verbose output"
  echo ""
}

err() {
  echo "$@" >/dev/stderr
}

while getopts "e:hv" OPT; do
  case "$OPT" in
  e)
    EDITOR_PATH="$OPTARG"
    ;;
  h)
    usage
    exit 1
    ;;
  v)
    VERBOSE="Y"
    ;;
  *)
    usage
    exit 2
  esac
done

if [ -z "$EDITOR_PATH" ]; then
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
  cat "$TEMPNAME"
fi

if [ $? -eq 0 ]; then
  echo "starting $EDITOR_PATH $TEMPNAME ..."
  "$EDITOR_PATH" "$TEMPNAME" 1>/dev/null 2>/dev/null &
fi
