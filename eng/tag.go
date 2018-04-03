package eng

// Tag is a unique name for articles in a site
type Tag struct {
	Name string
	Site *Site
}

// Articles with the tag
func (t *Tag) Articles() []Article {
	var aa []Article
	for _, a := range t.Site.Articles {
		for _, tag := range a.Tags {
			if t.Name == tag {
				aa = append(aa, a)
			}
		}
	}

	return aa
}
