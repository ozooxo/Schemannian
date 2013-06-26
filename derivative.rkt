#lang racket

(require "fundamental.rkt")

(provide deriv)

(define (deriv exp var)
  (cond ((number? exp) 0)
        ((variable? exp)
         (if (same-variable? exp var) 1 0))
        ((sum? exp)
         (make-sum (map
                    (lambda (arg-lst) (deriv arg-lst var)) 
                    (get-arg-lst exp))))
        ((product? exp)
         (map-derivation (lambda (exp) (deriv exp var)) make-product (get-arg-lst exp)))
        ((exponentiation? exp)
         (make-product (list (exponent exp)
                             (make-exponentiation (base exp) (- (exponent exp) 1)) 
                             (deriv (base exp) var))))
        ((eq? (get-op exp) 'log)
         (make-product (list (make-exponentiation (get-arg exp) -1)(deriv (get-arg exp) var))))
        ((eq? (get-op exp) 'sin)
         (make-product (list (list 'cos (get-arg exp)) (deriv (get-arg exp) var))))
        ((eq? (get-op exp) 'cos)
         (make-product -1 (list (list 'sin (get-arg exp)) (deriv (get-arg exp) var))))
        (else
         (error "unknown expression type -- DERIV" exp))))

;(deriv '(+ x 2 x x 3) 'x) ;3
;(deriv '(+ (* x 2) (* x x y 3)) 'x) ;'(+ 2 (+ (* 3 x y) (* 3 x y)))
;(deriv '(** (+ (* 2 x) y) 3) 'x) ;'(* 6 (** (+ (* 2 x) y) 2))
;(deriv '(log (** x 3)) 'x) ;'(* (** (** x 3) -1) (* 3 (** x 2)))
;(deriv '(sin (* 3 x)) 'x) ;'(* 3 (cos (* 3 x)))
