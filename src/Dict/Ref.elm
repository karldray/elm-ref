module Dict.Ref (get, map) where
{-| Tools for dealing with `Ref Dict` values.
These functions are analagous to the corresponding ones from the Dict module.

See
[CounterDict.elm](https://github.com/karldray/elm-ref/blob/master/examples/CounterDict.elm)
for example usage.

@docs get, map
-}

import Dict exposing (Dict)
import Maybe
import Ref exposing (Ref, transform)
import Signal


{-| Refer to the element at a given key in a dictionary. -}
get : comparable -> Ref (Dict comparable a) -> Maybe (Ref a)
get key dict = Maybe.map (\v -> item key v dict) (Dict.get key dict.value)

{-| Apply an update function to the element at a given key in a dictionary.
Does nothing if the key isn't in the dictionary.
-}
updateAt : comparable -> (a -> a) -> Dict comparable a -> Dict comparable a
updateAt key f dict = case Dict.get key dict of
    Nothing -> dict
    Just val -> Dict.insert key (f val) dict

{-| Like `get`, but use the provided value and don't check that the key exists. -}
item : comparable -> a -> Ref (Dict comparable a) -> Ref a
item key value dict =
    { value = value
    , address = Signal.forwardTo (transform dict) (updateAt key)
    }

{-| Map over a dictionary, passing keys and values to the provided function.
Values (but not keys) are passed "by reference". -}
map : (comparable -> Ref a -> b) -> Ref (Dict comparable a) -> Dict comparable b
map f dict = Dict.map (\k v -> f k (item k v dict)) dict.value
