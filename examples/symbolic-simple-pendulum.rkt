#lang racket

(require "../fundamental.rkt"
         "../calculus.rkt"
         "../lagrangian.rkt"
         "../mechanical-objects.rkt"
         "../solve.rkt")

;;;

(define pendulum1 (make-pendulum 'm1 'l1 'pivotX1 'pivotY1 (make-function 'theta1 't)))

(define L1 (lagrangian (list pendulum1)))
L1 ;'(+ (* -9.8 m1 (+ pivotY1 (* -1 l1 (cos (function theta1 t))))) (* 0.5 m1 (** l1 2) (** (deriv (function theta1 t) t) 2)))

(define euler-lagrangian-L1 
  (euler-lagrangian-equation L1 
                             (list (make-function 'theta1 't)) 
                             (list (deriv (make-function 'theta1 't) 't)) 
                             't))

euler-lagrangian-L1 
;print out the symbolic equation of motion for simple pendulum
;'((= (+ (* m1 (** l1 2) (deriv (deriv (function theta1 t) t) t)) (* 9.8 m1 l1 (sin (function theta1 t)))) 0))