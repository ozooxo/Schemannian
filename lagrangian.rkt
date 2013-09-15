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