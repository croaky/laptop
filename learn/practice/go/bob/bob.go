// Package bob acts like a lackadaisical teenager.
// In conversation, Bob's responses are very limited.
package bob

import (
	"regexp"
	"strings"
)

// Hey accepts a remark to Bob and returns Bob's response.
func Hey(remark string) string {
	s := strings.TrimSpace(remark)
	if s == "" {
		return "Fine. Be that way!"
	}
	if yell(s) && anyLetters(s) {
		if question(s) {
			return "Calm down, I know what I'm doing!"
		}
		return "Whoa, chill out!"
	}
	if question(s) {
		return "Sure."
	}
	return "Whatever."
}

func yell(s string) bool {
	return s == strings.ToUpper(s)
}

func anyLetters(s string) bool {
	return regexp.MustCompile(`[A-Za-z]+`).MatchString(s)
}

func question(s string) bool {
	return strings.HasSuffix(s, "?")
}
