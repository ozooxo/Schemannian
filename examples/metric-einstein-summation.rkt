#lang racket

(require "../tensor.rkt"
         "../riemannian.rkt")

(define g (make-tensor '((_ a) (_ b)) '((a b c d) (e f g h) (i j k l) (m n o p)))) 
(einstein-summation (mul (change-index '((^ a) (^ b)) (metric '(^ ^) g)) 
                         (change-index '((_ b) (_ c)) (metric '(_ _) g))))

;'(tensor
;  ((^ a) (_ c))
;  ((scalar . 1) (scalar . 0) (scalar . 0) (scalar . 0))
;  ((scalar . 0) (scalar . 1) (scalar . 0) (scalar . 0))
;  ((scalar . 0) (scalar . 0) (scalar . 1) (scalar . 0))
;  ((scalar . 0) (scalar . 0) (scalar . 0) (scalar . 1)))