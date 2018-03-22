package gigasecond

import (
	"testing"
	"time"
)

const (
	fmtD  = "2006-01-02"
	fmtDT = "2006-01-02T15:04:05"
)

func TestAddGigasecond(t *testing.T) {
	for _, tc := range addCases {
		in := parse(tc.in, t)
		want := parse(tc.want, t)
		got := AddGigasecond(in)
		if !got.Equal(want) {
			t.Fatalf(`FAIL: %s
AddGigasecond(%s)
   = %s
want %s`, tc.description, in, got, want)
		}
		t.Log("PASS:", tc.description)
	}
	t.Log("Tested", len(addCases), "cases.")
}

func parse(s string, t *testing.T) time.Time {
	tt, err := time.Parse(fmtDT, s)
	if err != nil {
		tt, err = time.Parse(fmtD, s)
	}
	return tt
}

func BenchmarkAddGigasecond(b *testing.B) {
	for i := 0; i < b.N; i++ {
		AddGigasecond(time.Time{})
	}
}
