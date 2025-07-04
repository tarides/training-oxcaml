
---
# Previously

* Slides an materials: [`https://github.com/tarides/training-oxcaml`](https://github.com/tarides/training-oxcaml)
  - `src`: examples
  - `slides`: slides
* April 30, 2025 [Set-up](00_setup.html)

---
# Locality Mode OxCaml

```ocaml
let f () =
  let u @ local = [6; 2; 8] in (* mode *)
  let len = Base.List.length u in
  len;;
```
```ocaml
let f () =
  let local_ u = [6; 2; 8] in
  let len = Base.List.length u in
  len;;
```
```ocaml
let f () =
  let u : int list @@ local = stack_ [6; 2; 8] in (* modality *)
  let len = Base.List.length u in
  len;;
```
```ocaml
let f () =
  let u = local_ [6; 2; 8] in
  let len = Base.List.length u in
  len;;
```

Other keywords to spot: `stack_`, `global_`, `@ global`, `exclave_` and `[@local_opt]`

---
# **Type**: what it is &mdash; **Mode**: how it's used

<div style="display: flex; justify-content: center;">
<table style="border-collapse: collapse;">
<thead>
<tr>
<th style="padding: 5px 10px;">Mode</th>
<th style="padding: 5px 10px; border-bottom: 1px solid black; border-right: 1px solid black; border-left: 1px solid black">Lifetime</th>
<th style="padding: 5px 10px;">Allocation</th>
</tr>
</thead>
<tbody>
<tr>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-top: 1px solid black; border-right: 1px solid black"><code class="remark-inline-code">global</code> | missing</td>
<td style="padding: 5px 10px;">MAY outlive its region</td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-top: 1px solid black; border-left: 1px solid black">MUST be on the heap</td>
</tr>
<tr>
<td style="padding: 5px 10px;"><code class="remark-inline-code">local</code></td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-right: 1px solid black; border-left: 1px solid black">MUST NOT outlive its region</td>
<td style="padding: 5px 10px;">MAY be on the stack</td>
</tr>
</tbody>
</table>
</div>

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
    val global_global : s -> t * t                (* Legacy *)
    val local_global : local_ s -> t * t
    val global_local : s -> local_ t * t
    val local_local : local_ s -> local_ t * t
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
# In the next episodes

* [Locality 2](02_local_2.html)
* Longer examples
* Globalizing
* Locality and closures
* Locality and mutability
* Locality and tail calls
* Locality, currying and partial applications
* `[@local_opt]` limited mode polymorphism
* More on `exclave_`
