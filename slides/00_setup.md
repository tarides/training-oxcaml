
---
# `opam` global switch, single command

Git commit points to branch `with-extensions` as of December 10, 2024. Update from April 25, 2025 does not seem to work.


```shell
opam switch create 5.2.0+flambda2 --repos janestreet-with-extensions=\
  git+https://github.com/janestreet/opam-repository.git#3cb7f5ee49e3be100d322e4dd9be18aab28dd3e8,default


eval $(opam env --switch 5.2.0+flambda2)
```

---
# `opam` local switch, step by step

```shell
mkdir oxcaml; cd oxcaml

opam switch create . --empty

eval $(opam env)

opam repo add --rank=1 janestreet-with-extensions \
  git+https://github.com/janestreet/opam-repository.git#3cb7f5ee49e3be100d322e4dd9be18aab28dd3e8

opam switch set-invariant "5.2.0+flambda2"
```

---
# Install minimum platform

```shell
opam install ocaml-lsp-server merlin utop ocamlformat
```

---
# `dune pkg`

Work in progress. Update from @maiste expected soon.
