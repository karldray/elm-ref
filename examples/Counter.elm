module Counter where

import Html exposing (Html, button, span, text)
import Html.Events exposing (onClick)
import Ref exposing (Ref, transform)


type alias Model = Int

init : Int -> Model
init n = n


view : Ref Model -> Html
view model =
    button [onClick (transform model) (\n -> n + 1)] [text (toString model.value)]

viewWithRemove : Ref Model -> Signal.Address () -> Html
viewWithRemove model remove =
    span [] [
            view model,
            button [onClick remove ()] [text "x"]
        ]


main : Signal Html
main = Signal.map view (Ref.new (init 0))
