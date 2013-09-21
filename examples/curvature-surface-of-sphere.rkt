#lang racket

(require "../tensor.rkt"
         "../riemannian.rkt")

;;;

(define g (make-tensor '((_ a) (_ b)) 
                       '(((** r 2) 0)
                         (0 (* (** r 2) (** (sin theta) 2))))))

(define Gamma^a_bc (christoffel '((^ a) (_ b) (_ c)) g '(theta phi)))
;Gamma^a_bc
(define R^a_bcd (riemann-tensor '((^ a) (_ b) (_ c) (_ d)) Gamma^a_bc '(theta phi)))
;R^a_bcd
(define R_ab (ricci-curvature-tensor '((_ a) (_ b)) R^a_bcd))
;R_ab 
(ricci-scalar g R_ab)
;'(scalar * 2 (** r -2)) ;which is correct.