#lang racket

(require "fundamental.rkt" "mechanical-objects.rkt")

(define (lagrangian object-lst)
  (make-sum (append (map (lambda (f) (f 'kinetic-energy)) object-lst)
                    (map (lambda (f) (make-product (list -1 (f 'potential-energy)))) object-lst))))

;;;

(define pendulum1 (make-pendulum 'm1 'l1 'pivotX1 'pivotY1 (make-function 'theta1 't)))
(define pendulum2 (make-pendulum 'm2 'l2 (pendulum1 'X) (pendulum1 'Y) (make-function 'theta2 't))) 

;(lagrangian (list pendulum1)) ;'(+ (* 0.5 m1 (** l1 2) (** (deriv (function theta1 t) t) 2)) (* -9.8 m1 (+ pivotY1 (* -1 l1 (cos (function theta1 t))))))
;(lagrangian (list pendulum1 pendulum2)) ;complicated