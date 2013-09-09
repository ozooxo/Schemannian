#lang racket

(require "fundamental.rkt")

(define g 9.8) 

(define (make-pendulum mass length pivotX pivotY amplitude)
  (define X
    (make-sum (list pivotX (list '* length (list 'sin amplitude)))))
  (define Y
    (make-sum (list pivotY (list '* -1 length (list 'cos amplitude)))))
  (define potential-energy
    (make-product (list mass g Y)))
  (define kinetic-energy
    (make-product (list 0.5 mass (list '** length 2) (list '** (list 'deriv amplitude) 2))))
  (define (dispatch m)
    (cond ((eq? m 'X) X)
          ((eq? m 'Y) Y)
          ((eq? m 'potential-energy) potential-energy)
          ((eq? m 'kinetic-energy) kinetic-energy)))
  dispatch) 

(define pendulum1 (make-pendulum 'm1 'l1 'pivotX1 'pivotY1 (make-function 'theta1 't)))
(pendulum1 'X)
(define pendulum2 (make-pendulum 'm2 'l2 'pivotX2 'pivotY2 (make-function 'theta2 't))) 
(pendulum1 'X)
(pendulum2 'X)