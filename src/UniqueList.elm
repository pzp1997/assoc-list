module UniqueList exposing
    ( Set
    , empty, singleton, insert, remove
    , isEmpty, member, size
    , union, intersect, diff
    , toList, fromList
    , map, foldl, foldr, filter, partition
    )

{-| A unique list is a list of values with the guarantee that no value will be
duplicated. The values can be of any type (so long as it has a reasonable
definition for equality). This includes pretty much everything except for
functions and things that contain functions.

All functions in this module are "stack safe," which means that your program
won't crash from recursing over large association lists. You can read
Evan Czaplicki's
[document on tail-call elimination](https://github.com/evancz/functional-programming-in-elm/blob/master/recursion/tail-call-elimination.md)
for more information about this topic.


# Sets

@docs Set


# Build

@docs empty, singleton, insert, remove


# Query

@docs isEmpty, member, size


# Combine

@docs union, intersect, diff


# Lists

@docs toList, fromList


# Transform

@docs map, foldl, foldr, filter, partition

-}

import Basics exposing (Bool, Int)
import Dict
import List exposing ((::))
import Maybe exposing (Maybe(..))


{-| Represents a set of unique values. So `(Set Int)` is a set of integers and
`(Set String)` is a set of strings.
-}
type Set t
    = S (List t)


{-| Create an empty set.
-}
empty : Set a
empty =
    S []


{-| Create a set with one value.
-}
singleton : a -> Set a
singleton key =
    S [ key ]


{-| Insert a value into a set.
-}
insert : a -> Set a -> Set a
insert key set =
    let
        (S alteredList) =
            remove key set
    in
    S (key :: alteredList)


{-| Remove a value from a set. If the value is not found, no changes are made.
-}
remove : a -> Set a -> Set a
remove targetKey (S uniqueList) =
    S (List.filter (\key -> key /= targetKey) uniqueList)


{-| Determine if a set is empty.
-}
isEmpty : Set a -> Bool
isEmpty set =
    set == S []


{-| Determine if a value is in a set.
-}
member : a -> Set a -> Bool
member key (S uniqueList) =
    List.member key uniqueList


{-| Determine the number of elements in a set.
-}
size : Set a -> Int
size (S uniqueList) =
    List.length uniqueList


{-| Get the union of two sets. Keep all values.

If you are using this module as an ordered set, the ordering of the output set
will be all the entries of the first set (from most recently inserted to least
recently inserted) followed by all the entries of the second set that are not
in the first set (from most recently inserted to least recently inserted).

    toList (union (fromList [ "Bob" ]) (fromList [ "Alice", "Bob" ]))
    --> [ "Bob", "Alice" ]

-}
union : Set a -> Set a -> Set a
union (S uniqueList) set =
    List.foldr insert set uniqueList


{-| Get the intersection of two sets. Keeps values that appear in both sets.

If you are using this module as an ordered set, the output set will have the
same relative order as the first set.

-}
intersect : Set a -> Set a -> Set a
intersect (S leftList) rightSet =
    S (List.filter (\key -> member key rightSet) leftList)


{-| Get the difference between the first set and the second. Keeps values
that do not appear in the second set.

If you are using this module as an ordered set, the output set will have the
same relative order as the first set.

-}
diff : Set a -> Set a -> Set a
diff (S leftList) rightSet =
    S (List.filter (\key -> not (member key rightSet)) leftList)


{-| Convert a set into a list, in the order the values were inserted with the
most recently inserted value at the head of the list.
-}
toList : Set a -> List a
toList (S uniqueList) =
    uniqueList


{-| Convert a list into a set, removing any duplicates.

If you are using this module as an ordered set, please note that the elements
are inserted from right to left. (If you want to insert the elements from left
to right, you can simply call `List.reverse` on the input before passing it to
`fromList`.)

-}
fromList : List a -> Set a
fromList list =
    List.foldr insert (S []) list


{-| Fold over the values in a set from most recently inserted to least recently
inserted.
-}
foldl : (a -> b -> b) -> b -> Set a -> b
foldl func initialState (S uniqueList) =
    List.foldl func initialState uniqueList


{-| Fold over the values in a set from least recently inserted to most recently
inserted.
-}
foldr : (a -> b -> b) -> b -> Set a -> b
foldr func initialState (S uniqueList) =
    List.foldr func initialState uniqueList


{-| Map a function onto a set, creating a new set with no duplicates.
-}
map : (a -> b) -> Set a -> Set b
map func (S uniqueList) =
    fromList (List.map func uniqueList)


{-| Only keep elements that pass the given test.


    positives : Set Int
    positives =
        filter (\x -> x > 0) (fromList [ -2, -1, 0, 1, 2 ])

    --> positives == fromList [ 0, 1, 2 ]

-}
filter : (a -> Bool) -> Set a -> Set a
filter isGood (S uniqueList) =
    S (List.filter isGood uniqueList)


{-| Create two new sets. The first contains all the elements that passed the
given test, and the second contains all the elements that did not.
-}
partition : (a -> Bool) -> Set a -> ( Set a, Set a )
partition isGood (S uniqueList) =
    let
        ( uniqueList1, uniqueList2 ) =
            List.partition isGood uniqueList
    in
    ( S uniqueList1, S uniqueList2 )
