package main

import "testing"

func TestXxx(t *testing.T) {
	a := NewAuthor()
	id, name := NewAuthorIDs()

	if a.ID != id {
		t.Error("Expected author ID to be `whoami` but was nil")
	}
	if a.Name != name {
		t.Error("Expected author name to be 'Your Name' but was ", a.Name)
	}
	if a.URL != "https://author.example.com" {
		t.Error(
			"Expected author URL to be 'https://author.example.com' but was ",
			a.URL,
		)
	}
}
