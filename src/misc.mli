val last : 'a list -> 'a
val slice : int -> 'a list -> ('a list * 'a list)
val map4 : ('a -> 'b -> 'c -> 'd -> 'e)
  -> 'a list -> 'b list -> 'c list -> 'd list -> 'e list
val bisect : 'a list -> ('a list * 'a list)
