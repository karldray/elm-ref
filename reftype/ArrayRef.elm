module ArrayRef where

import Array exposing (Array)
import Maybe
import Ref exposing (Ref, transform)
import Signal


-- create a ref to the element at a given index in an array

get : Int -> Ref (Array t) -> Maybe (Ref t)
get index array = Maybe.map (\v -> item index v array) (Array.get index array.value)

-- like get, but use the provided value and don't check that the index is in bounds

item : Int -> t -> Ref (Array t) -> Ref t
item index value array =
    { value = value
    , address = Signal.forwardTo (Ref.transform array) (Array.set index)
    }

-- map over a ref'd array, passing elements "by reference" to the provided function

indexedMap : (Int -> Ref t -> u) -> Ref (Array t) -> Array u
indexedMap f array = Array.indexedMap (\i x -> f i (item i x array)) array.value

map : (Ref t -> u) -> Ref (Array t) -> Array u
map f = indexedMap (\i x -> f x)
