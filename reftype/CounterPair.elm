module CounterPair where

import Counter
import Html exposing (Html, div)
import Ref exposing (Ref)


type alias Model = {topCounter: Counter.Model, bottomCounter: Counter.Model}

init : Counter.Model -> Counter.Model -> Model
init x y = {topCounter = x, bottomCounter = y}

view : Ref Model -> Html
view model = div [] [
        Counter.view (Ref.field model "topCounter"),
        Counter.view (Ref.field model "bottomCounter")
    ]


main : Signal Html
main = Signal.map view (Ref.signal (init 0 0))
