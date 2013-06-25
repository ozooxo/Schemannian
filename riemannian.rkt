#lang racket

(require "tensor.rkt")
(require "linear-algebra.rkt")

;;;

(define (identity-mat-as-tensor index-lst dim)
  (cond ((not (= 2 (length index-lst))) (error "Length of index-lst doesn't match" index-lst))
        ((eq? (car (car index-lst)) (car (cadr index-lst))) (error "Indices should be one sub one super" index-lst))
        (else (make-tensor index-lst (identity-mat dim)))))

;(identity-mat-as-tensor '((_ a) (^ b)) 4) ;works

(define (metric upper-lower-lst tnsr)
  (cond ((not (= 2 (length (get-index tnsr)))) (error "Not a metric" tnsr))
        ((not (= 2 (length upper-lower-lst))) (error "Upper-lower-lst doesn't match" upper-lower-lst))
        ((or (equal? upper-lower-lst '(_ ^)) (equal? upper-lower-lst '(^ _)))
         (identity-mat-as-tensor (list (list (car upper-lower-lst) (cadr (car (get-index tnsr))))
                                 (list (cadr upper-lower-lst) (cadr (cadr (get-index tnsr))))) (length (get-matrix tnsr))))
        ((and (eq? (car upper-lower-lst) (car (car (get-index tnsr))))
              (eq? (cadr upper-lower-lst) (car (cadr (get-index tnsr))))) tnsr)
        ;Haven't done the inverse matrix for g__ to g^^ or g^^ to g__. That part should be hard:-(
        ))

(define g (make-tensor '((_ a) (_ b)) '((1 0 0) (0 -1 0) (0 0 0))))
;(metric '(_ ^) g) ;work
;(metric '(_ _) g) ;work