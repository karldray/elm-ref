module Ref where

import Native.Ref
import Signal exposing (Address, Mailbox, Message)


type alias Ref t = {value: t, address: Address t}


-- address builders for use in Html event attributes

set : Ref t -> Address t
set r = r.address

transform : Ref t -> Address (t -> t)
transform r = Signal.forwardTo r.address (\f -> f r.value)


-- apply a "focus" to a ref

type alias FieldSpec t u = {get: t -> u, set: u -> t -> t}

map : FieldSpec t u -> Ref t -> Ref u
map f r = {
    value = f.get r.value,
    address = Signal.forwardTo (transform r) (f.set)
    }


-- create a focus from a named field

fieldSpec : String -> FieldSpec t u
fieldSpec = Native.Ref.fieldSpec


-- create a ref to a member of a ref'd record

field : String -> Ref t -> Ref u
field = fieldSpec >> map


-- helpers for defining the top-level main signal

fromMailbox : Mailbox t -> Signal (Ref t)
fromMailbox m = Signal.map (\x -> {value = x, address = m.address}) m.signal

signal : t -> Signal (Ref t)
signal = fromMailbox << Signal.mailbox
