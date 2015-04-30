module IdListRef where

import IdList exposing (IdList)
import Ref exposing (Ref, transform)
import Signal


-- create a ref to an element in a ref'd IdList

item : Ref (IdList t) -> (Int, t) -> Ref t
item list (id, val) = {
        value = val,
        address = Signal.forwardTo (Ref.transform list) (IdList.set id)
    }


-- map over a ref'd IdList, passing elements "by reference" to the provided function

map : (Ref t -> u) -> Ref (IdList t) -> List u
map f list = List.map (f << item list) list.value
