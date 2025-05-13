let log () =
  let minor, promoted, major = Gc.counters () in
  Printf.printf "minor: %f promoted:%f major:%f\n" minor promoted major

let () =
  log ();
  let arg n = Sys.argv.(n) |> int_of_string |> (lsl) 1 in
  let rec loop i =
    if i = 0 then ()
    else begin
      let _ = Array.init (arg 1) Fun.id in
      loop (i - 1)
    end
  in
  loop (arg 2);
  log ()
