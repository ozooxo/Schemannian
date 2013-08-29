#lang racket

(require "generic-hash.rkt" "fundamental.rkt")

(define (grassmannian? datum) 
  (cond ((number? datum) false)
        ((variable? datum) false)
        (else (eq? (type-tag datum) 'grassmannian))))

(define (install-grassmannian-package)
  (define (tag x) (attach-tag 'grassmannian x))
  (put 'make-grassmannian 'grassmannian tag))
;  (put 'add '(scalar grassmannian) (lambda (x y) (list '+ (make-scalar x) (tag y))))
;  (put 'add '(grassmannian scalar) (lambda (x y) (list '+ (make-scalar y) (tag x)))) ;So the grassmannian is always after the scalar
;  (put 'add '(grassmannian grassmannian) (lambda (x y) (list '+ (tag x) (tag y)))))

(install-grassmannian-package)
(define (make-grassmannian x) ((get 'make-grassmannian 'grassmannian) x))

(define (has-same-grassmannians? args)
  (define (same?-iter args grassmannian-lst)
    (cond ((null? args) false)
          ((grassmannian? (car args))
           (if (index (car args) grassmannian-lst) ;"index" in "fundamental.rkt" works using "equal?".
               true
               (same?-iter (cdr args) (cons (car args) grassmannian-lst))))
          (else (same?-iter (cdr args) grassmannian-lst))))
  (same?-iter args '()))
;(has-same-grassmannians? (list 2 (make-grassmannian 'x) 3 'x (make-grassmannian 'z))) ;#f
;(has-same-grassmannians? (list 2 (make-grassmannian 'x) 3 'x (make-grassmannian 'x))) ;#t

(define (simplify-grassmannian exp)
  (cond ((sum? exp) (make-sum (map simplify-grassmannian (get-arg-lst exp))))
        ((product? exp)
         (if (has-same-grassmannians? (get-arg-lst exp))
             0
             (make-product (map simplify-grassmannian (get-arg-lst exp)))))
        (else exp)))

;(simplify-grassmannian (list '+ 2 (make-grassmannian 'x) 3 'x (make-grassmannian 'z))) ;okay
;(simplify-grassmannian (list '* 2 (make-grassmannian 'x) 3 'x (make-grassmannian 'z))) ;okay
;(simplify-grassmannian (list '* 2 (make-grassmannian 'x) 3 'x (make-grassmannian 'x))) ;0
;(simplify-grassmannian (list '* 0 (make-grassmannian 'x) 3 'x (make-grassmannian 'z))) ;0

(define (grassmannian-integrate exp var-lst)