package eng

import "os/user"

// Author is an author of articles
type Author struct {
	ID   string `json:"id"`
	Name string `json:"name"`
	URL  string `json:"url"`
}

// NewAuthor constructs a new author
func NewAuthor() Author {
	return Author{
		ID:   NewAuthorID(),
		Name: "Your Name",
		URL:  "https://author.example.com",
	}
}

// NewAuthorID constructs a new author ID
func NewAuthorID() string {
	u, err := user.Current()
	printError(err)

	return u.Name
}
