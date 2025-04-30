module Input : sig
  type t
  val start : string -> t
  val read : t -> string
  val read_ : t @ local -> string
  val close : t -> unit
end = struct
  type t = string
  exception Found of int
  let state : string option array = Array.make 256 None

  let index what =
    try
      for i = 0 to 255 do if state.(i) = what then raise (Found i) done;
      raise Not_found
    with Found i -> i

  let start : string -> t = fun name ->
    state.(index None) <- Some name;
    name

  let read : t -> string = fun handle ->
    ignore (index (Some handle));
    "42"

  let read_ : t @ local -> string = fun handle ->
    ignore (index (Some handle));
    "42"

  let close handle =
    state.(index (Some handle)) <- None

end

let with_input (f : Input.t -> 'a) name =
  let sin = Input.start name in
  let x = f sin in
  Input.close sin;
  x

let with_input_ (f : Input.t @ local -> 'a) name =
  let sin = Input.start name in
  let x = f sin in (* sin promoted *)
  Input.close sin;
  x

(*
Session.(with_input Input.read "foo")    pass
Session.(with_input Input.read_ "foo")   pass, read_ promoted
Session.(with_input_ Input.read "foo")   fail
Session.(with_input_ Input.read_ "foo")  pass
*)
