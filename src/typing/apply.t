Local values can't be passed to functions that don't respect the locality contract
  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let local_ x = "abc" in
  >   let _ = Typing.Arrow.global_to_local x in
  >   ();;
  Line 3, characters 39-40:
  3 |   let _ = Typing.Arrow.global_to_local x in
                                             ^
  Error: This value escapes its region.

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let local_ x = "abc" in
  >   let _ = Typing.Arrow.global_to_global x in
  >   ();;
  Line 3, characters 40-41:
  3 |   let _ = Typing.Arrow.global_to_global x in
                                              ^
  Error: This value escapes its region.

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let local_ x = "abc" in
  >   let _ = Typing.Arrow.local_to_local x in
  >   ();;
  - : unit = ()

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let local_ x = "abc" in
  >   let _ = Typing.Arrow.local_to_global x in
  >   ();;
  - : unit = ()

Global parameter are always applicable
  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let x = "abc" in
  >   let _ = Typing.Arrow.global_to_local x in
  >   ();;
  - : unit = ()

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let x = "abc" in
  >   let _ = Typing.Arrow.global_to_global x in
  >   ();;
  - : unit = ()

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let x = "abc" in
  >   let _ = Typing.Arrow.local_to_local x in
  >   ();;
  - : unit = ()

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let x = "abc" in
  >   let _ = Typing.Arrow.local_to_global x in
  >   ();;
  - : unit = ()
