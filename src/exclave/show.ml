[@@@ocaml.warning "-32"]

let list_show : ('a -> string) -> 'a list -> string = fun f u ->
  let rec loop : string -> 'a list -> string = fun acc u ->
    match u with
    | [] -> acc
    | x :: u -> loop (acc ^ f x) u in
  loop "" u

let list_show : ('a -> local_ string) -> 'a list -> string = fun f u ->
  let rec loop : local_ string -> 'a list -> local_ string = fun acc u ->
    match u with
    | [] -> acc
    | x :: u ->
      exclave_
      let local_ s = Base.String.append acc (f x) in
      loop s u in
  let result = Base.String.globalize (loop "" u) in
  result
