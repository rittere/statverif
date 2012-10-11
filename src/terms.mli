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
(* This modules contains basic functions to manipulate terms *)

val tuple_table : (Types.typet list, Types.funsymb) Hashtbl.t

(* [get_tuple_fun n] returns the function symbol corresponding
   to tuples of arity [n] *)
val get_tuple_fun : Types.typet list -> Types.funsymb

val get_term_type : Types.term -> Types.typet
val get_format_type : Types.format -> Types.typet
val copy_n : int -> 'a -> 'a list
val tl_to_string : string -> Types.typet list -> string
val eq_lists : 'a list -> 'a list -> bool

(* Creates and returns a new identifier or variable *)

(* [record_id s ext] records the identifier [s] so that it will not be 
   reused elsewhere. [record_id] must be called only before calls to 
   [fresh_id] or [new_var_name] *)
val record_id : string -> Parsing_helper.extent -> unit

(* [fresh_id s] creates a fresh identifier by changing the number of [s].
   Reuses exactly [s] when [s] has not been used before. *) 
val fresh_id : string -> string

(* [new_var s t] creates a fresh variable with name [s] and type [t] *)
val new_var : string -> Types.typet -> Types.binder

(* [new_var_noren s t] creates a fresh variable with name [s] and type [t] 
   The name of this variable is exactly [s], without renaming it to
   a fresh name even if s is already used. Such variables should never
   be displayed. *)
val new_var_noren : string -> Types.typet -> Types.binder

(* [copy_var v] creates a fresh variable with the same sname and type as [v]  *)
val copy_var : Types.binder -> Types.binder

(* [copy_var_noren v] creates a fresh variable with the same name and type 
   as [v]. The name is exactly the same as [v], without renaming to a fresh
   name. *)
val copy_var_noren : Types.binder -> Types.binder

(* [new_var_def t] creates a fresh variable with a default name and type [t] *) 
val new_var_def : Types.typet -> Types.term
(* [val_gen tl] creates new variables of types [tl] and returns them in a 
   list *)
val var_gen : Types.typet list -> Types.term list



(* [occurs_var v t] returns true when variable [v] occurs in [t] *)
val occurs_var : Types.binder -> Types.term -> bool
val occurs_var_fact : Types.binder -> Types.fact -> bool

(* [occurs_f f t] returns true when function symbol [f] occurs in [t] *)
val occurs_f : Types.funsymb -> Types.term -> bool

(* Syntactic equality *)
val equal_terms : Types.term -> Types.term -> bool
val equals_term_pair : 'a * Types.term -> 'a * Types.term -> bool
val equal_facts : Types.fact -> Types.fact -> bool
val equals_simple_constraint : Types.constraints -> Types.constraints -> bool

(* Copies. Variables must be linked only to other variables, with VLink *)
val copy_term : Types.term -> Types.term
val copy_fact : Types.fact -> Types.fact
val copy_constra : Types.constraints list -> Types.constraints list
val copy_rule : Types.reduction -> Types.reduction
val copy_red : (Types.term list * Types.term) -> (Types.term list * Types.term)
(* To cleanup variable links after copies and other manipulations
   [current_bound_vars] is the list of variables that currently have a link.
   [cleanup()] removes all links of variables in [current_bound_vars],
   and resets [current_bound_vars] to the empty list
 *)
val current_bound_vars : Types.binder list ref
val cleanup : unit -> unit
val link : Types.binder -> Types.linktype -> unit
val auto_cleanup : (unit -> 'a) -> 'a

(* Exception raised when unification fails *)
exception Unify
val occur_check : Types.binder -> Types.term -> unit
(* Unify two terms/facts by linking their variables to terms *)
val unify : Types.term -> Types.term -> unit
val unify_facts : Types.fact -> Types.fact -> unit
(* Copies. Variables can be linked to terms with TLink *)
val copy_term2 : Types.term -> Types.term
val copy_fact2 : Types.fact -> Types.fact
val copy_constra2 : Types.constraints list -> Types.constraints list

exception NoMatch
val match_terms2 : Types.term -> Types.term -> unit
val match_facts2 : Types.fact -> Types.fact -> unit
val matchafact : Types.fact -> Types.fact -> bool
(* Same as matchafact except that it returns false when all variables
   are mapped to variables by the matching substitution *)
val matchafactstrict : Types.fact -> Types.fact -> bool

(* Copy of terms and constraints after matching.
   Variables can be linked to terms with TLink, but the link
   is followed only once, not recursively *)
val copy_term3 : Types.term -> Types.term
val copy_fact3 : Types.fact -> Types.fact
val copy_constra3 : Types.constraints list -> Types.constraints list

(* Size of terms/facts *)
val term_size : Types.term -> int
val fact_size : Types.fact -> int

(* [get_var vlist t] accumulate in reference list [vlist] the list of variables
   in the term [t].
   [get_vars_constra vlist c] does the same for the constraint [c], and
   [get_vars_fact vlist f] for the fact f *)
val get_vars : Types.binder list ref -> Types.term -> unit
val get_vars_constra : Types.binder list ref -> Types.constraints -> unit
val get_vars_fact : Types.binder list ref -> Types.fact -> unit

(* The next five functions are useful for the unification simplification
   of inequality constraints and of testunif facts. *)

val new_gen_var : Types.typet -> Types.funsymb
val generalize_vars_not_in : Types.binder list -> Types.term -> Types.term

(* [replace_f_var vl t] replaces names in t according to
   the association list vl. That is, vl is a reference to a list of pairs
   (f_i, v_i) where f_i is a (nullary) function symbol and
   v_i is a variable. Each f_i is replaced with v_i in t.
   If an f_i in general_vars occurs in t, a new entry is added
   to the association list vl, and f_i is replaced accordingly. *)

val replace_f_var : (Types.funsymb * Types.binder) list ref -> Types.term -> Types.term

(* [rev_assoc v2 vl] looks for [v2] in the association list [vl].
   That is, [vl] is a list of pairs (f_i, v_i) where f_i is a 
   (nullary) function symbol and v_i is a variable.
   If [v2] is a v_i, then it returns f_i[],
   otherwise it returns [v2] unchanged. *)

val rev_assoc : Types.binder -> (Types.funsymb * Types.binder) list -> Types.term

(* [follow_link var_case t] follows links stored in variables in [t]
   and returns the resulting term. Variables are translated
   by the function [var_case] *)

val follow_link : (Types.binder -> Types.term) -> Types.term -> Types.term

(* [replace name f t t'] replaces all occurrences of the name [f] (ie f[]) with [t]
   in [t'] *)

val replace_name : Types.funsymb -> Types.term -> Types.term -> Types.term

(* [skip n l] returns list [l] after removing its first [n] elements *)
val skip : int -> 'a list -> 'a list

(* Do not select Out facts, blocking facts, or pred_TUPLE(vars) *)
val add_unsel : Types.fact -> unit
val is_unselectable : Types.fact -> bool

(* helper function for decomposition of tuples *)
val reorganize_fun_app : Types.funsymb -> Types.term list -> 
  Types.term list list

(* Constants *)

val true_cst : Types.funsymb
val false_cst : Types.funsymb

(* Functions *)

val equal_fun : Types.typet -> Types.funsymb
val and_fun : Types.funsymb
val not_fun : Types.funsymb
val new_name_fun : Types.typet -> Types.funsymb
