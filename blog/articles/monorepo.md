# Monorepo

Organizing code into a monorepo can offer a great software development workflow.

The following is an example of how a monorepo could evolve,
based on our experience at [Interstellar](https://interstellar.com)
(formerly [Chain](https://chain.com)).

## Mentality

Imagine we are software engineers at an organization.
We expect to write software to support the organization,
and for that software to take the shape of multiple programs.

We plan to work incrementally,
to choose technologies suited to their tasks that we also enjoy,
and to be unafraid to write bespoke software
that improves our happiness and productivity.

## New repo

We initialize a monorepo on GitHub: `org/repo`:

```
.
└── README.md
```

We write a `README.md`:

```md
Add to your shell profile:

  # Set environment variable to monorepo path
  export ORG="$HOME/org"

  # Prepend monorepo scripts
  export PATH="$ORG/bin:$PATH"

Clone:

  git clone https://github.com/org/repo.git $ORG
  cd $ORG
```

The `$ORG` environment variable will be used throughout the codebase.


## Initial design

We [design] an initial architecture like this:

[design]: https://github.com/statusok/statusok/blob/master/learn/books/sw-design.md

* a "Dashboard" web interface for customers, written in React (TypeScript)
* mobile apps for customers, written in React Native (TypeScript)
* SDKs for customers, written for Go, Node (TypeScript), and Ruby
* an internal HTTP API used by the web interface and SDKs, written in Go
* a Postgres database backing the HTTP API

We add new files and directories (old files omitted with `...` for brevity):

```
.
├── ...
├── cmd
│   └── serverd
│       └── main.go
├── dashboard
├── mobile
│   └── app
│       ├── android
│       └── ios
├── sdk
│   ├── go
│   ├── node
│   └── ruby
└── server
    └── http_handler.go
```

## Commit messages

We use [community conventions][commit] for commit messages
with the addition that the first line ("subject line")
should be prefixed:

[commit]: https://chris.beams.io/posts/git-commit/

```
$ git log
dashboard: redirect to new project form after sign up
sdk/node: enable Keep-Alive in HTTP agent
server: document access to prod db
```

The prefix refers to the module
that the patch is primarily concerned with.
It often, but not always, matches a filesystem directory,

If a module's interface changes,
the patch will likely touch other files
to conform to the new interface,
but the prefix should be where the action is.

Although we don't worry about it much,
we try to keep the subject line under 50 characters.
It can be nice to [err on the side of brevity][brevity]
for module names.

[brevity]: https://golang.org/doc/effective_go.html#package-names

## Dependencies

To aid local development and help onboard teammates,
we might provide a `setup.sh` script for each project.
In turn,
each `setup.sh` script might invoke more general `$ORG/bin/setup-*` scripts.

Since all engineers have `$ORG/bin` on our `$PATH`,
all scripts in `bin/` are available everywhere at our shell
without a directory prefix.

We can also use [ASDF](asdf-version-manager)'s `.tool-versions` file
to pin versions for dependencies:

```
.
├── ...
├── .tool-versions
├── bin
│   ├── setup-go
│   ├── setup-localhost-tls
│   ├── setup-node
│   ├── setup-postgres
│   └── setup-ruby
├── dashboard
│   └── setup.sh
├── mobile
│   └── setup.sh
├── sdk
│  ├── go
│  │   └── setup.sh
│  ├── node
│  │   └── setup.sh
│  └── ruby
│      └── setup.sh
└── server
    └── setup.sh
```

## Formatting

Our Go code is already formatted with [gofmt]
but we could be more consistent in our TypeScript and Ruby code.
We add config files for [Prettier] and [Rubocop]
at the top of the file hierarchy:

[gofmt]: https://golang.org/cmd/gofmt/
[Prettier]: https://prettier.io/
[Rubocop]: https://rubocop.readthedocs.io/en/latest/

```
.
├── ...
├── .rubocop.yml
└── .prettierrc.yml
```

## Infrastructure

Our software can only be fully realized once it's in our customers' hands.
We choose Amazon Web Services (AWS) as a host for our core software,
such as EC2 for the HTTP API.

We add an `infra` directory for [Terraform], `systemd`, `bash` files, etc.:

[Terraform]: https://www.terraform.io/

```
.
├── ...
└── infra
```

## CI

To move quickly without breaking things,
we write automated tests
and run those tests continuously
when we integrate our changes into the codebase.

We also want our Continuous Integration (CI) service to:

* begin running the tests in < 5s after opening or editing a pull request
* run the tests in an environment with [parity] to the production environment
* run only the tests relevant to the change

[parity]: https://12factor.net/dev-prod-parity

We observe common causes of slow-starting tests on hosted CI services
are multi-tenant queues and containerization.
In those environments,
noisy neighbors backlog the queues
and containers have cache misses.

To meet our design goals, we write our own CI service, `testbot`
(design credit [Keith Rarick](https://xph.us/)):

```
.
├── ...
├── cmd
│   └── testbot
│       └── main.go
├── dashboard
│   └── Testfile
├── sdk
│   ├── go
│   │   └── Testfile
│   ├── node
│   │   └── Testfile
│   └── ruby
│       └── Testfile
├── server
│   └── Testfile
└── testbot
    ├── Testfile
    ├── farmer
    │   ├── Procfile
    │   └── main.go
    └── worker
        └── main.go
```

We open a GitHub pull request to add a new feature to the SDKs:

```
sdk/go/account.go             | 10 +++++-----
sdk/go/account_test.go        | 10 +++++-----
sdk/node/src/account.ts       | 10 +++++-----
sdk/node/test/account.ts      | 10 +++++-----
sdk/ruby/lib/account.rb       | 10 +++++-----
sdk/ruby/spec/account_spec.rb | 10 +++++-----
6 files changed, 60 insertions(+), 60 deletions(-)
```

A `testbot farmer` process on a server
responds to the GitHub webhook by:

* identifying the directories containing files that have changed
* walking up the file hierarchy to find `Testfile`s for changed directories
* saving test jobs to its backing Postgres database

Each `Testfile` defines test jobs for its directory. Ours might be:

```
$ cat $ORG/sdk/go/Testfile
tests: cd $ORG/sdk && go test -cover ./...
$ cat $ORG/sdk/node/Testfile
tests: cd $ORG/sdk/node && npm install && npm test
$ cat $ORG/sdk/ruby/Testfile
tests: $ORG/sdk/ruby/test.sh
```

A single `Testfile` can define multiple test jobs.
As test scripts become lengthier,
it is convenient to extract them to their own script.

Each line contains a name and command
separated by a colon.
The name appears in GitHub checks.
The command is run by a `testbot worker`,
which is continuously long polling `testbot farmer` via HTTP over TLS,
asking for test jobs.

Each `testbot worker` runs on an EC2 instance
created from the same Amazon Machine Image (AMI) used by our production server.
We run more instances to increase test parallelism.

In this example,
the tests for the Go, Node, and Ruby SDKs
will begin to run almost simultaneously
as different `testbot worker` processes pick them up.

Tests for `dashboard` and `server` will not run in this pull request
because no files in their directories were changed.

## Testing across services

To make it convenient to test across service boundaries,
we write a `with-serverd` script that:

* installs the `serverd` binary
* migrates the database
* creates a team and credential
* runs `serverd serve` without blocking programs
  passed as arguments to `with-serverd`

We place this script in `$ORG/bin` to make it available on our `$PATH`.

This script can be used in `Testfile`s:

```
$ cat $ORG/dashboard/Testfile
tests: with-serverd $ORG/dashboard/test.sh
$ cat $ORG/sdk/go/Testfile
tests: cd $ORG/sdk && with-serverd go test -cover ./...
```

Tests that depend on `with-serverd`
can avoid mocking on HTTP boundaries,
making actual requests to the backing service
and generating observable logs.

To broadly cover the product's surface area,
we move the Go SDK's `Testfile`
to the top of the file hierarchy
so its test jobs will run on all pull requests:

```
.
├── ...
├── Testfile
├── bin
│   └── with-serverd
└── sdk
    └── go
```

## Open source

Our SDKs should be open source on GitHub
and available on registries such as [NPM](https://www.npmjs.com/)
and [Rubygems](https://rubygems.org/)
but we like the monorepo as the canonical place
for our development workflow.

So, we decide to mirror the SDK code to open source repos.

This provides community access.
Although the community patch workflow is a bit manual,
these are SDKs tightly coupled to our product
and we expect community patches to be rare.

Other kinds of projects such as general-purpose libraries
might be better suited to live as
standalone open source repos outside the monorepo.

To meet our design goals, we write a `mirrorbot` program
(design credit [Bob Glickstein](http://www.geebobg.com/)):

```
.
├── ...
├── .mirrorbot.yml
└── cmd
    └── mirrorbot
        ├── Procfile
        ├── Testfile
        └── main.go
```

`mirrorbot` runs as a command-line program
that copies relevant changes from the `$ORG` monorepo
to one or more target repos.
It can be run on a laptop or a server.

On startup,
it clones the monorepo and each target repo.
Each copied commit includes an `upstream:[SHA]` line ([example][mirror]).
`mirrorbot` reads that SHA from the latest commit
on the destination branch of each target repo
to get its cursor.

[mirror]: https://github.com/sequence/sequence-sdk-ruby/commit/d00d15292808b7cf3c69c879ae9da781c819e658

Mirror then fast-forwards the local monorepo,
looking for new commits.

For each target repo,
a patch file is produced for each new commit.
The patch file is then filtered to remove anything not applicable to that repo.
If anything remains,
the patch is applied and committed.
Any new commits are then pushed to GitHub.

A `.mirrorbot.yml` file configures the program.
It maps monorepo branches to target repo branches
and monorepo directories and files to target repo directories and files.
For example:

```yml
github.com/org/org-sdk-node:
  - branch:
    - master: master
  - mirror:
    - sdk/node: /
github.com/org/org-sdk-ruby:
  - branch:
    - master: master
  - mirror:
    - sdk/ruby: /
```

## Backwards compatibility

As our customers use the software,
we better understand their needs
and begin to design v2.

To do this well,
we add new interfaces and deprecate old interfaces
in the v1.x series of the SDKs.
The server continues to support the v1.x series now and
for a well-communicated time period past the release of v2.0
(such as 90 days).

As we release minor versions v1.1 and v1.2,
patch versions v1.2.1 and v1.2.2,
and eventually v2,
we want to carefully ensure backwards compatibility.

To meet our design goals,
we write `with-go-sdk`, `with-node-sdk`, and `with-ruby-sdk` scripts
(design credit [Keith Rarick](https://xph.us/)):

```
.
├── ...
└── bin
    ├── with-go-sdk
    ├── with-node-sdk
    └── with-ruby-sdk
```

We use these scripts to run processes using a given version of our SDKs:

```
with-go-sdk [version] [command]
with-node-sdk [version] [command]
with-ruby-sdk [version] [command]
```

The `version` can be a released version to a registry such as NPM or Rubygems
or a special value `monorepo` to use the current `$ORG` source code.

For example:

```
with-ruby-sdk 1.0 ruby -e "require 'org-sdk'; puts OrgSDK::VERSION"
```

We update the `Testfile` at the top of the file hierarchy
to test supported releases
and the current source code (pre-release)
on every pull request:

```
$ cat $ORG/Testfile
gohead: with-serverd with-go-sdk monorepo go test -cover ./...
gov1: with-serverd with-go-sdk 1.5 go test -cover ./...
gov2: with-serverd with-go-sdk 2 go test -cover ./...
# ... etc.
rubyv2: with-serverd with-ruby-sdk 2 $ORG/sdk/ruby/test.sh
```

The SDK scripts are composable with the `with-serverd` script.

In addition to running on CI,
they are useful for quickly testing bug reports
from customers on a particular version,
and hopefully providing a great customer experience for them.

## Repo integrations

We often want to integrate tools such as
[Netlify](https://www.netlify.com/)
or [Heroku](https://www.heroku.com/)
with the repo.

Usually, integrating with third-party tools involves providing a manifest like:

```
cd subdir && command
```

For Heroku specifically,
we found it helpful to write a [Monorepo buildpack][buildpack],
which involves adding a `heroku.sh` file
to the subdirectory for Heroku-deployable projects:

[buildpack]: https://github.com/croaky/heroku-buildpack-monorepo

```
.
├── ...
├── cmd
│   └── mirrorbot
│       ├── Procfile
│       └── heroku.sh
└── testbot
    └── farmer
        ├── Procfile
        └── heroku.sh
```

## Conclusion

Working in a monorepo can encourage a feeling of "tight integration",
where service boundaries are well-defined and less likely to be mocked out.
Some tasks are a particular pleasure,
such as searching across projects
for callsites of a function or RPC.

For other tasks,
it can help to write custom tools.
Writing those custom tools offers an opportunity
to design an ideal experience for the engineering team.

In this example, the final directory structure looks something like this:

```
.
├── .mirrorbot.yml
├── .prettierrc.yml
├── .rubocop.yml
├── .tool-versions
├── README.md
├── Testfile
├── bin
│   ├── setup-go
│   ├── setup-localhost-tls
│   ├── setup-node
│   ├── setup-postgres
│   ├── setup-ruby
│   ├── with-go-sdk
│   ├── with-node-sdk
│   ├── with-ruby-sdk
│   └── with-serverd
├── cmd
│   ├── mirrorbot
│   │   ├── Procfile
│   │   ├── Testfile
│   │   ├── heroku.sh
│   │   ├── main.go
│   │   └── setup.sh
│   ├── serverd
│   │   └── main.go
│   └── testbot
│       └── main.go
├── dashboard
│   ├── Testfile
│   └── setup.sh
├── infra
│   └── setup.sh
├── mobile
│   ├── Testfile
│   ├── app
│   │   ├── android
│   │   └── ios
│   └── setup.sh
├── sdk
│   ├── go
│   │   └── setup.sh
│   ├── node
│   │   ├── Testfile
│   │   └── setup.sh
│   └── ruby
│       ├── Testfile
│       └── setup.sh
├── server
│   ├── Testfile
│   ├── http_handler.go
│   └── setup.sh
└── testbot
    ├── Testfile
    ├── farmer
    │   ├── Procfile
    │   ├── heroku.sh
    │   └── main.go
    ├── setup.sh
    └── worker
        └── main.go
```
