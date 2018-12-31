module AssocList exposing
    ( Dict
    , empty, singleton, insert, update, remove
    , isEmpty, member, get, size
    , keys, values, toList, fromList
    , map, foldl, foldr, filter, partition
    , union, intersect, diff, merge
    )

{-| A dictionary mapping unique keys to values. The keys can be any comparable
type. This includes `Int`, `Float`, `Time`, `Char`, `String`, and tuples or
lists of comparable types.

TODO update: Insert, remove, and query operations all take _O(log n)_ time.


# Dictionaries

@docs Dict


# Build

@docs empty, singleton, insert, update, remove


# Query

@docs isEmpty, member, get, size


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

    import Dict exposing (Dict)

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
get targetKey (D dict) =
    lookup targetKey dict


lookup : k -> List ( k, v ) -> Maybe v
lookup targetKey dict =
    case dict of
        [] ->
            Nothing

        ( key, value ) :: rest ->
            if key == targetKey then
                Just value

            else
                lookup targetKey rest


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
-}
size : Dict k v -> Int
size (D dict) =
    List.length dict


{-| Determine if a dictionary is empty.

    isEmpty empty == True

-}
isEmpty : Dict k v -> Bool
isEmpty (D dict) =
    dict == []


{-| Insert a key-value pair into a dictionary. Replaces value when there is
a collision.
-}
insert : k -> v -> Dict k v -> Dict k v
insert key value (D dict) =
    D (( key, value ) :: deleteKey key dict)


{-| Remove a key-value pair from a dictionary. If the key is not found,
no changes are made.
-}
remove : k -> Dict k v -> Dict k v
remove targetKey (D dict) =
    D (deleteKey targetKey dict)


deleteKey : k -> List ( k, v ) -> List ( k, v )
deleteKey targetKey dict =
    List.filter (\( key, _ ) -> key /= targetKey) dict


{-| Update the value of a dictionary for a specific key with a given function.
-}
update : k -> (Maybe v -> Maybe v) -> Dict k v -> Dict k v
update targetKey alter dict =
    case alter (get targetKey dict) of
        Just alteredValue ->
            insert targetKey alteredValue dict

        Nothing ->
            remove targetKey dict



{-
   update : k -> (Maybe v -> Maybe v) -> Dict k v -> Dict k v
   update targetKey alter (D dict) =
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
                   dict
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
union (D leftDict) rightDict =
    List.foldr
        (\( lKey, lValue ) result ->
            insert lKey lValue result
        )
        rightDict
        leftDict


{-| Keep a key-value pair when its key appears in the second dictionary.
Preference is given to values in the first dictionary.
-}
intersect : Dict k v -> Dict k v -> Dict k v
intersect (D leftDict) rightDict =
    D (List.filter (\( key, _ ) -> member key rightDict) leftDict)


{-| Keep a key-value pair when its key does not appear in the second dictionary.
-}
diff : Dict k a -> Dict k b -> Dict k a
diff (D leftDict) rightDict =
    D (List.filter (\( k, _ ) -> not (member k rightDict)) leftDict)


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
merge leftStep bothStep rightStep ((D leftDict) as wrappedLD) (D rightDict) initialResult =
    let
        ( inBoth, inRightOnly ) =
            List.partition (\( key, _ ) -> member key wrappedLD) rightDict

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
            case lookup lKey inBoth of
                Just rValue ->
                    bothStep lKey lValue rValue result

                Nothing ->
                    leftStep lKey lValue result
        )
        intermediateResult
        leftDict



-- TRANSFORM


{-| Apply a function to all values in a dictionary.
-}
map : (k -> a -> b) -> Dict k a -> Dict k b
map alter (D dict) =
    D (List.map (\( k, v ) -> ( k, alter k v )) dict)


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
foldl func initialResult (D dict) =
    List.foldl
        (\( key, value ) result ->
            func key value result
        )
        initialResult
        dict


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
foldr func initialResult (D dict) =
    List.foldr
        (\( key, value ) result ->
            func key value result
        )
        initialResult
        dict


{-| Keep only the key-value pairs that pass the given test.
-}
filter : (k -> v -> Bool) -> Dict k v -> Dict k v
filter isGood (D dict) =
    D (List.filter (\( k, v ) -> isGood k v) dict)


{-| Partition a dictionary according to some test. The first dictionary
contains all key-value pairs which passed the test, and the second contains
the pairs that did not.
-}
partition : (k -> v -> Bool) -> Dict k v -> ( Dict k v, Dict k v )
partition isGood (D dict) =
    let
        ( good, bad ) =
            List.partition (\( k, v ) -> isGood k v) dict
    in
    ( D good, D bad )



-- LISTS


{-| Get all of the keys in a dictionary, sorted from lowest to highest.

    keys (fromList [ ( 0, "Alice" ), ( 1, "Bob" ) ]) == [ 0, 1 ]

-}
keys : Dict k v -> List k
keys (D dict) =
    List.map Tuple.first dict


{-| Get all of the values in a dictionary, in the order of their keys.

    values (fromList [ ( 0, "Alice" ), ( 1, "Bob" ) ]) == [ "Alice", "Bob" ]

-}
values : Dict k v -> List v
values (D dict) =
    List.map Tuple.second dict


{-| Convert a dictionary into an association list of key-value pairs, sorted by keys.
-}
toList : Dict k v -> List ( k, v )
toList (D dict) =
    dict


{-| Convert an association list into a dictionary.
-}
fromList : List ( k, v ) -> Dict k v
fromList assocs =
    List.foldl (\( key, value ) dict -> insert key value dict) empty assocs
