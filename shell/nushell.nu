# https://www.nushell.sh/book/configuration.html

$env.config.show_banner = false
$env.PROMPT_COMMAND_RIGHT = ""

# Environment variables
$env.VISUAL = "nvim"
$env.EDITOR = "nvim"
$env.CLICOLOR = "1"
$env.BAT_THEME = "TwoDark"
$env.BUNDLE_IGNORE_FUNDING_REQUESTS = "true"
$env.BUNDLE_IGNORE_MESSAGES = "true"
$env.BUNDLE_JOBS = "16"
$env.GEM_OPTS = "--no-document"
$env.RUBYOPT = "--enable=frozen-string-literal --enable-yjit"
$env.NPM_CONFIG_FUND = "false"
$env.PGUSER = "postgres"
$env.PGGSSENCMODE = "disable"
$env.LAPTOP = $"($env.HOME)/laptop"
$env.FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git"

# PATH setup
$env.PATH = ($env.PATH | split row (char esep) | prepend [
  $"($env.HOME)/go/bin"
  $"($env.HOME)/.rubies/ruby-3.4.5/bin"
  $"/opt/homebrew/bin"
  $"/opt/homebrew/opt/node/bin"
  $"/opt/homebrew/.bun/bin"
  $"/opt/homebrew/opt/postgresql@17/bin"
  $"($env.HOME)/.cargo/bin"
  $"($env.LAPTOP)/bin"
  ".git/safe/../../bin"
])

# Aliases
alias b = bundle
alias c = git create-branch
alias flush-cache = sudo killall -HUP mDNSResponder
alias m = rake db:migrate db:rollback and rake db:migrate db:test:prepare
alias vim = nvim

# History
$env.config.history.max_size = 500
$env.config.history.sync_on_enter = true
$env.config.history.file_format = "plaintext"
$env.config.history.isolation = false

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
