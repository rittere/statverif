prefix=/usr/local

all:
	ocamlbuild -use-ocamlfind main.native
	ocamlbuild -use-ocamlfind statveriftotex.native

clean:
	ocamlbuild -clean

install: all
	mkdir -p $(DESTDIR)$(prefix)/bin
	install -m 755 _build/main.native $(DESTDIR)$(prefix)/bin/statverif
	install -m 755 _build/statveriftotex.native $(DESTDIR)$(prefix)/bin/statveriftotex
