#lang racket

(require racket/stream 
         "fundamental.rkt")

(provide numerical-solve)

;;;

(define (deriv-order exp)
  (cond ((function? exp) 0)
        ((deriv? exp) (+ 1 (deriv-order (get-function-kernal exp))))
        (else (error "Not a derivative" exp))))

;(deriv-order '(deriv (deriv (function theta1 t) t) t)) ;2

(define (numerical-solve eqn initial-exp-lst initial-lst num-var num-dvar) ;"initial condition" gives from zero's order to (n-1) order
  (if (= (deriv-order (eqn-LHS eqn)) (length initial-lst))
      (let ([num-eqn-RHS (exp-replace (eqn-RHS eqn) initial-exp-lst initial-lst)])
        (if (not (number? num-eqn-RHS))
            (error "Equation include further parameters, numerical calculation is not possible" eqn)
            (stream-cons (cons num-var initial-lst) (numerical-solve eqn
                                                                     initial-exp-lst 
                                                                     (map (lambda (x dx) (+ x (* num-dvar dx))) initial-lst (cons num-eqn-RHS (drop-right initial-lst 1)))
                                                                     (+ num-var num-dvar)
                                                                     num-dvar))))
      (error "Initial condition not enough for eqn" eqn initial-lst)))

;(define solution (numerical-solve '(= (deriv (deriv (function theta1 t) t) t) (function theta1 t)) 
;                                  '((function theta1 t) (deriv (function theta1 t) t))
;                                  '(1 1) 
;                                  0
;                                  0.1))
;(stream-take 10 solution)
;(require "plot.rkt")
;(listplot (map (lambda (x) (drop-right x 1)) (stream-take 10 solution)) 0 1 0 3) ;curve quite makes sense.