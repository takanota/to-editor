#!/bin/bash
set -u

VERBOSE=N
[ -v EDITOR ] || EDITOR=gedit

err() {
  echo "$@" >/dev/stderr
}

while getopts ":e:v" OPT; do
  case "$OPT" in
  e)
    EDITOR="$OPTARG"
    ;;
  v)
    VERBOSE="Y"
    ;;
  esac
done

EDITOR_PATH=$(which $EDITOR)
if [ -z "$EDITOR_PATH" ]; then
  err "editor is not exists: $EDITOR"
  exit 1
elif [ ! -x "$EDITOR_PATH" ]; then
  err "editor is not executable: $EDITOR"
  exit 1
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
  echo "starting $EDITOR $TEMPNAME ..."
  "$EDITOR" "$TEMPNAME" 1>/dev/null 2>/dev/null &
fi
