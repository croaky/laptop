# Blog

A static blog.

## Write

Generate an article:

```
./genblog article example-article
```

Edit `articles/example-article.md` in a text editor.
This is a pure Markdown file with no front matter.

The first line of the file is the article title.
It must be an `<h1>` tag:

```md
# Example Article
```

Preview at <http://localhost:2000> with:

```
./genblog serve
```

See the JSON feed at <http://localhost:2000/feed.json>.

Add images to the `public/images` directory.
Refer to them in articles via relative path:

```md
![alt text](images/example.png)
```

## Configure

Configure blog in `config.json`:

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
      "author_ids": [
        "alice",
        "bob"
      ],
      "id": "article-with-multiple-authors",
      "published": "2018-03-15"
    },
    {
      "id": "article-with-tags",
      "published": "2018-03-01",
      "tags": [
        "go",
        "unix"
      ]
    },
    {
      "id": "article-with-updated-date",
      "published": "2018-02-15",
      "updated": "2018-02-20"
    },
    {
      "id": "article-with-redirects",
      "published": "2018-02-01",
      "redirects": [
        "/article-original-name",
        "/article-renamed-again",
        "/this-feature-works-only-on-netlify",
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

Set `source_url` to get "Edit this article" footer links
to the article's Markdown file.

## Publish

Configure [Netlify](https://www.netlify.com):

* Repository: `https://github.com/example/example`
* Branch: `master`
* Build Cmd: `./genblog build`
* Public folder: `public`

To publish articles, commit to the GitHub repo:

```
git add --all
git commit --verbose
git push
```

View deploy logs in the Netlify web interface.

## Get help

View [releases].
Open a [GitHub Issue][issues].
Read [contribution instructions][contrib]
and [MIT License][license].

[releases]: https://github.com/statusok/statusok/releases
[issues]: https://github.com/statusok/statusok/issues
[contrib]: CONTRIBUTING.md
[license]: ../LICENSE
