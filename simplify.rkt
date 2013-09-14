#lang racket

(require "fundamental.rkt")

(provide simplify)

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

(define (combine-consts exp)
  (define counter-hash (make-hash))
  (define (put-to-hash term const)
    (if (hash-has-key? counter-hash term)
        (hash-set! counter-hash term (+ (hash-ref counter-hash term) const))
        (hash-set! counter-hash term const)))
  (define (put-in exp)
    (if (product? exp)
        (let ([prod-exp (make-product (get-arg-lst exp))])
          ;(print prod-exp)
          (cond ((symbol? prod-exp) (put-to-hash (list prod-exp) 1))
                ((number? (car (get-arg-lst prod-exp)))
                 (put-to-hash (cdr (get-arg-lst prod-exp)) (car (get-arg-lst prod-exp))))
                (else (put-to-hash (list prod-exp) 1))))
        (put-to-hash (list exp) 1)))
  (if (sum? exp)
      (begin
        ;(println (get-arg-lst exp))
        (map put-in (get-arg-lst exp))
        ;(println counter-hash)
        (make-sum (map (lambda (x) (make-product (cons (cdr x) (car x)))) (hash->list counter-hash))))
      exp))

;(combine-consts '(* 3 a b)) ;'(* 3 a b)
;(combine-consts '(+ (* 3 a b) (* 5 a b) (* b 6 c) f 7)) ;'(+ (* 6 (b c)) f (* 8 (a b)))

(define (combine-sin2-cos2 exp)
  (define (is-cos2? x) (and (exponentiation? x) (= (exponent x) 2) (cos? (base x))))
  (define (include-cos2? exp)
    (and (product? exp) (not (null? (filter is-cos2? exp)))))
  (define (cos2-factor exp)
    (filter (lambda (x) (not (is-cos2? x))) exp))
  (define (is-sin2? x) (and (exponentiation? x) (= (exponent x) 2) (sin? (base x))))
  (define (include-sin2? exp)
    (and (product? exp) (not (null? (filter is-sin2? exp)))))
  (define (sin2-factor exp)
    (filter (lambda (x) (not (is-sin2? x))) exp))
  (cos2-factor '(+ x y 1 (** (cos (+ z w)) 2) (** (sin (+ z w)) 2)))
  (if (sum? exp)
      (let ([cos2?-lst (filter is-cos2? exp)]
            [sin2?-lst (filter is-sin2? exp)]
            [cos2-facter?-lst (filter include-cos2? exp)]
            [sin2-facter?-lst (filter include-sin2? exp)])
        (cond ((and (= (length cos2?-lst) 1) (= (length sin2?-lst) 1) (equal? (get-arg (base (car cos2?-lst))) (get-arg (base (car sin2?-lst)))))
               (make-sum (cons 1 (filter (lambda (x) (not (or (is-cos2? x) (is-sin2? x)))) (get-arg-lst exp)))))
              ((and (= (length cos2-facter?-lst) 1)
                    (= (length sin2-facter?-lst) 1)
                    (equal? (cos2-factor (car cos2-facter?-lst)) (sin2-factor (car sin2-facter?-lst)))
                    (equal? (get-arg (base (car (filter is-cos2? (car cos2-facter?-lst)))))
                            (get-arg (base (car (filter is-sin2? (car sin2-facter?-lst)))))))
               (make-sum (cons (cos2-factor (car cos2-facter?-lst)) (filter (lambda (x) (not (or (include-cos2? x) (include-sin2? x)))) (get-arg-lst exp)))))
              (else exp)))
      exp))

;(combine-sin2-cos2 '(+ x y 1 (** (cos (+ z w)) 2) (** (sin (+ z w)) 2))) ;'(+ 2 x y)
;(combine-sin2-cos2 '(+ x y 1 (** (cos (+ z w)) 2) (** (sin (+ z x)) 2))) ;same as before
;(combine-sin2-cos2 '(+ x y 1 (* a (** (cos (+ z w)) 2)) (* (** (sin (+ z w)) 2) a))) ;'(+ 1 (* a) x y) ;we can cancel (* a) by doing another simplify, so doesn't matter.
;(combine-sin2-cos2 '(+ x y 1 (* a (** (cos (+ z w)) 2)) (* (** (sin (+ z w)) 2) a b))) ;same as before
;(combine-sin2-cos2 '(+ x y 1 (* a (** (cos (+ z x)) 2)) (* (** (sin (+ z w)) 2) a))) ;same as before

(define (simplify exp)
  (cond ((sum? exp) ((function-chain (list combine-consts combine-sin2-cos2 distributivity))
                     (make-sum (map simplify (get-arg-lst exp)))))
        ((product? exp) (make-product (map simplify (get-arg-lst exp))))
        (else exp)))

;(simplify '(+ 2 3 x (* x 5) (+ 2 y))) ;'(+ 7 x (* 5 x) y)
;(simplify '(* w (+ (* x y z) (* z y w) (* z y)))) ;'(* w (+ 1 x w) y z)
;(simplify '(+ (* 3 a b) (* 5 a b) (* b 6 c) f 7)) ;'(+ 7 (* 6 b c) f (* 8 a b))
;(simplify '(+ x y 1 (* a (** (cos (+ z w)) 2)) (* (** (sin (+ z w)) 2) a))) ;'(+ 1 y x a)

;(distributivity '(+
;   (* (** l2 2) (** (cos (function theta2 t)) 2) (** (deriv (function theta2 t) t) 2))
;   (* (** l2 2) (** ((sin (function theta2 t)) (deriv (function theta2 t) t)) 2))))

;(simplify '(+
;   (* (** l2 2) (** (cos (function theta2 t)) 2) (** (deriv (function theta2 t) t) 2))
;   (* (** l2 2) (** ((sin (function theta2 t)) (deriv (function theta2 t) t)) 2))))

;'(*
;  (+ (* (** (cos (function theta2 t)) 2) (** (deriv (function theta2 t) t) 2)) (** ((sin (function theta2 t)) (deriv (function theta2 t) t)) 2))
;  (** l2 2))
