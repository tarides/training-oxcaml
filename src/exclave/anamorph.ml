[@@@ocaml.warning "-32"]

let rec unfold : ('a -> ('b * 'a) option) -> 'a -> 'b list = fun f x ->
  match f x with
    | Some (y, x) -> y :: unfold f x
    | None -> []

type ('a, 'b) glocal_pair = {
  global_ fst : 'a;
  snd : 'b;
}

let rec unfold : (local_ 'a -> ('b, 'a) glocal_pair option) -> local_ 'a -> 'b list = fun f x ->
  let local_ y = f x in
  match y with
    | Some { fst; snd } -> fst :: unfold f snd
    | None -> []
