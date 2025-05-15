

---
# **Type**: what it is &mdash; **Mode**: how it's used

<div style="display: flex; justify-content: center;">
<table style="border-collapse: collapse;">
<thead>
<tr>
<th style="padding: 5px 10px;">Application</th>
<th style="padding: 5px 10px; border-bottom: 1px solid black; border-right: 1px solid black; border-left: 1px solid black">
                               <code class="remark-inline-code">t</code></th>
<th style="padding: 5px 10px;"><code class="remark-inline-code">local t</code></th>
</tr>
</thead>
<tbody>
<tr>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-top: 1px solid black; border-right: 1px solid black">
                               <code class="remark-inline-code">t -> .</code></td>
<td style="padding: 5px 10px;">✓</td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-top: 1px solid black; border-left: 1px solid black">✗</td>
</tr>
<tr>
<td style="padding: 5px 10px;"><code class="remark-inline-code">local t -> .</code></td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-right: 1px solid black; border-left: 1px solid black">✓</td>
<td style="padding: 5px 10px;">✓</td>
</tr>
</tbody>
</table>
</div>

Higher-order functions should usually mark their function arguments as local_, to allow local closures to be passed in.

* Region: compile-time representation of a stack frame
  - Function bodies
  - Loop bodies
  - Lazy expressions
  - Module level bindings
* Inference decides how to allocate, defaults to the stack
* Regions can nest and are wider than scopes
  ```ocaml
  let f () =
    let foo =
      let local_ bar = ("region", "scope") in
      bar in
    fst foo;;
  ```

---
# What does `local` mean?

- The value does not escape its region
  * Neither function result nor exception payload
  * Not captured in closure, not referred from mutable area
  * Not reachable from a heap allocated value
  * Freed at its region's end, without triggering the GC
- In function types &mdash; **This is the most important**
  * Contract between caller and callee
  * `local` means in the caller's region
  * Parameter: callee respects caller's locality
  * Result: callee stores in caller's region
  * This really defines 4 arrows
    ```ocaml
    val f0 : s -> t * t                (* All global, legacy *)
    val f1 : local_ s -> t * t
    val f2 : s -> local_ t * t
    val f3 : local_ s -> local_ t * t
    ```

---
# What is `local` for?

0. Low-latency code
> More importantly, stack allocations will never trigger a GC, and so they're safe to use in low-latency code that must currently be zero-alloc
1. Functions passed to higher-order iterators (such as `map`, `fold`, `bind` and others) are allocated on the stack
2. Safer callbacks

---
# Hands-on

```ocaml
let monday () = let str = "mon" ^ "day" in str;;
```

```ocaml
let bye () = let ciao = "sorry" in failwith ciao;;
```

```ocaml
let make_counter () =
  let counter = ref (-1) in
  fun () -> incr counter; !counter;;
```

```ocaml
let state = ref ""
let set () = state := "disco";;
```

```ocaml
let rec map f = function [] -> [] | x :: u -> f x :: map f u;;
```

```ocaml
let f1 (local_ u : int list) = [1; 2; 3];;
```

```ocaml
let f2 (local_ u : int list) = u;;
```

```ocaml
let f3 (local_ u : int list) = 42 :: u;;
```

---
# List length

* Write a list length function in imperative style, using a **local counter**
* Use a `stack_ (ref 0)` local mutable counter that stores the number of traversed list elements

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
# Locality Mode Ordering

* Key idea: a heap allocated value may respect the `local` contract
* Examples: `map`, `fold` and `bind` higher-order parameters
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
let top : (s -> local_ int * int) -> unit = fun f -> assert false
let lft : (string -> int * int) -> unit = fun f -> assert false
let rht : (local_ string -> local_ int * int) -> unit = fun f -> assert false
let bot : (local_ string -> int * int) -> unit = fun f -> assert false
```

Verify mode “subtyping” rules


---
# In the next episodes

* Longer examples
* Locality and closures
* Locality and mutability
* Locality and tail calls
* Locality, currying and partial applications
* `[@local_opt]` limited mode polymorphism
* More on `exclave_`
