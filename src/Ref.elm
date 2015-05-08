module Ref (Ref, Focus, focus, map, transform, set, signal, fromMailbox) where
{-| A `Ref` represents a "mutable" piece of data that might exist inside a larger data structure.
It exposes the current value of that data and encapsulates the information needed to update it.

# Creating top-level Refs
@docs signal, fromMailbox

# Manipulating Refs
These functions help you work with references to records.
For working with references to collections, see the Array.Ref and Dict.Ref modules.
@docs Focus, focus, map

# Address builders for use in Html.Events attributes
@docs transform, set
-}

import Signal exposing (Address, Mailbox, Message)


type alias Ref t = {value: t, address: Address t}


{-| Create an Address that replaces the referenced value with whatever you send it. -}
set : Ref t -> Address t
set r = r.address

{-| Create an Address that updates the referenced value by applying functions to it. -}
transform : Ref t -> Address (t -> t)
transform r = Signal.forwardTo r.address (\f -> f r.value)


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

{-| Apply a Focus to a "big" Ref, creating a reference to the "small" value inside it. -}
map : Focus t u -> Ref t -> Ref u
map f r = {
    value = f.get r.value,
    address = Signal.forwardTo (transform r) (f.set)
    }


{-| Create a Ref that refers to the value in a Mailbox. -}
fromMailbox : Mailbox t -> Signal (Ref t)
fromMailbox m = Signal.map (\x -> {value = x, address = m.address}) m.signal

{-| Create a new mutable object with the given initial value. -}
signal : t -> Signal (Ref t)
signal = fromMailbox << Signal.mailbox
