module Ref (Ref, field, transform, set, signal, fromMailbox) where
{-| A `Ref` represents a "mutable" piece of data that might exist inside a larger data structure.
It exposes the current value of that data and encapsulates the information needed to update it.

Refs can simplify building modular UI components that know how to update themselves.
A typical module might look like this:

```elm
type alias Model = {foo: String, widget: Widget.Model}

changeFoo : String -> Model -> Model
changeFoo x model = {model | foo <- x}

view : Ref Model -> Html
view model =
    div [] [
        text model.value.foo, -- model.value is our Model
        (button
            [onClick (transform model) (changeFoo "Hello")] -- on click, perform an update
            [text "Hi"]
        ),
        -- pass the contained widget's model "by reference" to its module's view function 
        Widget.view (Ref.field "widget" model)
    ]

main : Signal Html
main = Signal.map view (Ref.signal initialModel)
```

Note: When using Refs, an Action type (as described in
[the Elm Architecture](https://github.com/evancz/elm-architecture-tutorial#the-elm-architecture))
is not part of a typical module's public API.
However, it's good practice to keep model-manipulating code separate from view logic.
Your module should still use an abstraction like Actions
so that you can change the behavior of your updates without touching view code.


# Fields
@docs field

# Array and Dict elements
See Array.Ref. Dict.Ref doesn't exist yet.

# Address builders for use in Html.Events attributes
@docs transform, set

# Creating top-level Refs
@docs signal, fromMailbox
-}

import Native.Ref
import Signal exposing (Address, Mailbox, Message)


type alias Ref t = {value: t, address: Address t}


-- address builders for use in Html event attributes

{-| Create an Address that replaces the referenced value with whatever you send it. -}
set : Ref t -> Address t
set r = r.address

{-| Create an Address that updates the referenced value by applying functions to it. -}
transform : Ref t -> Address (t -> t)
transform r = Signal.forwardTo r.address (\f -> f r.value)


-- focus stuff

{-| A Focus describes how to get and set a value of one type inside a value of another type. -}
type alias Focus t u = {get: t -> u, set: u -> t -> t}

{-| Apply a Focus to a Ref. -}
map : Focus t u -> Ref t -> Ref u
map f r = {
    value = f.get r.value,
    address = Signal.forwardTo (transform r) (f.set)
    }

{-| Create a Focus representing a record field with the provided name. -}
fieldSpec : String -> Focus t u
fieldSpec = Native.Ref.fieldSpec


{-| Create a reference to a field of a referenced record. -}
field : String -> Ref t -> Ref u
field = fieldSpec >> map


-- helpers for defining the top-level main signal

{-| Create a Ref that refers to the value in a Mailbox. -}
fromMailbox : Mailbox t -> Signal (Ref t)
fromMailbox m = Signal.map (\x -> {value = x, address = m.address}) m.signal

{-| Create a new mutable object with the given initial value. -}
signal : t -> Signal (Ref t)
signal = fromMailbox << Signal.mailbox
