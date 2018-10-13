#!/bin/bash
set -u
VERBOSE=N

while getopts "v" OPT; do
  case "$OPT" in
  v)
    VERBOSE="Y"
    ;;
  esac
done

MKTEMP_OPT="--suffix .txt stdin.XXXXXXXXXX"
if [ -w . ]; then
  MKTEMP_OPT="-p . $MKTEMP_OPT"
fi
TEMPNAME=$(mktemp $MKTEMP_OPT)

on_exit() {
  sleep 5
  if [ "$VERBOSE" == "Y" ]; then
    rm -v $TEMPNAME
  else
    rm $TEMPNAME
  fi
}
trap 'on_exit' EXIT

if [ "$VERBOSE" == "Y" ]; then
  tee $TEMPNAME
  echo "--> $TEMPNAME"
else
  cat $TEMPNAME
fi

[ $? -eq 0 ] && atom $TEMPNAME
