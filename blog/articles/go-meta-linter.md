# Go Meta Linter

Pipe [linter] output to a [static analysis tool][used]
to find issues in a Go program.

[linter]: https://github.com/alecthomas/gometalinter
[used]: https://github.com/sqs/used

Install tools:

```
go get -u github.com/alecthomas/gometalinter
go get -u github.com/sqs/used
gometalinter -i -u
```

Change into the directory of a Go program:

```
cd thoughtbot/rss
```

Analyze it:

```
gometalinter --json ./... | used -top 10
```

Review output, sorted by the most-used identifiers:

```
{"linter":"gas","severity":"warning","path":"main.go","line":51,"col":0,"message":"Errors unhandled.,LOW,HIGH"}
{"linter":"gas","severity":"warning","path":"main.go","line":52,"col":0,"message":"Errors unhandled.,LOW,HIGH"}
{"linter":"gas","severity":"warning","path":"main.go","line":62,"col":0,"message":"Errors unhandled.,LOW,HIGH"}
{"linter":"gas","severity":"warning","path":"main.go","line":72,"col":0,"message":"Errors unhandled.,LOW,HIGH"}
{"linter":"errcheck","severity":"warning","path":"integration_test.go","line":98,"col":16,"message":"error return value not checked (feed.WriteRss(w))"}
```

Fix them one at a time!
