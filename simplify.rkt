#lang racket

(require "fundamental.rkt")

(define (distributivity exp)
  (if (and (sum? exp) (and-lst (map product? (get-arg-lst exp))))
      (let ([intersect (list-intersect (map get-arg-lst (get-arg-lst exp)))])
        (make-product (cons (make-sum (map (lambda (lst) (make-product (removes intersect (get-arg-lst lst)))) (get-arg-lst exp))) intersect)))
      exp))

;(distributivity '(+ 2 3 x (* x 5) (+ 2 y))) ;same
;(distributivity '(+ (* x y z) (* z y w) (* z y))) ;'(* (+ 1 x w) y z)
;(distributivity '(+ (* x y y z) (* y z y w) (* y z y))) ;'(* (+ (* x y) (* y w) y) y z) ;currently it doesn't work for duplicate paras
;(distributivity '(+ (* x y z) (* z y w) (* z))) ;'(* (+ 1 (* x y) (* y w)) z)
;(distributivity '(+ (* x y z) (* z y w) (* z y) (* 2 n))) ;'(+ (* x y z) (* z y w) (* z y) (* 2 n)) ;nothing change

(define (simplify exp)
  (cond ((sum? exp) (distributivity (make-sum (map simplify (get-arg-lst exp)))))
        ((product? exp) (make-product (map simplify (get-arg-lst exp))))
        (else exp)))

(simplify '(+ 2 3 x (* x 5) (+ 2 y))) ;'(+ 7 x (* 5 x) y)
(simplify '(* w (+ (* x y z) (* z y w) (* z y)))) ;'(* w (+ 1 x w) y z)