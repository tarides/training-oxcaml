A `global` to `local` function is at the top of the lattice, it can't be used in any other context
  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.bot Arrow.global_to_local);;
  Line 1, characters 20-41:
  1 | Typing.(Lattice.bot Arrow.global_to_local);;
                          ^^^^^^^^^^^^^^^^^^^^^
  Error: This expression has type string -> local_ int * int
         but an expression was expected of type local_ string -> int * int

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.lft Arrow.global_to_local);;
  Line 1, characters 20-41:
  1 | Typing.(Lattice.lft Arrow.global_to_local);;
                          ^^^^^^^^^^^^^^^^^^^^^
  Error: This expression has type string -> local_ int * int
         but an expression was expected of type string -> int * int

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.rht Arrow.global_to_local);;
  Line 1, characters 20-41:
  1 | Typing.(Lattice.rht Arrow.global_to_local);;
                          ^^^^^^^^^^^^^^^^^^^^^
  Error: This expression has type string -> local_ int * int
         but an expression was expected of type local_ string -> int * int

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.top Arrow.global_to_local);;
  - : unit = ()

A `global` to `global` function may only be lifted to `global` to `local`.
  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.bot Arrow.global_to_global);;
  Line 1, characters 20-42:
  1 | Typing.(Lattice.bot Arrow.global_to_global);;
                          ^^^^^^^^^^^^^^^^^^^^^^
  Error: This expression has type string -> int * int
         but an expression was expected of type local_ string -> int * int

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.lft Arrow.global_to_global);;
  - : unit = ()

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.rht Arrow.global_to_global);;
  Line 1, characters 20-42:
  1 | Typing.(Lattice.rht Arrow.global_to_global);;
                          ^^^^^^^^^^^^^^^^^^^^^^
  Error: This expression has type string -> int * int
         but an expression was expected of type local_ string -> int * int

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.top Arrow.global_to_global);;
  - : unit = ()

A `local` to `local` function may only be lifted to `global` to `local`.
  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.bot Arrow.local_to_local);;
  Line 1, characters 20-40:
  1 | Typing.(Lattice.bot Arrow.local_to_local);;
                          ^^^^^^^^^^^^^^^^^^^^
  Error: This expression has type local_ string -> local_ int * int
         but an expression was expected of type local_ string -> int * int

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.lft Arrow.local_to_local);;
  Line 1, characters 20-40:
  1 | Typing.(Lattice.lft Arrow.local_to_local);;
                          ^^^^^^^^^^^^^^^^^^^^
  Error: This expression has type local_ string -> local_ int * int
         but an expression was expected of type local_ string -> int * int

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.rht Arrow.local_to_local);;
  - : unit = ()

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.top Arrow.local_to_local);;
  - : unit = ()

A “globalizing” function, with type `local_ t -> s` can be used in any context.
  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.bot Arrow.local_to_global);;
  - : unit = ()

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.lft Arrow.local_to_global);;
  - : unit = ()

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.rht Arrow.local_to_global);;
  - : unit = ()

  $ ocaml -noprompt -no-version -I .typing.objs/byte typing.cma << EOF | head -c -1
  > Typing.(Lattice.top Arrow.local_to_global);;
  - : unit = ()
