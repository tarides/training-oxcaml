
---
# OxCaml

* Jane Street's fork of OCaml
* Oxidized OCaml, Rust-like features
* Targetted at low-latency performances and easier code review
* Modes
  - Stack allocation: locality
  - Ownership and immutable updates: uniqueness and affinity
  - Parallelism and data race freedom: portability and containment
  - More? `unyielding`
* Kinds and unboxed types
* Comprehensions
* Miscellaneous, and counting
  - Immutable arrays
  - Apply and include functor to current module

---
# Sources

* GitHub
  - `ocaml-flambda/flambda-backend`, directory [`jane/docs`](https://github.com/ocaml-flambda/flambda-backend/tree/main/jane/doc)
  - `janestreet/opam-repository`, branch [`with-extensions`](`https://github.com/janestreet/opam-repository/tree/with-extensions`)
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
# `opam` global switch, single command

Git commit points to branch `with-extensions` as of December 10, 2024. Update from April 25, 2025 does not work good enough.


```shell
opam switch create 5.2.0+flambda2 --repos janestreet-with-extensions=git+https://github.com/janestreet/opam-repository.git#3cb7f5ee49e3be100d322e4dd9be18aab28dd3e8,default


eval $(opam env --switch "5.2.0+flambda2")
```

* Tip: `opam update` with care
* Note: There's also a `with-extensions-dev` branch

---
# `opam` local switch, step by step

A variant on the previous

```shell
mkdir oxcaml; cd oxcaml

opam switch create . --empty

eval $(opam env)

opam repo add --rank=1 janestreet-with-extensions git+https://github.com/janestreet/opam-repository.git#3cb7f5ee49e3be100d322e4dd9be18aab28dd3e8

opam switch 'set-invariant' '5.2.0+flambda2'
```

---
# Install minimum platform

```shell
opam install ocaml-lsp-server merlin utop ocamlformat
```

Not using versions numbers to let `opam` pick the right ones

---
# `dune pkg`

Work in progress. Update from @maiste expected soon.
