While OxCaml preserves compatiblity with OCaml as much as possible, there are a number of OCaml packages published on Opam which are breaking for small reasons, as seen on the OxCaml healtcheck: https://oxcaml.check.ci.dev/

Fixing those libraries is a nice way to contribute to OxCaml, by enabling more libraries to be used with it. Just pick a red or yellow package with a large number of revdeps from the OxCaml healtcheck webpage to maximize your impact. The red packages are definitively failing, while the yellow ones can point to the root issue. Sometimes the yellow packages are simply picking the wrong dependency instead of the OxCaml compatible one (and that requires a fix too, to ensure they pick a version with `+jst`).

Once you have identified a package that you would like to fix (please make sure it hasn't already been fixed at https://github.com/janestreet/opam-repository/pulls first), the process is fairly simple. First grab the source of the package at its latest version `X.Y.Z` and reproduce the error locally:

```shell
$ opam source --dev buggypkg.X.Y.Z

$ cd buggypkg

buggypkg/ $ dune build --release
# ... some errors ...
```

In general the errors will be related to the changes in the OCaml AST introduced by OxCaml to supports modes and unboxed types (typically for PPX or in OCaml tooling). It is simply a matter of adding `_` to fix the arity of the AST constructors:

```diff
- | Ptyp_any -> ...
+ | Ptyp_any _ -> ...

- | Ptyp_var name -> ...
+ | Ptyp_var (name, _) ->
```

You can check the new AST definitions at https://github.com/ocaml-flambda/flambda-backend/blob/main/parsing/parsetree.mli and https://github.com/ocaml-flambda/flambda-backend/blob/main/typing/typedtree.mli if you have any doubts. As a first patch, we recommend focusing on fixing the package instead of trying to integrate the new OxCaml features, as this can be done later (but ensuring the library compiles with OxCaml will unstuck other opam packages so it's a super useful first step!).

You may also run into modes errors which will require more thoughts:

```
   let length_utf8 = Uutf.String.fold_utf_8 (fun count _ _ -> count + 1) 0
       ^^^^^^^^^^^
Error: This value is local, but expected to be global because it is inside a module.
```

Here we can see a comeback of the "value restriction" for modes. In this case it is enough to make explicit that `length_utf8` is a function with one argument, instead of a partial application:

```diff
-  let length_utf8 = Uutf.String.fold_utf_8 (fun count _ _ -> count + 1) 0
+  let length_utf8 t = Uutf.String.fold_utf_8 (fun count _ _ -> count + 1) 0 t
```

After a bit of work, `dune build --release` should finally work! (and hopefully `dune test` does too)

To submit your fix, you'll need a fork of the OxCaml opam-repository on Github: https://github.com/janestreet/opam-repository/ (which we recommend naming `jst-opam-repository` in case you already have a fork of the OCaml opam-repository)

```shell
$ git clone 'git@github.com:YOURNAME/jst-opam-repository.git'
$ cd jst-opam-repository/packages

$ git checkout with-extensions  # select the OxCaml branch
$ git checkout -b buggypkg      # start a new branch to fix buggypkg

# create a new package entry for buggypkg
$ mkdir buggypkg.X.Y.Z+jst
$ cd buggypkg.X.Y.Z+jst
$ mkdir files                   # create a folder to hold your patch

# export your fix from your buggypkg folder:
buggypkg/ $ git diff > /home/PATH/TO/jst-opam-repository/packages/buggypkg.X.Y.Z/files/diff.patch

# back to your opam-repository folder, compute the sha256 hash of your fix:
$ sha256sum files/diff.patch
008883a395b9966318d3e405e98612c5cfb988b51f0728249231d7a20e3a5455  files/diff.patch

# copy the original buggypkg opam file:
$ opam show --raw buggypkg.X.Y.Z > opam
```

As a final step, edit the `opam` file to fix the `version` field to add `+jst`:

```diff
- version: "X.Y.Z"
+ version: "X.Y.Z+jst"
```

and to add at the end of the file your patch and its sha256 hash:

```
patches: [ "diff.patch" ]
extra-files: [
  [
    "diff.patch"
    "sha256=008883a395b9966318d3e405e98612c5cfb988b51f0728249231d7a20e3a5455"
  ]
]
```

(You may sometimes have to edit the dependencies of this package to ensure it picks the `+jst` versions.)

And you are done! Commit your `opam` and `files/diff.patch` with a `--signoff`:

```shell
$ git add opam files/diff.patch
$ git commit --signoff -m 'fix buggypkg'
```

Then test the installation from your local opam-repository:

```shell
$ opam repository set-url with-extensions 'git+file:///home/PATH/TO/jst-opam-repository#buggypkg'

$ opam install buggypkg  # please make sure it picks your X.Y.Z+jst version by default
```

If everything works fine, then push your branch and open a PR at https://github.com/janestreet/opam-repository/pulls to share with the community. Make sure your PR targets the `with-extensions` branch and not the default `master` branch. Thank you for your help!
