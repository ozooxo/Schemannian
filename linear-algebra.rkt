#lang racket

(require "fundamental.rkt")

(provide (all-defined-out))

;;;

(define (identity-mat dim)
  (define (one-zeroes-lst dim)
    (define (one-zeroes-iter d)
      (cond ((= 1 d) (list 0))
            ((< d dim) (cons 0 (one-zeroes-iter (- d 1))))
            ((= d dim) (cons 1 (one-zeroes-iter (- d 1))))))
    (one-zeroes-iter dim))
  (if (= dim 1)
      (list (list 1))
      (cons (one-zeroes-lst dim) (map (lambda (element) (cons 0 element)) (identity-mat (- dim 1))))))

;(identity-mat 4) ;'((1 0 0 0) (0 1 0 0) (0 0 1 0) (0 0 0 1))

;;;

(define (dot-product-vector v w)
  (accumulate (lambda args (make-sum args)) 0 (map (lambda args (make-product args)) v w)))

(define (matrix-*-vector m v)
  (define (dot-v w) (dot-product-vector v w))
  (map dot-v m))

(define (transpose-mat m) (accumulate-n cons '() m))

(define (matrix-*-matrix m n)
  (let ((cols (transpose-mat n)))
    (map (lambda (x) (matrix-*-vector m x)) n)))
    ;If the definition is like "m.nT", then we should use "(map <??> n)" rather than "(map <??> m)".

;(define v '(a 5))
;(define w '(d 7))
;(define m '((b c) (e 3)))
;(dot-product-vector v w) ;'(+ 35 (* a d))
;(matrix-*-vector m v) ;'((+ (* a b) (* 5 c)) (+ 15 (* a e)))
;(transpose-mat m) ;'((b e) (c 3))
;(matrix-*-matrix m m) ;'(((+ (* b b) (* c c)) (+ (* b e) (* 3 c))) ((+ (* e b) (* 3 c)) (+ 9 (* e e))))

(define (trace-mat m)
  (if (null? (cdr (car m)))
      (car (car m))
      (make-sum (list (car (car m)) (trace-mat (map cdr (cdr m)))))))

;(trace-mat '((1 2 3) (4 5 6) (7 8 9))) ;15
;(trace-mat '((a b c) (d e f) (g h i))) ;'(+ a (+ e i))