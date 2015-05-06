A `Ref` represents a "mutable" piece of data that might exist inside a larger data structure.
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

## Full examples

Ref-based versions of Counter, CounterPair, and CounterList
in the style of the Elm Architecture tutorial are
[here](https://github.com/karldray/elm-ref/tree/master/examples).
