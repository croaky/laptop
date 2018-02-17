# Eng

A minimal static site generator,
ideal for software engineering blogs.

1. Markdown files without front matter
1. All configuration in `eng.json` file
1. Local preview server
1. Responsive, high-performance theme
1. Atom feed
1. Images

[Example](https://www.statusok.com)

## Install

```
go get github.com/statusok/statusok/cmd/eng
```

## Setup

Initialize site:

```
eng init example-site
cd example-site
```

Explore generated files:

```
example-site
├── README.md
├── articles
├── eng.json
```

See all subcommands and flags:

```
eng help
eng help subcommand
```

## Workflow

Run a local server:

```
eng local
```

Preview in a browser:

```
open http://localhost:2000
```

Create an article:

```
eng new article-slug
```

See articles in the `articles` directory:

```
articles
  └── article-slug.md
```

Configure site in `eng.json`:

```
{
  "articles": [
    {
      "author_ids": ["croaky"],
      "id": "test-spies-vs-mocks",
      "published": "2015-03-19",
      "redirects": ["/a-closer-look-at-test-spies"]
    },
    {
      "author_ids": [
        "croaky",
        "frechg"
      ],
      "canonical": "https://robots.thoughtbot.com/north-star-metric",
      "id": "north-star-metric",
      "published": "2014-12-25",
      "updated": "2018-01-29"
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

Add images to the `public/images` directory.
Refer to them in articles via relative path (`![](images/example.png)`).
Commit them to version control.

## Publish

Configure [Netlify] to link to the [GitHub] repository with these settings:

[Netlify]: https://www.netlify.com
[GitHub]: https://github.com

* Branch: `master`
* Build Cmd: `eng build`
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

[issues]: https://github.com/statusok/eng/issues
[contrib]: CONTRIBUTING.md
[LICENSE]: LICENSE
