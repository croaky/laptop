#!/usr/bin/env sh

# Run this script to build an updated blog template.

set -e

cd "$OK/cmd/genblog"

GOOS=linux GOARCH=amd64 go build -o template/bin/linux .
GOOS=darwin GOARCH=amd64 go build -o template/bin/mac .

cp README.md blog

line_number() {
  grep -n "$1" template/README.md | cut -f1 -d:
}

from=$(line_number "# genblog")
to=$(line_number '## Write')
to=$((to - 1))

sed -i '' "$from","$to"d template/README.md

prepend() {
  # shellcheck disable=SC2059
  (printf "$1"; cat "$2") > tmp
  mv tmp "$2"
}

prepend "# Blog\n\nA static blog.\n\n" template/README.md

tar -czf blog.tar.gz template
