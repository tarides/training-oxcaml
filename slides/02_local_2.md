
---
# Previously

* Slides an materials: [`https://github.com/tarides/training-oxcaml`](https://github.com/tarides/training-oxcaml)
  - `src`: examples
  - `slides`: slides
* April 30, 2025 [Set-up](00_setup.html)
* April 30, 2025 [Locality 1](01_local_1.html)
  - Syntax
  - Lifetimes, regions and allocation
  - First examples


---
# What locality can do

```ocaml
let dead_drop : string list ref = ref [];;
```
```ocaml
let spy f x =
  dead_drop := x :: !dead_drop;
  f x;;
```
```ocaml
List.map (spy String.length) [ "alice"; "bob" ];;
```
```ocaml
!dead_drop;;
```
```ocaml
let rec map (f : local_ 'a -> 'b) = function
  | [] -> []
  | x :: u -> f x :: map f u;;
```
```ocaml
map (spy String.length) [ "alice"; "bob" ];;
```
```ocaml
Base.List.map (spy String.length) [ "alice"; "bob" ];;
```

---
# List length

* Write a list length function in imperative style, using a **local counter**
* Use a `stack_ (ref 0)` to stores the number of traversed list elements

---
# Locality and function types

```ocaml
Base.List.length;;
```
```ocaml
fun () -> let local_ foo = [1;2;3] in let len = Base.List.length foo in len;;
```
```ocaml
let foo = [3; 4; 5];;
```
```ocaml
Base.List.length foo;;
```
```ocaml
let local_list : int -> local_ int list =
  fun n -> exclave_ Base.List.init n ~f:Fun.id;;
```
```ocaml
List.length (local_list 3);;
```
```ocaml
Base.List.length (local_list 3);;
```

---
# Taking a look at _Hello World_

```ocaml
external globalize_string : string @ local -> string = "%obj_dup"

let () =
  let local_message : string @@ local = "Hello, World" in
  (* Can't print [local_message] -- the value would escape. *)

  let global_message = globalize_string local_message in
  (* Copy the string to create a new global value. *)

  print_endline global_message
;;
```

---
# Tail calls

```ocaml
fun () ->
  let local_ s = "abc" in
  Base.String.globalize s;;
```

```ocaml
fun () ->
  let local_ s = "abc" in
  let ret = Base.String.globalize s in
  ret;;
```

---
# Locality Mode Ordering

* Key idea: a heap allocated value may respect the locality contract
* Examples: higher-order parameter of `map`, `fold` and `bind`
* It's always possible to promote a value from `global` to `local`
* This is expressed by and order on locality modes

```
                  t < local_ t        s < local_ s


                       t -> local_ s
                        /        \
                       /          \
                    t -> s    local_ t -> local_ s
                       \          /
                        \        /
                      local_ t -> s
```
* No mode polymorphism! Can't use `'a -> local_ 'b` when `'a -> 'b` is needed

---
# Locality Mode Ordering, cont'd

```ocaml
let f0 : string -> int * int = fun _ -> (3, 14);;
let f1 : local_ string -> int * int = fun _ -> (3, 14);;
let f2 : string -> local_ int * int = fun _ -> exclave_ (3, 14);;
let f3 : local_ string -> local_ int * int = fun _ -> exclave_ (3, 14);;
```

```ocaml
let top : (s -> local_ int * int) -> unit = fun f -> ()
let lft : (string -> int * int) -> unit = fun f -> ()
let rht : (local_ string -> local_ int * int) -> unit = fun f -> ()
let bot : (local_ string -> int * int) -> unit = fun f -> ()
```

Verify mode “subtyping” rules

---
# The `unfold` function

```ocaml
let rec unfold : ('a -> ('b * 'a) option) -> 'a -> 'b list = fun f x ->
  match f x with
    | Some (y, x) -> y :: unfold f x
    | None -> []
```

- Observation: `'a` values are transient. They're only needed to construct the list. They could be allocated on the stack.
- Exercise: Adapt `unfold` to OxCaml such that `'a` values are allocated on the stack

---
# In the next episodes

* [Locality 3](03_local_3.html)
* Locality and mutability
* Locality, currying and partial applications
* `[@local_opt]` limited mode polymorphism
