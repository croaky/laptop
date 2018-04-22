# Contributing

Get a working [Go installation].
Fork the repo.
Clone the project into your [Go work environment].

  [Go installation]: http://golang.org/doc/install
  [Go work environment]: http://golang.org/doc/code.html

Set up:

```
go get -t -d -v ./...
go install -v ./...
```

Test the packages:

```
go test -v -race ./...
```

Make your change with new passing tests.
Push to your fork.
Write a [good commit message][commit].
Submit a pull request.

  [commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html

Others will give feedback.
Discuss the code.
Make improvements.
A maintainer will merge the pull request.
