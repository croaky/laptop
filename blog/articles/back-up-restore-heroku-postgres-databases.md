# Back Up and Restore Heroku Databases

Configure staging and production Git remotes to
point to Heroku applications:

```
heroku git:remote -r staging -a your-staging-app
heroku git:remote -r production -a your-production-app
```

Install [Parity].
On OS X, install via Homebrew:

[Parity]: https://github.com/thoughtbot/parity

```
brew tap thoughtbot/formulae
brew install parity
```

Create a database backup at any time:

```
production backup
```

Restore a production database backup into staging environment:

```
staging restore production
```

Restore a production database backup into local development environment:

```
development restore production
```
