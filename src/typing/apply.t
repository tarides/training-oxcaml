  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let local_ x = "abc" in
  >   let _ = Typing.Arrow.global_to_local x in
  >   ();;

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let local_ x = "abc" in
  >   let _ = Typing.Arrow.global_to_global x in
  >   ();;

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let local_ x = "abc" in
  >   let _ = Typing.Arrow.local_to_local x in
  >   ();;

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let local_ x = "abc" in
  >   let _ = Typing.Arrow.local_to_global x in
  >   ();;

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let x = "abc" in
  >   let _ = Typing.Arrow.global_to_local x in
  >   ();;

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let x = "abc" in
  >   let _ = Typing.Arrow.global_to_global x in
  >   ();;

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let x = "abc" in
  >   let _ = Typing.Arrow.local_to_local x in
  >   ();;

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > let _ =
  >   let x = "abc" in
  >   let _ = Typing.Arrow.local_to_global x in
  >   ();;
