bench: stock oxcaml

build:
	dune build ./iter.exe

stock: build
	time dune exec --context=stock ./iter.exe 14 13

oxcaml: build
	time dune exec --context=oxcaml ./iter.exe 14 13
