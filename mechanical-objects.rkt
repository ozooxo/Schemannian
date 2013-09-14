#lang racket

(require "fundamental.rkt" "calculus.rkt" "simplify.rkt")

(provide make-pendulum)

(define g 9.8) 

(define (make-pendulum mass length pivotX pivotY amplitude)
  (define X
    (make-sum (list pivotX (list '* length (list 'sin amplitude)))))
  (define Y
    (make-sum (list pivotY (list '* -1 length (list 'cos amplitude)))))
  (define potential-energy
    (make-product (list mass g Y)))
  (define kinetic-energy
    (make-product (list 0.5 mass (simplify (simplify (make-sum (list (make-exponentiation (deriv X 't) 2) (make-exponentiation (deriv Y 't) 2))))))))
  (define (dispatch m)
    (cond ((eq? m 'X) X)
          ((eq? m 'Y) Y)
          ((eq? m 'potential-energy) potential-energy)
          ((eq? m 'kinetic-energy) kinetic-energy)))
  dispatch) 

(define pendulum1 (make-pendulum 'm1 'l1 'pivotX1 'pivotY1 (make-function 'theta1 't)))
;(pendulum1 'X) ;'(+ pivotX1 (* l1 (sin (function theta1 t))))
;(pendulum1 'Y) ;'(+ pivotY1 (* -1 l1 (cos (function theta1 t))))
;(pendulum1 'potential-energy) ;'(* 9.8 m1 (+ pivotY1 (* -1 l1 (cos (function theta1 t)))))
;(pendulum1 'kinetic-energy) ;'(* 0.5 m1 (** l1 2) (** (deriv (function theta1 t) t) 2))

(define pendulum2 (make-pendulum 'm2 'l2 (pendulum1 'X) (pendulum1 'Y) (make-function 'theta2 't))) 
;(pendulum2 'X)
;(pendulum2 'kinetic-energy) ;complicated, as (x+y)^2 expansion is not included yet.