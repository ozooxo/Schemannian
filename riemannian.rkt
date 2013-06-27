#lang racket

(require (only-in "fundamental.rkt" list-take))
(require "tensor.rkt")
(require "linear-algebra.rkt")

;;;

(define (identity-mat-as-tensor index-lst dim)
  (cond ((not (= 2 (length index-lst))) (error "Length of index-lst doesn't match" index-lst))
        ((eq? (car (car index-lst)) (car (cadr index-lst))) (error "Indices should be one sub one super" index-lst))
        (else (make-tensor index-lst (identity-mat dim)))))

;(identity-mat-as-tensor '((_ a) (^ b)) 4) ;works

(define (tensor-order tnsr) (length (get-index tnsr)))
(define (tensor-dimension tnsr) (length (get-matrix tnsr)))
;For tensors in tensor.rkt, the dimensions belong to different indices need not be the same.
;In Riemannian geometry, the dimension (of space) should be the same for all orders.
;In here, we don't check whether it is true or not.

(define (metric upper-lower-lst tnsr)
  (cond ((not (= 2 (tensor-order tnsr))) (error "Not a metric" tnsr))
        ((not (= 2 (length upper-lower-lst))) (error "Upper-lower-lst doesn't match" upper-lower-lst))
        ((or (equal? upper-lower-lst '(_ ^)) (equal? upper-lower-lst '(^ _)))
         (identity-mat-as-tensor (list (list (car upper-lower-lst) (cadr (car (get-index tnsr))))
                                       (list (cadr upper-lower-lst) (cadr (cadr (get-index tnsr))))) 
                                 (tensor-dimension tnsr)))
        ((and (eq? (car upper-lower-lst) (car (car (get-index tnsr))))
              (eq? (cadr upper-lower-lst) (car (cadr (get-index tnsr))))) tnsr)
        (else 
         (make-tensor (list (list (car upper-lower-lst) (cadr (car (get-index tnsr))))
                            (list (cadr upper-lower-lst) (cadr (cadr (get-index tnsr)))))
                      (mat-inverse (get-matrix-without-tag tnsr))))))

;(define g (make-tensor '((_ a) (_ b)) '((1 0 0) (0 -1 0) (0 0 2))))
;(metric '(_ ^) g) ;works
;(metric '(_ _) g) ;works
;(metric '(^ ^) g) ;works

(define (christoffel index-lst g-tensor coordinate-lst)
  (if (not (= 3 (length index-lst)))
      (error "Christoffel symbol needs 3 indices, given" (length index-lst))
      (partial-deriv (change-index (list-take index-lst 2) g-tensor)
                     (make-tensor (list-tail index-lst 2) coordinate-lst))
      ;Right now it is only the first term. Need a function for permutation of indices.
      ))

(define g (make-tensor '((_ a) (_ b)) '((x1 0) (0 x2))))
(christoffel '((_ i) (_ j) (_ k)) g '(x1 x2))