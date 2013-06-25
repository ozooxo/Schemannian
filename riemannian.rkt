#lang racket

(require "tensor.rkt")

;;;

(define (identity-matrix index-lst dim)
  (define (one-zeroes-lst dim)
    (define (one-zeroes-iter d)
      (cond ((= 1 d) (list 0))
            ((< d dim) (cons 0 (one-zeroes-iter (- d 1))))
            ((= d dim) (cons 1 (one-zeroes-iter (- d 1))))))
    (one-zeroes-iter dim))
  (define (identity-mat-build dim)
    (if (= dim 1)
        (list (list 1))
        (cons (one-zeroes-lst dim) (map (lambda (element) (cons 0 element)) (identity-mat-build (- dim 1))))))       
  (cond ((not (= 2 (length index-lst))) (error "Length of index-lst doesn't match" index-lst))
        ((eq? (car (car index-lst)) (car (cadr index-lst))) (error "Indices should be one sub one super" index-lst))
        (else (make-tensor index-lst (identity-mat-build dim)))))

;(identity-matrix '((_ a) (^ b)) 4) ;works

(define (metric upper-lower-lst tnsr)
  (cond ((not (= 2 (length (get-index tnsr)))) (error "Not a metric" tnsr))
        ((not (= 2 (length upper-lower-lst))) (error "Upper-lower-lst doesn't match" upper-lower-lst))
        ((or (equal? upper-lower-lst '(_ ^)) (equal? upper-lower-lst '(^ _)))
         (identity-matrix (list (list (car upper-lower-lst) (cadr (car (get-index tnsr))))
                                (list (cadr upper-lower-lst) (cadr (cadr (get-index tnsr))))) (length (get-matrix tnsr))))
        ((and (eq? (car upper-lower-lst) (car (car (get-index tnsr))))
              (eq? (cadr upper-lower-lst) (car (cadr (get-index tnsr))))) tnsr)
        ;Haven't done the inverse matrix for g__ to g^^ or g^^ to g__. That part should be hard:-(
        ))

(define g (make-tensor '((_ a) (_ b)) '((1 0 0) (0 -1 0) (0 0 0))))
;(metric '(_ ^) g) ;work
;(metric '(_ _) g) ;work