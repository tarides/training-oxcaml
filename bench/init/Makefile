bench: stock oxcaml

build:
	dune build ./bench.exe

stock: build
	time dune exec --context=stock ./bench.exe 14 13

oxcaml: build
	time dune exec --context=default ./bench.exe 14 13
