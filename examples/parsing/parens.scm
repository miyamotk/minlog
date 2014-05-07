;; 2014-01-30.  examples/parsing/parens.scm.  New formulation with U
;; only.  Hopefully clearer.

;; Let E range over expressions formed as lists of left and righ
;; parentheses L,R.  We are interested in the correct ones, in the
;; sense of being generated by either of the grammars

;; grammar U
;; E ::= Nil | ELER

;; grammar S
;; E ::= Nil | LER | EE

;; It is easy to see that both grammars generate the same expressions.
;; S appears to be more natural, but its generation trees are not
;; unique: one can always append the empty list Nil.  This can be
;; repaired easily by only dealing with non-empty lists.  However,
;; this has the drawback that it is often useful to specialize general
;; lemmas (like the closure poperty of U below) to the empty list.
;; Therefore we restrict attention to U.

;; Consider the problem of recognizing whether a list of left and
;; right parentheses is a correct expression, and if so produce a
;; generating tree (a.k.a. parse tree).  Usually one tackles this
;; problem by the write-and-verify method: one writes such a parser as
;; a shift-reduce syntax analyser, and verifies that it is correct and
;; complete.  Here we take this problem as an example for the
;; prove-and-extract method.

;; First we formulate the grammar U as an inductivly defined predicate
;; over lists x,y,z of parentheses L,R given by the clauses

;; U(Nil par)
;; U x -> U y -> U(x++L: ++y++R:)

;; We work with two predicates RP n x meaning x R^n in U and LP n y
;; meaning L^n y in U.  For RP we have an inductive definition

;; RP 0(Nil par)
;; z in U -> RP n x -> RP(Succ n)(x++z++L:)

;; LP can be defined via a boolean valued function with defining
;; equations

;; LP 0(Nil par)          True
;; LP(Succ n)(Nil par)    False
;; LP n(L::x)             LP(Succ n)x
;; LP 0(R::x)             False
;; LP(Succ n)(R::x)       LP n x

;; Clearly the following closure property of U holds

;; RP n x -> z in U -> LP n y -> x++z++y in U

;; One proves by induction on y that the claim holds for all n.  Base
;; y=(Nil par).  Use induction on RP n x.  Step.  In case L::y use IHy
;; for n+1.  In case R::y again use induction on RP n x.  The first RP
;; clause uses Efq, the second one IHy, GenU and equality arguments.

;; In particular we have LP 0 y -> y in U.  Conversely one can easily
;; prove y in U -> LP 0 y by induction on U.  Hence the test LP 0 y is
;; correct (all y in U satisfies it) and complete (it implies y in U).
;; Because of LP 0 y <-> y in U we have a decision procedure for U.
;; With p a boolean variable we can express this by a proof of

;; ex p((p -> y in U) & ((P -> F) -> y in U -> F))

;; The computational content of this proof is a parser for U.  Given y
;; it returns a boolean expressing whether or not y is in U, and if so
;; it also returns a generation tree (a.k.a. parse tree) for y in U.

;; We now carry out this program.

;; (load "~/git/minlog/init.scm")

;; Binary trees, or derivations

(add-algs "bin"
	  '("bin" "O")
	  '("bin=>bin=>bin" "BinBranch"))

(add-infix-display-string "BinBranch" "B" 'pair-op) ;right associative

(set! COMMENT-FLAG #f)
(libload "nat.scm")
(libload "list.scm")
(set! COMMENT-FLAG #t)

(add-algs "par" '("L" "par") '("R" "par"))
(add-totality "par")

(add-var-name "p" (py "boole"))
(add-var-name "x" "y" "z" (py "list par"))

;; ParEqToEqD
(set-goal "all par1,par2(par1=par2 -> par1 eqd par2)")
(cases)
(cases)
(assume "Useless")
(use "InitEqD")
(assume "L=R")
(use "EFEqD")
(use "AtomToEqDTrue")
(use "L=R")
(cases)
(assume "R=L")
(use "EFEqD")
(use "AtomToEqDTrue")
(use "R=L")
(assume "Useless")
(use "InitEqD")
;; Proof finished.
(save "ParEqToEqD")

;; ListParEqToEqD
(set-goal "all x1,x2(x1=x2 -> x1 eqd x2)")
(ind)
(cases)
(assume "Useless")
(use "InitEqD")
(assume "par1" "x1" "Absurd")
(use "EFEqD")
(use "AtomToEqDTrue")
(use "Absurd")
(assume "par1" "x1" "IH")
(cases)
(assume "Absurd")
(use "EFEqD")
(use "AtomToEqDTrue")
(use "Absurd")
(assume "par2" "x2" "=Hyp")
(ng "=Hyp")
(assert "x1=x2")
 (use "=Hyp")
(assume "x1=x2")
(assert "par1=par2")
 (use "=Hyp")
(assume "par1=par2")
(drop "=Hyp")
(assert "x1 eqd x2")
 (use "IH")
 (use "x1=x2")
(assume "x1 eqd x2")
(assert "par1 eqd par2")
 (use "ParEqToEqD")
 (use "par1=par2")
(assume "par1 eqd par2")
(elim "x1 eqd x2")
(assume "x^3")
(elim "par1 eqd par2")
(assume "par^3")
(use "InitEqD")
;; Proof finished.
(save "ListParEqToEqD")

;; Inductively define a predicate (grammar) U over list par, by clauses

(add-ids (list (list "U" (make-arity (py "list par")) "bin"))
	 '("U(Nil par)" "InitU")
	 '("allnc x,y(U x -> U y -> U(x++L: ++y++R:))" "GenU"))

;; LP

(add-program-constant "LP" (py "nat=>list par=>boole"))

(add-computation-rules
 "LP 0(Nil par)"       "True"
 "LP(Succ n)(Nil par)" "False"
 "LP n(L::x)"          "LP(Succ n)x"
 "LP 0(R::x)"          "False"
 "LP(Succ n)(R::x)"    "LP n x")

;; LPTotal
(set-goal (rename-variables (term-to-totality-formula (pt "LP"))))
(assert
 "allnc x^(TotalList x^ -> allnc n^(TotalNat n^ -> TotalBoole(LP n^ x^)))")
 (assume "x^" "Tx")
 (elim "Tx")
 (assume "n^" "Tn")
 (elim "Tn")
 (use "TotalBooleTrue")
 (assume "n^1" "Useless1" "Useless2")
 (use "TotalBooleFalse")
 (assume "par^" "Tpar")
 (elim "Tpar")
 (assume "x^1" "Tx1" "IHx1" "n^" "Tn")
 (ng #t)
 (use "IHx1")
 (use "TotalNatSucc")
 (use "Tn")
 (assume "x^1" "Tx1" "IHx1" "n^" "Tn")
 (elim "Tn")
 (use "TotalBooleFalse")
 (assume "n^1" "Tn1" "Useless")
 (ng #t)
 (use "IHx1")
 (use "Tn1")
(assume "LPTotalAux" "n^" "Tn" "x^" "Tx")
(use "LPTotalAux")
(use "Tx")
(use "Tn")
;; Proof finished.
(save "LPTotal")

;; LPProp
(set-goal "all x,y,n,m(LP n x -> LP m y -> LP(n+m)(x++y))")
(ind)
(ind)
(cases)
(cases)
(auto)
(ng)
(cases)
(assume "y" "IHy")
(ng)
(assume "n" "m" "Hyp1" "Hyp2")
(use-with "IHy" (pt "n") (pt "Succ m") "Hyp1" "Hyp2")
(assume "y" "IHy" "n")
(cases)
(assume "Hyp1" "Absurd")
(use "Efq")
(use "Absurd")
(ng)
(use "IHy")

(cases)
(assume "x" "IHx")
(ng)
(assume "y" "n" "m" "Hyp1" "Hyp2")
(use-with "IHx" (pt "y") (pt "Succ n") (pt "m") "Hyp1" "Hyp2")
(assume "x" "IHx" "y")
(cases)
(assume "m" "Absurd" "Hyp1")
(use "Efq")
(use "Absurd")
(use "IHx")
;; Proof finished.
(save "LPProp")

;; RP (with a parameter predicate to be substituted by U)

(add-pvar-name "P" (make-arity (py "list par")))

(add-ids
 (list (list "RP" (make-arity (py "nat") (py "list par")) "list"))
 '("RP 0(Nil par)" "InitRP")
 '("allnc n,x,z(P z -> RP n x -> RP(Succ n)(x++z++L:))" "GenRP"))

;; ClosureU
(set-goal
 "all y allnc n,x,z((RP (cterm (x^) U x^))n x -> U z -> LP n y -> U(x++z++y))")
(ind)

;; Base.  Case y=(Nil par)
(assume "n" "x" "z" "RP n x")
(elim "RP n x")

;; InitRP
(ng #t)
(auto)

;; GenRP
(ng #t)
(assume "n1" "x1" "z1" "Useless1" "Useless2" "Useless3" "Useless4" "Absurd")
(use "Efq")
(use "Absurd")

;; Step
(cases)
;; Case L.  Use IHy for n+1
(ng #t)
(assume "y" "IHy" "n" "x" "z" "RP n x" "U z" "LP(Succ n)y")
(use-with "IHy" (pt "Succ n") (pt "x++z++L:") (pt "(Nil par)") "?" "?" "?")
(use "GenRP")
(use "U z")
(use "RP n x")
(use "InitU")
(use "LP(Succ n)y")

;; Case R
(assume "y" "IHy" "n" "x" "z" "RP n x")
(elim "RP n x")

;; First RP clause
(ng #t)
(assume "U z" "Absurd")
(use "Efq")
(use "Absurd")

;; Second RP clause.  Uses IHy, GenU and equality arguments.
(assume "n1" "x1" "z1" "U z1" "RP n1 x1" "IH" "U z")
(ng #t)
(simp (pf "x1++z1++(L::z)++(R::y)=x1++z1++(L::z)++R: ++y"))
(simp (pf "x1++z1++(L::z)=x1++(z1++(L::z))"))
(simp (pf "x1++(z1++(L::z))++R: =x1++(z1++(L::z)++R:)"))
(use "IHy")
(use "RP n1 x1")
(use-with "GenU" (pt "z1") (pt "z") "U z1" "U z")
(simp "ListAppdAssoc")
(simp "ListAppdAssoc")
(simp "ListAppdAssoc")
(use "Truth")
(simp "ListAppdAssoc")
(use "Truth")
(ng #t)
(use "Truth")
;; Proof finished
(save "ClosureU")

;; Soundness
(set-goal "allnc y(U y -> LP 0 y)")
(assume "z" "IdHyp")
(elim "IdHyp")
(use "Truth")
(assume "x" "y" "U x" "LP 0 x" "U y" "LP 0 y")
(simp "<-" "ListAppdAssoc")
(use-with "LPProp" (pt "x") (pt "L::y++R:") (pt "0") (pt "0")
	  "LP 0 x" "?")
(ng #t)
(use-with "LPProp" (pt "y") (pt "R:") (pt "0") (pt "1")
	  "LP 0 y" "Truth")
;; Proof finished.
(save "Soundness")

;; Completeness
(set-goal "all y(LP 0 y -> U y)")
(assume "y" "LP 0 y")
(use-with "ClosureU" (pt "y") (pt "0") (pt "(Nil par)")  (pt "(Nil par)")
	  "?" "InitU" "LP 0 y")
(use "InitRP")
;; Proof finished.
(save "Completeness")

;; ParseLemma
(set-goal "all y ex p((p -> U y) & ((p -> F) -> U y -> F))")
(assume "y")
(ex-intro (pt "LP 0 y"))
(split)
(use "Completeness")
(assume "LP 0 y -> F" "U y")
(use "LP 0 y -> F")
(use "Soundness")
(use "U y")
;; Proof finished.
(save "ParseLemma")

(animate "ClosureU")
(animate "Completeness")

(add-var-name "a" (py "bin"))
(add-var-name "as" (py "list bin"))
(add-var-name "f" (py "list bin=>bin=>bin"))

(define eterm (proof-to-extracted-term (theorem-name-to-proof "ParseLemma")))
(define parser-term (rename-variables (nt eterm)))
(ppc parser-term)

;; [x]
;;  LP 0 x@
;;  (Rec list par=>list bin=>bin=>bin)x
;;  ([as,a][case as ((Nil bin) -> a)
;;                   (a0::as0 -> O)])
;;  ([par,x0,f,as,a]
;;    [case par
;;      (L -> f(a::as)O)
;;      (R -> [case as ((Nil bin) -> O)
;;                      (a0::as0 -> f as0(a0 B a))])])
;;  (Nil bin)
;;  O

;; Since this term involves the recursion operator it is not easy to
;; read.  To grasp its meaning we rewrite it.  In case LP 0 x the
;; result is obtained by applying g to [],O with g recursively defined
;; by

;;   g([],as,a) = a if as=[]
;;                O else
;; g(L::x,as,a) = g(x,a::as,[])
;; g(R::x,as,a) = O               if as=[]
;;                g(x,as0,a0 B a) if as=a0::as0

;; Test of parser-term of type list par=>boole@bin on a list of
;; lists of pars.

;; (generate-seq n) generates a list of 2^n infinite sequences starting
;; with all possible variations of n digits and continuing with 0.

(define (generate-seq n)
  (if (= n 0)
      (list (lambda (n) 0))
      (foldr (lambda (f l)
	       (cons (lambda (n) (if (= n 0) 0 (f (- n 1))))
		     (cons (lambda (n) (if (= n 0) 1 (f (- n 1))))
			   l)))
	     '()
	     (generate-seq (- n 1)))))

;; (length (generate-seq 4))
;; 16

;; (first f n) returns a list of (f 0),(f 1),...,(f n-1).

(define (first f n)
  (if (= n 0)
      '()
       (cons (f 0)
	     (first (lambda (n) (f (+ n 1))) (- n 1)))))

;; (for-each (lambda (x) (display (first x 7)) (newline)) (generate-seq 4))

;; (0 0 0 0 0 0 0)
;; (1 0 0 0 0 0 0)
;; (0 1 0 0 0 0 0)
;; (1 1 0 0 0 0 0)
;; (0 0 1 0 0 0 0)
;; (1 0 1 0 0 0 0)
;; (0 1 1 0 0 0 0)
;; (1 1 1 0 0 0 0)
;; (0 0 0 1 0 0 0)
;; (1 0 0 1 0 0 0)
;; (0 1 0 1 0 0 0)
;; (1 1 0 1 0 0 0)
;; (0 0 1 1 0 0 0)
;; (1 0 1 1 0 0 0)
;; (0 1 1 1 0 0 0)
;; (1 1 1 1 0 0 0)

(define (blist-to-lpar-term blist)
  (if (null? blist)
      (pt "(Nil par)")
      (mk-term-in-app-form
       (pt "(Cons par)")
       (if (zero? (car blist)) (pt "L") (pt "R"))
       (blist-to-lpar-term (cdr blist)))))

(pp (blist-to-lpar-term '(0 1 0)))
;; L::R::L:

(define (generate-lpar-terms n)
  (let* ((seq (generate-seq n))
	 (01lists (map (lambda (f) (first f n)) seq))
	 (reduced-01lists
	  (list-transform-positive 01lists
	    (lambda (l)
	      (and (zero? (car l))
		   (not (zero? (car (last-pair l)))))))))
    (map blist-to-lpar-term reduced-01lists)))

(for-each pp (generate-lpar-terms 6))
;; L::L::L::L::L::R:
;; L::R::L::L::L::R:
;; L::L::R::L::L::R:
;; L::R::R::L::L::R:
;; L::L::L::R::L::R:
;; L::R::L::R::L::R:
;; L::L::R::R::L::R:
;; L::R::R::R::L::R:
;; L::L::L::L::R::R:
;; L::R::L::L::R::R:
;; L::L::R::L::R::R:
;; L::R::R::L::R::R:
;; L::L::L::R::R::R:
;; L::R::L::R::R::R:
;; L::L::R::R::R::R:
;; L::R::R::R::R::R:

;; Test parser-term on all lpar-terms of length l.

(define (test-parser-term parser-term . l)
  (let ((len (if (null? l) 4 (car l))))
    (map (lambda (lpar-term)
	   (display "Testing on ")
	   (display (term-to-string lpar-term))
	   (let* ((pairterm (nt (make-term-in-app-form parser-term lpar-term)))
		  (lterm (term-in-pair-form-to-left pairterm))
		  (rterm (term-in-pair-form-to-right pairterm)))
	     (if (and (term-in-const-form? lterm)
		      (string=? "True" (const-to-name
					(term-in-const-form-to-const lterm))))
		 (begin (display " Parse tree: ")
			(display (term-to-string rterm)))
		 (display " No"))
	     (newline)))
	 (generate-lpar-terms len)))
    *the-non-printing-object*)

(test-parser-term parser-term 6)

;; Testing on L::R::R::R::R::R: No
;; Testing on L::L::R::R::R::R: No
;; Testing on L::R::L::R::R::R: No
;; Testing on L::L::L::R::R::R: Parse tree: O B O B O B O
;; Testing on L::R::R::L::R::R: No
;; Testing on L::L::R::L::R::R: Parse tree: O B(O B O)B O
;; Testing on L::R::L::L::R::R: Parse tree: (O B O)B O B O
;; Testing on L::L::L::L::R::R: No
;; Testing on L::R::R::R::L::R: No
;; Testing on L::L::R::R::L::R: Parse tree: (O B O B O)B O
;; Testing on L::R::L::R::L::R: Parse tree: ((O B O)B O)B O
;; Testing on L::L::L::R::L::R: No
;; Testing on L::R::R::L::L::R: No
;; Testing on L::L::R::L::L::R: No
;; Testing on L::R::L::L::L::R: No
;; Testing on L::L::L::L::L::R: No