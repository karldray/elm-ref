module CounterDict where

import Dict exposing (Dict)
import Dict.Ref
import Counter
import Html exposing (Html, button, div, input, span, text)
import Html.Attributes exposing (value)
import Html.Events exposing (on, onClick, targetValue)
import Ref exposing (Ref, set, transform)


type alias Model =
    { name : String
    , counters : Dict String Counter.Model
    }

init : Model
init =
    { name = "foo"
    , counters = Dict.empty
    }

nameField = Ref.focus .name (\x m -> {m | name <- x})
countersField = Ref.focus .counters (\x m -> {m | counters <- x})

view : Ref Model -> Html
view model =
    let
        name = Ref.map nameField model
        counters = Ref.map countersField model
        currentCounter = Dict.Ref.get name.value counters
    in
        div [] (
            [div [] [
                input [
                    value name.value,
                    on "input" targetValue (Signal.message (set name))
                ] [],
                case currentCounter of
                    Nothing ->
                        button [
                            onClick (transform counters) (Dict.insert name.value (Counter.init 0))
                        ] [text ("add " ++ name.value)]
                    Just counter ->
                        span [] [
                            text (name.value ++ ": "),
                            Counter.view counter
                        ]
            ]]
            ++
            Dict.Ref.mapToList (\k v ->
                let remove = Signal.forwardTo (transform counters) (always (Dict.remove k))
                in  div [] [
                        Counter.viewWithRemove v remove,
                        text k
                    ]
            ) counters
        )


main : Signal Html
main = Signal.map view (Ref.new init)
