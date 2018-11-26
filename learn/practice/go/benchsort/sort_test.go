package sort

import "testing"

var items = []int{
	4, 202, 3, 9, 6, 5, 1, 43, 506, 2, 0, 8, 7, 100, 25, 4, 5, 97, 1000, 27,
}

func BenchmarkBubble(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Bubble(items)
	}
}

func BenchmarkSelection(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Selection(items)
	}
}

func BenchmarkInsertion(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Insertion(items)
	}
}

func BenchmarkShell(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Shell(items)
	}
}

func BenchmarkComb(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Comb(items)
	}
}

func BenchmarkMerge(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Merge(items)
	}
}
