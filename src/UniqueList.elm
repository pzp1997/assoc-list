module UniqueList exposing
    ( empty, singleton, insert, remove
    , isEmpty, member, size
    , union, intersect, diff
    , toList, fromList
    , map, foldl, foldr, filter, partition
    , Set
    )

{-| A set of unique values. The values can be any comparable type. This
includes `Int`, `Float`, `Time`, `Char`, `String`, and tuples or lists
of comparable types.

Insert, remove, and query operations all take _O(log n)_ time.


# Sets

@docS uniqueList


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
-}
union : Set a -> Set a -> Set a
union (S uniqueList) set =
    List.foldr insert set uniqueList


{-| Get the intersection of two sets. Keeps values that appear in both sets.
-}
intersect : Set a -> Set a -> Set a
intersect (S leftList) rightSet =
    S (List.filter (\key -> member key rightSet) leftList)


{-| Get the difference between the first set and the second. Keeps values
that do not appear in the second set.
-}
diff : Set a -> Set a -> Set a
diff (S leftList) rightSet =
    S (List.filter (\key -> not (member key rightSet)) leftList)


{-| Convert a set into a list, sorted from lowest to highest.
-}
toList : Set a -> List a
toList (S uniqueList) =
    uniqueList


{-| Convert a list into a set, removing any duplicates.
-}
fromList : List a -> Set a
fromList list =
    List.foldr insert (S []) list


{-| Fold over the values in a set, in order from lowest to highest.
-}
foldl : (a -> b -> b) -> b -> Set a -> b
foldl func initialState (S uniqueList) =
    List.foldl func initialState uniqueList


{-| Fold over the values in a set, in order from highest to lowest.
-}
foldr : (a -> b -> b) -> b -> Set a -> b
foldr func initialState (S uniqueList) =
    List.foldr func initialState uniqueList


{-| Map a function onto a set, creating a new set with no duplicates.
-}
map : (a -> b) -> Set a -> Set b
map func (S uniqueList) =
    S (List.map func uniqueList)


{-| Only keep elements that pass the given test.

    import Set exposing (Set)

    numbers : Set Int
    numbers =
        Set.fromList [ -2, -1, 0, 1, 2 ]

    positives : Set Int
    positives =
        Set.filter (\x -> x > 0) numbers

    -- positives == Set.fromList [1,2]

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
