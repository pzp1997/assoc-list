module AssocList exposing
    ( Dict
    , empty, singleton, insert, update, remove
    , isEmpty, member, get, size
    , eq
    , keys, values, toList, fromList
    , map, foldl, foldr, filter, partition
    , union, intersect, diff, merge
    )

{-| An [association list](https://en.wikipedia.org/wiki/Association_list) is a
list of tuples that map unique keys to values. The keys can be of any type (so
long as it has a reasonable definition for equality). This includes pretty
much everything except for functions and things that contain functions.

This library is intended to be used as a drop-in replacement for the `Dict`
module in elm/core. You might import it like so,

    import AssocList as Dict exposing (Dict)

Since this library does not require your keys to be `comparable`, some
operations are asymptotically slower than those in the `Dict` module in
elm/core. If you are working with small-ish dictionaries, this is likely not
a problem. Furthermore, the bottleneck point in most Elm programs is DOM
manipulation, so slower data structure operations are unlikely to cause a
noticable difference in how your app performs. For a detailed comparison of
the performance characteristics of the two implementations,
[Performance.md](TODO).

All functions in this library are "stack safe," which means that your program
won't crash from recursing over large association lists. You can read
Evan Czaplicki's
[document on tail-call elimination](https://github.com/evancz/functional-programming-in-elm/blob/master/recursion/tail-call-elimination.md)
for more information about this topic.


# Dictionaries

@docs Dict


# Build

@docs empty, singleton, insert, update, remove


# Query

@docs isEmpty, member, get, size


# Equality

@docs eq


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

    animals = fromList [ ("Tom", Cat), ("Jerry", Mouse) ]

    get "Tom"   animals == Just Cat
    get "Jerry" animals == Just Mouse
    get "Spike" animals == Nothing

-}
get : k -> Dict k v -> Maybe v
get targetKey (D alist) =
    getUnboxed targetKey alist


getUnboxed : k -> List ( k, v ) -> Maybe v
getUnboxed targetKey alist =
    case alist of
        [] ->
            Nothing

        ( key, value ) :: rest ->
            if key == targetKey then
                Just value

            else
                getUnboxed targetKey rest


{-| Determine if a key is in a dictionary.
-}
member : k -> Dict k v -> Bool
member targetKey (D alist) =
    -- TODO consider avoiding the extra function call
    memberUnboxed targetKey alist


memberUnboxed : k -> List ( k, v ) -> Bool
memberUnboxed targetKey alist =
    case getUnboxed targetKey alist of
        Just _ ->
            True

        Nothing ->
            False


{-| Determine the number of key-value pairs in the dictionary.
-}
size : Dict k v -> Int
size (D alist) =
    List.length alist


{-| Determine if a dictionary is empty.

    isEmpty empty == True

-}
isEmpty : Dict k v -> Bool
isEmpty dict =
    dict == D []


{-| Compare two dictionaries for equality. Dictionaries are defined to be
equal when they have identical key-value pairs where keys and values are
compared using the built-in equality operator. The built-in equality operator
will behave strangely with the `Dict` type in this library since association
lists have no canonical form.

    eq (fromList [ ( 'a', 1 ), ( 'b', 2 ) ]) (fromList [ ( 'b', 2 ), ( 'a', 1 ) ]) == True

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
insert key value (D alist) =
    D (insertUnboxed key value alist)



-- D (( key, value ) :: removeUnboxed key dict)


insertUnboxed : k -> v -> List ( k, v ) -> List ( k, v )
insertUnboxed key value alist =
    ( key, value ) :: removeUnboxed key alist


{-| Remove a key-value pair from a dictionary. If the key is not found,
no changes are made.
-}
remove : k -> Dict k v -> Dict k v
remove targetKey (D alist) =
    D (removeUnboxed targetKey alist)


removeUnboxed : k -> List ( k, v ) -> List ( k, v )
removeUnboxed targetKey alist =
    List.filter (\( key, _ ) -> key /= targetKey) alist


{-| Update the value of a dictionary for a specific key with a given function.
-}
update : k -> (Maybe v -> Maybe v) -> Dict k v -> Dict k v
update targetKey alter (D alist) =
    case alter (getUnboxed targetKey alist) of
        Just alteredValue ->
            D (insertUnboxed targetKey alteredValue alist)

        Nothing ->
            D (removeUnboxed targetKey alist)



-- TODO decide on implementation for update
{-
   update : k -> (Maybe v -> Maybe v) -> Dict k v -> Dict k v
   update targetKey alter (D alist) =
       let
           ( targetValue, alteredDictionary ) =
               List.foldr
                   (\(( key, value ) as entry) ( capturedValue, accumulator ) ->
                       if key == targetKey then
                           ( Just value, accumulator )

                       else
                           ( capturedValue, entry :: accumulator )
                   )
                   ( Nothing, [] )
                   alist
       in
       case alter targetValue of
           Just alteredValue ->
               D (( targetKey, alteredValue ) :: alteredDictionary)

           Nothing ->
               D alteredDictionary
-}


{-| Create a dictionary with one key-value pair.
-}
singleton : k -> v -> Dict k v
singleton key value =
    D [ ( key, value ) ]



-- COMBINE


{-| Combine two dictionaries. If there is a collision, preference is given
to the first dictionary.
-}
union : Dict k v -> Dict k v -> Dict k v
union (D leftAlist) (D rightAlist) =
    D
        (List.foldr
            (\( lKey, lValue ) result ->
                insertUnboxed lKey lValue result
            )
            rightAlist
            leftAlist
        )


{-| Keep a key-value pair when its key appears in the second dictionary.
Preference is given to values in the first dictionary.
-}
intersect : Dict k v -> Dict k v -> Dict k v
intersect (D leftAlist) (D rightAlist) =
    D (List.filter (\( key, _ ) -> memberUnboxed key rightAlist) leftAlist)


{-| Keep a key-value pair when its key does not appear in the second dictionary.
-}
diff : Dict k a -> Dict k b -> Dict k a
diff (D leftAlist) (D rightAlist) =
    D (List.filter (\( k, _ ) -> not (memberUnboxed k rightAlist)) leftAlist)


{-| The most general way of combining two dictionaries. You provide three
accumulators for when a given key appears:

1.  Only in the left dictionary.
2.  In both dictionaries.
3.  Only in the right dictionary.

You then traverse all the keys from lowest to highest, building up whatever
you want.

-}
merge :
    (k -> a -> result -> result)
    -> (k -> a -> b -> result -> result)
    -> (k -> b -> result -> result)
    -> Dict k a
    -> Dict k b
    -> result
    -> result
merge leftStep bothStep rightStep (D leftAlist) (D rightAlist) initialResult =
    let
        ( inBoth, inRightOnly ) =
            List.partition
                (\( key, _ ) ->
                    memberUnboxed key leftAlist
                )
                rightAlist

        intermediateResult =
            List.foldr
                (\( rKey, rValue ) result ->
                    rightStep rKey rValue result
                )
                initialResult
                inRightOnly
    in
    List.foldr
        (\( lKey, lValue ) result ->
            case getUnboxed lKey inBoth of
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


{-| Fold over the key-value pairs in a dictionary from lowest key to highest key.

    import Dict exposing (Dict)

    getAges : Dict String User -> List String
    getAges users =
        Dict.foldl addAge [] users

    addAge : String -> User -> List String -> List String
    addAge _ user ages =
        user.age :: ages


    -- getAges users == [33,19,28]

-}
foldl : (k -> v -> b -> b) -> b -> Dict k v -> b
foldl func initialResult (D alist) =
    List.foldl
        (\( key, value ) result ->
            func key value result
        )
        initialResult
        alist


{-| Fold over the key-value pairs in a dictionary from highest key to lowest key.

    import Dict exposing (Dict)

    getAges : Dict String User -> List String
    getAges users =
        Dict.foldr addAge [] users

    addAge : String -> User -> List String -> List String
    addAge _ user ages =
        user.age :: ages


    -- getAges users == [28,19,33]

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


{-| Get all of the keys in a dictionary, sorted from lowest to highest.

    keys (fromList [ ( 0, "Alice" ), ( 1, "Bob" ) ]) == [ 0, 1 ]

-}
keys : Dict k v -> List k
keys (D alist) =
    List.map Tuple.first alist


{-| Get all of the values in a dictionary, in the order of their keys.

    values (fromList [ ( 0, "Alice" ), ( 1, "Bob" ) ]) == [ "Alice", "Bob" ]

-}
values : Dict k v -> List v
values (D alist) =
    List.map Tuple.second alist


{-| Convert a dictionary into an association list of key-value pairs, sorted by keys.
-}
toList : Dict k v -> List ( k, v )
toList (D alist) =
    alist


{-| Convert an association list into a dictionary.
-}
fromList : List ( k, v ) -> Dict k v
fromList assocs =
    D
        (List.foldl
            (\( key, value ) alist ->
                insertUnboxed key value alist
            )
            []
            assocs
        )
