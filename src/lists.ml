let head_tail lst n =
    let head = ref [] in
    let tail = ref [] in
    for i = (List.length lst) downto 1 do
        if (List.length lst) - i < n then
            tail := (List.nth lst (i-1)) :: !tail
        else
            head := (List.nth lst (i-1)) :: !head
    done;
    !head, !tail

let update_list lst n new_value =
    let i = ref (-1) in
    List.map (fun x ->
        i := !i + 1;
        if !i == n then
            new_value
        else
            x)
        lst

