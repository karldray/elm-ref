module CounterList where

import Counter
import Html exposing (Html, div, button, text)
import Html.Events exposing (onClick)
import IdList exposing (IdList)
import IdListRef
import Ref exposing (Ref, transform)


type alias Model = IdList Counter.Model

init : List Counter.Model -> Model
init = IdList.fromList

addBtn : Ref Model -> Html
addBtn model = button [onClick (transform model) (IdList.prepend 0)] [text "+"]

view1 : Ref Model -> Html
view1 model = div [] (
        [addBtn model]
        ++
        IdListRef.map Counter.view model
    )

view2 : Ref Model -> Html
view2 model = div [] (
        [addBtn model]
        ++
        List.map (\item ->
            let id = fst item
                counter = IdListRef.item model item
                remove = Signal.forwardTo (transform model) (always (IdList.remove id))
            in  Counter.viewWithRemove counter remove
        ) model.value
    )


main : Signal Html
main = Signal.map view2 (Ref.signal (init []))
