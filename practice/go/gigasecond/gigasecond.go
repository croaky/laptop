// Package gigasecond calculates the gigasecond since a date.
package gigasecond

import "time"

// AddGigasecond increments a date by 1,000,000,000 seconds.
func AddGigasecond(t time.Time) time.Time {
	return t.Add(time.Second * 1000000000)
}
