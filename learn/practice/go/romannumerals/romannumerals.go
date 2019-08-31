package romannumerals

import "fmt"

// ToRomanNumeral converts Arabic integers to Roman Numerals, or errors
func ToRomanNumeral(arabic int) (string, error) {
	conversions := []struct {
		arabic int
		roman  string
	}{
		{1000, "M"},
		{900, "CM"},
		{500, "D"},
		{400, "CD"},
		{100, "C"},
		{90, "XC"},
		{50, "L"},
		{40, "XL"},
		{10, "X"},
		{9, "IX"},
		{5, "V"},
		{4, "IV"},
		{1, "I"},
	}
	romanized := ""

	for _, c := range conversions {
		for arabic >= c.arabic {
			romanized += c.roman
			arabic -= c.arabic
		}
	}

	if romanized == "" {
		return "", fmt.Errorf("%v could not be converted to Roman numeral", arabic)
	}

	return romanized, nil
}
