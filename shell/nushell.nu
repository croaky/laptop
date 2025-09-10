# https://www.nushell.sh/book/configuration.html

# Hide welcome banner
$env.config.show_banner = false

# Aliases
alias b = bundle
alias c = git create-branch
alias fg = job unfreeze
alias flush-cache = sudo killall -HUP mDNSResponder
alias m = rake db:migrate db:rollback and rake db:migrate db:test:prepare
alias vim = nvim

# Editor
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# fzf and fd to find files, fzf and rg to search files
$env.FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git"

# Ruby
$env.BUNDLE_IGNORE_FUNDING_REQUESTS = "true"
$env.BUNDLE_IGNORE_MESSAGES = "true"
$env.BUNDLE_JOBS = "16"
$env.GEM_OPTS = "--no-document"
$env.RUBYOPT = "--enable=frozen-string-literal --enable-yjit"

# Node
$env.NPM_CONFIG_FUND = "false"

# Postgres
$env.PGUSER = "postgres"
$env.PROMPT_COMMAND_RIGHT = ""

# https://github.com/ged/ruby-pg/issues/538
# https://github.com/rails/rails/issues/38560#issuecomment-1881733872
# https://blog.phusion.nl/2017/10/13/why-ruby-app-servers-break-on-macos-high-sierra-and-what-can-be-done-about-it/
$env.PGGSSENCMODE = "disable"

# PATH
$env.PATH = ($env.PATH | split row (char esep) | prepend [
  $"($env.HOME)/go/bin"
  $"($env.HOME)/.rubies/ruby-3.4.5/bin"
  $"/opt/homebrew/bin"
  $"/opt/homebrew/opt/node/bin"
  $"/opt/homebrew/.bun/bin"
  $"/opt/homebrew/opt/postgresql@17/bin"
  $"($env.HOME)/laptop/bin"
  ".git/safe/../../bin"
])

# History
$env.config.history.file_format = "plaintext"
$env.config.history.isolation = false
$env.config.history.max_size = 500
$env.config.history.sync_on_enter = true

# Bat
$env.BAT_THEME = "TwoDark"

# Prompt
def git_prompt_info [] {
  let branch = (do { git current-branch } | complete)
  if $branch.exit_code == 0 {
    $" (ansi green_bold)($branch.stdout | str trim)(ansi reset)"
  } else {
    ""
  }
}
$env.PROMPT_COMMAND = {||
  let current_dir = ($env.PWD | path basename)
  $"(ansi blue_bold)($current_dir)(ansi reset)(git_prompt_info) "
}
$env.PROMPT_INDICATOR = "% "
