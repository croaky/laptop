# Given a collection of intervals,
# merge all overlapping intervals.

input = [[1, 3], [8, 10], [2, 6], [15, 18]]
want = [[1, 6], [8, 10], [15, 18]]

input = input.sort # ascending by first element
prev = nil
output = []

input.each do |pair|
  if prev.nil?
    prev = pair
    next
  end
  if prev[1] > pair[0] # overlaps
    output << [
      prev[0] < pair[0] ? prev[0] : pair[0],
      prev[1] > pair[1] ? prev[1] : pair[1],
    ]
  else
    output << pair
  end
  prev = pair
end

puts output == want
