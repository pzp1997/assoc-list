module Test.AssocList exposing (tests)

import AssocList as Dict
import Expect
import Test exposing (..)


animals : Dict.Dict String String
animals =
    Dict.fromList [ ( "Tom", "cat" ), ( "Jerry", "mouse" ) ]


expectDictEq : Dict.Dict k v -> Dict.Dict k v -> Expect.Expectation
expectDictEq leftDict rightDict =
    Expect.equal True (Dict.eq leftDict rightDict)


tests : Test
tests =
    let
        buildTests =
            describe "build Tests"
                [ test "empty" <|
                    \() ->
                        expectDictEq (Dict.fromList []) Dict.empty
                , test "singleton" <|
                    \() ->
                        expectDictEq
                            (Dict.fromList [ ( "k", "v" ) ])
                            (Dict.singleton "k" "v")
                , test "insert" <|
                    \() ->
                        expectDictEq
                            (Dict.fromList [ ( "k", "v" ) ])
                            (Dict.insert "k" "v" Dict.empty)
                , test "insert replace" <|
                    \() ->
                        expectDictEq
                            (Dict.fromList [ ( "k", "vv" ) ])
                            (Dict.insert "k" "vv" (Dict.singleton "k" "v"))
                , test "update" <|
                    \() ->
                        expectDictEq
                            (Dict.fromList [ ( "k", "vv" ) ])
                            (Dict.update "k" (\v -> Just "vv") (Dict.singleton "k" "v"))
                , test "update Nothing" <|
                    \() ->
                        expectDictEq
                            Dict.empty
                            (Dict.update "k" (\v -> Nothing) (Dict.singleton "k" "v"))
                , test "remove" <|
                    \() ->
                        expectDictEq
                            Dict.empty
                            (Dict.remove "k" (Dict.singleton "k" "v"))
                , test "remove not found" <|
                    \() ->
                        expectDictEq
                            (Dict.singleton "k" "v")
                            (Dict.remove "kk" (Dict.singleton "k" "v"))
                ]

        queryTests =
            describe "query Tests"
                [ test "member 1" <| \() -> Expect.equal True (Dict.member "Tom" animals)
                , test "member 2" <| \() -> Expect.equal False (Dict.member "Spike" animals)
                , test "get 1" <| \() -> Expect.equal (Just "cat") (Dict.get "Tom" animals)
                , test "get 2" <| \() -> Expect.equal Nothing (Dict.get "Spike" animals)
                , test "get with duplicate key" <|
                    \() ->
                        Expect.equal (Just 2)
                            (Dict.get "a" (Dict.insert "a" 2 (Dict.singleton "a" 1)))
                , test "size of empty dictionary" <| \() -> Expect.equal 0 (Dict.size Dict.empty)
                , test "size of example dictionary" <| \() -> Expect.equal 2 (Dict.size animals)
                , test "size with duplicate key" <|
                    \() ->
                        Expect.equal 1
                            (Dict.size (Dict.insert "a" 2 (Dict.singleton "a" 1)))
                ]

        equalityTests =
            describe "equality Tests"
                [ test "eq empty" <|
                    \() ->
                        expectDictEq (Dict.fromList []) Dict.empty
                , test "eq in order" <|
                    \() ->
                        expectDictEq
                            (Dict.fromList [ ( 'a', 1 ), ( 'b', 2 ) ])
                            (Dict.fromList [ ( 'a', 1 ), ( 'b', 2 ) ])
                , test "eq out of order" <|
                    \() ->
                        expectDictEq
                            (Dict.fromList [ ( 'a', 1 ), ( 'b', 2 ) ])
                            (Dict.fromList [ ( 'b', 2 ), ( 'a', 1 ) ])
                , test "eq left bigger" <|
                    \() ->
                        Expect.equal False
                            (Dict.eq
                                (Dict.fromList [ ( 'a', 1 ), ( 'b', 2 ) ])
                                (Dict.fromList [ ( 'a', 1 ) ])
                            )
                , test "eq right bigger" <|
                    \() ->
                        Expect.equal False
                            (Dict.eq
                                (Dict.singleton 'a' 1)
                                (Dict.fromList [ ( 'a', 1 ), ( 'b', 2 ) ])
                            )
                , test "eq different values" <|
                    \() ->
                        Expect.equal False
                            (Dict.eq
                                (Dict.singleton 'a' 1)
                                (Dict.singleton 'a' 2)
                            )
                ]

        combineTests =
            describe "combine Tests"
                [ test "union" <|
                    \() ->
                        expectDictEq
                            animals
                            (Dict.union
                                (Dict.singleton "Jerry" "mouse")
                                (Dict.singleton "Tom" "cat")
                            )
                , test "union collison" <|
                    \() ->
                        expectDictEq
                            (Dict.singleton "Tom" "cat")
                            (Dict.union
                                (Dict.singleton "Tom" "cat")
                                (Dict.singleton "Tom" "mouse")
                            )
                , test "intersect" <|
                    \() ->
                        expectDictEq
                            (Dict.singleton "Tom" "cat")
                            (Dict.intersect
                                animals
                                (Dict.singleton "Tom" "cat")
                            )
                , test "diff" <|
                    \() ->
                        expectDictEq
                            (Dict.singleton "Jerry" "mouse")
                            (Dict.diff animals (Dict.singleton "Tom" "cat"))
                ]

        transformTests =
            describe "transform Tests"
                [ test "filter" <|
                    \() ->
                        expectDictEq
                            (Dict.singleton "Tom" "cat")
                            (Dict.filter (\k v -> k == "Tom") animals)
                , test "partition fst" <|
                    \() ->
                        expectDictEq
                            (Dict.singleton "Tom" "cat")
                            (Tuple.first (Dict.partition (\k v -> k == "Tom") animals))
                , test "partition snd" <|
                    \() ->
                        expectDictEq
                            (Dict.singleton "Jerry" "mouse")
                            (Tuple.second (Dict.partition (\k v -> k == "Tom") animals))
                ]

        mergeTests =
            let
                insertBoth key leftVal rightVal dict =
                    Dict.insert key (leftVal ++ rightVal) dict

                s1 =
                    Dict.empty |> Dict.insert "u1" [ 1 ]

                s2 =
                    Dict.empty |> Dict.insert "u2" [ 2 ]

                s23 =
                    Dict.empty |> Dict.insert "u2" [ 3 ]

                b1 =
                    List.map (\i -> ( i, [ i ] )) (List.range 1 10) |> Dict.fromList

                b2 =
                    List.map (\i -> ( i, [ i ] )) (List.range 5 15) |> Dict.fromList

                bExpected =
                    [ ( 1, [ 1 ] ), ( 2, [ 2 ] ), ( 3, [ 3 ] ), ( 4, [ 4 ] ), ( 5, [ 5, 5 ] ), ( 6, [ 6, 6 ] ), ( 7, [ 7, 7 ] ), ( 8, [ 8, 8 ] ), ( 9, [ 9, 9 ] ), ( 10, [ 10, 10 ] ), ( 11, [ 11 ] ), ( 12, [ 12 ] ), ( 13, [ 13 ] ), ( 14, [ 14 ] ), ( 15, [ 15 ] ) ]
            in
            describe "merge Tests"
                [ test "merge empties" <|
                    \() ->
                        expectDictEq
                            Dict.empty
                            (Dict.merge Dict.insert insertBoth Dict.insert Dict.empty Dict.empty Dict.empty)
                , test "merge singletons in order" <|
                    \() ->
                        expectDictEq
                            (Dict.fromList [ ( "u1", [ 1 ] ), ( "u2", [ 2 ] ) ])
                            (Dict.merge Dict.insert insertBoth Dict.insert s1 s2 Dict.empty)
                , test "merge singletons out of order" <|
                    \() ->
                        expectDictEq
                            (Dict.fromList [ ( "u1", [ 1 ] ), ( "u2", [ 2 ] ) ])
                            (Dict.merge Dict.insert insertBoth Dict.insert s2 s1 Dict.empty)
                , test "merge with duplicate key" <|
                    \() ->
                        expectDictEq
                            (Dict.fromList [ ( "u2", [ 2, 3 ] ) ])
                            (Dict.merge Dict.insert insertBoth Dict.insert s2 s23 Dict.empty)
                , test "partially overlapping" <|
                    \() ->
                        expectDictEq
                            (Dict.fromList bExpected)
                            (Dict.merge Dict.insert insertBoth Dict.insert b1 b2 Dict.empty)
                ]
    in
    describe "Dict Tests"
        [ buildTests
        , queryTests
        , equalityTests
        , combineTests
        , transformTests
        , mergeTests
        ]
