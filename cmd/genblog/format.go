package main

import (
	"strings"

	"github.com/russross/blackfriday"
)

func toTitle(s string) string {
	noDashes := strings.Replace(s, "-", " ", -1)
	noUnderscores := strings.Replace(noDashes, "_", " ", -1)
	return strings.Title(noUnderscores)
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
