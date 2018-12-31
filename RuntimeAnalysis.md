# Build

empty           O(1)    SS  -- O(1)
singleton       O(1)    SS  -- O(1)
insert          O(n)    SS  -- O(log n)
update          O(n)    SS  -- O(log n)
remove          O(n)    SS  -- O(log n)


# Query

isEmpty         O(1)    SS  -- O(1)
member          O(n)    SS  -- O(log n)
get             O(n)    SS  -- O(log n)
size            O(n)    SS  -- O(n)


# Lists

keys            O(n)    SS  -- O(n)
values          O(n)    SS  -- O(n)
toList          O(1)    SS  -- O(n)
fromList        O(n^2)  SS  -- O(n log n)


# Transform

map             O(n)    SS  -- O(n)
foldl           O(n)    SS  -- O(n)
foldr           O(n)    SS  -- O(n)
filter          O(n)    SS  -- O(n)
partition       O(n)    SS  -- O(n)


# Combine

union           O(n * (n + m))    SS  -- O(n log (n + m))
intersect       O(n * m)          SS  -- O(n log m)
diff            O(n * m)          SS  -- O(m log n)
merge           O(n * m)          SS  -- O(n + m)
