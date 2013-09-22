#lang racket

(require "fundamental.rkt"
         2htdp/image)

(provide show-expression)

(define (show-expression exp [parentheses? false])
  (define (show x) (text x 24 "black"))
  (define blank (text " " 12 "black"))
  (define show+ (show "+"))
  ;(define show* (show "*"))
  (define (add-parentheses x) (beside (show "(") x (show ")")))
  (define (besidee lst)
    (let ([len (length lst)])
      (cond ((= len 0) (show "1"))
            ((= len 1) (car lst))
            (else (apply beside/align (cons "bottom" lst))))))
  (define (get-deriv-arg-lst exp lst)
    (if (deriv? exp)
        (cons (get-deriv-arg exp) (get-deriv-arg-lst (get-deriv-kernel exp) lst))
        lst))
  (define (get-deriv-deepest-kernel exp)
    (if (deriv? exp)
        (get-deriv-deepest-kernel (get-deriv-kernel exp))
        exp))
  (cond ((number? exp) (show (number->string exp)))
        ((variable? exp) (show (symbol->string exp)))
        ((sum? exp)
         (let ([to-show (besidee (list-mixed-up (map show-expression (get-arg-lst exp)) show+))])
           (if (eq? parentheses? false)
               to-show
               (add-parentheses to-show))))
        ((product? exp)
         (define (denominator? x) (and (exponentiation? x) (number? (exponent x)) (< (exponent x) 0)))
         (let ([numerator (filter (function-chain (list not denominator?)) (get-arg-lst exp))]
               [denominator (map (lambda (x) (make-exponentiation (base x) (- (exponent x)))) (filter denominator? (get-arg-lst exp)))])
           (let ([draw-numerator (besidee (map (lambda (x) (show-expression x true)) numerator))]
                 [draw-denominator (besidee (map (lambda (x) (show-expression x true)) denominator))])
             (if (null? denominator)
                 draw-numerator
                 (above 
                  draw-numerator
                  (rectangle (max (image-width draw-numerator) (image-width draw-denominator)) 2 "solid" "black")
                  draw-denominator)))))
        ((exponentiation? exp) (beside/align "bottom" (show-expression (base exp) true) (above (show-expression (exponent exp) true) blank)))
        ((log? exp) (beside (show "log") (add-parentheses (show-expression (get-arg exp)))))
        ((sin? exp) (beside (show "sin") (add-parentheses (show-expression (get-arg exp)))))
        ((cos? exp) (beside (show "cos") (add-parentheses (show-expression (get-arg exp)))))
        ((function? exp) (beside (show-expression (get-function-kernal exp))
                                 (add-parentheses (show-expression (get-function-arg exp)))))
        ((deriv? exp)
         (let ([arg-lst (get-deriv-arg-lst exp '())]
               [deepest-kernel (get-deriv-deepest-kernel exp)])
           (let ([draw-d-above (beside/align "bottom" (if (= (length arg-lst) 1)
                                                          (show "d")
                                                          (show-expression (make-exponentiation 'd (length arg-lst))))
                                             (if (function? deepest-kernel)
                                                 (show-expression deepest-kernel)
                                                 (add-parentheses (show-expression deepest-kernel))))]
                 [draw-d-bottom (beside/align "bottom"
                                              (show "d")
                                              (if (= (length arg-lst) 1)
                                                  (show-expression (car arg-lst))
                                                  (show-expression (make-exponentiation (car arg-lst) (length arg-lst)))))])
             (above 
              draw-d-above
              (rectangle (max (image-width draw-d-above) (image-width draw-d-bottom)) 2 "solid" "black")
              draw-d-bottom))))
        ))

;(show-expression '(* 2 b (** c -2)))
;(show-expression '(+ 3 x y))
;(show-expression '(** x (+ y z)))
(show-expression '(* 3 (** x z) y (+ a 2) (** z (* 2 b (** c -1))) (** w -2) (** (cos x) -1)))

(show-expression '(deriv (+ 2 (function x t)) t))
(show-expression '(deriv (deriv (function x t) t) t))