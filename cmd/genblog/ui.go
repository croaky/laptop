package main

import (
	"encoding/json"
	"html/template"
	"io"
	"strings"
	"time"

	"github.com/kr/jsonfeed"
)

var indexPage = template.Must(template.ParseFiles(wd + "/ui/index.html"))
var articlePage = template.Must(template.ParseFiles(wd + "/ui/article.html"))
var tagPage = template.Must(template.ParseFiles(wd + "/ui/tag.html"))

func indexFeed(w io.Writer, blog *Blog) {
	feed := jsonfeed.Feed{
		Title:       blog.Name,
		HomePageURL: blog.URL,
		FeedURL:     blog.URL + "/feed.json",
	}

	feed.Items = make([]jsonfeed.Item, len(blog.Articles))

	for i, a := range blog.Articles {
		a.Blog = blog
		item := jsonfeed.Item{
			ID:          blog.URL + "/" + a.ID,
			URL:         blog.URL + "/" + a.ID,
			Title:       a.Title(),
			ContentHTML: string(a.Body()),
			Tags:        a.Tags,
		}

		published, err := time.Parse("2006-01-02", a.Published)
		if err == nil {
			item.DatePublished = published
		}

		updated, err := time.Parse("2006-01-02", a.LastUpdated())
		if err == nil {
			item.DateModified = updated
		}

		authors := a.Authors()

		if len(authors) == 1 {
			item.Author = &jsonfeed.Author{
				Name: authors[0].Name,
				URL:  authors[0].URL,
			}
		}

		if len(authors) > 1 {
			var names []string
			for _, author := range authors {
				names = append(names, author.Name)
			}
			name := strings.Join(names, " and ")
			item.Author = &jsonfeed.Author{Name: name}
		}

		feed.Items[i] = item
	}

	check(json.NewEncoder(w).Encode(&feed))
}
