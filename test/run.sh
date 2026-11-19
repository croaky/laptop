#!/bin/bash

# Run each test in test/. The Neovim tests need the tools that
# laptop.sh installs: go, nvim with its plugins, and dprint. So they
# run only on the workstation. The Checkfile also runs the bashrc,
# hostctl, ssh, and trust tests, but on Linux with bash 5, not on
# macOS with /bin/bash 3.2.
set -euo pipefail

dir=$(cd "$(dirname "$0")" && pwd -P)
"$dir/bashrc_test.sh" </dev/null
"$dir/trust_test.sh" </dev/null | grep -v '^trusted '
"$dir/nvim_test.sh" </dev/null | grep -v '^trusted '
"$dir/hostctl_test.sh" </dev/null
"$dir/ssh_test.sh" </dev/null
"$dir/argv_test.sh" </dev/null
