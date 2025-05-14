let log () =
  let minor, promoted, major = Gc.counters () in
  Printf.printf "minor: %f promoted:%f major:%f\n" minor promoted major

let () =
  print_endline Sys.ocaml_version;
  log ();
  let arg n = Sys.argv.(n) |> int_of_string |> (lsl) 1 in
  let rec loop i =
    if i = 0 then ()
    else begin
      (* let _ = String.init (arg 1) (fun i -> char_of_int (i mod 256)) in *)
      (* let _a = Array.init (arg 1) (fun i -> i mod 256) in *)
      let _a = Base.Array.init (arg 1) ~f:(fun i -> i mod 256) in
      loop (i - 1)
    end
  in
  loop (arg 2);
  log ()
