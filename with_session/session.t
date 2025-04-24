  $ ocamlc -i session.ml
  module Input :
    sig
      type t
      val start : string -> t
      val read : t -> string
      val read_ : local_ t -> string
      val close : t -> unit
    end
  val with_input : (Input.t -> 'a) -> string -> 'a
  val with_input_ : (local_ Input.t -> 'a) -> string -> 'a

  $ ocaml -noprompt -no-version -I .session.objs/byte session.cma << EOF
  > Session.(with_input Input.read "foo");;
  - : string = "42"
  

  $ ocaml -noprompt -no-version -I .session.objs/byte session.cma << EOF
  > Session.(with_input Input.read_ "foo");;
  - : string = "42"
  

  $ ocaml -noprompt -no-version -I .session.objs/byte session.cma << EOF
  > Session.(with_input_ Input.read "foo");;
  Line 1, characters 21-31:
  1 | Session.(with_input_ Input.read "foo");;
                           ^^^^^^^^^^
  Error: This expression has type Session.Input.t -> string
         but an expression was expected of type local_ Session.Input.t -> 'a
  
  $ ocaml -noprompt -no-version -I .session.objs/byte session.cma << EOF
  > Session.(with_input_ Input.read_ "foo");;
  - : string = "42"
  
