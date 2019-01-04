module Basic exposing (main, testCondition, testDict, testEquality)

import AssocList as Dict exposing (Dict)


testDict : Dict String Int
testDict =
    let
        leftDict =
            Dict.update "a" (always (Just 4)) Dict.empty

        rightDict =
            Dict.remove "a" (Dict.insert "b" 2 (Dict.singleton "a" 1))
    in
    Dict.map (\_ v -> v + 1)
        (Dict.union
            (Dict.intersect leftDict rightDict)
            (Dict.diff leftDict rightDict)
        )


testCondition : Int
testCondition =
    if Dict.member "b" testDict then
        case Dict.get "b" testDict of
            Just x ->
                x

            Nothing ->
                0

    else
        Dict.size (Tuple.second (Dict.partition (\_ _ -> False) testDict))


testEquality : List String
testEquality =
    if Dict.eq (Dict.fromList []) testDict then
        Dict.keys (Dict.filter (\_ _ -> True) testDict)

    else if testCondition == 0 then
        List.map Tuple.first (Dict.toList testDict)

    else if Dict.isEmpty testDict then
        Dict.foldl (\k _ _ -> [ k ]) [] testDict

    else
        Dict.foldr (\k _ _ -> [ k ]) [] testDict


main =
    Platform.worker
        { init = \() -> ( testEquality, Cmd.none )
        , update =
            \_ _ ->
                ( List.map String.fromInt <|
                    Dict.values
                        (Dict.merge
                            Dict.insert
                            (\k v _ result -> Dict.insert k v result)
                            Dict.insert
                            Dict.empty
                            testDict
                            testDict
                        )
                , Cmd.none
                )
        , subscriptions = \_ -> Sub.none
        }
