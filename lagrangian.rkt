#lang racket

(require "fundamental.rkt"
         "calculus.rkt")

(provide lagrangian
         euler-lagrangian-equation)

;;;

(define (lagrangian object-lst)
  (make-sum (append (map (lambda (f) (f 'kinetic-energy)) object-lst)
                    (map (lambda (f) (make-product (list -1 (f 'potential-energy)))) object-lst))))

(define (euler-lagrangian-equation L coordi-lst coordi-dot-lst time)
   (map (lambda (coordi coordi-dot) (make-eqn (make-sum (list (deriv (deriv L coordi-dot) time)
                                                              (make-product (list -1 (deriv L coordi)))))
                                              0)) coordi-lst coordi-dot-lst))

;;;

(require "mechanical-objects.rkt"
         "solve.rkt")

(define pendulum1 (make-pendulum 'm1 'l1 'pivotX1 'pivotY1 (make-function 'theta1 't)))
(define pendulum2 (make-pendulum 'm2 'l2 (pendulum1 'X) (pendulum1 'Y) (make-function 'theta2 't))) 

;(lagrangian (list pendulum1)) ;'(+ (* 0.5 m1 (** l1 2) (** (deriv (function theta1 t) t) 2)) (* -9.8 m1 (+ pivotY1 (* -1 l1 (cos (function theta1 t))))))
;(lagrangian (list pendulum1 pendulum2)) ;complicated

(define L1 (lagrangian (list pendulum1)))
(define euler-lagrangian-L1 (euler-lagrangian-equation L1 (list (make-function 'theta1 't)) (list (deriv (make-function 'theta1 't) 't)) 't))
;euler-lagrangian-L1 ;correct
;(solve (car euler-lagrangian-L1) '(deriv (deriv (function theta1 t) t) t)) ;'(= ... (* -9.8 m1 l1 (sin (function theta1 t)) (** m1 -1) (** (** l1 2) -1)))

(define L (lagrangian (list pendulum1 pendulum2)))
;(euler-lagrangian-equation L
;                           (list (make-function 'theta1 't) (make-function 'theta2 't))
;                           (list (deriv (make-function 'theta1 't) 't) (deriv (make-function 'theta2 't) 't))
;                           't) ;two equations, really complicated.