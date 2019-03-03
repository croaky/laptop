#!/usr/bin/env sh

# Run this script to build binaries

set -e

cd "$OK/cmd/genblog"

GOOS=linux GOARCH=amd64 go build -o blog/bin/linux .
GOOS=darwin GOARCH=amd64 go build -o blog/bin/mac .

cp README.md blog

line_number() {
  grep -n "$1" blog/README.md | cut -f1 -d:
}

from=$(line_number "# genblog")
to=$(line_number '## Write')
to=$((to - 1))

sed -i '' "$from","$to"d blog/README.md

prepend() {
  # shellcheck disable=SC2059
  (printf "$1"; cat "$2") > tmp
  mv tmp "$2"
}

prepend "# Blog\n\nA static blog.\n\n" blog/README.md

tar -czf blog.tar.gz blog
