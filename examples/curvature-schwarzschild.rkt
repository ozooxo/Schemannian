#lang racket

(require "../tensor.rkt"
         "../riemannian.rkt")

;;;

(define g (make-tensor '((_ a) (_ b)) 
                       '(((+ 1 (* -1 rs (** r -1))) 0 0 0)
                         (0 (* -1 (** (+ 1 (* -1 rs (** r -1))) -1)) 0 0)
                         (0 0 (* -1 (** r 2)) 0)
                         (0 0 0 (* -1 (** r 2) (** (sin theta) 2))))))
(define Gamma^a_bc (christoffel '((^ a) (_ b) (_ c)) g '(t r theta phi)))
Gamma^a_bc
(define R^a_bcd (riemann-tensor '((^ a) (_ b) (_ c) (_ d)) Gamma^a_bc '(t r theta phi)))
;R^a_bcd
(define R_ab (ricci-curvature-tensor '((_ a) (_ b)) R^a_bcd))
;R_ab ;It should already be zero, which is not true here.
;(ricci-scalar g R_ab)