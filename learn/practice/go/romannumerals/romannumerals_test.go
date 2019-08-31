package romannumerals

import "testing"

type romanNumeralTest struct {
	arabic   int
	roman    string
	hasError bool
}

var romanNumeralTests = []romanNumeralTest{
	{1, "I", false},
	{2, "II", false},
	{3, "III", false},
	{4, "IV", false},
	{5, "V", false},
	{6, "VI", false},
	{9, "IX", false},
	{27, "XXVII", false},
	{48, "XLVIII", false},
	{49, "XLIX", false},
	{59, "LIX", false},
	{93, "XCIII", false},
	{141, "CXLI", false},
	{163, "CLXIII", false},
	{402, "CDII", false},
	{575, "DLXXV", false},
	{911, "CMXI", false},
	{1024, "MXXIV", false},
	{3000, "MMM", false},
}

func TestRomanNumerals(t *testing.T) {
	tc := append(romanNumeralTests, []romanNumeralTest{
		{0, "", true},
		{-1, "", true},
		{3001, "MMMI", false},
	}...)

	for _, test := range tc {
		actual, err := ToRomanNumeral(test.arabic)
		if err == nil && test.hasError {
			t.Errorf("ToRomanNumeral(%d) should return an error.", test.arabic)
			continue
		}
		if err != nil && !test.hasError {
			var _ error = err
			t.Errorf("ToRomanNumeral(%d) should not return an error.", test.arabic)
			continue
		}
		if !test.hasError && actual != test.roman {
			t.Errorf("ToRomanNumeral(%d): %s, expected %s", test.arabic, actual, test.roman)
		}
	}
}

func BenchmarkRomanNumerals(b *testing.B) {
	for i := 0; i < b.N; i++ {
		for _, test := range romanNumeralTests {
			ToRomanNumeral(test.arabic)
		}
	}
}
