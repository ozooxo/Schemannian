#lang racket

(require racket/stream 
         "fundamental.rkt"
         "simplify.rkt")

(provide numerical-solve)

;;;

(define (replace-transcendental-function exp)
  (cond ((log? exp) (make-log (get-arg exp)))
        ((sin? exp) (make-sin (get-arg exp)))
        ((cos? exp) (make-cos (get-arg exp)))
        ((symbol? exp) exp)
        ((number? exp) exp)
        (else (simplify (map replace-transcendental-function exp)))))

;(replace-transcendental-function '(+ 2 3 x (sin 5) (cos (+ 6 x))))

(define (deriv-order exp)
  (cond ((function? exp) 0)
        ((deriv? exp) (+ 1 (deriv-order (get-function-kernal exp))))
        (else (error "Not a derivative" exp))))

;(deriv-order '(deriv (deriv (function theta1 t) t) t)) ;2

(define (numerical-solve eqn initial-exp-lst initial-lst num-var num-dvar) ;"initial condition" gives from zero's order to (n-1) order
  (if (= (deriv-order (eqn-LHS eqn)) (length initial-lst))
      (let ([num-eqn-RHS (replace-transcendental-function (exp-replace (eqn-RHS eqn) initial-exp-lst initial-lst))])
        (if (not (number? num-eqn-RHS))
            (error "Equation include further parameters, numerical calculation is not possible" eqn)
            (stream-cons (cons num-var initial-lst) (numerical-solve eqn
                                                                     initial-exp-lst 
                                                                     ;(map (lambda (x dx) (+ x (* num-dvar dx))) initial-lst (cons num-eqn-RHS (drop-right initial-lst 1)))
                                                                     (map (lambda (x dx) (+ x (* num-dvar dx))) initial-lst (append (cdr initial-lst) (list num-eqn-RHS)))
                                                                     (+ num-var num-dvar)
                                                                     num-dvar))))
      (error "Initial condition not enough for eqn" eqn initial-lst)))

;;;

;(require "plot.rkt")

;(define solution (numerical-solve '(= (deriv (deriv (function theta1 t) t) t) (function theta1 t)) 
;                                  '((function theta1 t) (deriv (function theta1 t) t))
;                                  '(1 1) 
;                                  0
;                                  0.1))
;(stream-take 10 solution)
;(listplot (map (lambda (x) (drop-right x 1)) (stream-take 30 solution)) 0 2 0 6) ;curve quite makes sense.

;(define solution (numerical-solve '(= (deriv (deriv (function theta1 t) t) t) (* -1 (sin (function theta1 t)))) 
;                                  '((function theta1 t) (deriv (function theta1 t) t))
;                                  '(1 0) 
;                                  0
;                                  0.1))
;(stream-take 10 solution)
;(listplot (map (lambda (x) (drop-right x 1)) (stream-take 60 solution)) 0 5 -1 1) ;curve quite makes sense.
