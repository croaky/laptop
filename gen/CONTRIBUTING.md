# Contributing

Get a working [Go installation](http://golang.org/doc/install).
For example, with [ASDF](https://github.com/asdf-vm/asdf):

```
git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf"
asdf plugin-add go https://github.com/kennyp/asdf-golang
asdf install go 1.9.3
```

Fork the repo. Clone the project into your
[Go work environment](http://golang.org/doc/code.html).

```
export OK="$GOPATH/src/statusok"
git clone https://github.com/statusok/statusok.git $OK
cd $OK/gen
go get -t -d -v ./...
go test -v -race ./...
```

Make changes.
Push to your fork.
Submit a pull request.
Discuss and improve the code with reviewers.
A maintainer will merge the pull request.
