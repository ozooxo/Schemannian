#lang racket

(require "../fundamental.rkt"
         "../calculus.rkt"
         "../lagrangian.rkt"
         "../mechanical-objects.rkt"
         "../solve.rkt")

;;;

(define pendulum1 (make-pendulum 'm1 'l1 'pivotX1 'pivotY1 (make-function 'theta1 't)))
(define pendulum2 (make-pendulum 'm2 'l2 (pendulum1 'X) (pendulum1 'Y) (make-function 'theta2 't))) 

(define L (lagrangian (list pendulum1 pendulum2)))
L
(define euler-lagrangian-L
  (euler-lagrangian-equation L
                             (list (make-function 'theta1 't) (make-function 'theta2 't))
                             (list (deriv (make-function 'theta1 't) 't) (deriv (make-function 'theta2 't) 't))
                             't))

euler-lagrangian-L
;print out the symbolic equations of motion for double pendulum.
;there are two equations, but they are really complicated.