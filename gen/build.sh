#!/usr/bin/env sh

# Run this script to build binaries

set -ex

GOOS=linux GOARCH=amd64 go build -o blog/bin/linux .
GOOS=darwin GOARCH=amd64 go build -o blog/bin/mac .

tar -czf blog.tar.gz blog
