1. All-in-One: Create switch, link repo, set invariant and install compiler

```bash
opam switch create 5.2.0+flambda2 --repos janestreet-with-extensions=git+https://github.com/janestreet/opam-repository.git#with-extensions,default

eval $(opam env --switch 5.2.0+flambda2)
```

1. Step-by-Step

```bash
mkdir oxcaml; cd oxcaml

opam switch create . --empty

eval $(opam env)

opam repo add --rank=1 janestreet-with-extensions https://github.com/janestreet/opam-repository.git#with-extensions

opam switch set-invariant 5.2.0+flambda2

```

2. Install Platform

```bash
opam install ocamlformat merlin ocaml-lsp-server utop
```


3. What works

```ocaml
Sys.ocaml_version;;
```

```ocaml
let three () =
  let u = stack_ [4; 5; 6] in
  Base.List.length u + 0;;
```

```ocaml
let f () = let local_ s = ref 42 in ();;
```

4. What does not work

* `overwrite` for `unique` e.g.

```ocaml
type 'a list = Nil | Cons of { hd : 'a; tl : 'a list }

let rec rev_append : 'a list @ unique -> 'a list -> 'a list = fun acc -> function
| Nil -> acc
| Cons u -> rev_append (Cons { overwrite u with tl = acc }) u.tl
```

* Rust-style `&` operator

```ocaml
type 'a aliased = { a : 'a @@ aliased } [@@unboxed]

let borrow : ('a @ local -> 'b) -> 'a @ unique -> ('a * 'b aliased) @ unique = fun f x ->
  let result = f &x in
  x, { a = result }
```

```ocaml
let fourtytwo () =
  let u = stack_ (Base.List.init ~f:(fun _ -> 42) 42) in
  Base.List.length u + 0;;
```

```ocaml
let f () = let s = stack_ (ref 42) in ();;
```

```ocaml
2+2;;
```
5. Questions

6. Notes

(https://github.com/ocaml-flambda/flambda-backend)
jane/doc/extensions/stack

> More importantly, stack allocations will never trigger a GC, and so they're safe to use in low-latency code that must currently be zero-alloc.

> stack-allocated values must not be used after their stack frame is freed

> A stack frames is represented as a region at compile time, and each stack-allocated value lives in the surrounding region (usually a function body). Stack-allocated values are not allowed to escape their region.

> the `local_` annotation places obligations only on the definition [...] not its uses.

> At runtime, stack allocations do not take place on the function call stack, but on a separately-allocated stack that follows the same layout as the OCaml minor heap. In particular, this allows local-returning functions (see "Use exclave_ to return a local value" below) without the need to copy returned values.


```ocaml
let create_counter () =
  let counter = ref 0 in
  fun () -> let n = !counter in incr counter; n;;
```
