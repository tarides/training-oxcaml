
<style>
  code.remark-inline-code {
    font-size: 0.85em;
  }
</style>

---
# Previously

* Slides an materials: [`https://github.com/tarides/training-oxcaml`](https://github.com/tarides/training-oxcaml)
  - `src`: examples
  - `slides`: slides
* April 30, 2025 [Set-up](00_setup.html)
* April 30, 2025 [Locality 1](01_local_1.html)
* May 15, 2025 [Locality 2](02_local_2.html)
* June 5, 2025 [Locality 3](03_local_3.html)

---
# Modal Axis, Modes and Submoding

<div style="display: flex; justify-content: center;">
<table style="border-collapse: collapse;">
<thead>
<tr>
<th style="padding: 5px 10px;"></th>
<th style="padding: 5px 10px; border-bottom: 1px solid black; border-right: 1px solid black; border-left: 1px solid black; text-align: left;">Past</th>
<th style="padding: 5px 10px; text-align: right;">Future</th>
</tr>
</thead>
<tbody>
<tr>
<td style="padding: 5px 10px; border-bottom: 3px double black; border-top: 1px solid black; border-right: 1px solid black">Stack allocation</td>
<td style="padding: 5px 10px; border-bottom: 3px double black; text-align: left;"> </td>
<td style="padding: 5px 10px; border-bottom: 3px double black; border-top: 1px solid black; border-left: 1px solid black; text-align: right;">Locality<br><code class="remark-inline-code"><em>global</em> < local</code></td>
</tr>
<tr>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-top: 1px solid black; border-right: 1px solid black">Ownership</td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; text-align: left;">Uniqueness <br> <code class="remark-inline-code">unique < <em>aliased</em></code> </td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-top: 1px solid black; border-left: 1px solid black; text-align: right;">Affinity <br> <code class="remark-inline-code"><em>many</em> < once</code></td>
</tr>
<tr>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-top: 1px solid black; border-right: 1px solid black">Shared Memory <br> </td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; text-align: left;">Contention <br> <code class="remark-inline-code"><em>uncontended</em> < shared < contended</code> </td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-top: 1px solid black; border-left: 1px solid black; text-align: right;">Portability<br> <code class="remark-inline-code">portable < <em>nonportable</em></code></td>
</tr>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-top: 1px solid black; border-right: 1px solid black">Effects</td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; text-align: left;"></td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-top: 1px solid black; border-left: 1px solid black; text-align: right;">Yielding<br><code class="remark-inline-code">unyielding < yielding</code></td>
</tr>
<tr>
<td style="padding: 5px 10px;">Mutable Data</td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-right: 1px solid black; border-left: 1px solid black; text-align: left;">Visibility <br> <code class="remark-inline-code">read_write < read < immutable</code> </td>
<td style="padding: 5px 10px; text-align: right;">Statefulness <br> <code class="remark-inline-code">stateless < observing < stateful</code></td>
</td>
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
  - `('a, 'k)` capsule data
  - `'k` password
  - `'b` result
* In `map` & `extract`, `Key.t` is `unique` therefore `f` has R/W access to `'a`
* In `map_shared` & `extract_shared`, `Key.t` is `aliased` therefore `f` only has R access to `'a`
* Both extract functions returns `portable` and `contened`: mutable state can't leak


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
<td style="padding: 5px 10px; border-top: 1px solid black; text-align: left;"><code class="remark-inline-code">map</code></td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">'a -> 'b</code></td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">unique</code></td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">('b, 'k) t</code></td>
</tr>
<tr>
<td style="padding: 5px 10px; border-top: 1px solid black; text-align: left;"><code class="remark-inline-code">extract</code></td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">'a -> 'b @ once unique portable contended</code></td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">unique</code></td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">'b @ once unique portable contended</code></td>
</tr>
<tr>
<td style="padding: 5px 10px; border-top: 1px solid black; text-align: left;"><code class="remark-inline-code">map_shared</code></td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">'a @ shared -> 'b</code></td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">shared</code></td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">('b, 'k) t</code></td>
</tr>
<tr>
<td style="padding: 5px 10px; border-top: 1px solid black; text-align: left;"><code class="remark-inline-code">extract_shared</code></td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">'a @ shared -> 'b @ portable contended</code></td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">shared</code></td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-left: 1px solid black; text-align: left;"><code class="remark-inline-code">'b @ portable contended</code></td>
</tr>
</tbody>
</table>
</div>
