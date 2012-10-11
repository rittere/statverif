(*************************************************************
 *                                                           *
 *       Cryptographic protocol verifier                     *
 *                                                           *
 *       Bruno Blanchet and Xavier Allamigeon                *
 *                                                           *
 *       Copyright (C) INRIA, LIENS, MPII 2000-2012          *
 *                                                           *
 *************************************************************)

(*

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details (in file LICENSE).

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*)
open Types

type out_pos =
    Spass
  | Solve

type in_pos =
    Horn
  | HornType
  | SpassIn
  | Pi
  | PiType
  | Default

let gc = ref false

let out_kind = ref Solve

let in_kind = ref Default

let out_file = ref ""

let out_n = ref 0

let up_out = function
    "spass" -> Spass
  | "solve" -> Solve
  | _ -> Parsing_helper.user_error "-out should be followed by spass or solve\n"

let up_in = function
    "horn" -> Horn
  | "horntype" -> HornType
  | "spass" -> SpassIn
  | "pi" -> Pi
  | "pitype" -> PiType
  | _ -> Parsing_helper.user_error "-in should be followed by horn, horntype, spass, pi, or pitype\n"


let interference_analysis rulelist queries =
  if (TermsEq.hasEquations()) && (not (!Param.weaksecret_mode)) then
    Parsing_helper.input_warning "using \"noninterf\" in the presence of equations may yield many\nfalse attacks. If you observe false attacks, try to code the desired\nproperty using \"choice\" instead." Parsing_helper.dummy_ext;
  let result = Rules.bad_derivable rulelist in
  if result = [] then
    begin
      Display.Text.print_string "RESULT ";
      Display.Text.display_eq_query queries;
      Display.Text.print_line " is true (bad not derivable).";
      if !Param.html_output then
	begin
	  Display.Html.print_string "<span class=\"result\">RESULT ";
	  Display.Html.display_eq_query queries;
	  Display.Html.print_line " is <span class=\"trueresult\">true (bad not derivable)</span>.</span>"
	end
    end
  else
    begin
      let l = List.map (fun rule ->
        Display.Text.print_string "goal reachable: ";
        Display.Text.display_rule rule;
	if !Param.html_output then
	  begin
	    Display.Html.print_string "goal reachable: ";
            Display.Html.display_rule rule
	  end;
        let new_tree = History.build_history rule in
	let r = 
	  (* For weak secrets, the reconstructed attack really falsifies the
	     equivalence; for other equivalences, it just reaches the program
	     point at which we find the first difference of execution, which
	     does not guarantee that the equivalence is false *)
	  if (!Param.reconstruct_trace) && (!Param.reconstruct_derivation) then
	    if (!Param.weaksecret != None) then
	      Reduction.do_reduction None None new_tree
	    else if (!Param.non_interference) then
	      begin
		ignore (Reduction.do_reduction None None new_tree);
		false
	      end
            else if (!Param.has_choice) then
	      begin
		ignore (Reduction_bipro.do_reduction new_tree);
		false
	      end
	    else
	      false
	  else
	    false
	in
	Terms.cleanup();
	r
	  ) result
      in
      Display.Text.print_string "RESULT ";
      Display.Text.display_eq_query queries;
      if List.exists (fun x -> x) l then
	Display.Text.print_line " is false."
      else
	Display.Text.print_line " cannot be proved (bad derivable).";
      if !Param.html_output then
	begin
	  Display.Html.print_string "<span class=\"result\">RESULT ";
	  Display.Html.display_eq_query queries;
	  if List.exists (fun x -> x) l then
	    Display.Html.print_line " is <span class=\"falseresult\">false</span>.</span>"
	  else
	    Display.Html.print_line " <span class=\"unknownresult\">cannot be proved (bad derivable)</span>.</span>"
	end
    end


let out solve query_to_facts clauses queries =
  match !out_kind with
    Solve ->
      solve clauses queries
  | Spass ->
      if !out_file = "" then
	Parsing_helper.user_error "Error: you should provide the output filename by the option -o <filename>\n";
      incr out_n;
      let out_name = !out_file ^ 
	    (if !out_n = 1 then "" else string_of_int (!out_n)) in
      Spassout.main out_name clauses (query_to_facts queries)
 
let solve_only solve query_to_facts clauses queries =
  match !out_kind with
    Solve ->
      solve clauses queries
  | Spass ->
      Parsing_helper.user_error "Error: the clauses generated by ProVerif for process equivalences cannot be\ntranslated to the Spass input format.\n"

let ends_with s sub =
  let l_s = String.length s in
  let l_sub = String.length sub in
  (l_s >= l_sub) && (String.sub s (l_s - l_sub) l_sub = sub)
  

let anal_file s =
  try
    let in_front_end =
      match !in_kind with
	Default -> (* Set the front-end depending on the extension of the file *)
	  let s_up = String.uppercase s in
	  if ends_with s_up ".PV" then PiType else
	  if ends_with s_up ".PI" then Pi else
          if ends_with s_up ".HORNTYPE" then HornType else
          Horn (* Horn is the default when no extension is recognized for compatibility reasons *)
      |	x -> x
    in
    if (!Param.html_output) then
      begin
	Display.LangHtml.openfile ((!Param.html_dir) ^ "/index.html") "ProVerif: main result page";
	Display.Html.print_string "<H1>ProVerif results</H1>\n"
      end;
    match in_front_end with
      Default ->
	Parsing_helper.internal_error "The Default case should have been removed previously"
    | Horn ->
	(* If the input consists of Horn clauses, no explanation can be given *)
	Param.verbose_explain_clauses := Param.Clauses;
	Param.explain_derivation := false;
	let p = Syntax.parse_file s in
	out (fun p q -> Rules.main_analysis p q)
	    (fun q -> q) p (!Syntax.query_facts);
	if (!Param.html_output) then
	  Display.LangHtml.close()
    | HornType ->
	(* If the input consists of Horn clauses, no explanation can be given *)
	Param.verbose_explain_clauses := Param.Clauses;
	Param.explain_derivation := false;
	Param.typed_frontend := true;
	(* Param.ignore_types := false; *)
	let p = Tsyntax.parse_file s in
	out (fun p q -> Rules.main_analysis p q)
	    (fun q -> q) p (!Tsyntax.query_facts);
	if (!Param.html_output) then
	  Display.LangHtml.close()
    | SpassIn ->
	Parsing_helper.user_error "Error: spass input not yet implemented\n"
    | PiType ->
	Param.typed_frontend := true;
	(* Param.ignore_types := false; *)

	let p = Pitsyntax.parse_file s in
	let p = 
	  if !Param.move_new then
	    Pitransl.move_new p
	  else
	    p
	in
	Pitransl.record_eqs();

	if (!Param.html_output) then
	  begin
	    Display.LangHtml.openfile ((!Param.html_dir) ^ "/process.html") "ProVerif: process";
	    Display.Html.print_string "<H1>Process</H1>\n";
	    Display.Html.display_process_occ "" p;
	    Display.Html.newline();
	    Display.LangHtml.close();
	    Display.Html.print_string "<A HREF=\"process.html\" TARGET=\"process\">Process</A><br>\n"
	  end 
	else if (!Param.verbose_explain_clauses = Param.ExplainedClauses) || (!Param.explain_derivation) then
	  begin
	    print_string "Process:\n";
	    Display.Text.display_process_occ "" p;
	    Display.Text.newline()
	  end;

	if !Param.has_choice then
	  begin
	    if (!Pitsyntax.query_list != [])
	    || (Pitsyntax.get_noninterf_queries() != [])
	    || (Pitsyntax.get_weaksecret_queries() != [])
	    then Parsing_helper.user_error "Queries are incompatible with choice\n";
	    if (!Param.key_compromise != 0) then
	      Parsing_helper.user_error "Key compromise is incompatible with choice\n";

	    print_string "-- Observational equivalence\n";
	    if !Param.html_output then
	      Display.Html.print_string "<span class=\"query\">Observational equivalence</span><br>\n";
	    Param.weaksecret_mode := true;
	    Selfun.inst_constraints := true;
	    let rules = Pitranslweak.transl p in
	    solve_only interference_analysis (fun q -> q) rules Pitypes.ChoiceQuery;
	    Param.weaksecret_mode := false;
	    Selfun.inst_constraints := false
	  end
	else
	  begin
	    if !Param.html_output then
	      Display.Html.print_string "<UL>\n";

        (* Secrecy and authenticity *)

	List.iter (fun q ->
	  begin
	    let queries = Pitsyntax.transl_query q in
	    let rules = Pitransl.transl p in
	    let queries = List.map Pitsyntax.update_type_names queries in
                (* Note: pisyntax translates bindings let x = ... into PutBegin(false,[])
		   since these bindings are useless once they have been interpreted 
		   Such dummy PutBegin(false,[]) should not be displayed. *)
	    let queries' = List.filter (function Pitypes.PutBegin(_,[]) -> false | _ -> true) queries in
	    print_string ("-- Query ");
	    Display.Text.display_list Display.Text.display_corresp_putbegin_query "; " queries';
	    print_newline();
	    if !Param.html_output then
	      begin
		Display.Html.print_string "<LI><span class=\"query\">Query ";
		Display.Html.display_list Display.Html.display_corresp_putbegin_query "; " queries';
		Display.Html.print_string "</span><br>\n"
	      end;
	    out Piauth.solve_auth Pitsyntax.query_to_facts rules queries;
	    incr Param.current_query_number
	  end) (!Pitsyntax.query_list);

        (* Key compromise is now compatible with authenticity
           or non-interference: Param.key_compromise := 0; *)

        (* Non-interference *)

	List.iter (fun noninterf_queries ->
	  begin
	    let noninterf_queries_names = List.map fst noninterf_queries in
	    Param.secret_vars := noninterf_queries_names;
	    Param.secret_vars_with_sets := noninterf_queries;
	    Param.non_interference := true;
	    let _ = Pitsyntax.transl_query ([],[]) in (* Ignore all events *)
	    let rules = Pitransl.transl p in
	    print_string "-- ";
	    Display.Text.display_eq_query (Pitypes.NonInterfQuery noninterf_queries);
	    Display.Text.newline();
	    if !Param.html_output then
	      begin
		Display.Html.print_string "<LI><span class=\"query\">";
		Display.Html.display_eq_query (Pitypes.NonInterfQuery noninterf_queries);
		Display.Html.print_string "</span><br>\n"
	      end;
	    solve_only interference_analysis (fun q -> q) rules (Pitypes.NonInterfQuery noninterf_queries);
	    Param.non_interference := false;
	    incr Param.current_query_number
	  end) (Pitsyntax.get_noninterf_queries());

	(* Weak secrets *)

	List.iter (fun weaksecret ->
	  begin
	    Param.weaksecret := Some weaksecret;
	    Param.weaksecret_mode := true;
	    Selfun.inst_constraints := true;
	    print_string ("-- Weak secret " ^ weaksecret.f_name ^ "\n");
	    if !Param.html_output then
	      Display.Html.print_string ("<LI><span class=\"query\">Weak secret " ^ weaksecret.f_name ^ "</span><br>\n");
	    let _ = Pitsyntax.transl_query ([],[]) in (* Ignore all events *)
	    let rules = Pitransl.transl p in
	    solve_only interference_analysis (fun q -> q) rules (Pitypes.WeakSecret weaksecret);
	    Param.weaksecret := None;
	    Param.weaksecret_mode := false;
	    Selfun.inst_constraints := false;
	    incr Param.current_query_number
	  end) (Pitsyntax.get_weaksecret_queries());

	    if (!Param.html_output) then
	      Display.Html.print_string "</UL>\n"
	  end;

	if (!Param.html_output) then
	  Display.LangHtml.close()

    | Pi ->
	let p = Pisyntax.parse_file s in
	let p = 
	  if !Param.move_new then
	    Pitransl.move_new p
	  else
	    p
	in
	Pitransl.record_eqs();

	if (!Param.html_output) then
	  begin
	    Display.LangHtml.openfile ((!Param.html_dir) ^ "/process.html") "ProVerif: process";
	    Display.Html.print_string "<H1>Process</H1>\n";
	    Display.Html.display_process_occ "" p;
	    Display.Html.newline();
	    Display.LangHtml.close();
	    Display.Html.print_string "<A HREF=\"process.html\" TARGET=\"process\">Process</A><br>\n"
	  end 
	else if (!Param.verbose_explain_clauses = Param.ExplainedClauses) || (!Param.explain_derivation) then
	  begin
	    print_string "Process:\n";
	    Display.Text.display_process_occ "" p;
	    Display.Text.newline()
	  end;

	if !Param.has_choice then
	  begin
	    if (!Pisyntax.query_list != [])
	    || (Pisyntax.get_noninterf_queries() != [])
	    || (Pisyntax.get_weaksecret_queries() != [])
	    then Parsing_helper.user_error "Queries are incompatible with choice\n";
	    if (!Param.key_compromise != 0) then
	      Parsing_helper.user_error "Key compromise is incompatible with choice\n";

	    print_string "-- Observational equivalence"; print_newline();
	    if !Param.html_output then
	      Display.Html.print_string "<span class=\"query\">Observational equivalence</span><br>\n";
	    Param.weaksecret_mode := true;
	    Selfun.inst_constraints := true;
	    let rules = Pitranslweak.transl p in
	    solve_only interference_analysis (fun q -> q) rules Pitypes.ChoiceQuery;
	    Param.weaksecret_mode := false;
	    Selfun.inst_constraints := false
	  end
	else
	  begin
	    if !Param.html_output then
	      Display.Html.print_string "<UL>\n";

        (* Secrecy and authenticity *)

	List.iter (fun q ->
	  begin
	    let queries = Pisyntax.transl_query q in
	    let rules = Pitransl.transl p in
	    let queries = List.map Pisyntax.update_arity_names queries in
	    if !Param.tulafale != 1 then 
	      begin
                (* Note: pisyntax translates bindings let x = ... into PutBegin(false,[])
		   since these bindings are useless once they have been interpreted 
		   Such dummy PutBegin(false,[]) should not be displayed. *)
		let queries = List.filter (function Pitypes.PutBegin(_,[]) -> false | _ -> true) queries in
		print_string ("-- Query ");
		Display.Text.display_list Display.Text.display_corresp_putbegin_query "; " queries;
		print_newline();
		if !Param.html_output then
		  begin
		    Display.Html.print_string "<LI><span class=\"query\">Query ";
		    Display.Html.display_list Display.Html.display_corresp_putbegin_query "; " queries;
		    Display.Html.print_string "</span><br>\n"
		  end
	      end
	    else
	      print_string "-- Secrecy & events.\n";
	    out Piauth.solve_auth Pisyntax.query_to_facts rules queries;
	    incr Param.current_query_number
	  end) (!Pisyntax.query_list);

        (* Key compromise is now compatible with authenticity
           or non-interference: Param.key_compromise := 0; *)

        (* Non-interference *)

	List.iter (fun noninterf_queries ->
	  begin
	    let noninterf_queries_names = List.map fst noninterf_queries in
	    Param.secret_vars := noninterf_queries_names;
	    Param.secret_vars_with_sets := noninterf_queries;
	    Param.non_interference := true;
	    let _ = Pisyntax.transl_query [] in (* Ignore all events *)
	    let rules = Pitransl.transl p in
	    print_string "-- ";
	    Display.Text.display_eq_query (Pitypes.NonInterfQuery noninterf_queries);
	    Display.Text.newline();
	    if !Param.html_output then
	      begin
		Display.Html.print_string "<LI><span class=\"query\">";
		Display.Html.display_eq_query (Pitypes.NonInterfQuery noninterf_queries);
		Display.Html.print_string "</span><br>\n"
	      end;
	    solve_only interference_analysis (fun q -> q) rules (Pitypes.NonInterfQuery noninterf_queries);
	    Param.non_interference := false;
	    incr Param.current_query_number
	  end) (Pisyntax.get_noninterf_queries());

	(* Weak secrets *)

	List.iter (fun weaksecret ->
	  begin
	    Param.weaksecret := Some weaksecret;
	    Param.weaksecret_mode := true;
	    Selfun.inst_constraints := true;
	    print_string ("-- Weak secret " ^ weaksecret.f_name ^ "\n");
	    if !Param.html_output then
	      Display.Html.print_string ("<LI><span class=\"query\">Weak secret " ^ weaksecret.f_name ^ "</span><br>\n");
	    let _ = Pisyntax.transl_query [] in (* Ignore all events *)
	    let rules = Pitransl.transl p in
	    solve_only interference_analysis (fun q -> q) rules (Pitypes.WeakSecret weaksecret);
	    Param.weaksecret := None;
	    Param.weaksecret_mode := false;
	    Selfun.inst_constraints := false;
	    incr Param.current_query_number
	  end) (Pisyntax.get_weaksecret_queries());

	    if (!Param.html_output) then
	      Display.Html.print_string "</UL>\n"
	  end;

	if (!Param.html_output) then
	  Display.LangHtml.close()

  with e ->
    Parsing_helper.internal_error (Printexc.to_string e)


let _ =
  Arg.parse
    [ "-test", Arg.Unit (fun () -> 
        if !Param.tulafale == 0 then
          Param.verbose_explain_clauses := Param.ExplainedClauses), 
        "\t\tdisplay a bit more information for debugging";
      "-in", Arg.String(fun s -> in_kind := up_in s), 
        "<format> \t\tchoose the input format (horn, horntype, spass, pi, pitype)";
      "-out", Arg.String(fun s -> out_kind := up_out s), 
        "<format> \tchoose the output format (solve, spass)";
      "-o", Arg.String(fun s -> out_file := s),
        "<filename> \tchoose the output file name (for spass output)";
      "-lib", Arg.String (fun s -> Param.lib_name := s),
        "<filename> \tchoose the library file (for pitype front-end only)";
      "-TulaFale", Arg.Int(fun n ->
	Param.tulafale := n;
	if n = 1 then
	  begin
	    Param.reconstruct_trace := false;
	    Param.verbose_explain_clauses := Param.Clauses;
	    Param.explain_derivation := false;
	    Param.abbreviate_derivation := false;
	    Param.redundant_hyp_elim := true;
	    Param.redundant_hyp_elim_begin_only := true
	  end
	    ),
        "<version> \tindicate the version of TulaFale when ProVerif is used inside TulaFale";
      "-gc", Arg.Set gc, 
        "\t\t\tdisplay gc statistics";
      "-color", Arg.Set Param.ansi_color,
        "\t\t\tuse ANSI color codes";
      "-html", Arg.String (fun s -> 
	Param.html_output := true;
	Param.html_dir := s;
	if !Param.tulafale == 0 then
          Param.verbose_explain_clauses := Param.ExplainedClauses), 
        "\t\t\tHTML display"
    ]
    anal_file "Proverif. Cryptographic protocol verifier, by Bruno Blanchet and Xavier Allamigeon";
  if !gc then Gc.print_stat stdout
