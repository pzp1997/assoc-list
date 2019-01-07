# Association lists

An [association list](https://en.wikipedia.org/wiki/Association_list) is a list of tuples that map unique keys to values. The keys can be of any type (so long as it has a reasonable definition for equality). This includes pretty much everything except for functions and things that contain functions.

## Usage

This library is intended to be used as a drop-in replacement for the `Dict` module in elm/core. You might use it like so,

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

(Note the use of a custom type as the dictionary key, which is not possible with the `Dict` module in elm/core!)

## Performance

Since this library does not require your keys to be `comparable`, some operations are asymptotically slower than those in the `Dict` module in elm/core. The good news is that if you are working with small-ish dictionaries, this is likely not a problem. Furthermore, the bottleneck point in most Elm programs is DOM manipulation, so slower data structure operations are unlikely to cause a noticeable difference in how your app performs. For a detailed comparison of the performance characteristics of the two implementations, see [Performance.md](https://github.com/pzp1997/assoc-list/blob/master/Performance.md).

## Comparison to existing work

### Dictionary with non-comparable keys

All the existing libraries that I have found that attempt to solve the dictionary with non-comparable keys problem suffer from at least one of the following issues:

1.  stores a function for converting keys to `comparable` within the data structure itself

    -   can cause runtime errors should you ever use the `==` operator to compare the structures
    -   makes serialization trickier (for this reason, conventional wisdom states that you should "never put functions in your `Model` or `Msg` types")
    -   see this [Discourse post](https://discourse.elm-lang.org/t/consequences-of-functions-in-the-model-with-0-19) and this [Elm Discuss thread](https://groups.google.com/forum/#!topic/elm-discuss/bOAHwSnklLc) for more information

2.  does not provide full type-level safety against operating on two dictionaries with different comparators, e.g. `union (singleton identity 0 'a') (singleton (\x -> x + 1) 1 'b')`

Here is a detailed analysis of all the relevant libraries I could find:

turboMaCk/any-dict

-   suffers from problems (1) and (2)

rtfeldman/elm-sorter-experiment

-   suffers from problem (1)

jjant/elm-dict

-   similar to problem (1), the data structure itself is actually a function
-   does not support the entire `Dict` API from elm/core

eeue56/elm-all-dict

-   suffers from problems (1) and (2)
-   some parts of the library rely on Kernel code, making it non-trivial to update to 0.19

robertjlooby/elm-generic-dict

-   suffers from problem (1)
-   has not been updated to 0.19 as of time of writing

### Ordered dictionary

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
