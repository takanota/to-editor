#!/usr/bin/env bash
#
# to-editor.sh: open stdin to editor
#
set -euo pipefail

usage() {
  echo "usage"
  echo "  $0 [OPTION...] CMDLINE"
  echo ""
  echo "parameters"
  echo "  CMDLINE          command line to open editor"
  echo "  OPTION"
  echo "    -d, --dir=DIR  directory to create temporary file"
  echo "                   (default: current directory)"
  echo "    -c, --clear=N  remove temporary file after N second(s)"
  echo "                   (0 to skip remove temporary file)"
  echo "    -h, --help     show this help"
  echo "    -v, --version  verbose output"
  echo ""
}

err() {
  echo "[ERROR] $@" >/dev/stderr
}

clear_stdin_file() {
  if [ "$clear_seconds" == "0" ]; then
    return
  fi
  if [ ! -f "$stdin_file" ]; then
    return
  fi

  sleep "$clear_seconds"
  if [ "$verbose" == "Y" ]; then
    rm -v "$stdin_file"
  else
    rm "$stdin_file"
  fi
}
trap 'clear_stdin_file' EXIT

verbose=N
stdin_dir=.
stdin_file=
clear_seconds=5
editor_cmdline=

while [ $# -gt 0 ]; do
  if [ -z "$editor_cmdline" ]; then
    case "$1" in
    -d|--dir)
      shift
      stdin_dir="$1"
      ;;
    --dir=*)
      stdin_dir="${1#*=}"
      ;;
    -c|--clear)
      shift
      clear_seconds="$1"
      ;;
    --clear=*)
      clear_seconds="${1#*=}"
      ;;
    -h|--help)
      usage
      exit 1
      ;;
    -v|--verbose)
      verbose=Y
      ;;
    *)
      editor_cmdline="$1"
      ;;
    esac
  else
    editor_cmdline="$editor_cmdline $1"
  fi
  shift
done

if [ -z "$editor_cmdline" ]; then
  err "CMDLINE is required"
  usage
  exit 3
fi
if [[ ! "$clear_seconds" =~ ^[0-9]+$ ]]; then
  err "--clear=N must be numeric"
  usage
  exit 4
fi

stdin_file=$(mktemp "$stdin_dir/stdin.XXXXXXXXXX.txt")
if [ "$verbose" == "Y" ]; then
  tee "$stdin_file"
  echo "--> $stdin_file"
else
  cat > "$stdin_file"
fi

echo "starting $editor_cmdline $stdin_file ..."
$editor_cmdline "$stdin_file"
