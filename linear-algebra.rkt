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
    ;We may need to change the sign here later for consistency reasons.

;(define v '(a 5))
;(define w '(d 7))
;(define m '((b c) (e 3)))
;(dot-product-vector v w) ;'(+ 35 (* a d))
;(matrix-*-vector m v) ;'((+ (* a b) (* 5 c)) (+ 15 (* a e)))
;(transpose-mat m) ;'((b e) (c 3))
;(matrix-*-matrix m m) ;'(((+ (* b b) (* c c)) (+ (* b e) (* 3 c))) ((+ (* e b) (* 3 c)) (+ 9 (* e e))))

(define (mat-trace m)
  (if (null? (cdr (car m)))
      (car (car m))
      (make-sum (list (car (car m)) (mat-trace (map cdr (cdr m)))))))

;(mat-trace '((1 2 3) (4 5 6) (7 8 9))) ;15
;(mat-trace '((a b c) (d e f) (g h i))) ;'(+ a (+ e i))

(define (mat-delete-column m pos) (list-delete m pos))
(define (mat-delete-row m pos) (map (lambda (lst) (list-delete lst pos)) m))

(define (mat-determinant m)
  (define (pointer num columns)
    (if (null? columns)
        '()
        (begin
         (cons 
          (make-product (list (sign num) (mat-determinant (map cdr (mat-delete-column m num))) (car (car columns))))
          (pointer (+ num 1) (cdr columns))))))
  (cond ((not (= (length m) (length (car m)))) (error "Not a squared matrix"))
        ((null? (cdr m)) (car (car m)))
        (else (make-sum (pointer 0 m)))))

(define (mat-factor m i j) (list-ref (list-ref m i) j))
(define (mat-cofactor m i j) (make-product
                              (list
                               (sign (+ i j))
                               (mat-determinant (mat-delete-column (mat-delete-row m j) i)))))

(define (mat-inverse m)
  (let ([det (mat-determinant m)]
        [len (length m)])
    (map (lambda (row) (map (lambda (column) (make-product (list (mat-cofactor m column row)
                                                                 (make-exponentiation det -1))))
                            (range len))) 
         (range len))))

;(define l '((10 -9 -12) (7 -12 11) (-10 10 3)))
;(define m '((a b c) (d e f) (g h i)))
;(define n '((1 2 4 8) (3 5 6 2) (7 9 8 4) (1 3 2 4)))
;(mat-delete-column m 1) ;'((a b c) (g h i))
;(mat-delete-row m 1) ;'((a c) (d f) (g i))
;(mat-determinant m) ;'(+ (* (+ (* i e) (* -1 f h)) a) (* -1 (+ (* i b) (* -1 c h)) d) (* (+ (* f b) (* -1 c e)) g))
;(mat-determinant n) ;-204
;(mat-factor m 1 2) ;'f
;(mat-cofactor m 1 2) ;'(+ (* h a) (* -1 b g))
;(mat-inverse l) ;checked with wolframalpha.com, it works.
;(mat-inverse n) ;works