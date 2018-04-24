/*

Command gen generates a static blog.

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
	"os"
)

func main() {
	if len(os.Args) < 2 {
		usage()
	}
	blog := currentBlog()
	switch os.Args[1] {
	case "article":
		if len(os.Args) != 3 {
			usage()
		}
		CreateArticle(os.Args[2], blog)
		blog.writeConfig()
		fmt.Println("[gen] Created article at ./articles/" + os.Args[2] + ".md")
	case "serve":
		blog := currentBlog()
		fmt.Println("[gen] Serving blog at http://localhost:2000")
		blog.Serve("2000")
	case "build":
		blog := currentBlog()
		blog.Build()
		fmt.Println("[gen] Built blog at ./public")
	default:
		usage()
	}
}

func currentBlog() *Blog {
	dir, err := os.Getwd()
	must(err)
	blog := &Blog{RootDir: dir}
	blog.loadConfig()
	return blog
}

func usage() {
	fmt.Fprint(os.Stderr, usageString)
	os.Exit(2)
}

const usageString = `usage:
  gen article <article-url-slug>
  gen serve
  gen build
`
