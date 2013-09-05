let rec last = function
   [] -> raise (Failure "last")
 | [x] -> x
 | x::l -> last l

(* Return (a,b) where a contains the first n items of l,
   and b contains the rest. *)
let rec slice n l =
  match n, l with
  | 0, l    -> ([], l)
  | n, []   -> raise (Failure "slice")
  | n, x::l ->
    let a, b = slice (n-1) l in
    (x::a, b)

let rec map4 f l1 l2 l3 l4 =
  match (l1, l2, l3, l4) with
     ([], [], [], []) -> []
   | (x1::l1, x2::l2, x3::l3, x4::l4) -> (f x1 x2 x3 x4) :: (map4 f l1 l2 l3 l4)
   | (_, _, _, _) -> raise (Failure "map4")

let bisect l =
  let len = List.length l in
  if len mod 2 <> 0 then raise (Failure "bisect");
  let rec peel n l =
    match (n, l) with
      | n, x::l when n > 0 ->
        let (l,r) = peel (n-1) l in
        (x::l, r)
      | 0, l ->
        ([], l)
  in peel (len / 2) l
