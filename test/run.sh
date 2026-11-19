#!/bin/bash

# Run each test in test/. The tests need the tools that laptop.sh
# installs: zsh, go, nvim with its plugins, dprint, and the pinned
# goimports. So they run on the workstation, not in the Checkfile.
set -euo pipefail

dir=$(cd "$(dirname "$0")" && pwd -P)
"$dir/zshrc_test.zsh" </dev/null
"$dir/trust_test.sh" </dev/null | grep -v '^trusted '
"$dir/nvim_test.sh" </dev/null | grep -v '^trusted '
