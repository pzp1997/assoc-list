module Main exposing (main)

import AssocList as Dict exposing (Dict)
import Html exposing (Html)


type Character
    = Ariel
    | Simba
    | Mufasa
    | Woody


type Movie
    = LittleMermaid
    | LionKing
    | ToyStory


characterToMovie : Dict Character Movie
characterToMovie =
    Dict.fromList
        [ ( Ariel, LittleMermaid )
        , ( Simba, LionKing )
        , ( Mufasa, LionKing )
        , ( Woody, ToyStory )
        ]


main : Html msg
main =
    Html.text <|
        case Dict.get Simba characterToMovie of
            Just LionKing ->
                "Simba was in The Lion King"

            Just _ ->
                "Simba was not in The Lion King"

            Nothing ->
                "I am not sure who Simba is"
