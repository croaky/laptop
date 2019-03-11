/*

Command genblog generates a static blog.

Create an article:

  genblog article <article-url-slug>

Run a local server:

  genblog serve

Build static HTML to `public/`:

  genblog build

*/
package main

import (
	"fmt"
	"os"
)

var wd string

func main() {
	if len(os.Args) < 2 {
		usage()
	}
	var err error
	wd, err = os.Getwd()
	check(err)

	blog := currentBlog()
	switch os.Args[1] {
	case "article":
		if len(os.Args) != 3 {
			usage()
		}
		CreateArticle(os.Args[2], blog)
		blog.writeConfig()
		fmt.Println("genblog: Created article at ./articles/" + os.Args[2] + ".md")
	case "serve":
		blog := currentBlog()
		fmt.Println("genblog: Serving blog at http://localhost:2000")
		blog.Serve("2000")
	case "build":
		blog := currentBlog()
		blog.Build()
		fmt.Println("genblog: Built blog at ./public")
	default:
		usage()
	}
}

func currentBlog() *Blog {
	dir, err := os.Getwd()
	check(err)
	blog := &Blog{RootDir: dir}
	blog.loadConfig()
	return blog
}

func usage() {
	const s = `usage:
  genblog article <article-url-slug>
  genblog serve
  genblog build
`
	fmt.Fprint(os.Stderr, s)
	os.Exit(2)
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}
