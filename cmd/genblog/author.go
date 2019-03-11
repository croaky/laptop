package main

import "os/user"

// Author is an author of articles
type Author struct {
	ID   string `json:"id"`
	Name string `json:"name"`
	URL  string `json:"url"`
}

// NewAuthor constructs a new author
func NewAuthor() Author {
	id, name := NewAuthorIDs()
	return Author{
		ID:   id,
		Name: name,
		URL:  "https://author.example.com",
	}
}

// NewAuthorIDs constructs a new author ID and name
func NewAuthorIDs() (id, name string) {
	u, err := user.Current()
	check(err)
	if u.Name == "" {
		name = "Your Name"
	} else {
		name = u.Name
	}
	return u.Username, name
}
