module AssocList exposing
    ( Dict
    , empty, singleton, insert, update, remove
    , isEmpty, member, get, size, eq
    , keys, values, toList, fromList
    , map, foldl, foldr, filter, partition
    , union, intersect, diff, merge
    )

{-| An [association list](https://en.wikipedia.org/wiki/Association_list) is a
list of tuples that map unique keys to values. The keys can be of any type (so
long as it has a reasonable definition for equality). This includes pretty
much everything except for functions and things that contain functions.

All functions in this module are "stack safe," which means that your program
won't crash from recursing over large association lists. You can read
Evan Czaplicki's
[document on tail-call elimination](https://github.com/evancz/functional-programming-in-elm/blob/master/recursion/tail-call-elimination.md)
for more information about this topic.


# Dictionaries

@docs Dict


# Build

@docs empty, singleton, insert, update, remove


# Query

@docs isEmpty, member, get, size, eq


# Lists

@docs keys, values, toList, fromList


# Transform

@docs map, foldl, foldr, filter, partition


# Combine

@docs union, intersect, diff, merge

-}


{-| A dictionary of keys and values. So a `Dict String User` is a dictionary
that lets you look up a `String` (such as user names) and find the associated
`User`.

    import AssocList as Dict exposing (Dict)

    users : Dict String User
    users =
        Dict.fromList
            [ ( "Alice", User "Alice" 28 1.65 )
            , ( "Bob", User "Bob" 19 1.82 )
            , ( "Chuck", User "Chuck" 33 1.75 )
            ]

    type alias User =
        { name : String
        , age : Int
        , height : Float
        }

-}
type Dict a b
    = D (List ( a, b ))


{-| Create an empty dictionary.
-}
empty : Dict k v
empty =
    D []


{-| Get the value associated with a key. If the key is not found, return
`Nothing`. This is useful when you are not sure if a key will be in the
dictionary.

    type Animal
        = Cat
        | Mouse

    animals : Dict String Animal
    animals = fromList [ ("Tom", Cat), ("Jerry", Mouse) ]

    get "Tom"   animals --> Just Cat
    get "Jerry" animals --> Just Mouse
    get "Spike" animals --> Nothing

-}
get : k -> Dict k v -> Maybe v
get targetKey (D alist) =
    case alist of
        [] ->
            Nothing

        ( key, value ) :: rest ->
            if key == targetKey then
                Just value

            else
                get targetKey (D rest)


{-| Determine if a key is in a dictionary.
-}
member : k -> Dict k v -> Bool
member targetKey dict =
    case get targetKey dict of
        Just _ ->
            True

        Nothing ->
            False


{-| Determine the number of key-value pairs in the dictionary.

    size (fromList [ ( "a", 1 ), ( "b", 2 ), ( "c", 3 ) ]) --> 3

    size (insert 1 "b" (singleton 1 "a")) --> 1

-}
size : Dict k v -> Int
size (D alist) =
    List.length alist


{-| Determine if a dictionary is empty.

    isEmpty empty --> True

-}
isEmpty : Dict k v -> Bool
isEmpty dict =
    dict == D []


{-| Compare two dictionaries for equality, ignoring insertion order.
Dictionaries are defined to be equal when they have identical key-value pairs
where keys and values are compared using the built-in equality operator.

You should almost never use the built-in equality operator to compare
dictionaries from this module since association lists have no canonical form.

    eq
        (fromList [ ( "a", 1 ), ( "b", 2 ) ])
        (fromList [ ( "b", 2 ), ( "a", 1 ) ])
    --> True

-}
eq : Dict k v -> Dict k v -> Bool
eq leftDict rightDict =
    merge
        (\_ _ _ -> False)
        (\_ a b result -> result && a == b)
        (\_ _ _ -> False)
        leftDict
        rightDict
        True


{-| Insert a key-value pair into a dictionary. Replaces value when there is
a collision.
-}
insert : k -> v -> Dict k v -> Dict k v
insert key value dict =
    let
        (D alteredAlist) =
            remove key dict
    in
    D (( key, value ) :: alteredAlist)


{-| Remove a key-value pair from a dictionary. If the key is not found,
no changes are made.
-}
remove : k -> Dict k v -> Dict k v
remove targetKey (D alist) =
    D (List.filter (\( key, _ ) -> key /= targetKey) alist)


{-| Update the value of a dictionary for a specific key with a given function.

If you are using this module as an ordered dictionary, please note that if you
are replacing the value of an existing entry, the entry will remain where it
is in the insertion order. (If you do want to change the insertion order,
consider using `get` in conjunction with `insert` instead.)

-}
update : k -> (Maybe v -> Maybe v) -> Dict k v -> Dict k v
update targetKey alter ((D alist) as dict) =
    let
        maybeValue =
            get targetKey dict
    in
    case maybeValue of
        Just _ ->
            case alter maybeValue of
                Just alteredValue ->
                    D
                        (List.map
                            (\(( key, _ ) as entry) ->
                                if key == targetKey then
                                    ( targetKey, alteredValue )

                                else
                                    entry
                            )
                            alist
                        )

                Nothing ->
                    remove targetKey dict

        Nothing ->
            case alter Nothing of
                Just alteredValue ->
                    D (( targetKey, alteredValue ) :: alist)

                Nothing ->
                    dict


{-| Create a dictionary with one key-value pair.
-}
singleton : k -> v -> Dict k v
singleton key value =
    D [ ( key, value ) ]



-- COMBINE


{-| Combine two dictionaries. If there is a collision, preference is given
to the first dictionary.

If you are using this module as an ordered dictionary, the ordering of the
output dictionary will be all the entries of the first dictionary (from most
recently inserted to least recently inserted) followed by all the entries of
the second dictionary (from most recently inserted to least recently inserted).

-}
union : Dict k v -> Dict k v -> Dict k v
union (D leftAlist) rightDict =
    List.foldr
        (\( lKey, lValue ) result ->
            insert lKey lValue result
        )
        rightDict
        leftAlist


{-| Keep a key-value pair when its key appears in the second dictionary.
Preference is given to values in the first dictionary.
-}
intersect : Dict k v -> Dict k v -> Dict k v
intersect (D leftAlist) rightDict =
    D (List.filter (\( key, _ ) -> member key rightDict) leftAlist)


{-| Keep a key-value pair when its key does not appear in the second dictionary.
-}
diff : Dict k a -> Dict k b -> Dict k a
diff (D leftAlist) rightDict =
    D (List.filter (\( key, _ ) -> not (member key rightDict)) leftAlist)


{-| The most general way of combining two dictionaries. You provide three
accumulators for when a given key appears:

1.  Only in the left dictionary.
2.  In both dictionaries.
3.  Only in the right dictionary.

You then traverse all the keys in the following order, building up whatever
you want:

1.  All the keys that appear only in the right dictionary from least
    recently inserted to most recently inserted.
2.  All the keys in the left dictionary from least recently inserted to most
    recently inserted (without regard to whether they appear only in the left
    dictionary or in both dictionaries).

-}
merge :
    (k -> a -> result -> result)
    -> (k -> a -> b -> result -> result)
    -> (k -> b -> result -> result)
    -> Dict k a
    -> Dict k b
    -> result
    -> result
merge leftStep bothStep rightStep ((D leftAlist) as leftDict) (D rightAlist) initialResult =
    let
        ( inBothAlist, inRightOnlyAlist ) =
            List.partition
                (\( key, _ ) ->
                    member key leftDict
                )
                rightAlist

        intermediateResult =
            List.foldr
                (\( rKey, rValue ) result ->
                    rightStep rKey rValue result
                )
                initialResult
                inRightOnlyAlist
    in
    List.foldr
        (\( lKey, lValue ) result ->
            case get lKey (D inBothAlist) of
                Just rValue ->
                    bothStep lKey lValue rValue result

                Nothing ->
                    leftStep lKey lValue result
        )
        intermediateResult
        leftAlist



-- TRANSFORM


{-| Apply a function to all values in a dictionary.
-}
map : (k -> a -> b) -> Dict k a -> Dict k b
map alter (D alist) =
    D (List.map (\( key, value ) -> ( key, alter key value )) alist)


{-| Fold over the key-value pairs in a dictionary from most recently inserted
to least recently inserted.

    users : Dict String Int
    users =
        fromList
            [ ( "Alice", 28 )
            , ( "Bob", 19 )
            , ( "Chuck", 33 )
            ]

    foldl (\name age result -> age :: result) [] users --> [28,19,33]

-}
foldl : (k -> v -> b -> b) -> b -> Dict k v -> b
foldl func initialResult (D alist) =
    List.foldl
        (\( key, value ) result ->
            func key value result
        )
        initialResult
        alist


{-| Fold over the key-value pairs in a dictionary from least recently inserted
to most recently insered.

    users : Dict String Int
    users =
        fromList
            [ ( "Alice", 28 )
            , ( "Bob", 19 )
            , ( "Chuck", 33 )
            ]

    foldr (\name age result -> age :: result) [] users --> [33,19,28]

-}
foldr : (k -> v -> b -> b) -> b -> Dict k v -> b
foldr func initialResult (D alist) =
    List.foldr
        (\( key, value ) result ->
            func key value result
        )
        initialResult
        alist


{-| Keep only the key-value pairs that pass the given test.
-}
filter : (k -> v -> Bool) -> Dict k v -> Dict k v
filter isGood (D alist) =
    D (List.filter (\( key, value ) -> isGood key value) alist)


{-| Partition a dictionary according to some test. The first dictionary
contains all key-value pairs which passed the test, and the second contains
the pairs that did not.
-}
partition : (k -> v -> Bool) -> Dict k v -> ( Dict k v, Dict k v )
partition isGood (D alist) =
    let
        ( good, bad ) =
            List.partition (\( key, value ) -> isGood key value) alist
    in
    ( D good, D bad )



-- LISTS


{-| Get all of the keys in a dictionary, in the order that they were inserted
with the most recently inserted key at the head of the list.

    keys (fromList [ ( 0, "Alice" ), ( 1, "Bob" ) ]) --> [ 1, 0 ]

-}
keys : Dict k v -> List k
keys (D alist) =
    List.map Tuple.first alist


{-| Get all of the values in a dictionary, in the order that they were inserted
with the most recently inserted value at the head of the list.

    values (fromList [ ( 0, "Alice" ), ( 1, "Bob" ) ]) --> [ "Bob", "Alice" ]

-}
values : Dict k v -> List v
values (D alist) =
    List.map Tuple.second alist


{-| Convert a dictionary into an association list of key-value pairs, in the
order that they were inserted with the most recently inserted entry at the
head of the list.
-}
toList : Dict k v -> List ( k, v )
toList (D alist) =
    alist


{-| Convert an association list into a dictionary. The elements are inserted
from left to right. (If you want to insert the elements from right to left, you
can simply call `List.reverse` on the input before passing it to `fromList`.)
-}
fromList : List ( k, v ) -> Dict k v
fromList alist =
    List.foldl
        (\( key, value ) result ->
            insert key value result
        )
        (D [])
        alist
