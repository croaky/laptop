# Gen

A static blog generator.

[Example](https://www.statusok.com)

* Markdown files without front matter
* Local preview server
* Images
* Single `gen.json` config file
* Tags
* Multiple authors
* "Last updated" timestamp
* Redirects
* "Edit this article" footer links
* `rel=canonical` tags
* Atom feed
* Single theme
* Responsive design
* PageSpeed Insights score of 100

## Create a blog

```
go get github.com/statusok/statusok/gen
gen blog example-blog
cd example-blog
```

## Write

```
gen article example-article
```

Edit `articles/example-article.md` in your favorite editor.

Preview with your favorite Markdown previewer.
Or, preview at <http://localhost:2000> with:

```
gen serve
```

Add images to the `public/images` directory.
Refer to them in articles via relative path:

```md
![](images/example.png)
```

## Configure

Configure blog in `gen.json`:

```json
{
  "articles": [
    {
      "id": "article-with-minimum-required-elements",
      "published": "2018-04-15"
    },
    {
      "author_ids": [
        "alice",
      ],
      "id": "article-with-single-author",
      "published": "2018-04-01"
    },
    {
      "id": "article-with-tags",
      "published": "2018-03-15",
      "tags": [
        "go",
        "unix"
      ]
    },
    {
      "author_ids": [
        "alice",
        "bob"
      ],
      "id": "article-with-multiple-authors",
      "published": "2018-03-01"
    },
    {
      "id": "article-with-updated-date",
      "published": "2018-02-15",
      "updated": "2018-02-20"
    },
    {
      "id": "article-with-redirects-from-previous-ids",
      "published": "2018-02-01",
      "redirects": [
        "/article-original",
        "/article-renamed-again"
      ]
    },
    {
      "canonical": "https://seo.example.com/avoid-duplicate-content-penalty",
      "id": "article-with-rel-canonical",
      "published": "2018-01-15"
    }
  ],
  "authors": [
    {
      "id": "alice",
      "name": "Alice",
      "url": "https://example.com/alice"
    },
    {
      "id": "bob",
      "name": "Bob",
      "url": "https://example.com/bob"
    }
  ],
  "name": "Example Blog",
  "source_url": "https://github.com/example/example/tree/master",
  "url": "https://blog.example.com"
}
```

## Publish

Configure [Netlify] with these settings:

[Netlify]: https://www.netlify.com

* Repository: `https://github.com/example/example`
* Branch: `master`
* Build Cmd: `go get github.com/statusok/statusok/gen && $GOPATH/bin/gen build`
* Public folder: `public`

To publish articles, commit to the GitHub repo:

```
git add --all
git commit --verbose
git push
```

View deploy logs in the Netlify web interface.

## Get help

Open a [GitHub Issue][issues].
Read [contribution instructions][contrib]
and [MIT License][license].

[issues]: https://github.com/statusok/statusok/issues
[contrib]: CONTRIBUTING.md
[license]: ../LICENSE
