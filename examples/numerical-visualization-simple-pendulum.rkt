#lang racket

(require 2htdp/universe
         "../fundamental.rkt"
         "../calculus.rkt"
         "../mechanical-objects.rkt"
         "../lagrangian.rkt"
         "../solve.rkt"
         "../numerical-differential-equation.rkt"
         "../show-mechanical-objects.rkt")

;;;

(define pendulum1 (make-pendulum 20 250 300 50 (make-function 'theta1 't)))

(define L1 (lagrangian (list pendulum1)))
(define euler-lagrangian-L1 (euler-lagrangian-equation L1 (list (make-function 'theta1 't)) (list (deriv (make-function 'theta1 't) 't)) 't))

euler-lagrangian-L1 
;print out the Euler Lagrangian equation:
;'((= (+ (* 1250000.0 (deriv (deriv (function theta1 t) t) t)) (* 49000.0 (sin (function theta1 t)))) 0))

(define euler-lagrangian-solution (numerical-solve (solve (car euler-lagrangian-L1) '(deriv (deriv (function theta1 t) t) t)) 
                                     '((function theta1 t) (deriv (function theta1 t) t))
                                     '(0.3 0) 
                                     0
                                     0.1)) ;this parameter adjusts how quickly the times goes can be.
;(stream-take 10 euler-lagrangian-solution)

(define solution-next (stream-next euler-lagrangian-solution))
(animate (lambda (time) ((create-pendulum-moving time) pendulum1 solution-next)))
;show video of a simple pendulum.