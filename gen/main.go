package main

import (
	"fmt"
	"os"

	"gopkg.in/urfave/cli.v1" // imports as package "cli"
)

var port string

func main() {
	app := cli.NewApp()
	app.Name = "gen"
	app.Usage = "Generate a static blog."
	app.Version = "0.0.0"

	app.Commands = []cli.Command{
		{
			Action: initCommand,
			Name:   "init",
			Usage:  "initialize site's directory structure",
		},
		{
			Name:   "local",
			Usage:  "serve site locally",
			Action: localCommand,
			Flags: []cli.Flag{
				cli.StringFlag{
					Destination: &port,
					Name:        "port, p",
					Usage:       "port number to listen on (defaults to 2000)",
				},
			},
		},
		{
			Name:   "new",
			Usage:  "create a new article",
			Action: newCommand,
		},
		{
			Action: buildCommand,
			Name:   "build",
			Usage:  "build site to HTML",
		},
	}

	app.Run(os.Args)
}

func initCommand(c *cli.Context) error {
	if c.NArg() > 1 {
		return cli.NewExitError(
			"Error: <site-directory-name> can't contain spaces",
			1,
		)
	}

	name := c.Args().First()
	if name == "" {
		return cli.NewExitError("Usage: gen init <site-directory-name>", 1)
	}

	Init(name)
	return nil
}

func localCommand(c *cli.Context) error {
	dir, err := os.Getwd()
	if err != nil {
		fmt.Println("[gen] Error:", err)
		return err
	}

	if port == "" {
		port = "2000"
	}

	s := NewSite(dir)
	s.Serve(port)
	return nil
}

func newCommand(c *cli.Context) error {
	if c.NArg() > 1 {
		return cli.NewExitError(
			"Error: <article-url-slug> can't contain spaces",
			1,
		)
	}

	name := c.Args().First()
	if name == "" {
		return cli.NewExitError("Usage: gen new <article-url-slug>", 1)
	}

	dir, _ := os.Getwd()
	s := Site{RootDir: dir}
	s.InitArticle(name)
	return nil
}

func buildCommand(c *cli.Context) {
	dir, _ := os.Getwd()
	s := Site{RootDir: dir}
	s.Build()
}
