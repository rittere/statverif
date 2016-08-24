(* print additional debugging information *)

let debug_print = 
  if !Param.debug_output then 
    Printf.printf 
  else fun _ -> ()

