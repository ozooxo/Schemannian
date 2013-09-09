#lang racket

(require "fundamental.rkt")

(define (simplify exp)
  (cond ((sum? exp) (make-sum (map simplify (get-arg-lst exp))))
        ((product? exp) (make-product (map simplify (get-arg-lst exp))))
        (else exp)))

(simplify '(+ 2 3 x (* x 5) (+ 2 y))) ;'(+ 7 x (* 5 x) y)