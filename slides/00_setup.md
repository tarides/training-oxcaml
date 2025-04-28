
---
# `opam` global switch, single command

```shell
opam switch create 5.2.0+flambda2 --repos janestreet-with-extensions=\
  git+https://github.com/janestreet/opam-repository.git#with-extensions,default

eval $(opam env --switch 5.2.0+flambda2)
```

---
# `opam` local switch, step by step

```shell
mkdir oxcaml; cd oxcaml

opam switch create . --empty

eval $(opam env)

opam repo add --rank=1 janestreet-with-extensions \
  https://github.com/janestreet/opam-repository.git#with-extensions

opam switch "set-invariant 5.2.0+flambda2"
```

---
# Install minimum platform

```shell
opam install ocaml-lsp-server merlin utop ocamlformat
```

---
# `dune pkg`

TODO
