
all:
	ocamlbuild -use-ocamlfind main.byte
	ocamlbuild -use-ocamlfind main.native

clean:
	ocamlbuild -clean

install: _build/main.byte
	install -m 755 _build/main.byte /usr/local/bin/statverif
