package eng

import (
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"path"
	"strings"
	"time"

	"github.com/gorilla/feeds"
)

// Site is an Eng project
type Site struct {
	Articles  []Article `json:"articles"`
	Authors   []Author  `json:"authors"`
	Name      string    `json:"name"`
	RootDir   string    `json:"-"`
	SourceURL string    `json:"source_url,omitempty"`
	URL       string    `json:"url"`
}

// NewSite constructs a new site from root directory
// and eng.json config file within root directory
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

	err := s.createRootDir()
	printError(err)

	err = s.createConfigFile()
	printError(err)

	err = s.createREADME()
	printError(err)

	err = s.createArticlesDir()
	printError(err)

	return nil
}

// Build the HTML for the Eng site.
func (s *Site) Build() {
	s.loadConfig(nil)

	err := s.createPublicDirs()
	printError(err)

	f, err := os.Create("public/index.html")
	if err != nil {
		printError(err)
	} else {
		indexToHTML(f, s)
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
	fmt.Println("[eng] Serving site at http://localhost:" + port)
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
	config, err := ioutil.ReadFile(s.RootDir + "/eng.json")
	if err != nil {
		fmt.Println("[eng] Warning: no eng.json config file")
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

	err = ioutil.WriteFile(s.RootDir+"/eng.json", config, 0644)
	if err != nil {
		fmt.Println("[eng] Warning: no eng.json config file")
	}
}

func (s *Site) handler(w http.ResponseWriter, r *http.Request) {
	s.loadConfig(nil)
	fmt.Println("[eng] " + r.Method + " " + r.URL.Path)
	switch {
	case r.URL.Path == "/":
		indexToHTML(w, s)
	case r.URL.Path == "/feed.atom":
		indexToAtom(w, s)
	case r.URL.Path == "/favicon.ico":
		// no-op
	case strings.HasPrefix(r.URL.Path, "/tags/"):
		_, name := path.Split(r.URL.Path)
		tag := Tag{Name: name, Site: s}
		tagIndexToHTML(w, &tag)
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

func (s *Site) createRootDir() error {
	return os.Mkdir(s.RootDir, os.ModePerm)
}

func (s *Site) createConfigFile() error {
	return s.executeTemplate("eng.json", s)
}

func (s *Site) createREADME() error {
	return s.executeTemplate("README.md", s)
}

func (s *Site) createArticlesDir() error {
	return os.Mkdir(s.articlesDir(), os.ModePerm)
}

func (s *Site) createPublicDirs() error {
	return os.MkdirAll(s.RootDir+"/public/tags", os.ModePerm)
}

func (s *Site) createRedirects() error {
	f, err := os.Create("public/_redirects")
	printError(err)

	tmpl := parseTextTemplate("_redirects")

	return tmpl.Execute(f, s)
}

func (s *Site) executeTemplate(name string, data interface{}) error {
	f, err := os.Create(s.RootDir + "/" + name)
	printError(err)

	tmpl := parseTextTemplate(name)

	return tmpl.Execute(f, data)
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
