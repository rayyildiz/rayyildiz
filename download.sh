#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

echo "generating and downloading github statst and top langs svg icons"

curl -sSL "https://stats.rayyildiz.com/api?username=rayyildiz&show_icons=true&hide_border=true" \
  -o icons/github-stats.svg

curl -sSL "https://stats.rayyildiz.com/api/top-langs/?username=rayyildiz&langs_count=7&cache_seconds=3000&hide=Asp,Ruby,HTML,css,javascript,shell,vim%20script,TypeScript,Dockerfile,Scala,Makefile,Dart,TSQL,SCSS,Emacs%20Lisp,Objective-C,C%23&show_icons=true&hide_border=true" \
  -o icons/github-top7.svg

echo "finished"
