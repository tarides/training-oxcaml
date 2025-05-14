let log () =
  let minor, promoted, major = Gc.counters () in
  Printf.printf "minor: %f promoted:%f major:%f\n" minor promoted major

let arg n = Sys.argv.(n) |> int_of_string |> (lsl) 1

type ('a, 'b) glocal_pair = {
  global_ fst : 'a;
  snd : 'b;
}

let rec unfold : (local_ 'a -> ('b, 'a) glocal_pair option) -> local_ 'a -> 'b list = fun f x ->
  let local_ y = f x in
  match y with
    | Some { fst; snd } -> fst :: unfold f snd
    | None -> []

let () =
  print_endline Sys.ocaml_version;
  log ();
  let _a = unfold (fun n -> let n = Base.Int.of_string n in if n > 0 then Some { fst = n; snd = Base.Int.to_string (n - 1) } else None) (Base.Int.to_string (arg 1)) in ();
  log ()
