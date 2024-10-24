#!/usr/bin/env bash
#
# to-editor.sh: open stdin to editor
#
set -euo pipefail

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

verbose=N
editor_path=
tempdir=.
clear_seconds=5

while [ $# -gt 0 ]; do
  case "$1" in
  -e|--editor)
    shift
    editor_path=$1
    ;;
  --editor=*)
    editor_path=${1#*=}
    ;;
  -d|--tmpdir)
    shift
    tempdir=$1
    ;;
  --tmpdir=*)
    tempdir=${1#*=}
    ;;
  -c|--clear)
    shift
    clear_seconds=$1
    ;;
  --clear=*)
    clear_seconds=${1#*=}
    ;;
  -h|--help)
    usage
    exit 1
    ;;
  -v|--verbose)
    verbose=Y
    ;;
  *)
    err "Unknown option $1"
    usage
    exit 2
  esac
  shift
done

if [ -z "$editor_path" ]; then
  err "--editor=EDITOR is required"
  usage
  exit 3
fi
if [ ! -x "$editor_path" ]; then
  err "editor is not executable: $editor_path"
  exit 4
fi
if [[ ! "$clear_seconds" =~ ^[0-9]+$ ]]; then
  err "--clear=N must be numeric"
  usage
  exit 5
fi

tempfile=$(mktemp "$tempdir/stdin.XXXXXXXXXX.txt")
on_exit() {
  sleep $clear_seconds
  if [ "$verbose" == "Y" ]; then
    rm -v "$tempfile"
  else
    rm "$tempfile"
  fi
}
if [ $clear_seconds -gt 0 ]; then
  trap 'on_exit &' EXIT
fi

if [ "$verbose" == "Y" ]; then
  tee "$tempfile"
  echo "--> $tempfile"
else
  cat > "$tempfile"
fi

echo "starting $editor_path $tempfile ..."
"$editor_path" "$tempfile" 1>/dev/null 2>/dev/null &
