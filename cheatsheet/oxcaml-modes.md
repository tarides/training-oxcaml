| Past    | Future       |
|----------------|------------------|
|||
| | Locality   |
| | `glogal < local`|_
|| _Applies to non immediate values_ <br> MAY be stack allocated <br> MUST NOT outlive region |
|||
| _Applies to mutable data_ | _Applies to functions_ |
| Uniqueness   | Affinity   |
| `unique < aliased` <br> <br> | `many < once` <br> <br> |
|||
| Contention   | Portability|
| `uncontended < shared < contended` <br> <br> | `portable < nonportable` <br> <br> |
| `uncontented` R/W access <br> `shared` RO access <br> `contended` no access||
| |  Yielding     |
||`unyielding < yielding`<br> <br> |
|||
| Visibility | Statefulness |
|`read_write < read < immutable`<br> <br> |`stateless < observing < stateful`<br> <br> |
|||
