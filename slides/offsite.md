
<style>
  code.remark-inline-code {
    font-size: 0.85em;
  }
</style>

---
# OxCaml

* Jane Street's <s>fork</s> branch of OCaml &mdash; https://oxcaml.org/
* Oxidized OCaml, additional Rust-like features and much more
* Performance-oriented
  * Modes
     - Stack allocation: locality
     - Ownership, non aliased values: uniqueness and affinity
     - Data race freedom: portability and containment
     - More
  * Flambda 2
  * Kinds, layouts and unboxed types
  * SIMD & types for small numbers
* Comfort
  - Labelled tuples
  - Modules and functors sugar
  - Comprehensions

---
# Sources

* https://oxcaml.org/
* GitHub
  - [`tarides/training-oxcaml`](https://github.com/tarides/training-oxcaml)
  - [`jane/docs`](https://github.com/oxcaml/oxcaml), directory `jane/docs`
  - `janestreet/opam-repository`, branch [`with-extensions`](https://github.com/janestreet/opam-repository/tree/with-extensions)
* YouTube videos
  - Chris Casinghino [Making OCaml Safe for Performance Engineering](https://youtu.be/g3qd4zpm1LA?si=rA41PUZq2ZtJKVEg)
  - Alessio Duè [Safe Concurrency in OCaml](https://youtu.be/KKPNURUbfEE?si=qRw_l-ryq3VDSqV7)
  - Richard Eisenberg [_Unboxed OCaml_ series](https://www.youtube.com/playlist?list=PLCiAikFFaMJrgFrWRKn0-1EI3gVZLQJtJ)
* Jane Street Tech Blog
  1. [Oxidizing OCaml: Locality](https://blog.janestreet.com/oxidizing-ocaml-locality/)
  2. [Oxidizing OCaml: Rust-Style Ownership](https://blog.janestreet.com/oxidizing-ocaml-ownership/)
  3. [Oxidizing OCaml: Data Race Freedom](https://blog.janestreet.com/oxidizing-ocaml-parallelism/)
* Conference papers
  - ICFP 24: [Oxidizing OCaml with Modal Memory Management](https://dl.acm.org/doi/10.1145/3674642)
  - POPL 25: [Data Race Freedom à la Mode](https://dl.acm.org/doi/10.1145/3704859)

---
# Show me some code

```ocaml
fun () ->
  let local_ mambo = "disco" in
  Base.String.length mambo
```

* Type: what the data is &mdash; Mode: how the data is used
* `value : type @ modes`
* Mode checking and mode inference!
* Modal axis: locality, uniqueness, affinity, portability and containment, etc.
* Modes: the “at something” inside a modal axis
* Modes don't have types, types don't have modes
* Compatibility: in each axis, the *legacy* mode represents “stock OCaml”

---
# Locality

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
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-top: 1px solid black; border-right: 1px solid black"><code class="remark-inline-code">global</code></td>
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
    val global_global : s -> t
    val local_global : local_ s -> t
    val global_local : s -> local_ t
    val local_local : local_ s -> local_ t
    ```

---
# Locality Mode Ordering

* Key idea: a heap allocated value may respect the locality contract
* Examples: higher-order parameter of `map`, `fold` and `bind`
* It's always possible to promote a value from `global` to `local`
* This is expressed by and order on locality modes

```
                  t < local t        s < local s


                       t -> local s
                        /        \
                       /          \
                    t -> s    local t -> local s
                       \          /
                        \        /
                      local t -> s
```
* No mode polymorphism! Can't use `'a -> local_ 'b` when `'a -> 'b` is needed

---
# Curried Functions and Partial Applications

* 20th century FP languages

```
a -> b -> c ≅ a -> (b -> c)
```

* OxCaml

```
local_ a -> b -> c ≆ local_ a -> (b -> c)
```

```
local_ a -> b -> c ≅ local_ a -> local_ (b -> c)

local_ (a -> b -> c -> d) -> e -> f -> g
≅
local_ (a -> local_ (b -> local_ (c -> d))) -> local_ (e -> local_ (f -> g))

```

* Global closure can't capture local values
* Curried function must return local closure to capture earlier arguments

---
# Mode Crossing

* OCaml has two kinds of values, distinguished by their lowest-bit
  - Immediate (1), on stack: `bool`, `int` and constructors s.a. `[]`, `()`, `None`
  - Pointers (0), on some heap: the rest

* Locality doesn't apply to immediate values

> **Locality** is **irrelevant** for **types that never cause allocation** on
> the OCaml heap, like `int`. Values of such types **mode cross** on the
> locality axis; they may be used as `global` even when they are `local`.

* `let local_ answer = 42 (* local_ meaningless *)`

---
# The all-in table

<div style="display: flex; justify-content: center;">
<table style="border-collapse: collapse;">
<thead>
<tr>
<th style="padding: 5px 10px; border-bottom: 1px solid black; "></th>
<th style="padding: 5px 10px; border-bottom: 1px solid black; border-right: 1px solid black; border-left: 1px solid black; text-align: left;">Past</th>
<th style="padding: 5px 10px; border-bottom: 1px solid black; text-align: right;">Future</th>
</tr>
</thead>
<tbody>
<tr>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-right: 1px solid black">Stack allocation</td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; text-align: left;"> </td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: right;">Locality<br><code class="remark-inline-code"><em>global</em> < local</code></td>
</tr>
<tr>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-right: 1px solid black">Ownership</td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; text-align: left;">Uniqueness <br> <code class="remark-inline-code">unique < <em>aliased</em></code> </td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: right;">Affinity <br> <code class="remark-inline-code"><em>many</em> < once</code></td>
</tr>
<tr>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-right: 1px solid black">Shared Memory <br> </td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; text-align: left;">Contention <br> <code class="remark-inline-code"><em>uncontended</em> < shared < contended</code> </td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: right;">Portability<br> <code class="remark-inline-code">portable < <em>nonportable</em></code></td>
</tr>
<tr>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-right: 1px solid black">Effects</td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; text-align: left;"></td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: right;">Yielding<br><code class="remark-inline-code">unyielding < yielding</code></td>
</tr>
<tr>
<td style="padding: 5px 10px;">Mutable Data</td>
<td style="padding: 5px 10px; border-right: 1px solid black; border-left: 1px solid black; text-align: left;">Visibility <br> <code class="remark-inline-code">read_write < read < immutable</code> </td>
<td style="padding: 5px 10px; text-align: right;">Statefulness <br> <code class="remark-inline-code">stateless < observing < stateful</code></td>
</tr>


</tbody>
</table>
</div>

Notes: Contented means _disputé_ in French.

---
# Mode Rules

* Each axis has a *legacy* mode, stock OCaml behaviour
* All axes, except `contention` & `portability`, default is backward compatibility
* A type *crosses* a modal axis, if its values aren't affected by the axis' modes
  1. Past axis applies to <u>mutable or mutable nesting data</u>
  2. Future axis:
     - Locality: applies non immediate data
     - All others: applies to <u>functions or function nesting data</u>
* Submoding allows passing low modes as high mode argument
* Modes as parameters or results
  - Past modal axis, modes as types, input and output requirements
  - Future modal axis: behaviour guarantee rather than input requirement
* Futured closure can't capture above its mode, or past mode, except highest

---
# Shortened `Basement.Capsule` from `base`

```ocaml
val create : unit -> Key.packed @ unique @@ portable

(* Means to turn [Key.t] into [Password.t] and wrap data into a [Capsule.t] *)

module Data : sig
  type ('a, 'k) t : value mod contended portable

  val map :
    password:local_ 'k Password.t ->
    f:local_ ('a -> 'b) @ once portable ->
    ('a, 'k) t -> ('b, 'k) t @@ portable

  val extract :
    password:local_ 'k Password.t ->
    f:local_ ('a -> 'b @ once unique portable contended) @ once portable ->
    ('a, 'k) t -> 'b @ once unique portable contended @@ portable

  val map_shared : 'k ('a : value mod portable) 'b.
    password:local_ 'k Password.Shared.t ->
    f:local_ ('a @ shared -> 'b) @ once portable ->
    ('a, 'k) t -> ('b, 'k) t @@ portable

  val extract_shared : 'k ('a : value mod portable) 'b.
    password:local_ 'k Password.Shared.t ->
    f:local_ ('a @ shared -> 'b @ portable contended) @ once portable ->
    ('a, 'k) t -> 'b @ portable contended @@ portable
end
```

---
# `Capsule` cont'd

* All functions can be called in any thread: `@@portable`
* `map`, `extract`, `map_shared` and `extract_shared` &mdash; look alike typing, mode variations
  - `'a -> 'b` function at `local`, `once` and `portable` : single call from any thread
  - `('a, 'k)` capsule data (`'a` implicitly `uncontended`)
  - `'k` password
  - `'b` result
* In `map` & `extract`, `Key.t` is `unique` therefore `f` has R/W access to `'a`
* In `map_shared` & `extract_shared`, `Key.t` is `aliased` therefore `f` only has R access to `'a`
* Both extract functions returns `portable` and `contened`: mutable state can't leak


---
# `{map|extract}(_shared)`

```ocaml
val {map|extract}(_shared) :
  password:local_ 'k Password.Shared.t ->
  f:local_ ('a @ ... -> 'b @ ...) @ once portable ->
  ('a, 'k) t ->
  'b @ ...
  @@ portable
```

<div style="display: flex; justify-content: center;">
<table style="border-collapse: collapse;">
<thead>
<tr>
<th style="padding: 5px 10px; border-bottom: 1px solid black; text-align: center; font-weight: normal;"><code class="remark-inline-code">f : &hellip; @ local once portable</code></th>
<th style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: center; font-weight: normal;"><code class="remark-inline-code">&hellip; -&gt; 'b</code></th>
<th style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: center; font-weight: normal;"><code class="remark-inline-code">&hellip; -&gt; 'b portable contended</code></th>
</tr>
</thead>
<tbody>
<tr>
<td style="padding: 5px 10px; border-bottom: 1px solid black; text-align: left;"><code class="remark-inline-code">'a @ uncontended -&gt; &hellip;</code><br><code class="remark-inline-code">'k Password.t</code> from <code class="remark-inline-code">unique Key.t</code></td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">map</code></td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">extract</code></td>
</tr>
<tr>
<td style="padding: 5px 10px; text-align: left;"><code class="remark-inline-code">'a @ shared -&gt;</code><br><code class="remark-inline-code">'k Password.Shared.t</code> from <code class="remark-inline-code"><code class="remark-inline-code">shared 'k Key.t</code></td>
<td style="padding: 5px 10px; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">map_shared</code></td>
<td style="padding: 5px 10px; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">extract_shared</code></td>
</tr>
</tbody>
</table>
</div>


---
# `Capsule` cont'd

<div style="display: flex; justify-content: center;">
<table style="border-collapse: collapse;">
<thead>
<tr>
<th style="padding: 5px 10px; border-bottom: 1px solid black; text-align: center;"></th>
<th style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: center;"><code class="remark-inline-code">f @ local once portable</code></th>
<th style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: center;"><code class="remark-inline-code">Key</code></th>
<th style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: center;"><code class="remark-inline-code">result</code></th>
</tr>
</thead>
<tbody>
<tr>
<td style="padding: 5px 10px; border-bottom: 1px solid black; text-align: left;"><code class="remark-inline-code">map</code></td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">'a @ uncontended -> 'b</code></td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">unique</code></td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">('b, 'k) t</code></td>
</tr>
<tr>
<td style="padding: 5px 10px; border-bottom: 1px solid black; text-align: left;"><code class="remark-inline-code">extract</code></td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">'a @ uncontended -> 'b @ once unique portable contended</code></td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">unique</code></td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">'b @ once unique portable contended</code></td>
</tr>
<tr>
<td style="padding: 5px 10px; border-bottom: 1px solid black; text-align: left;"><code class="remark-inline-code">map_shared</code></td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">'a @ shared -> 'b</code></td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">shared</code></td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">('b, 'k) t</code></td>
</tr>
<tr>
<td style="padding: 5px 10px; text-align: left;"><code class="remark-inline-code">extract_shared</code></td>
<td style="padding: 5px 10px; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">'a @ shared -> 'b @ portable contended</code></td>
<td style="padding: 5px 10px; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">shared</code></td>
<td style="padding: 5px 10px; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">'b @ portable contended</code></td>
</tr>
</tbody>
</table>
</div>

