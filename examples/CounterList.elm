module CounterList where

import Array exposing (Array)
import Array.Extra
import Array.Ref
import Counter
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Ref exposing (Ref, transform)


type alias Model = Array Counter.Model

init : List Counter.Model -> Model
init = Array.fromList


addBtn : Ref Model -> Html
addBtn model = button [onClick (transform model) (Array.push (Counter.init 0))] [text "+"]

view1 : Ref Model -> Html
view1 model = div [] (
        [addBtn model]
        ++
        Array.toList (Array.Ref.map Counter.view model)
    )

view2 : Ref Model -> Html
view2 model = div [] (
        [addBtn model]
        ++
        Array.toList (Array.Ref.indexedMap (\i counter ->
            let remove = Signal.forwardTo (transform model) (always (Array.Extra.removeAt i))
            in  Counter.viewWithRemove counter remove
        ) model)
    )

viewBoth : Ref Model -> Html
viewBoth model = div [] [view1 model, view2 model]


main : Signal Html
main = Signal.map viewBoth (Ref.signal (init []))
