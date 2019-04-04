# Contributing

Get a working [Go installation](http://golang.org/doc/install):

```
gover="1.12"
if ! go version | grep -Fq "$gover"; then
  rm -rf /usr/local/go
  curl "https://dl.google.com/go/go$gover.darwin-amd64.tar.gz" | \
    sudo tar xz -C /usr/local
fi
```

Fork the repo. Clone the project into your
[Go work environment](http://golang.org/doc/code.html).

```
export OK="$HOME/statusok"
git clone https://github.com/statusok/statusok.git $OK
cd $OK/cmd/genblog
go get -t -d -v ./...
go test -v -race ./...
```

Make changes.
Push to your fork.
Submit a pull request.
Discuss and improve the code with reviewers.
A maintainer will merge the pull request.
