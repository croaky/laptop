package main

import "os"

// Tag is a unique name for articles in a site
type Tag struct {
	Name string
	Site *Site
}

// Articles with the tag
func (t *Tag) Articles() []Article {
	var aa []Article
	for _, a := range t.Site.Articles {
		for _, tag := range a.Tags {
			if t.Name == tag {
				aa = append(aa, a)
			}
		}
	}

	return aa
}

// Build templatizes tag to a file on disk in public/
func (t *Tag) Build() {
	f, err := os.Create(t.publicPath())
	if err != nil {
		printError(err)
	} else {
		tagIndexToHTML(f, t)
	}
}

func (t *Tag) publicPath() string {
	return "public/tags/" + t.Name + ".html"
}
