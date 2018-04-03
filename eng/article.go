package eng

import (
	"bytes"
	"fmt"
	"html/template"
	"io/ioutil"
	"net/http"
	"os"
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
	Updated   string   `json:"updated"`
	Site      *Site    `json:"-"`
}

// NewArticle constructs a new Article
func NewArticle(id string) *Article {
	return &Article{
		ID: id,
	}
}

// Build templatizes article to a file on disk in public/
func (a *Article) Build(s *Site) {
	f, err := os.Create(a.publicPath())
	if err != nil {
		printError(err)
	} else {
		a.Site = s
		templatizeArticle(f, a)
	}
}

// Serve templatizes article to an HTTP respose
func (a *Article) Serve(w http.ResponseWriter, s *Site) {
	if a.Title() == "" {
		fmt.Fprintf(w, "404")
	} else {
		a.Site = s
		templatizeArticle(w, a)
	}
}

// Title of article
func (a *Article) Title() string {
	return string(a.input()[2:a.indexFirstLineBreak()])
}

// Body is the HTML for the body text of the article, minus the Title
func (a *Article) Body() template.HTML {
	bodyWithoutTitle := a.input()[a.indexFirstLineBreak():]
	return template.HTML(renderMarkdown(bodyWithoutTitle))
}

// Authors is a slice of Author structs
func (a *Article) Authors() []Author {
	authors := make([]Author, len(a.AuthorIDs))

	for index, id := range a.AuthorIDs {
		authors[index] = a.Site.findAuthor(id)
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

// LastUpdatedIn formats Updated as January 2, 2006
func (a *Article) LastUpdatedIn() string {
	t, err := time.Parse("2006-01-02", a.LastUpdated())
	if err != nil {
		return ""
	}
	return t.Format("2006 January")
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
		printError(err)
		input = []byte("")
	}
	return input
}

func (a *Article) indexFirstLineBreak() int {
	return bytes.Index(a.input(), []byte("\n"))
}

func renderMarkdown(input []byte) []byte {
	htmlRenderer := blackfriday.HtmlRenderer(0, "", "")
	extensions := 0
	extensions |= blackfriday.EXTENSION_AUTOLINK
	extensions |= blackfriday.EXTENSION_AUTO_HEADER_IDS
	extensions |= blackfriday.EXTENSION_FENCED_CODE
	extensions |= blackfriday.EXTENSION_NO_INTRA_EMPHASIS
	extensions |= blackfriday.EXTENSION_SPACE_HEADERS
	extensions |= blackfriday.EXTENSION_STRIKETHROUGH
	extensions |= blackfriday.EXTENSION_TABLES

	return blackfriday.Markdown(input, htmlRenderer, extensions)
}
