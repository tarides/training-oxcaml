bench: stock oxcaml

bench.exe:
	dune build ./bench.exe

bench2.exe:
	dune build ./bench2.exe

oxcaml: bench.exe
	time dune exec --context=default ./bench.exe 18

stock: bench2.exe
	time dune exec --context=stock ./bench2.exe 18

