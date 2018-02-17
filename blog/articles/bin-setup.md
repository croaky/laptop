# ./bin/setup

Regardless of programming language or project type,
a nice pattern for working on a project is:

```
git clone git@github.com:organization/project.git
cd project
./bin/setup
```

Regardless of the `bin/setup` file's contents,
a developer should be able to clone the project and
run one command to start contributing.

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
