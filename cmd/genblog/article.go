package main

import (
	"bytes"
	"fmt"
	"html/template"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/russross/blackfriday"
)

// Article contains article data
type Article struct {
	AuthorIDs []string `json:"author_ids"`
	Canonical string   `json:"canonical,omitempty"`
	ID        string   `json:"id"`
	Published string   `json:"published"`
	Redirects []string `json:"redirects,omitempty"`
	Tags      []string `json:"tags,omitempty"`
	Updated   string   `json:"updated,omitempty"`
	Blog      *Blog    `json:"-"`
}

// CreateArticle creates a new Article
func CreateArticle(id string, blog *Blog) {
	author := NewAuthor()
	article := Article{
		AuthorIDs: []string{author.ID},
		ID:        id,
		Published: time.Now().Format("2006-01-02"),
		Blog:      blog,
	}
	blog.Articles = append([]Article{article}, blog.Articles...)
	newAuthor := true
	for _, a := range blog.Authors {
		if a.ID == author.ID {
			newAuthor = false
		}
	}
	if newAuthor {
		blog.Authors = append([]Author{author}, blog.Authors...)
	}

	err := os.Mkdir(blog.articlesDir(), os.ModePerm)
	if err != nil && !strings.Contains(err.Error(), "file exists") {
		fmt.Println("error: " + err.Error())
		os.Exit(1)
	}

	f, err := os.Create(blog.articlesDir() + "/" + id + ".md")
	check(err)
	defer f.Close()

	noDashes := strings.Replace(id, "-", " ", -1)
	noUnderscores := strings.Replace(noDashes, "_", " ", -1)
	title := strings.Title(noUnderscores)

	_, err = f.WriteString("# " + title + "\n\n\n")
	check(err)
	f.Sync()
}

// Build templatizes article to a file on disk in public/
func (a *Article) Build(blog *Blog) {
	f, err := os.Create(a.publicPath())
	check(err)
	a.Blog = blog
	buildArticlePage(f, a)
}

// Serve templatizes article to an HTTP respose
func (a *Article) Serve(w http.ResponseWriter, blog *Blog) {
	if a.Title() == "" {
		fmt.Fprintf(w, "404")
	} else {
		a.Blog = blog
		buildArticlePage(w, a)
	}
}

// Title of article
func (a *Article) Title() string {
	return string(a.input()[2:a.indexFirstLineBreak()])
}

// Body is the HTML for the body text of the article, minus the Title
func (a *Article) Body() template.HTML {
	body := a.input()[a.indexFirstLineBreak():]
	markdown := blackfriday.Run(body)
	return template.HTML(markdown)
}

// Authors is a slice of Author structs
func (a *Article) Authors() []Author {
	authors := make([]Author, len(a.AuthorIDs))
	for index, id := range a.AuthorIDs {
		authors[index] = a.Blog.findAuthor(id)
	}
	return authors
}

// LastUpdated is Updated if present, otherwise Published
func (a *Article) LastUpdated() string {
	if a.Updated != "" {
		return a.Updated
	}
	return a.Published
}

// LastUpdatedIn formats LastUpdated as 2006 January
func (a *Article) LastUpdatedIn() string {
	t, err := time.Parse("2006-01-02", a.LastUpdated())
	if err != nil {
		return ""
	}
	return t.Format("2006 January")
}

// LastUpdatedOn formats Updated as January 2, 2006
func (a *Article) LastUpdatedOn() string {
	t, err := time.Parse("2006-01-02", a.LastUpdated())
	if err != nil {
		return ""
	}
	return t.Format("January 2, 2006")
}

func (a *Article) srcPath() string {
	return "articles/" + a.ID + ".md"
}

func (a *Article) publicPath() string {
	return "public/" + a.ID + ".html"
}

func (a *Article) input() []byte {
	input, err := ioutil.ReadFile(a.srcPath())
	if err != nil {
		input = []byte("")
	}
	return input
}

func (a *Article) indexFirstLineBreak() int {
	return bytes.Index(a.input(), []byte("\n"))
}
