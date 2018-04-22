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
	case "init":
		if len(os.Args) != 3 {
			usage()
		}
		name := os.Args[2]
		Init(name)
	case "new":
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
  gen init <site-directory-name>
  gen new <article-url-slug>
  gen serve
  gen build
`
