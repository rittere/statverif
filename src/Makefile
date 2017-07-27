
all:
	ocamlbuild -use-ocamlfind main.native
	ocamlbuild -use-ocamlfind statveriftotex.native

clean:
	ocamlbuild -clean

install: _build/main.native _build/statveriftotex.native
	install -m 755 _build/main.native /usr/local/bin/statverif
	install -m 755 _build/statveriftotex.native /usr/local/bin/statveriftotex
