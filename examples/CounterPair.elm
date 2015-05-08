module CounterPair where

import Counter
import Html exposing (Html, div)
import Ref exposing (Ref)


type alias Model = {left: Counter.Model, right: Counter.Model}

init : Counter.Model -> Counter.Model -> Model
init x y = {left = x, right = y}


leftField = Ref.focus .left (\x m -> {m | left <- x})
rightField = Ref.focus .right (\x m -> {m | right <- x})

view : Ref Model -> Html
view model = div [] [
        Counter.view (Ref.map leftField model),
        Counter.view (Ref.map rightField model)
    ]


main : Signal Html
main = Signal.map view (Ref.new (init 0 0))
