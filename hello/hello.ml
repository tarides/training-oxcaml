external globalize_string : string @ local -> string = "%obj_dup"

let () =
  let local_message : string @@ local = "Hello, World" in
  (* Can't print [local_message] -- the value would escape. *)
  let global_message = globalize_string local_message in
  (* Copy the string to create a new global value. *)
  print_endline global_message
;;
