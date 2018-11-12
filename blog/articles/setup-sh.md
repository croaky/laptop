# setup.sh

Regardless of programming language or project type,
a nice pattern for working on a project is:

```
git clone git@github.com:org/monorepo.git
cd monorepo/project
./setup.sh
```

Regardless of the `setup.sh` file's contents,
a developer should be able to clone the [monorepo](monorepo),
change into the project directory,
and run one command to start contributing.

Example:

```
#!/bin/sh
# Set up Rails app after cloning codebase.
set -ex

# Install Ruby dependencies
gem install bundler --conservative
bundle check || bundle install

# Install JavaScript dependencies
bin/yarn

# Set up database
bin/rails db:setup
```
