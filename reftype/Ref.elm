module Ref where

import Native.Ref
import Signal exposing (Address, Mailbox, Message)


type alias Ref t = {value: t, address: Address t}


-- address builders for use in Html event attributes

set : Ref t -> Address t
set r = r.address

transform : Ref t -> Address (t -> t)
transform r = Signal.forwardTo r.address (\f -> f r.value)


-- create a ref to a member of a ref'd object

type alias FieldSpec t u = {get: t -> u, set: u -> t -> t}

fieldSpec : String -> FieldSpec t u
fieldSpec = Native.Ref.fieldSpec

field : Ref t -> String -> Ref u
field r name =
    let f = fieldSpec name
    in {
        value = f.get r.value,
        address = Signal.forwardTo (transform r) f.set
    }


-- helpers for defining the top-level main signal

fromMailbox : Mailbox t -> Signal (Ref t)
fromMailbox m = Signal.map (\x -> {value = x, address = m.address}) m.signal

signal : t -> Signal (Ref t)
signal = fromMailbox << Signal.mailbox
