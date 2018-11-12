# Start a Rails Project with Suspenders

Introducing [Suspenders], a Rails template.

[Suspenders]: http://github.com/thoughtbot/suspenders

## Install

To create a new project,
check out [the GitHub repository][Suspenders] and run:

```
./script/create_project projectname
```

This will create a project in `../projectname`.
Follow the instructions on GitHub to upload that project there.
This script creates an entirely new Git repository,
and is not meant to be used against an existing repo.

Changes to the template can be pulled it into your project via:

```
rake git:pull:suspenders
```

This is funny because you're pulling your suspenders.

## About

Suspenders was created for use at [thoughtbot]
as a base application
with best-practice configuration
and reasonable plugins
that the majority of our applications used.

[thoughtbot]: https://thoughtbot.com

Thanks to various [Boston Ruby Group][Boston.rb] members for
using Suspenders this past weekend and
giving it it's first external test runs.

[Boston.rb]: http://bostonrb.org/

Suspenders currently includes Rails 2.1.1 and:

```
config/initializers
├── action_mailer_configs.rb
├── hoptoad.rb
├── requires.rb
├── time_formats.rb
vendor/gems
├── README.md
├── RedCloth
├── factory_girl
├── mocha
├── quietbacktrace
├── thoughtbot-shoulda
├── will_paginate
vendor/plugins
├── helper_test
├── hoptoad_notifier
├── limerick_rake
├── mile_marker
├── squirrel
```

## Testing

The basic test setup uses `Test::Unit`, `Shoulda`, `factory_girl`, and `mocha`,
and includes some standard shoulda macros that we've used on various projects.

[Factory Girl] is a fixture replacement library, following the factory pattern.
Place your factories in `test/factories.rb`.
The fixture directory has been removed, as fixtures are not used.

[Factory Girl]: https://github.com/thoughtbot/factory_girl

[Shoulda] is a pragmatic testing framework for Test-Driven Development
built on top of `Test::Unit`.
A number of additional testing macros are provided in `test/shoulda_macros`.

[Shoulda]: https://github.com/thoughtbot/shoulda

## Deployment

Deployment is done using Capistrano
and deploys to a Mongrel cluster running under Apache.

Rake tasks are provided for managing Git branches
for the deployment environments.

To push the Git master to Git staging branch run:

```
rake git:push:staging
```

To push the Git staging branch to production branch run:

```
rake git:push:production
```

Setup your deployment environment by running:

```
cap ENVIRONMENT deploy:setup
```

You'll be prompted for the environment's database password.

Deploy to the desired environment by running:

```
cap ENVIRONMENT deploy
```

The default environment for deploy is staging. To deploy to staging, run:

```
cap deploy
```

## Mascot

The official Suspenders mascot is Suspenders Boy.

![suspenders boy](images/suspenders-boy.png)
