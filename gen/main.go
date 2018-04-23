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
		Init(os.Args[2])
	case "article":
		if len(os.Args) != 3 {
			usage()
		}
		dir, err := os.Getwd()
		if err != nil {
			log.Fatal(err)
		}
		blog := &Blog{RootDir: dir}
		blog.loadConfig()
		blog.InitArticle(os.Args[2])
	case "serve":
		dir, err := os.Getwd()
		if err != nil {
			log.Fatal(err)
		}
		blog := &Blog{RootDir: dir}
		blog.loadConfig()
		blog.Serve("2000")
	case "build":
		dir, err := os.Getwd()
		if err != nil {
			log.Fatal(err)
		}
		blog := &Blog{RootDir: dir}
		blog.Build()
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
