(* print additional debugging information *)

let debug_print s =
  (if !Param.debug_output then 
    Printf.printf "%s" s
  else
      ())
	

