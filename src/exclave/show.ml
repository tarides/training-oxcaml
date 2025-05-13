[@@@ocaml.warning "-32"]

let list_show : ('a -> string) -> 'a list -> string = fun f u ->
  let rec loop : string -> 'a list -> string = fun acc u ->
    match u with
    | [] -> acc
    | x :: u -> loop (acc ^ f x) u in
  loop "" u

let list_append_local : local_ string -> local_ string -> local_ string = failwith "nope, sorry"

let list_show : ('a -> local_ string) -> 'a list -> string = fun f u ->
  let rec loop : local_ string -> 'a list -> local_ string = fun acc u ->
    match u with
    | [] -> acc
    | x :: u ->
      exclave_
      let local_ s = list_append_local acc (f x) in
      loop s u in
  let result = Base.String.globalize (loop "" u) in
  result

let array_set_local : local_ 'a array -> int -> local_ 'a -> unit = failwith "nope, sorry"

let list_show : ('a -> local_ string) -> 'a list -> string = fun f u ->
  let len = Base.List.length u in
  let local_ a = Base.Array.create_local ~len "" in
  let rec init_loop (local_ i : int) = function
    | [] -> ()
    | x :: u -> let local_ s = f x in array_set_local a i s; init_loop (i + 1) u in
  init_loop 0 u;
  let result = Base.String.concat_array ~sep:"; " a in
  result
