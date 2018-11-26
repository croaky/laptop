# Go Benchmarks for Sorting Algorithms

Benchmark common sorting algorithms written in Go.
Implementations are from [Sorting Algorithms Primer][primer].

[primer]: https://dave.cheney.net/2013/06/30/how-to-write-benchmarks-in-go

Run the benchmarks:

```
go test -bench=.
```

With the benchmark data:

```go
var items = []int{
  4, 202, 3, 9, 6, 5, 1, 43, 506, 2, 0, 8, 7, 100, 25, 4, 5, 97, 1000, 27,
}
```

The benchmarks are:

```
BenchmarkComb-4        100000000     14 ns/op
BenchmarkBubble-4       30000000     42 ns/op
BenchmarkInsertion-4     5000000    301 ns/op
BenchmarkSelection-4     3000000    491 ns/op
BenchmarkShell-4         2000000    564 ns/op
BenchmarkMerge-4          500000   2303 ns/op
```

TODO:

* Breadth First Search
* Depth First Search
* Binary Search
* Quick Sort
* Tree Insert / Find / etc

## Comb Sort

Time complexity:

* Worst case: O(n²)
* Average case: O(n²/2^p) (p is the number of increments)
* Best case: O(n(log(n)))

Space complexity:

* Worst case: O(1)

## Bubble Sort

Time complexity:

* Worst case: O(n²)
* Average case: O(n²)
* Best case: O(n)

Space complexity:

* Worst case: O(1)

## Insertion Sort

Time complexity:

* Worst case: O(n²)
* Average case: O(n²)
* Best case: O(n)

Space complexity:

* Worst case: O(1)

## Selection Sort

Time complexity:

* Worst case: O(n²)
* Average case: O(n²)
* Best case: O(n²)

Space complexity:

* Worst case: O(1)

## Shellsort

Time complexity:

* Worst case: O(n(log(n))²)
* Average case: depends on gap sequence
* Best case: O(n(log(n)))

Space complexity:

* Worst case: O(1)

## Merge Sort

Time complexity:

* Worst case: O(n(log(n)))
* Average case: O(n(log(n)))
* Best case: O(n(log(n)))

Space complexity:

* Worst case: O(n)
