# ./bin/setup

Regardless of programming language or project type,
a nice pattern for working on a codebase is:

```
git clone git@github.com:organization/project.git
cd project
./bin/setup
```

The goal of the `bin/setup` script is quick, reliable, consistent setup.

Here's an example `bin/setup`:

```
#!/bin/sh

# Set up Rails app. Run this script immediately after cloning the codebase.
# https://github.com/thoughtbot/guides/tree/master/protocol

# Exit if any subcommand fails
set -e

# Set up Ruby dependencies via Bundler
gem install bundler --conservative
bundle check || bundle install

# Set up configurable environment variables
if [ ! -f .env ]; then
  cp .sample.env .env
fi

# Set up database and add any development seed data
bin/rake dev:prime

# Add binstubs to PATH via export PATH=".git/safe/../../bin:$PATH" in ~/.zshenv
mkdir -p .git/safe

# Only if this isn't CI
# if [ -z "$CI" ]; then
# fi
```

Each project will be different.
Some might test if Redis is installed and, if not, install or print a message.
Some might want to pull some `ENV` variables into `.env` from Heroku.

Regardless of the `bin/setup` file's contents,
a developer should be able to clone the project and
run one setup command to start contributing.
