|           | Function  | No-Dups        | Dups | elm/core         |
|-----------|-----------|----------------|------|------------------|
| Build     | empty     | O(1)           |      | O(1)             |
|           | singleton | O(1)           |      | O(1)             |
|           | insert    | O(n)           |      | O(log n)         |
|           | update    | O(n)           |      | O(log n)         |
|           | remove    | O(n)           |      | O(log n)         |
| Query     | isEmpty   | O(1)           |      | O(1)             |
|           | member    | O(n)           |      | O(log n)         |
|           | get       | O(n)           |      | O(log n)         |
|           | size      | O(n)           |      | O(n)             |
| Lists     | keys      | O(n)           |      | O(n)             |
|           | values    | O(n)           |      | O(n)             |
|           | toList    | O(1)           |      | O(n)             |
|           | fromList  | O(n^2)         | O(1) | O(n log n)       |
| Transform | map       | O(n)           |      | O(n)             |
|           | foldl     | O(n)           |      | O(n)             |
|           | foldr     | O(n)           |      | O(n)             |
|           | filter    | O(n)           |      | O(n)             |
|           | partition | O(n)           |      | O(n)             |
| Combine   | union     | O(n * (n + m)) | O(d) | O(n log (n + m)) |
|           | intersect | O(n * m)       |      | O(n log m)       |
|           | diff      | O(n * m)       |      | O(m log n)       |
|           | merge     | O(n * m)       |      | O(n + m)         |
