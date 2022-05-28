#!/usr/bin/env bash

main() {
	need_cmd curl
	need_cmd grep
	need_cmd cut
	need_cmd xargs
	need_cmd chmod
  need_cmd mkdir
  need_cmd rm
  need_cmd tar
  need_cmd cp
  need_cmd mv
  need_cmd echo
	build
}

build() {

  CDIR="$(cd "$(dirname "$0")" && pwd)"
  build_dir=$CDIR/build

  while getopts A:K:q option
  do
    case "${option}"
    in
      q) QUIET=1;;
      A) ARCH=${OPTARG};;
      K) KERNEL=${OPTARG};;
    esac
  done

  rm -rf $build_dir
  mkdir -p $build_dir

  for f in *prerun.sh
  do
      cp $CDIR/$f $build_dir/
  done

  cd $build_dir

  if [ -z "$ARCH" ]; then
    ARCH=$(uname -m)
  fi
  if [ -z "$KERNEL" ]; then
    KERNEL=$(uname -s)
  fi
  #change Arch x86_64 to amd64
  if [ "$ARCH" == "x86_64" ]; then
    ARCH="amd64"
  fi
  echo "Downloading tmate for $ARCH and $KERNEL"
  # get latest version from github
  curl -s https://api.github.com/repos/tmate-io/tmate/releases/latest | grep browser_download_url | grep -i $KERNEL | grep -v "dbg" | grep -i $ARCH | cut -d '"' -f 4 | xargs curl -L -o tmate.tar.xz
  # extract
  tar xf tmate.tar.xz
  rm -f tmate.tar.xz
  mv tmate-*-static-*/tmate ./
  # make executable
  chmod +x ./tmate
  rm -rf tmate-*-static-*
}

cmd_chk() {
  >&2 echo Check "$1"
	command -v "$1" >/dev/null 2>&1
}

need_cmd() {
  if ! cmd_chk "$1"; then
    error "need $1 (command not found)"
    exit 1
  fi
}

main "$@" || exit 1
