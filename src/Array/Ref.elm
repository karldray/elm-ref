module Array.Ref (get, indexedMap, map) where
{-| Tools for dealing with `Ref Array` values.
These functions are analagous to the corresponding ones from the Array module.

See
[CounterList.elm](https://github.com/karldray/elm-ref/blob/master/examples/CounterList.elm)
for example usage.

@docs get, map, indexedMap
-}

import Array exposing (Array)
import Maybe
import Ref exposing (Ref, transform)
import Signal


{-| Refer to the element at a given index in an array. -}
get : Int -> Ref (Array t) -> Maybe (Ref t)
get index array = Maybe.map (\v -> item index v array) (Array.get index array.value)

{-| Apply an update function to the element at a given index in an array.
Does nothing if the index is out of bounds.
-}
updateAt : Int -> (a -> a) -> Array a -> Array a
updateAt i f a = case Array.get i a of
    Nothing -> a
    Just val -> Array.set i (f val) a

{-| Like `get`, but use the provided value and don't check that the index is in bounds. -}
item : Int -> t -> Ref (Array t) -> Ref t
item index value array =
    { value = value
    , address = Signal.forwardTo (transform array) (updateAt index)
    }

{-| Like `map`, but also passes element indexes to the provided function. -}
indexedMap : (Int -> Ref t -> u) -> Ref (Array t) -> Array u
indexedMap f array = Array.indexedMap (\i x -> f i (item i x array)) array.value

{-| Map over an array, passing elements "by reference" to the provided function. -}
map : (Ref t -> u) -> Ref (Array t) -> Array u
map f = indexedMap (\i x -> f x)
