
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
<td style="padding: 5px 10px; border-bottom: 1px solid black; text-align: left;">Contention <br> <code class="remark-inline-code">uncontended < shared < <em>contended</em></code> </td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-top: 1px solid black; border-left: 1px solid black; text-align: right;">Portability<br> <code class="remark-inline-code"><em>portable</em> < nonportable</code></td>
</tr>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-top: 1px solid black; border-right: 1px solid black">Effects</td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; text-align: left;"></td>
<td style="padding: 5px 10px; border-bottom: 1px solid black; border-top: 1px solid black; border-left: 1px solid black; text-align: right;">Yielding<br><code class="remark-inline-code"><em>unyielding</em> < yielding</code></td>
</tr>
<tr>
<td style="padding: 5px 10px;">Mutable Data</td>
<td style="padding: 5px 10px; border-top: 1px solid black; border-right: 1px solid black; border-left: 1px solid black; text-align: left;">Visibility <br> <code class="remark-inline-code">read_write < read < <em>immutable</em></code> </td>
<td style="padding: 5px 10px; text-align: right;">Statefulness <br> <code class="remark-inline-code"><em>stateless</em> < observing < stateful</code></td>
</td>
</tr>
</tbody>
</table>
</div>

Note: Contented means _disputé_ in French

---
# Boo

* A type *crosses* a modal axis, if its values aren't affected by the axis' modes
  1. Past axis applies to mutable or mutable nesting data
  2. Future axis:
     - Locality: applies non immediate data
     - All others: applies to functions or function nesting data
* Modes and stock OCaml
  - Past modal axis: legacy mode is maximum value
  - Future modal axis: legacy mode is minimum value
* All modal axis backward compatible, except Contention
  - `contended`
* Modes as parameters or results
  - Past modal axis, modes as types, input and output requirements
  - Future modal axis: behaviour guarantee rather than input requirement
     - Submoding allows passing a legacy-moded value as an OxCaml-moded argument
* Past modes 

* Future mode results - behaviour guarantee
* Past mode parameters - input requirement
* Past mode results - ?

* Legacy can't caputre OxCaml (future)
  - 
* Shared-Memory modal axis (contention & portability) are NOT backward compatible
  


Future modes (except locality)

---
# In the next episodes

* [Linearity 1](04_linear_1.html)
* Unicity
* Affinity
