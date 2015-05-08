module Ref (Ref, Focus, focus, map, transform, set, signal, fromMailbox) where
{-| A `Ref` represents a "mutable" piece of data that might exist inside a larger data structure.
It exposes the current value of that data and encapsulates the information needed to update it.

Refs can simplify building modular UI components that know how to update themselves.
A typical module might look like this:

```elm
type alias Model =
    { foo: String
    , widget: Widget.Model,
    , bloops: Array Bloop.Model
    }

-- a model-updating function
changeFoo : String -> Model -> Model
changeFoo x model = {model | foo <- x}


-- create Focus objects that represent fields of our Model type.
widgetFocus = Ref.focus .widget (\x m -> {m | widget <- x})
bloopsFocus = Ref.focus .bloops (\x m -> {m | bloops <- x})


view : Ref Model -> Html
view model =
    let
        -- create Refs to fields of our model record
        widget = Ref.map widgetFocus model
        bloops = Ref.map bloopsFocus model
    in
        div [] [
            -- model.value is our Model
            text model.value.foo,

            -- on click, perform an update
            (button [onClick (transform model) (changeFoo "Hello")] [text "Hi"]),

            -- pass a nested component's model "by reference" to its module's view function 
            Widget.view widget,

            -- map over an array, passing elements "by reference" to a view function
            span [] (Array.Ref.map Bloop.view bloops)
        ]


main : Signal Html
main = Signal.map view (Ref.signal initialModel)

```

## Full examples

Ref-based versions of Counter, CounterPair, and CounterList
in the style of the Elm Architecture tutorial are
[here](https://github.com/karldray/elm-ref/tree/master/examples).

## Note on model-view separation

In this pattern, an Action type (as described in
[the Elm Architecture](https://github.com/evancz/elm-architecture-tutorial#the-elm-architecture))
is not part of a typical module's public API.
However, it's still good practice to keep model-manipulating code separate from view logic,
and you can still use an Action type to help with this.
Just partially-apply your update function when constructing event handlers:

```elm
onClick (transform model) (update MyAction)
```

In fact, using Actions is easier in a Ref-based module because
you don't need to thread nested components' actions through your own Action/update code!


# Creating Refs
@docs Focus, focus, map

# Array.Ref and Dict.Ref
These modules help you:
- Create Refs that point to elements inside collections
- Map over collections, passing elements "by reference" to a function

# Address builders for use in Html.Events attributes
@docs transform, set

# Creating top-level Refs
@docs signal, fromMailbox
-}

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

{-| A Focus describes how to get and set a value of one type inside a value of another type.
The `get` function takes a "big" value and returns the "small" value inside it.
The `set` function takes a new "small" value and an old "big" value
and returns an updated "big" value.
-}
type alias Focus t u = {get: t -> u, set: u -> t -> t}

{-| Create a focus from `get` and `set` functions. -}
focus : (t -> u) -> (u -> t -> t) -> Focus t u
focus get set = {get = get, set = set}

{-| Apply a Focus to a Ref. -}
map : Focus t u -> Ref t -> Ref u
map f r = {
    value = f.get r.value,
    address = Signal.forwardTo (transform r) (f.set)
    }


-- helpers for defining the top-level main signal

{-| Create a Ref that refers to the value in a Mailbox. -}
fromMailbox : Mailbox t -> Signal (Ref t)
fromMailbox m = Signal.map (\x -> {value = x, address = m.address}) m.signal

{-| Create a new mutable object with the given initial value. -}
signal : t -> Signal (Ref t)
signal = fromMailbox << Signal.mailbox
