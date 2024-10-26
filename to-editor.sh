#!/usr/bin/env bash
#
# to-editor.sh: open stdin to editor
#
set -euo pipefail

usage() {
  echo "usage"
  echo "  $0 [OPTION...] EDITOR [- | CMDLINE...]"
  echo ""
  echo "parameters"
  echo "  EDITOR           editor executable"
  echo "  CMDLINE          command line to open editor."
  echo "                   '-' to open editor with stdin."
  echo "  OPTION"
  echo "    -d, --dir=DIR  directory to create stdin file"
  echo "                   (default: current directory)"
  echo "    -c, --clear=N  remove stdin file after N second(s)"
  echo "                   ('0' to skip remove stdin file)"
  echo "    -h, --help     show this help"
  echo "    -v, --verbose  verbose output"
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

verbose=N
stdin_dir=/tmp
stdin_file=
clear_seconds=0
editor_cmdline=()

while [ $# -gt 0 ]; do
  if [ ${#editor_cmdline[@]} -eq 0 ]; then
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
      editor_cmdline+=("$1")
      ;;
    esac
  elif [ "$1" = "-" ]; then
    stdin_file=$(mktemp "$stdin_dir/stdin.XXXXXXXXXX.txt")
    editor_cmdline+=("$stdin_file")
  else
    editor_cmdline+=("$1")
  fi
  shift
done

if [ ${#editor_cmdline[@]} -eq 0 ]; then
  err "EDITOR is required"
  usage
  exit 3
fi
if [[ ! "$clear_seconds" =~ ^[0-9]+$ ]]; then
  err "--clear=N must be numeric"
  usage
  exit 4
fi

if [ -n "$stdin_file" ]; then
  trap 'clear_stdin_file' EXIT
  if [ "$verbose" == "Y" ]; then
    tee "$stdin_file"
    echo "--> $stdin_file"
    echo "starting ${editor_cmdline[@]} ..."
  else
    cat > "$stdin_file"
  fi
fi

"${editor_cmdline[@]}" &
