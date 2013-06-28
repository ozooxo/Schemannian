#lang racket

(require (only-in "fundamental.rkt" list-take list-reverse map-n))
(require "tensor.rkt")
(require "linear-algebra.rkt")

(provide (all-defined-out))

;;;

(define (identity-mat-as-tensor index-lst dim)
  (cond ((not (= 2 (length index-lst))) (error "Length of index-lst doesn't match" index-lst))
        ((eq? (car (car index-lst)) (car (cadr index-lst))) (error "Indices should be one sub one super" index-lst))
        (else (make-tensor index-lst (identity-mat dim)))))

;(identity-mat-as-tensor '((_ a) (^ b)) 4) ;works

(define (tensor-order tnsr) (length (get-index tnsr)))
(define (tensor-dimension tnsr) (length (get-matrix tnsr)))
;For tensors in tensor.rkt, the dimensions belong to different indices need not be the same.
;In Riemannian geometry, the dimension (of space) should be the same for all orders.
;In here, we don't check whether it is true or not.

(define (einstein-summation tnsr)
  (define (index-same-back ele lst)
    (define (list-flip new-lst old-lst)
      (cond ((null? old-lst) false)
            ((eq? (cadr ele) (cadr (car old-lst))) (list-reverse new-lst (append (cdr old-lst) (list (car old-lst)))))
            (else (list-flip (cons (car old-lst) new-lst) (cdr old-lst)))))
    (list-flip '() lst))
  ;(index-same-back '(^ a) '((_ b) (_ a) (^ c))) ;'((_ b) (^ c) (_ a))
  
  (define (list-same-right lst)
    (define (list-same-right-recur lst)
      (if (null? lst)
          false
          (let ([remain (index-same-back (car lst) (cdr lst))])
            (if remain
                (append remain (list (car lst)))
                (let ([recur (list-same-right-recur (cdr lst))])
                  (if recur
                      (cons (car lst) recur)
                      false))))))
    (list-same-right-recur lst))
  (list-same-right '((_ a) (_ b) (^ a) (_ d) (^ b))) ;'((_ b) (_ d) (^ b) (^ a) (_ a))
  (list-same-right '((_ a) (_ b) (^ c) (_ d))) ;#f
  
  (define (tensor-trace tnsr)
    (let ([len (- (length (get-index tnsr)) 2)])
      (make-tensor
       (list-take (get-index tnsr) len)
       (map-n len mat-trace (get-matrix-without-tag tnsr)))))
  (if (= (length (get-index tnsr)) 2)
      (if (eq? (cadr (car (get-index tnsr))) (cadr (cadr (get-index tnsr))))
          (make-scalar (mat-trace (get-matrix-without-tag tnsr)))
          tnsr)
      (let ([new-index (list-same-right (get-index tnsr))])
        (if new-index
            (einstein-summation (tensor-trace (switch-index new-index tnsr)))
            tnsr))))

;(define t (make-tensor '((^ a) (_ a)) '((a b) (c d))))
;(einstein-summation t) ;'(scalar + a d)
;(define s (make-tensor '((^ a) (_ b)) '((a b) (c d))))
;(einstein-summation s)
;(define ts (make-tensor '((_ b) (^ a) (^ b)) (list (list (list 1 2) (list 3 4)) (list (list 5 6) (list 7 8)))))
;(einstein-summation ts) ;'(tensor (a) (scalar . 7) (scalar . 11))
;(define tss (make-tensor '((_ a) (^ b) (^ c)) (list (list (list 1 2) (list 3 4)) (list (list 5 6) (list 7 8)))))
;(einstein-summation tss) ;same as the original

(define (metric upper-lower-lst tnsr)
  (cond ((not (= 2 (tensor-order tnsr))) (error "Not a metric" tnsr))
        ((not (= 2 (length upper-lower-lst))) (error "Upper-lower-lst doesn't match" upper-lower-lst))
        ((or (equal? upper-lower-lst '(_ ^)) (equal? upper-lower-lst '(^ _)))
         (identity-mat-as-tensor (list (list (car upper-lower-lst) (cadr (car (get-index tnsr))))
                                       (list (cadr upper-lower-lst) (cadr (cadr (get-index tnsr))))) 
                                 (tensor-dimension tnsr)))
        ((and (eq? (car upper-lower-lst) (car (car (get-index tnsr))))
              (eq? (cadr upper-lower-lst) (car (cadr (get-index tnsr))))) tnsr)
        (else 
         (make-tensor (list (list (car upper-lower-lst) (cadr (car (get-index tnsr))))
                            (list (cadr upper-lower-lst) (cadr (cadr (get-index tnsr)))))
                      (mat-inverse (get-matrix-without-tag tnsr))))))

;(define g (make-tensor '((_ a) (_ b)) '((1 -3 1) (-3 -1 0) (1 0 2))))
;(define g (make-tensor '((_ a) (_ b)) '((1 -3 a) (-3 -1 0) (a 0 2)))) 
;The second one also works, but it doesn't know how to do simplification right now.
;(metric '(_ ^) g) ;works
;(metric '(_ _) g) ;works
;(metric '(^ ^) g) ;works
;(einstein-summation (mul (change-index '((^ a) (^ b)) (metric '(^ ^) g)) 
;                         (change-index '((_ b) (_ c)) (metric '(_ _) g)))) ;'(tensor ((^ a) (_ c)) identity)

(define (christoffel index-lst g-tensor coordinate-lst)
  (if (nand (= 3 (length index-lst))
            (eq? (car (car index-lst)) '^)
            (eq? (car (cadr index-lst)) '_)
            (eq? (car (caddr index-lst)) '_))
      (error "Christoffel symbol needs 3 indices, has super-sub-sub in order. You give" index-lst)
      (let ([first-term (partial-deriv (change-index '((_ dummy) (_ j)) g-tensor)
                                       (make-tensor '((_ k)) coordinate-lst))])
        (change-index
         index-lst
         (einstein-summation
          (mul
           (change-index '((^ i) (^ dummy)) (metric '(^ ^) g-tensor))
           (scalar-mul
            (/ 1 2)
            (add first-term 
                 (add (switch-index '((_ dummy) (_ k) (_ j)) first-term)
                      (scalar-mul -1 (switch-index '((_ j) (_ k) (_ dummy)) first-term)))))))))))

(define (riemann-tensor index-lst christoffel-gamma coordinate-lst)
  (if (nand (= 4 (length index-lst))
            (eq? (car (car index-lst)) '^)
            (eq? (car (cadr index-lst)) '_)
            (eq? (car (caddr index-lst)) '_)
            (eq? (car (cadddr index-lst)) '_))
      (error "Riemann curvature tensor needs 4 indices, has super-sub-sub-sub in order. You give" index-lst)
      (let* ([gamma (change-index '((^ i) (_ l) (_ j)) christoffel-gamma)]
             [partial-gamma (partial-deriv gamma (make-tensor '((_ k)) coordinate-lst))])
        (change-index
         index-lst
         (add
          (add (switch-index '((^ i) (_ j) (_ k) (_ l)) partial-gamma)
               (scalar-mul -1 (switch-index '((^ i) (_ k) (_ j) (_ l)) partial-gamma)))
          (switch-index
           '((^ i) (_ j) (_ k) (_ l))
           (add (einstein-summation
                 (mul (change-index '((^ i) (_ k) (_ dummy)) gamma)
                      (change-index '((^ dummy) (_ l) (_ j)) gamma)))
                (einstein-summation
                 (mul (change-index '((^ i) (_ l) (_ dummy)) gamma)
                      (change-index '((^ dummy) (_ k) (_ j)) gamma))))))))))

(define (ricci-curvature-tensor index-lst riemann-tnsr)
  (if (nand (= 2 (length index-lst))
            (eq? (car (car index-lst)) '_)
            (eq? (car (cadr index-lst)) '_))
      (error "Ricci curvature tensor needs 2 indices, has sub-sub in order. You give" index-lst)
      (change-index
       index-lst
       (einstein-summation
        (change-index  '((^ k) (_ i) (_ k) (_ j)) riemann-tnsr)))))

(define (ricci-scalar g-tnsr ricci-tnsr)
  (einstein-summation
   (mul (change-index '((^ i) (^ j)) (metric '(^ ^) g-tnsr))
        (change-index '((_ j) (_ i)) ricci-tnsr))))

;(define g (make-tensor '((_ a) (_ b)) '((x1 0) (0 x2))))
;(define gamma (christoffel '((^ i) (_ j) (_ k)) g '(x1 x2))) ;seems work, no simplification right now.
   ;'(tensor
   ;  ((^ i) (_ j) (_ k))
   ;  (((scalar * (1/2)(* x2 (** (* x2 x1) -1))) (scalar . 0)) ((scalar . 0) (scalar . 0)))
   ;  (((scalar . 0) (scalar . 0)) ((scalar . 0) (scalar * (1/2)(* x1 (** (* x2 x1) -1))))))
;;;(christoffel '((^ i) (_ j) (^ k)) g '(x1 x2)) ;index error
;(define r_abcd (riemann-tensor '((^ a) (_ b) (_ c) (_ d)) gamma '(x1 x2)))
;(define r_ab (ricci-curvature-tensor '((_ a) (_ b)) r_abcd)) ;It is symmetric right now.
;(ricci-scalar g r_ab) ;works. no simplification. so currently can't check whether right or now.

(define g (make-tensor '((_ a) (_ b)) 
                       '(((+ 1 (* -1 rs (** r -1))) 0 0 0)
                         (0 (* -1 (** (+ 1 (* -1 rs (** r -1))) -1)) 0 0)
                         (0 0 (* -1 (** r 2)) 0)
                         (0 0 0 (* -1 (** r 2) (** (sin theta) 2))))))
(define Gamma^a_bc (christoffel '((^ a) (_ b) (_ c)) g '(t r theta phi)))
(define R^a_bcd (riemann-tensor '((^ a) (_ b) (_ c) (_ d)) Gamma^a_bc '(t r theta phi)))
(define R_ab (ricci-curvature-tensor '((_ a) (_ b)) R^a_bcd))
(ricci-scalar g R_ab)