# Association lists

An [association list](https://en.wikipedia.org/wiki/Association_list) is a
list of tuples that map unique keys to values. The keys can be of any type (so
long as it has a reasonable definition for equality). This includes pretty
much everything except for functions and things that contain functions.

## Usage

This library is intended to be used as a drop-in replacement for the `Dict`
module in elm/core. You might use it like so,

```elm
import AssocList as Dict exposing (Dict)

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

Dict.get Simba characterToMovie --> Just LionKing
```

(Note the use of a custom type as the dictionary key, which is not possible with the `Dict` module in elm/core.)

## Performance

Since this library does not require your keys to be `comparable`, some
operations are asymptotically slower than those in the `Dict` module in
elm/core. If you are working with small-ish dictionaries, this is likely not
a problem. Furthermore, the bottleneck point in most Elm programs is DOM
manipulation, so slower data structure operations are unlikely to cause a
noticable difference in how your app performs. For a detailed comparison of
the performance characteristics of the two implementations, see
[Performance.md](Performance.md).

## Comparison to existing solutions

#### Dictionary with non-comparable keys

The majority of the existing libraries that attempt to solve the dictionary with non-comparable keys problem suffer from at least one of the following problems:

1.  stores function for converting keys to `comparable` within the data structure itself
2.  does not provide full type-level safety against operating on two dictionaries with different comparators, e.g. `union (singleton identity 0 'a') (singleton (\x -> x + 1) 1 'b')`

Here is a detailed analysis of all the relevant libraries I could find:

turboMaCk/any-dict

-   suffers from problems (1) and (2)

jjant/elm-dict

-   similar to problem (1), the data structure itself is actually a function
-   does not support the entire `Dict` API from elm/core

eeue56/elm-all-dict

-   suffers from problems (1) and (2)
-   some non-essential parts of the library rely on Kernel code, making it non-trivial to update to 0.19

robertjlooby/elm-generic-dict

-   suffers from problem (1)
-   suffers from problem (2), although the documentation does specify how the library will behave in these cases
-   has not been updated to 0.19 as of time of writing

#### Ordered dictionary

Although not the primary problem that this library aims to solve, assoc-list can also be used as an ordered dictionary, i.e. a dictionary that keeps track of the order in which entries were inserted. This functionality is similar to the following libraries:

y0hy0h/ordered-containers

-   requires the keys to be `comparable`

wittjosiah/elm-ordered-dict

-   requires the keys to be `comparable`
-   has not been updated to 0.19 as of time of writing

rnons/ordered-containers

-   requires the keys to be `comparable`
-   has not been updated to 0.19 as of time of writing

eliaslfox/orderedmap

-   requires the keys to be `comparable`
-   has not been updated to 0.19 as of time of writing
