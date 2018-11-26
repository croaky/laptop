package main

// Given a collection of intervals,
// merge all overlapping intervals.

import (
	"fmt"
	"reflect"
	"sort"
)

type byFirstElement [][]int

func (a byFirstElement) Len() int {
	return len(a)
}
func (a byFirstElement) Swap(i, j int) {
	a[i], a[j] = a[j], a[i]
}
func (a byFirstElement) Less(i, j int) bool {
	return a[i][0] < a[j][0]
}

func main() {
	input := [][]int{{1, 3}, {8, 10}, {2, 6}, {15, 18}}
	want := [][]int{{1, 6}, {8, 10}, {15, 18}}

	sort.Sort(byFirstElement(input))
	var prev []int
	output := [][]int{}

	for _, pair := range input {
		if len(prev) == 0 {
			prev = pair
			continue
		}
		if prev[1] > pair[0] { // overlaps
			a := pair[0]
			if prev[0] < pair[0] {
				a = prev[0]
			}
			b := pair[1]
			if prev[1] > pair[1] {
				b = prev[1]
			}
			output = append(output, []int{a, b})
		} else {
			output = append(output, pair)
		}
		prev = pair
	}

	fmt.Println(reflect.DeepEqual(output, want))
}
