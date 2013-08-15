module Fun = struct
    type t = Types.funsymb * string
    let compare = compare
end

module FunMap = Map.Make(Fun)
