#!/bin/bash

usage() {
  echo "usage"
  echo "  $0 [OPTION...]"
  echo ""
  echo "parameter"
  echo "  -e, --editor=EDITOR editor path"
  echo "  -d, --tmpdir=DIR    directory to create temporary file"
  echo "                      (default: current directory)"
  echo "  -c, --clear=N       remove temporary file after N second(s)"
  echo "                      (0 to skip remove temporary file)"
  echo "  -h, --help          show this help"
  echo "  -v, --version       verbose output"
  echo ""
}

err() {
  echo "[ERROR] $@" >/dev/stderr
}

VERBOSE=N
EDITOR_PATH=
TEMPDIR=.
CLEAR_SECONDS=5

while [ -n "$1" ]; do
  case "$1" in
  -e|--editor)
    shift
    EDITOR_PATH=$1
    ;;
  --editor=*)
    EDITOR_PATH=${1#*=}
    ;;
  -d|--tmpdir)
    shift
    TEMPDIR=$1
    ;;
  --tmpdir=*)
    TEMPDIR=${1#*=}
    ;;
  -c|--clear)
    shift
    CLEAR_SECONDS=$1
    ;;
  --clear=*)
    CLEAR_SECONDS=${1#*=}
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
fi
if [ ! -x "$EDITOR_PATH" ]; then
  err "editor is not executable: $EDITOR_PATH"
  exit 4
fi
if [[ ! "$CLEAR_SECONDS" =~ ^[0-9]+$ ]]; then
  err "--clear=N must be numeric"
  usage
  exit 5
fi

TEMPNAME=$(mktemp $TEMPDIR/stdin.XXXXXXXXXX.txt) || exit $?
on_exit() {
  sleep $CLEAR_SECONDS
  if [ "$VERBOSE" == "Y" ]; then
    rm -v "$TEMPNAME"
  else
    rm "$TEMPNAME"
  fi
}
if [ $CLEAR_SECONDS -gt 0 ]; then
  trap 'on_exit &' EXIT
fi

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
