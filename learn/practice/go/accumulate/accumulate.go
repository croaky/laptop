package accumulate

// Accumulate accepts a slice of strings and converts them by converter
func Accumulate(given []string, converter func(string) string) []string {
	var expected []string
	for _, v := range given {
		expected = append(expected, converter(v))
	}
	return expected
}
