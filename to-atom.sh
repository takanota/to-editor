#!/bin/bash

MKTEMP_OPT="--suffix .txt stdin.XXXXXXXXXX"
if [ -w . ]; then
  MKTEMP_OPT="-p . $MKTEMP_OPT"
fi
TEMPNAME=$(mktemp $MKTEMP_OPT)

on_exit() {
  sleep 5
  if [ -f $TEMPNAME ]; then
    rm -v $TEMPNAME
  fi
}
trap 'on_exit' EXIT

echo "--> $TEMPNAME"
tee -a $TEMPNAME && atom $TEMPNAME
