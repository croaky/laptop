package eng

import (
	"bytes"
	"html/template"
	"io"

	text "text/template"

	"github.com/GeertJohan/go.rice"
)

func templatizeArticle(w io.Writer, a *Article) {
	t := parseHTMLTemplates("article.html", "style.html", "favicon.html")
	err := t.Execute(w, a)
	printError(err)
}

func indexToHTML(w io.Writer, s *Site) {
	t := parseHTMLTemplates("index.html", "style.html", "favicon.html")
	err := t.Execute(w, s)
	printError(err)
}

func parseHTMLTemplates(filenames ...string) *template.Template {
	var names bytes.Buffer
	var content bytes.Buffer
	templateBox := rice.MustFindBox("templates")

	for _, filename := range filenames {
		s, err := templateBox.String(filename)
		printError(err)
		content.WriteString(s)
		names.WriteString(filename)
	}

	return template.Must(template.New(names.String()).Parse(content.String()))
}

func parseTextTemplate(filename string) *text.Template {
	templateBox := rice.MustFindBox("templates")
	s, err := templateBox.String(filename)
	printError(err)

	return text.Must(text.New(filename).Parse(s))
}
