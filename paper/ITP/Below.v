(* begin hide *)
Require Import Equations.
(* end hide *)

Equations Below_nat (P : nat -> Type) (n : nat) : Type :=
Below_nat P O := unit ;
Below_nat P (S n) := (P n * Below_nat P n)%type.

(** The [Below_nat] definition uses the built-in structural recursion
   to build a tuple of all the recursive subterms of a number, applied
   to an arbitrary arity [P].
   We can build this tuple for any [n : nat] given a functional
   [step] that builds a [P n] if we have [P] for all the strict 
   subterms of [n], and hence derive an eliminator: *)
(* begin hide *)
Definition below_nat (P : nat -> Type)
  (step : Π n : nat, Below_nat P n -> P n) (n : nat) : Below_nat P n.
Proof. admit. Qed.
(* end hide *)
(* match n with *)
(*   | 0 => () *)
(*   | S n' => let below := below_nat P step n' in *)
(*     (step n' below, below) *)
(* end. *)

Definition rec_nat (P : nat -> Type) 
  (step : Π n : nat, Below_nat P n -> P n) (n : nat) : P n := 
  step n (below_nat P step n).

(** Now suppose we want to define a function by recursion on 
   [n : nat]. We can simply apply this recursor to get an additional 
   [Below_nat P n] hypothesis in our context. If we then refine [n], 
   this [Below_nat P n] hypothesis will unfold at the same time to 
   a tuple of [P n'] for every recursive subterm [n'] of [n].
   These hypotheses form the allowed recursive calls of the function. 

   This construction generalizes to inductive families and the predicate
   can also be generalized by equalities in a similar fashion as the
   dependent case construct to allow recursion on subfamilies of a
   dependent inductive object. For example, consider defining 
   [vlast]: *)
(* begin hide *)
Require Import Bvector.
Hint Unfold noConfusion_nat : equations.
(* end hide *)

Equations vlast {A : Type} {n : nat} (v : vector A (S n)) : A :=
vlast A n v by rec v :=
vlast A ?(S n) (Vcons a ?(O) Vnil) := a ;
vlast A ?(S n) (Vcons a ?(S n) v) := vlast v.

(** Here we use recursion using [Below_vector].
   When we encounter a recursion user node [by rec v] (witnessed as $\Rec{v}{s}$ in 
   the splitting tree), we apply the recursor for the 
   type of [v], after having properly generalized it. The recursion hypothesis 
   is hence of the form: [[
   Below_vector A (λ (n' : nat) (v' : vector A n') =>
     Π (n : nat) (v : vector A (S n)),
     n' = S n -> v' ~= v -> vlast_comp v) n v ]]

   When we use non-structural recursion, recursive calls are rewritten 
   as applications of a trivial generic projection operator for the
   function: [[
   vlast_comp_proj : forall (A : Type) (n : nat) (v : vector A (S n))
     {vcomp : vlast_comp v} -> vlast_comp v ]]

   The last argument of the projection is implicit and will be filled 
   either automatically by a proof search procedure or interactively by
   the user. When we typecheck a recursive call, the procedure will try
   to find a satisfying [vlast_comp] object in the context, potentially 
   simplifying [Below] hypotheses and using specialization to find it. *)
(* begin hide *)
(*Recursive Extraction vlast.*)
(* end hide *)