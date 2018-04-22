# Gen

A static blog generator.

[Example](https://www.statusok.com)

* Markdown files without front matter
* Single `gen.json` config file
* Single theme
* Responsive design
* PageSpeed Insights score of 100
* Local preview server
* Tags
* Images
* Multiple authors
* Redirects
* Atom feed
* "Edit article" footer links
* "Last updated" timestamp

## Install

```
go get github.com/statusok/statusok/gen
```

## Setup

```
gen blog example-blog
cd example-blog
```

## Workflow

```
gen article example-article
$EDITOR articles/example-article.md
gen serve
```

Preview at <http://localhost:2000>.

Configure in `gen.json`:

```json
{
  "articles": [
    {
      "author_ids": [
        "croaky"
      ],
      "id": "laptop-setup-script",
      "published": "2014-06-18",
      "tags": [
        "setup",
        "unix"
      ],
      "updated": "2018-04-15"
    },
    {
      "author_ids": [
        "croaky",
        "frechg"
      ],
      "canonical": "https://robots.thoughtbot.com/north-star-metric",
      "id": "north-star-metric",
      "published": "2014-12-25",
      "tags": [
        "growth"
      ]
    },
    {
      "author_ids": [
        "croaky"
      ],
      "id": "decorators-ruby",
      "published": "2011-12-26",
      "redirects": [
        "/implement-decorators-with-ruby"
      ],
      "tags": [
        "ruby"
      ]
    },
  ],
  "authors": [
    {
      "id": "croaky",
      "name": "Dan Croak",
      "url": "https://github.com/croaky"
    },
    {
      "id": "frechg",
      "name": "Galen Frechette",
      "url": "http://galen.io"
    }
  ],
  "name": "Status OK blog",
  "source_url": "https://github.com/statusok/statusok/tree/master/blog",
  "url": "https://www.statusok.com"
}
```

## Images

Add images to the `public/images` directory.
Refer to them in articles via relative path:

```md
![](images/example.png)
```

Commit them to version control.

## Publish

Configure [Netlify] with these settings:

[Netlify]: https://www.netlify.com

* Repository: `https://github.com/owner/repo`
* Branch: `master`
* Build Cmd: `go get github.com/statusok/statusok/gen && $GOPATH/bin/gen build`
* Public folder: `public`

To publish articles, commit to the Git repo:

```
git add --all
git commit --verbose
git push
```

View deploy logs in the Netlify web interface.

## Support

Open a [GitHub Issue][issues] for help.
See [CONTRIBUTING.md][contrib] for instructions on contributing.
See [LICENSE] for the license.

[issues]: https://github.com/statusok/statusok/issues
[contrib]: CONTRIBUTING.md
[LICENSE]: ../LICENSE
