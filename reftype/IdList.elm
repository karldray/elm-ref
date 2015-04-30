module IdList where


type alias IdList t = List (Int, t)


--basics

elements : IdList t -> List t
elements = List.map snd

fromList : List t -> IdList t
fromList = List.indexedMap (,)


-- should be private

unusedId : IdList t -> Int
unusedId = List.map fst >> List.maximum >> Maybe.withDefault 0 >> (\n -> n + 1)


-- mutators

prepend : t -> IdList t -> IdList t
prepend x list = (unusedId list, x) :: list

remove : Int -> IdList t -> IdList t
remove id = List.filter (fst >> (/=) id)

update : Int -> (t -> t) -> IdList t -> IdList t
update id f = List.map (\(i, x) -> (i, if i == id then f x else x))

set : Int -> t -> IdList t -> IdList t
set id = update id << always
