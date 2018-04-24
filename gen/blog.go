package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"path"
	"strings"
	"text/template"
)

// Blog is a Gen project
type Blog struct {
	Articles  []Article `json:"articles"`
	Authors   []Author  `json:"authors"`
	Name      string    `json:"name"`
	RootDir   string    `json:"-"`
	SourceURL string    `json:"source_url,omitempty"`
	URL       string    `json:"url"`
}

// Build HTML for the blog.
func (blog *Blog) Build() {
	must(os.MkdirAll(blog.RootDir+"/public/tags", os.ModePerm))

	f, err := os.Create("public/index.html")
	must(err)
	must(indexPage.Execute(f, blog))

	f, err = os.Create("public/feed.atom")
	must(err)
	indexAtom(f, blog)

	for _, a := range blog.Articles {
		a.Build(blog)
	}

	for t := range blog.Tags() {
		tag := Tag{Name: t, Blog: blog}
		tag.Build()
	}

	must(blog.createRedirects())
}

// Serve the blog over HTTP
func (blog *Blog) Serve(port string) {
	http.HandleFunc("/", blog.handler)
	http.ListenAndServe(":"+port, nil)
}

// Tags is a collection of blog tags and their counts
func (blog *Blog) Tags() map[string]int {
	tt := make(map[string]int)
	for _, a := range blog.Articles {
		for _, t := range a.Tags {
			if i, ok := tt[t]; ok {
				tt[t] = i + 1
			} else {
				tt[t] = 1
			}
		}
	}

	return tt
}

func (blog *Blog) loadConfig() {
	config, err := ioutil.ReadFile(blog.RootDir + "/gen.json")
	must(err)
	must(json.Unmarshal(config, &blog))
}

func (blog *Blog) writeConfig() {
	config, err := json.MarshalIndent(blog, "", "  ")
	must(err)
	must(ioutil.WriteFile(blog.RootDir+"/gen.json", config, 0644))
}

func (blog *Blog) handler(w http.ResponseWriter, r *http.Request) {
	blog.loadConfig()
	fmt.Println("[gen] " + r.Method + " " + r.URL.Path)
	switch {
	case r.URL.Path == "/":
		must(indexPage.Execute(w, blog))
	case r.URL.Path == "/feed.atom":
		indexAtom(w, blog)
	case r.URL.Path == "/favicon.ico":
		// no-op
	case strings.HasPrefix(r.URL.Path, "/tags/"):
		_, name := path.Split(r.URL.Path)
		tag := Tag{Name: name, Blog: blog}
		must(tagPage.Execute(w, &tag))
	case strings.HasPrefix(r.URL.Path, "/images/"):
		_, filename := path.Split(r.URL.Path)
		image := blog.RootDir + "/public/images/" + filename
		http.ServeFile(w, r, image)
	default:
		article := blog.findArticle(r.URL.Path[1:])
		article.Serve(w, blog)
	}
}

func (blog *Blog) findAuthor(id string) Author {
	for _, a := range blog.Authors {
		if a.ID == id {
			return a
		}
	}
	return Author{ID: id}
}

func (blog *Blog) findArticle(id string) Article {
	for _, a := range blog.Articles {
		if a.ID == id {
			return a
		}
	}
	return Article{}
}

func (blog *Blog) createRedirects() error {
	f, err := os.Create(blog.RootDir + "/public/_redirects")
	must(err)

	tmpl := template.Must(
		template.
			New("redirects").
			Parse(`{{ range $article := .Articles -}}
{{ range .Redirects -}}
{{ . }} /{{ $article.ID }}
{{ end -}}
{{ end -}}
`),
	)
	return tmpl.Execute(f, blog)
}

func (blog *Blog) articlesDir() string {
	return blog.RootDir + "/articles"
}
