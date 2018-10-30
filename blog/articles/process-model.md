# Process Model

If we define Unix processes in a manifest named `Procfile`,
we can use tools to manage those processes.

## Examples

Rails app:

```
web: ./bin/rails server
webpacker: ./bin/webpack-dev-server
worker: QUEUES=mailers ./bin/rake jobs:work
```

Rails API with React frontend:

```
client: cd client && npm start
server: cd server && bundle exec puma -C config/puma.rb
```

Sinatra app:

```
web: cd canary && bundle exec ruby web.rb
```

Go API with React frontend:

```
client: cd client && npm start
server: cd serverd && go install && serverd
```

## Development

In development mode,
[Foreman] interleaves output streams,
responds to crashed processes,
and handles user-initiated restarts and shutdowns.

[Foreman]: http://ddollar.github.io/foreman/

```
foreman start
```

## Production

[Heroku uses the `Procfile`][Heroku] to specify the app's dynos.

[Heroku]: https://devcenter.heroku.com/articles/procfile

Foreman can also [export] the `Procfile`'s process definitions
to other formats such as `systemd`:

[export]: https://ddollar.github.io/foreman/#EXPORTING

```
foreman export systemd .
```
