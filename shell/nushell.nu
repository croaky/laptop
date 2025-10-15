# https://www.nushell.sh/book/configuration.html

# Hide welcome banner
$env.config.show_banner = false

# Aliases
alias b = bundle
alias c = git create-branch
alias fg = job unfreeze
alias flush-cache = sudo killall -HUP mDNSResponder
alias m = bundle exec rake db:migrate db:rollback and bundle exec rake db:migrate
alias vim = nvim

# Editor
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# fzf and fd to find files, fzf and rg to search files
$env.FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git"
$env.FZF_DEFAULT_OPTS = "
--color=bg+:#414559,bg:#303446,spinner:#F2D5CF,hl:#E78284
--color=fg:#C6D0F5,header:#E78284,info:#CA9EE6,pointer:#F2D5CF
--color=marker:#BABBF1,fg+:#C6D0F5,prompt:#CA9EE6,hl+:#E78284
--color=selected-bg:#51576D
--color=border:#737994,label:#C6D0F5"

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
  $"($env.HOME)/.rubies/ruby-3.4.7/bin"
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
$env.BAT_THEME = "CatppuccinFrappe"

# Prompt
def git_prompt_info [] {
  let branch = (do { git current-branch } | complete)
  if $branch.exit_code == 0 {
    $"(ansi green_bold)($branch.stdout | str trim)(ansi reset)"
  } else {
    ""
  }
}
$env.PROMPT_COMMAND = {||
  $"(git_prompt_info) "
}
$env.PROMPT_INDICATOR = "% "

# Catppuccin Frappe theme
let theme = {
  rosewater: "#f2d5cf"
  flamingo: "#eebebe"
  pink: "#f4b8e4"
  mauve: "#ca9ee6"
  red: "#e78284"
  maroon: "#ea999c"
  peach: "#ef9f76"
  yellow: "#e5c890"
  green: "#a6d189"
  teal: "#81c8be"
  sky: "#99d1db"
  sapphire: "#85c1dc"
  blue: "#8caaee"
  lavender: "#babbf1"
  text: "#c6d0f5"
  subtext1: "#b5bfe2"
  subtext0: "#a5adce"
  overlay2: "#949cbb"
  overlay1: "#838ba7"
  overlay0: "#737994"
  surface2: "#626880"
  surface1: "#51576d"
  surface0: "#414559"
  base: "#303446"
  mantle: "#292c3c"
  crust: "#232634"
}

let scheme = {
  recognized_command: $theme.blue
  unrecognized_command: $theme.text
  constant: $theme.peach
  punctuation: $theme.overlay2
  operator: $theme.sky
  string: $theme.green
  virtual_text: $theme.surface2
  variable: { fg: $theme.flamingo attr: i }
  filepath: $theme.yellow
}

$env.config.color_config = {
  separator: { fg: $theme.surface2 attr: b }
  leading_trailing_space_bg: { fg: $theme.lavender attr: u }
  header: { fg: $theme.text attr: b }
  row_index: $scheme.virtual_text
  record: $theme.text
  list: $theme.text
  hints: $scheme.virtual_text
  search_result: { fg: $theme.base bg: $theme.yellow }
  shape_closure: $theme.teal
  closure: $theme.teal
  shape_flag: { fg: $theme.maroon attr: i }
  shape_matching_brackets: { attr: u }
  shape_garbage: $theme.red
  shape_keyword: $theme.mauve
  shape_match_pattern: $theme.green
  shape_signature: $theme.teal
  shape_table: $scheme.punctuation
  cell-path: $scheme.punctuation
  shape_list: $scheme.punctuation
  shape_record: $scheme.punctuation
  shape_vardecl: $scheme.variable
  shape_variable: $scheme.variable
  empty: { attr: n }
  filesize: {||
    if $in < 1kb {
      $theme.teal
    } else if $in < 10kb {
      $theme.green
    } else if $in < 100kb {
      $theme.yellow
    } else if $in < 10mb {
      $theme.peach
    } else if $in < 100mb {
      $theme.maroon
    } else if $in < 1gb {
      $theme.red
    } else {
      $theme.mauve
    }
  }
  duration: {||
    if $in < 1day {
      $theme.teal
    } else if $in < 1wk {
      $theme.green
    } else if $in < 4wk {
      $theme.yellow
    } else if $in < 12wk {
      $theme.peach
    } else if $in < 24wk {
      $theme.maroon
    } else if $in < 52wk {
      $theme.red
    } else {
      $theme.mauve
    }
  }
  date: {|| (date now) - $in |
    if $in < 1day {
      $theme.teal
    } else if $in < 1wk {
      $theme.green
    } else if $in < 4wk {
      $theme.yellow
    } else if $in < 12wk {
      $theme.peach
    } else if $in < 24wk {
      $theme.maroon
    } else if $in < 52wk {
      $theme.red
    } else {
      $theme.mauve
    }
  }
  shape_external: $scheme.unrecognized_command
  shape_internalcall: $scheme.recognized_command
  shape_external_resolved: $scheme.recognized_command
  shape_block: $scheme.recognized_command
  block: $scheme.recognized_command
  shape_custom: $theme.pink
  custom: $theme.pink
  background: $theme.base
  foreground: $theme.text
  cursor: { bg: $theme.rosewater fg: $theme.base }
  shape_range: $scheme.operator
  range: $scheme.operator
  shape_pipe: $scheme.operator
  shape_operator: $scheme.operator
  shape_redirection: $scheme.operator
  glob: $scheme.filepath
  shape_directory: $scheme.filepath
  shape_filepath: $scheme.filepath
  shape_glob_interpolation: $scheme.filepath
  shape_globpattern: $scheme.filepath
  shape_int: $scheme.constant
  int: $scheme.constant
  bool: $scheme.constant
  float: $scheme.constant
  nothing: $scheme.constant
  binary: $scheme.constant
  shape_nothing: $scheme.constant
  shape_bool: $scheme.constant
  shape_float: $scheme.constant
  shape_binary: $scheme.constant
  shape_datetime: $scheme.constant
  shape_literal: $scheme.constant
  string: $scheme.string
  shape_string: $scheme.string
  shape_string_interpolation: $theme.flamingo
  shape_raw_string: $scheme.string
  shape_externalarg: $scheme.string
}
$env.config.highlight_resolved_externals = true
$env.config.explore = {
  status_bar_background: { fg: $theme.text, bg: $theme.mantle },
  command_bar_text: { fg: $theme.text },
  highlight: { fg: $theme.base, bg: $theme.yellow },
  status: {
    error: $theme.red,
    warn: $theme.yellow,
    info: $theme.blue,
  },
  selected_cell: { bg: $theme.blue fg: $theme.base },
}
