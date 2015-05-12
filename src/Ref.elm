module Ref (Ref, Focus, focus, map, fst, snd, destructure, transform, set, new) where
{-| A `Ref` represents a "mutable" piece of data that might exist inside a larger data structure.
It exposes the current value of that data and encapsulates the information needed to update it.

# Creating top-level Refs
@docs new

# Manipulating Refs

## Records
@docs Focus, focus, map

## Tuples
@docs fst, snd, destructure

## Collections
See the Array.Ref and Dict.Ref modules.


# Address builders for use in Html.Events attributes
@docs transform, set
-}

import Signal exposing (Address, Mailbox, Message)


type alias Ref t = {value: t, address: Address (t -> t)}


{-| Create an Address that replaces the referenced value with whatever you send it. -}
set : Ref t -> Address t
set r = Signal.forwardTo r.address always

{-| Create an Address that updates the referenced value by applying functions to it. -}
transform : Ref t -> Address (t -> t)
transform r = r.address


{-| A Focus describes how to get and set a value of one type inside a value of another type.
The `get` function takes a "big" value and returns the "small" value inside it.
The `set` function takes a new "small" value and an old "big" value
and returns an updated "big" value.
-}
type alias Focus t u = {get: t -> u, set: u -> t -> t}

{-| Create a Focus from a pair of `get` and `set` functions.
Typically, you'll use this to represent a field of a record type:

```elm
fooField = Ref.focus .foo (\x m -> {m | foo <- x})
```
-}
focus : (t -> u) -> (u -> t -> t) -> Focus t u
focus get set = {get = get, set = set}

{-| Convert an update function for small objects into an update function for big objects. -}
mapUpdate : Focus t u -> (u -> u) -> t -> t
mapUpdate f smallUpdate big = f.set (smallUpdate (f.get big)) big

{-| Apply a Focus to a "big" Ref, creating a reference to the "small" value inside it. -}
map : Focus t u -> Ref t -> Ref u
map f r = {
    value = f.get r.value,
    address = Signal.forwardTo (transform r) (mapUpdate f)
    }


{-| Split a referenced pair into two references. -}
destructure : Ref (a, b) -> (Ref a, Ref b)
destructure r = (fst r, snd r)

{-| Refer to the first element of a pair. -}
fst : Ref (a, b) -> Ref a
fst = map (focus Basics.fst (\x (_, y) -> (x, y)))

{-| Refer to the second element of a pair. -}
snd : Ref (a, b) -> Ref b
snd = map (focus Basics.snd (\y (x, _) -> (x, y)))

-- inverse of destructure? what about building records? when would these be useful?


{-| Create a new mutable object with the given initial value. -}
new : t -> Signal (Ref t)
new initialValue =
    let mailbox = Signal.mailbox identity
        value = Signal.foldp identity initialValue mailbox.signal
    in  Signal.map (\x -> {value = x, address = mailbox.address}) value
