cd src

ocamlyacc parser.mly
ocamllex lexer.mll
ocamlyacc piparser.mly
ocamllex pilexer.mll
ocamlyacc pitparser.mly
ocamllex pitlexer.mll
ocamlc -o ..\proverif.exe misc.mli misc.ml parsing_helper.mli parsing_helper.ml stringmap.mli stringmap.ml ptree.mli piptree.mli pitptree.mli types.mli funmap.mli funmap.ml pitypes.mli param.mli param.ml parser.mli parser.ml lexer.ml queue.mli queue.ml terms.mli terms.ml termslinks.mli termslinks.ml display.mli display.ml history.mli history.ml termsEq.mli termsEq.ml pievent.mli pievent.ml weaksecr.mli weaksecr.ml noninterf.mli noninterf.ml selfun.mli selfun.ml rules.mli rules.ml syntax.mli syntax.ml tsyntax.mli tsyntax.ml piparser.mli piparser.ml pilexer.ml pitparser.mli pitparser.ml pitlexer.ml spassout.mli spassout.ml reduction_helper.mli reduction_helper.ml simplify.mli simplify.ml pisyntax.mli pisyntax.ml pitsyntax.mli pitsyntax.ml pitransl.mli pitransl.ml pitranslweak.mli pitranslweak.ml destructor.mli destructor.ml reduction.mli reduction.ml reduction_bipro.mli reduction_bipro.ml piauth.mli piauth.ml main.ml

ocamllex lexertotex.mll
ocamllex pitlexertotex.mll
ocamlc -o ..\proveriftotex.exe parsing_helper.mli parsing_helper.ml ptree.mli piptree.mli pitptree.mli types.mli param.mli param.ml piparser.mli piparser.ml pilexer.ml pitparser.mli pitparser.ml pitlexer.ml fileprint.ml lexertotex.ml pitlexertotex.ml proveriftotex.ml

cd ..
