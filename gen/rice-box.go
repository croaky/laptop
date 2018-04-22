package main

import (
	"github.com/GeertJohan/go.rice/embedded"
	"time"
)

func init() {

	// define files
	file2 := &embedded.EmbeddedFile{
		Filename:    ".gitignore",
		FileModTime: time.Unix(1524336948, 0),
		Content:     string("public/*\n!public/images\n"),
	}
	file3 := &embedded.EmbeddedFile{
		Filename:    "README.md",
		FileModTime: time.Unix(1524411818, 0),
		Content:     string("# {{.Name}}\n\nA static blog.\n\n## Workflow\n\nSee [documentation][docs].\n\n[docs]: https://github.com/statusok/statusok/tree/master/gen\n"),
	}
	file4 := &embedded.EmbeddedFile{
		Filename:    "_redirects",
		FileModTime: time.Unix(1487054607, 0),
		Content:     string("{{ range $article := .Articles -}}\n{{ range .Redirects -}}\n{{ . }} /{{ $article.ID }}\n{{ end -}}\n{{ end -}}\n"),
	}
	file5 := &embedded.EmbeddedFile{
		Filename:    "article.html",
		FileModTime: time.Unix(1523837791, 0),
		Content:     string("<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n  <meta charset=\"utf-8\" />\n  <meta http-equiv=\"x-ua-compatible\" content=\"ie=edge\">\n  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n  <title>{{.Title}}</title>\n  <link rel=\"alternate\" href=\"feed.atom\" type=\"application/atom+xml\" />\n  {{- if .Canonical }}\n  <link rel=\"canonical\" href=\"{{.Canonical}}\">\n  {{- end }}\n  {{template \"style\" .}}\n  {{template \"favicon\" .}}\n</head>\n<body>\n  <div class=\"container\">\n    <nav>\n      <a href=\"/\">\n        {{.Site.Name}} &larr;\n      </a>\n    </nav>\n\n    <article>\n      <header class=\"lede\">\n        <h1 class=\"lede__headline\">{{.Title}}</h1>\n\n        <div class=\"lede__byline\">\n          {{- range .Authors }}\n            <div class=\"lede__author\">\n              <a href=\"{{.URL}}\" rel=\"author\">{{.Name}}</a>\n            </div>\n          {{- end }}\n\n          <time datetime=\"{{.LastUpdated}}\">\n            last updated {{.LastUpdatedOn}}\n          </time>\n        </div>\n      </header>\n      {{.Body}}\n    </article>\n\n    <footer>\n      {{- if .Site.SourceURL }}\n        <a href=\"{{.Site.SourceURL}}/articles/{{.ID}}.md\">Edit this article</a>\n      {{- end }}\n    </footer>\n  </div>\n</body>\n</html>\n"),
	}
	file6 := &embedded.EmbeddedFile{
		Filename:    "favicon.html",
		FileModTime: time.Unix(1517291315, 0),
		Content:     string("{{ define \"favicon\" -}}\n  <link rel=\"icon\" href=\"data:;base64,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\">\n{{- end }}\n"),
	}
	file7 := &embedded.EmbeddedFile{
		Filename:    "gen.json",
		FileModTime: time.Unix(1524411761, 0),
		Content:     string("{\n  \"authors\": [\n    {{- range .Authors }}\n    {\n      \"id\": \"{{.ID}}\",\n      \"name\": \"{{.Name}}\",\n      \"url\": \"{{.URL}}\"\n    }\n    {{- end }}\n  ],\n  \"name\": \"{{.Name}}\",\n  \"url\": \"{{.URL}}\"\n}\n"),
	}
	file8 := &embedded.EmbeddedFile{
		Filename:    "index.html",
		FileModTime: time.Unix(1523837836, 0),
		Content:     string("<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n  <meta charset=\"utf-8\" />\n  <meta http-equiv=\"x-ua-compatible\" content=\"ie=edge\">\n  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n  <title>{{.Name}}</title>\n  <link rel=\"alternate\" href=\"feed.atom\" type=\"application/atom+xml\" />\n  {{template \"style\" .}}\n  {{template \"favicon\" .}}\n</head>\n<body>\n  <div class=\"container\">\n    <nav>\n      {{.Name}}\n\n      {{- if .Tags }}\n        <div class=\"tags\">\n          {{- range $tag, $count := .Tags }}\n            <a href=\"/tags/{{$tag}}\">{{$tag}}</a>&nbsp;\n          {{- end }}\n        </div>\n      {{- end }}\n    </nav>\n\n    <main>\n      {{- range .Articles }}\n        <div class=\"index-article\">\n          <a href=\"/{{.ID}}\" class=\"index-article__link\">\n            {{.Title}}\n          </a>\n\n          <div class=\"index-article__byline\">\n            <time datetime=\"{{.LastUpdated}}\" class=\"index-article__published-on\">\n              {{.LastUpdatedIn}}\n            </time>\n          </div>\n        </div>\n      {{- end }}\n    <main>\n  </div>\n</body>\n</html>\n"),
	}
	file9 := &embedded.EmbeddedFile{
		Filename:    "style.html",
		FileModTime: time.Unix(1523856144, 0),
		Content:     string("{{ define \"style\" -}}\n<style>\n  body {\n    color: #3c3c3c;\n    font-family: -apple-system, BlinkMacSystemFont, \"Avenir Next\", \"Avenir\", \"Segoe UI\", \"Lucida Grande\", \"Helvetica Neue\", \"Helvetica\", \"Fira Sans\", \"Roboto\", \"Noto\", \"Droid Sans\", \"Cantarell\", \"Oxygen\", \"Ubuntu\", \"Franklin Gothic Medium\", \"Century Gothic\", \"Liberation Sans\", sans-serif;\n    font-size: 16px;\n    line-height: 22px;\n    -webkit-font-smoothing: antialiased;\n  }\n\n  a,\n  a:visited,\n  a:hover,\n  .index-article__link:hover {\n    border-bottom-color: #da393f;\n    border-bottom-style: solid;\n    border-bottom-width: 1px;\n    color: #3c3c3c;\n    text-decoration: none;\n    text-decoration-skip: ink;\n  }\n\n  a:hover {\n    color: #da393f;\n  }\n\n  .container {\n    margin: 1.5rem 1rem;\n    max-width: 700px;\n  }\n\n  @media all and (max-width: 575px) {\n    .container {\n      margin: 1rem 0;\n    }\n  }\n\n  img {\n    max-width: 100%;\n  }\n\n  article,\n  main {\n    margin: 1.5rem 0;\n  }\n\n  h2 {\n    line-height: 26px;\n    margin: 2rem 0 1.5rem;\n  }\n\n  p,\n  ul {\n    margin: 1rem 0;\n  }\n\n  li {\n    margin: 0.5rem 0;\n  }\n\n  nav .tags {\n    margin: 1.5rem 0 0.5rem 0;\n  }\n\n  .index-article {\n    margin: 1rem 0;\n  }\n\n  .index-article__link {\n    border-bottom: none;\n    font-size: 18px;\n    font-weight: bold;\n    line-height: 22px;\n    margin: 0;\n  }\n\n  .index-article__link:hover {\n    color: #3c3c3c;\n  }\n\n  .lede {\n    margin: 20px 0;\n  }\n\n  .lede__headline {\n    font-size: 32px;\n    line-height: 38px;\n    margin: 0;\n  }\n\n  .lede__byline {\n    line-height: 22px;\n    margin: 5px 0;\n  }\n\n  .lede__author {\n    margin-bottom: 0.25rem;\n  }\n\n  .lede__author a,\n  .lede__author a:visited {\n    font-weight: bold;\n    text-decoration: none;\n  }\n\n  pre {\n    background-color: #f7f7f7;\n    border-radius: 3px;\n    line-height: 1.5;\n    overflow-x: scroll;\n    padding: 10px;\n    word-wrap: normal;\n  }\n\n  code {\n    background-color: #f7f7f7;\n    font-family: \"SFMono-Regular\",Consolas,\"Liberation Mono\",Menlo,monospace;\n    font-size: 88%;\n    word-wrap: break-word;\n  }\n\n  :not(pre)>code {\n    margin: 0 0.05em;\n    padding: 3px 5px;\n  }\n\n  .meta-updated {\n    margin: 0 0.2em;\n  }\n\n  footer {\n    margin: 20px 0;\n  }\n</style>\n{{- end }}\n"),
	}
	filea := &embedded.EmbeddedFile{
		Filename:    "tag.html",
		FileModTime: time.Unix(1522727082, 0),
		Content:     string("<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n  <meta charset=\"utf-8\" />\n  <meta http-equiv=\"x-ua-compatible\" content=\"ie=edge\">\n  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n  <title>{{.Name}}</title>\n  <link rel=\"alternate\" href=\"feed.atom\" type=\"application/atom+xml\" />\n  {{template \"style\" .}}\n  {{template \"favicon\" .}}\n</head>\n<body>\n  <div class=\"container\">\n    <nav>\n      <a href=\"/\">\n        {{.Site.Name}} &larr;\n      </a>\n    </nav>\n\n    <article>\n      <header class=\"lede\">\n        <h1 class=\"lede__headline\">{{.Name}}</h1>\n      </header>\n    </article>\n\n    <main>\n      {{- range .Articles }}\n        <div class=\"index-article\">\n          <a href=\"/{{.ID}}\" class=\"index-article__link\">\n            {{.Title}}\n          </a>\n\n          <div class=\"index-article__byline\">\n            <time datetime=\"{{.LastUpdated}}\" class=\"index-article__published-on\">\n              {{.LastUpdatedIn}}\n            </time>\n          </div>\n        </div>\n      {{- end }}\n    <main>\n  </div>\n</body>\n</html>\n"),
	}

	// define dirs
	dir1 := &embedded.EmbeddedDir{
		Filename:   "",
		DirModTime: time.Unix(1524411761, 0),
		ChildFiles: []*embedded.EmbeddedFile{
			file2, // ".gitignore"
			file3, // "README.md"
			file4, // "_redirects"
			file5, // "article.html"
			file6, // "favicon.html"
			file7, // "gen.json"
			file8, // "index.html"
			file9, // "style.html"
			filea, // "tag.html"

		},
	}

	// link ChildDirs
	dir1.ChildDirs = []*embedded.EmbeddedDir{}

	// register embeddedBox
	embedded.RegisterEmbeddedBox(`templates`, &embedded.EmbeddedBox{
		Name: `templates`,
		Time: time.Unix(1524411761, 0),
		Dirs: map[string]*embedded.EmbeddedDir{
			"": dir1,
		},
		Files: map[string]*embedded.EmbeddedFile{
			".gitignore":   file2,
			"README.md":    file3,
			"_redirects":   file4,
			"article.html": file5,
			"favicon.html": file6,
			"gen.json":     file7,
			"index.html":   file8,
			"style.html":   file9,
			"tag.html":     filea,
		},
	})
}
