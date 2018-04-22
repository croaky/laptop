package main

import (
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"path"
	"strings"
	"text/template"
	"time"

	"github.com/gorilla/feeds"
)

// Site is a Gen project
type Site struct {
	Articles  []Article `json:"articles"`
	Authors   []Author  `json:"authors"`
	Name      string    `json:"name"`
	RootDir   string    `json:"-"`
	SourceURL string    `json:"source_url,omitempty"`
	URL       string    `json:"url"`
}

// NewSite constructs a new site from root directory
// and gen.json config file within root directory
func NewSite(name string) *Site {
	return &Site{
		Authors: []Author{NewAuthor()},
		Name:    toTitle(name),
		RootDir: name,
		URL:     "https://blog.example.com",
	}
}

// Init initializes a site
func Init(name string) error {
	s := NewSite(name)
	printError(os.Mkdir(s.RootDir, os.ModePerm))
	printError(os.Mkdir(s.articlesDir(), os.ModePerm))
	printError(os.MkdirAll(s.RootDir+"/public/images", os.ModePerm))
	printError(s.createREADME())
	printError(s.createGitIgnore())
	printError(s.createConfigFile())
	return nil
}

// Build HTML for the site.
func (s *Site) Build() {
	s.loadConfig(nil)

	printError(os.MkdirAll(s.RootDir+"/public/tags", os.ModePerm))

	f, err := os.Create("public/index.html")
	if err != nil {
		printError(err)
	} else {
		printError(indexPage.Execute(f, s))
	}

	f, err = os.Create("public/feed.atom")
	if err != nil {
		printError(err)
	} else {
		indexToAtom(f, s)
	}

	for _, a := range s.Articles {
		a.Build(s)
	}

	for t := range s.Tags() {
		tag := Tag{Name: t, Site: s}
		tag.Build()
	}

	s.createRedirects()
}

// Serve the site over HTTP
func (s *Site) Serve(port string) {
	s.loadConfig(&port)
	http.HandleFunc("/", s.handler)
	fmt.Println("[gen] Serving site at http://localhost:" + port)
	http.ListenAndServe(":"+port, nil)
}

// InitArticle initializes a new article
func (s *Site) InitArticle(slug string) error {
	f, err := os.Create(s.articlesDir() + "/" + slug + ".md")
	printError(err)
	defer f.Close()

	_, err = f.WriteString("# " + toTitle(slug) + "\n\n\n")
	if err != nil {
		printError(err)
		return err
	}
	f.Sync()
	s.loadConfig(nil)
	a := Article{
		AuthorIDs: []string{NewAuthorID()},
		ID:        slug,
		Published: time.Now().Format("2006-01-02"),
	}
	s.Articles = append([]Article{a}, s.Articles...)
	s.writeConfig()

	return nil
}

// Tags is a collection of site tags and their counts
func (s *Site) Tags() map[string]int {
	tt := make(map[string]int)
	for _, a := range s.Articles {
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

func (s *Site) loadConfig(port *string) {
	config, err := ioutil.ReadFile(s.RootDir + "/gen.json")
	if err != nil {
		fmt.Println("[gen] Warning: no gen.json config file")
		config = []byte("{}")
	}

	err = json.Unmarshal(config, &s)
	if err != nil {
		printError(err)
		panic(err)
	}

	if s.URL == "" {
		if port == nil {
			s.URL = "http://localhost:2000"
		} else {
			s.URL = "http://localhost:" + *port
		}
	}
}

func (s *Site) writeConfig() {
	config, err := json.MarshalIndent(s, "", "  ")
	if err != nil {
		printError(err)
		panic(err)
	}

	err = ioutil.WriteFile(s.RootDir+"/gen.json", config, 0644)
	if err != nil {
		fmt.Println("[gen] Warning: no gen.json config file")
	}
}

func (s *Site) handler(w http.ResponseWriter, r *http.Request) {
	s.loadConfig(nil)
	fmt.Println("[gen] " + r.Method + " " + r.URL.Path)
	switch {
	case r.URL.Path == "/":
		printError(indexPage.Execute(w, s))
	case r.URL.Path == "/feed.atom":
		indexToAtom(w, s)
	case r.URL.Path == "/favicon.ico":
		// no-op
	case strings.HasPrefix(r.URL.Path, "/tags/"):
		_, name := path.Split(r.URL.Path)
		tag := Tag{Name: name, Site: s}
		printError(tagPage.Execute(w, &tag))
	case strings.HasPrefix(r.URL.Path, "/images/"):
		_, filename := path.Split(r.URL.Path)
		image := s.RootDir + "/public/images/" + filename
		http.ServeFile(w, r, image)
	default:
		article := s.findArticle(r.URL.Path[1:])
		article.Serve(w, s)
	}
}

func (s *Site) findAuthor(id string) Author {
	for _, a := range s.Authors {
		if a.ID == id {
			return a
		}
	}

	return Author{ID: id}
}

func (s *Site) findArticle(id string) Article {
	for _, a := range s.Articles {
		if a.ID == id {
			return a
		}
	}

	return Article{}
}

func (s *Site) createRedirects() error {
	f, err := os.Create("public/_redirects")
	printError(err)

	tmpl := template.Must(
		template.
			New("redirects").
			Parse(`{{ range $article := .Articles -}}
{{ range .Redirects -}}
{{ . }} /{{ $article.ID }}
{{ end -}}
{{ end -}}`),
	)

	return tmpl.Execute(f, s)
}

func (s *Site) createREADME() error {
	f, err := os.Create(s.RootDir + "/README.md")
	printError(err)

	tmpl := template.Must(
		template.
			New("readme").
			Parse(`# {{.Name}}

A static blog.

## Workflow

See [documentation][docs].

[docs]: https://github.com/statusok/statusok/tree/master/gen`),
	)

	return tmpl.Execute(f, s)
}

func (s *Site) createGitIgnore() error {
	f, err := os.Create(s.RootDir + "/.gitignore")
	printError(err)

	tmpl := template.Must(
		template.
			New("gitignore").
			Parse(`public/*
!public/images`),
	)

	return tmpl.Execute(f, s)
}

func (s *Site) createConfigFile() error {
	f, err := os.Create(s.RootDir + "/gen.json")
	printError(err)

	tmpl := template.Must(
		template.
			New("gen").
			Parse(`{
  "authors": [
    {{- range .Authors }}
    {
      "id": "{{.ID}}",
      "name": "{{.Name}}",
      "url": "{{.URL}}"
    }
    {{- end }}
  ],
  "name": "{{.Name}}",
  "url": "{{.URL}}"
}`),
	)

	return tmpl.Execute(f, s)
}

func (s *Site) articlesDir() string {
	return s.RootDir + "/articles"
}

func toTitle(s string) string {
	noDashes := strings.Replace(s, "-", " ", -1)
	noUnderscores := strings.Replace(noDashes, "_", " ", -1)
	return strings.Title(noUnderscores)
}

func indexToAtom(w io.Writer, s *Site) {
	feed := feeds.Feed{
		Title:   s.Name,
		Link:    &feeds.Link{Href: s.URL},
		Updated: time.Now(),
	}

	for _, a := range s.Articles {
		published, err := time.Parse("2006-01-02", a.Published)

		if err == nil {
			item := &feeds.Item{
				Created: published,
				Link:    &feeds.Link{Href: s.URL + "/" + a.ID},
				Title:   a.Title(),
			}
			feed.Add(item)
		}
	}

	result, _ := feed.ToAtom()
	fmt.Fprintln(w, result)
}
