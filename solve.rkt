#lang racket

(require "fundamental.rkt")

(provide solve)

(define (solve-count exp var)
  (cond ((number? exp) 0)
        ((equal? exp var) 1)
        ((and (variable? exp) (not (same-variable? exp var))) 0)
        ((or (eqn? exp) (sum? exp) (product? exp) (exponentiation? exp))
         (apply + (map (lambda (x) (solve-count x var)) (get-arg-lst exp))))
        ((or (log? exp) (sin? exp) (cos? exp))
         (solve-count (get-arg exp) var))
        (else (error "unknown expression type -- SOLVE-COUNT" exp))))

;(solve-count '(= (* 3 y) x) 'y) ;1
;(solve-count '(= (* 3 (sin y)) (+ x y)) 'y) ;2

(define (switch-LHS-RHS eqn var)
  (if (= (solve-count (eqn-LHS eqn) var) 1)
      eqn
      (make-eqn (eqn-RHS eqn) (eqn-LHS eqn))))

;(switch-LHS-RHS '(= (* 3 y) x) 'y)
;(switch-LHS-RHS '(= x (* 3 y)) 'y)

(define (exp-with-var exp-lst var)
  (car (filter (lambda (exp) (= (solve-count exp var) 1)) exp-lst)))
(define (exp-lst-without-var exp-lst var)
  (filter (lambda (exp) (not (= (solve-count exp var) 1))) exp-lst))

;(exp-with-var '(x (+ 3 y) z) 'y) ;'(+ 3 y)
;(exp-lst-without-var '(x (+ 3 y) z) 'y) ;'(x z)

(define (solve eqn var)
  (cond ((and (eqn? eqn) (= (solve-count eqn var) 1))
         (let ([eqnn (switch-LHS-RHS eqn var)])
           (cond ((equal? (eqn-LHS eqnn) var) (eqn-RHS eqnn))
                 ((sum? (eqn-LHS eqnn)) 
                  (solve (make-eqn (exp-with-var (get-arg-lst (eqn-LHS eqnn)) var)
                                   (make-sum (cons (eqn-RHS eqnn) (map (lambda (x) (make-product (list -1 x))) (exp-lst-without-var (get-arg-lst (eqn-LHS eqnn)) var)))))
                         var))
                 ((product? (eqn-LHS eqnn)) 
                  (solve (make-eqn (exp-with-var (get-arg-lst (eqn-LHS eqnn)) var)
                                   (make-product (cons (eqn-RHS eqnn) (map (lambda (x) (make-exponentiation x -1)) (exp-lst-without-var (get-arg-lst (eqn-LHS eqnn)) var)))))
                         var))
                 ((and (exponentiation? (eqn-LHS eqnn)) (= (solve-count (base (eqn-LHS eqnn)) var) 1))
                  (solve (make-eqn (base (eqn-LHS eqnn)) (make-exponentiation (eqn-RHS eqnn) (make-exponentiation (exponent (eqn-LHS eqnn)) -1))) var))
                 ((and (exponentiation? (eqn-LHS eqnn)) (= (solve-count (exponent (eqn-LHS eqnn)) var) 1))
                  (solve (make-eqn (exponent (eqn-LHS eqnn)) (make-product (list (make-log (eqn-RHS eqnn)) (make-exponentiation (make-log (base (eqn-LHS eqnn))) -1)))) var))
                 ((log? (eqn-LHS eqnn))
                  (solve (make-eqn (get-arg (eqn-LHS eqnn)) (make-exponentiation (exp 1) (eqn-RHS eqnn))) var))
                 (else (error "Don't know how to do it right now")))))
        ((eqn? eqn)
         (error "Var appears in eqn not exactly once, don't know how to solve right now" eqn))
        (else (error "Not a equation" eqn))))

;(solve '(* 3 y) 'y) ;Not a equation (* 3 y)
;(solve '(= y (* 3 y)) 'y) ;Var appears in eqn not exactly once, don't know how to solve right now (= y (* 3 y))
;(solve '(= y x) 'y) ;'x
;(solve '(= x y) 'y) ;'x
;(solve '(= (+ y z) x) 'y) ;'(+ x (* -1 z))
;(solve '(= x (* z y)) 'y) ;'(* x (** z -1))
;(solve '(= (** x z) y) 'x) ;'(** y (** z -1))
;(solve '(= (** x z) y) 'z) ;'(* (log y) (** (log x) -1))
;(solve '(= x (log y)) 'y) ;'(** 2.718281828459045 x)
