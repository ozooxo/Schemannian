#lang racket

(require "fundamental.rkt")

(define *table* (make-hash))
(define (get op type) (hash-ref *table* (list op type)))
(define (put op type val) (hash-set! *table* (list op type) val))

(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
          (error
            "No method for these types -- APPLY-GENERIC"
            (list op type-tags))))))

(define (add x y) (apply-generic 'add x y))
(define (mul x y) (apply-generic 'mul x y))

;;;

(define (scalar? datum) (eq? (type-tag datum) 'scalar))
(define (tensor? datum) (eq? (type-tag datum) 'tensor))

(define (install-scalar-package)
  (define (tag x) (attach-tag 'scalar x))
  (define (add x y)
    (make-sum (list x y)))
  (define (mul x y)
    (make-product (list x y)))
  (put 'make-scalar 'scalar tag)
  (put 'add '(scalar scalar) (lambda (x y) (tag (add x y))))
  (put 'mul '(scalar scalar) (lambda (x y) (tag (mul x y)))))

(install-scalar-package)
(define (make-scalar x) ((get 'make-scalar 'scalar) x))

;(define s (make-scalar 2))
;(add s s) ;'(scalar . 4)

(define (install-tensor-package)
  (define (tag x) (attach-tag 'tensor x))
  (define (make-tensor index-lst contents-matrix)
    (cons index-lst (map-n (length index-lst) make-scalar contents-matrix)))
  (define (get-index tnsr) (car tnsr))
  (define (get-matrix tnsr) (cdr tnsr))
  (define (add-tensor x y)
    (define (add-tensor-contents x y)
      (cond ((and (null? x) (null? y)) '())
            ((and (scalar? (car x)) (scalar? (car y)))
             (cons (add (car x) (car y)) (add-tensor-contents (cdr x) (cdr y))))
            ((and (not (scalar? (car x))) (not (scalar? (car y))))
             (cons (add-tensor-contents (car x) (car y)) (add-tensor-contents (cdr x) (cdr y))))
            (else (error "Tensors don't match -- ADD-TENSOR"))))
    (cons (get-index x) (add-tensor-contents (get-matrix x) (get-matrix y))))
  (put 'make-tensor 'tensor (lambda (i m) (tag (make-tensor i m))))
  (put 'add '(tensor tensor) (lambda (x y) (tag (add-tensor x y)))))

(install-tensor-package)
(define (make-tensor index-lst contents-matrix)
  ((get 'make-tensor 'tensor) index-lst contents-matrix))

(define ts (make-tensor (list 'a 'b) (list (list '(+ c d) 2) (list 3 4))))
;(add ts ts) ;'(tensor (a b) ((scalar + (+ c d) (+ c d)) (scalar . 4)) ((scalar . 6) (scalar . 8)))