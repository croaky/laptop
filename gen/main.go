/*

Command gen generates a static blog.

Initialize blog:

  gen blog <blog-directory-name>

Create an article:

  gen article <article-url-slug>

Run a local server:

  gen serve

Build static HTML to `public/`:

  gen build

*/
package main

import (
	"fmt"
	"log"
	"os"
)

func main() {
	if len(os.Args) < 2 {
		usage()
	}
	switch os.Args[1] {
	case "blog":
		if len(os.Args) != 3 {
			usage()
		}
		name := os.Args[2]
		Init(name)
	case "article":
		if len(os.Args) != 3 {
			usage()
		}
		name := os.Args[2]
		dir, err := os.Getwd()
		if err != nil {
			log.Fatal(err)
		}
		NewSite(dir).InitArticle(name)
	case "serve":
		dir, err := os.Getwd()
		if err != nil {
			log.Fatal(err)
		}
		NewSite(dir).Serve("2000")
	case "build":
		dir, err := os.Getwd()
		if err != nil {
			log.Fatal(err)
		}
		NewSite(dir).Build()
	default:
		usage()
	}
}

func usage() {
	fmt.Fprint(os.Stderr, usageString)
	os.Exit(2)
}

const usageString = `usage:
  gen blog <blog-directory-name>
  gen article <article-url-slug>
  gen serve
  gen build
`
