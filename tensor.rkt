#lang racket

(require "generic-hash.rkt"
         "fundamental.rkt"
         "simplify.rkt"
         "calculus.rkt")
(require (only-in "linear-algebra.rkt" transpose-mat))

(provide (all-defined-out))

;;;

(define (add x y) (apply-generic 'add x y))
(define (mul x y) (apply-generic 'mul x y))
(define (simplify-generic x) (apply-generic 'simplify-generic x))
(define (partial-deriv fx x) (apply-generic 'partial-deriv fx x))

;;;

(define (scalar? datum) (eq? (type-tag datum) 'scalar))
(define (tensor? datum) (eq? (type-tag datum) 'tensor))

(define (install-scalar-package)
  (define (tag x) (attach-tag 'scalar x))
  (define (add x y) (simplify (make-sum (list x y))))
  (define (mul x y) (simplify (make-product (list x y))))
  (define (simplify-generic x) (simplify x))
  (define (partial-deriv fx x) (deriv fx x))
  (put 'make-scalar 'scalar tag)
  (put 'add '(scalar scalar) (lambda (x y) (tag (add x y))))
  (put 'mul '(scalar scalar) (lambda (x y) (tag (mul x y))))
  (put 'simplify-generic '(scalar) (lambda (x) (tag (simplify-generic x))))
  (put 'partial-deriv '(scalar scalar) (lambda (fx x) (tag (partial-deriv fx x)))))

(install-scalar-package)
(define (make-scalar x) ((get 'make-scalar 'scalar) x))

;(define s (make-scalar 2))
;(add s s) ;'(scalar . 4)

;(define x (make-scalar 'x))
;(define fx (make-scalar '(* y z)))
;(define gx (make-scalar '(* x y z)))
;(partial-deriv fx x) ;'(scalar . 0)
;(partial-deriv gx x) ;'(scalar * y z)

;(define t (make-scalar '(+ 3 6 (+ x 5 x))))
;(simplify-generic t) ;'(scalar + 14 (* 2 x))

(define (install-tensor-package)
  (define (switch-index-withmat level lst)
    (if (= level 1)
        (cons (cadr lst) (cons (car lst) (cddr lst)))
        (cons (car lst) (switch-index-withmat (- level 1) (cdr lst)))))
  (define (switch-index-mat level mat) ;For tensor Xabcd, level 1 is a<=>b, level 2 is b<=>c ...
    (if (= level 1)
        (transpose-mat mat)
        (map (lambda (mat) (switch-index-mat (- level 1) mat)) mat)))
  ;(switch-index-withmat 1 '(a b c d)) ;'(b a c d)
  ;(switch-index-withmat 2 '(a b c d)) ;'(a c b d)
  ;(switch-index-withmat 3 '(a b c d)) ;'(a b d c)
  ;(define mat (list (list 1 2) (list 3 4)))
  ;(define tam (list (list 5 6) (list 7 8)))
  ;(define mat-3d (list mat tam))
  ;(transpose-mat mat) ;'((1 3) (2 4))
  ;(switch-index-mat 1 (switch-index-mat 2 (switch-index-mat 1 mat-3d))) ;
  ;(switch-index-mat 2 (switch-index-mat 1 (switch-index-mat 2 mat-3d))) ;consistent
  
  (define (move-index-withmat from-level to-level lst)
    (cond ((= from-level to-level) lst)
          ((< from-level to-level) (switch-index-withmat to-level (move-index-withmat from-level (- to-level 1) lst)))
          ((> from-level to-level) (switch-index-withmat (+ to-level 1) (move-index-withmat from-level (+ to-level 1) lst)))))
  (define (move-index-mat from-level to-level mat)
    (cond ((= from-level to-level) mat)
          ((< from-level to-level) (switch-index-mat to-level (move-index-mat from-level (- to-level 1) mat)))
          ((> from-level to-level) (switch-index-mat (+ to-level 1) (move-index-mat from-level (+ to-level 1) mat)))))
  ;(move-index-withmat 1 3 '(a b c d)) ;'(a c d b)
  ;(move-index-withmat 3 1 '(a b c d)) ;'(a d b c)
  ;(switch-index-mat 2 (switch-index-mat 1 mat-3d))
  ;(move-index-mat 0 2 mat-3d) ;consistent
  ;(switch-index-mat 1 (switch-index-mat 2 mat-3d))
  ;(move-index-mat 2 0 mat-3d) ;consistent
  
  ;;;
  
  ;For the tensor defined here, the degree of freedom belong to every indices need not be the same.
  (define (tag x) (attach-tag 'tensor x))
  ;In "make-tensor", the index-lst doesn't care about the Einstein Summation at all.
  ;However, it works if the index-lst includes the information of the upper/lower indices.
  ;The convenience in riemannian.rkt is "let ([index-lst (list '(_ a) '(^ b) '(_ c))])".
  ;
  ;Notice that for "x_ab", "a" describes the other chain while "b" describes the inner chain.
  ;So it is (transpose x_ab) = '((_ _ _)
  ; (_ _ _)
  ; (_ _ _)) in Racket's list notation system.
  (define (make-tensor index-lst contents-matrix)
    (cons index-lst (map-n (length index-lst) make-scalar contents-matrix)))
  (put 'make-tensor 'tensor (lambda (i m) (tag (make-tensor i m))))
  
  (define (get-index tnsr) (car tnsr))
  (define (get-matrix tnsr) (cdr tnsr))
  (put 'get-index '(tensor) get-index)
  (put 'get-matrix '(tensor) get-matrix)
  
  (define (get-matrix-without-tag tnsr)
    (map-n (length (get-index tnsr)) contents (get-matrix tnsr)))
  (put 'get-matrix-without-tag '(tensor) get-matrix-without-tag)
  
  ;In "add-tensor", no matter whether the indices of x and y match or not, it follows the index of x.
  (define (add-tensor x y)
    (if (not (= (length (get-index x)) (length (get-index y))))
        (error "Tensor dimensions don't match -- ADD-TENSOR" x y)
        (cons (get-index x) (map-n (length (get-index x)) add (get-matrix x) (get-matrix y)))))
  (define (mul-tensor-to-scalar tnsr sclr)
    (cons (get-index tnsr)
          (map-n (length (get-index tnsr))
                 (lambda (t) (mul t (make-scalar sclr)))
                 (get-matrix tnsr))))
  (define (mul-tensor-to-tensor tnsr1 tnsr2)
    (cons (append (get-index tnsr1) (get-index tnsr2))
          (map-n (length (get-index tnsr1))
                 (lambda (t) (get-matrix (contents (mul t (tag tnsr2)))))
                 (get-matrix tnsr1))))
  (put 'add '(tensor tensor) (lambda (x y) (tag (add-tensor x y))))
  (put 'mul '(tensor scalar) (lambda (x y) (tag (mul-tensor-to-scalar x y))))
  (put 'mul '(scalar tensor) (lambda (x y) (tag (mul-tensor-to-scalar y x)))) ;We assume commutativity of scalars in here.
  (put 'mul '(tensor tensor) (lambda (x y) (tag (mul-tensor-to-tensor x y))))
  
  (define (simplify-generic-tensor x) (cons (get-index x) (map-n (length (get-index x)) simplify-generic (get-matrix x))))
  (put 'simplify-generic '(tensor) (lambda (x) (tag (simplify-generic-tensor x))))
  
  (define (partial-deriv-tensor-over-scalar fx x)
    (cons (get-index fx)
          (map-n (length (get-index fx))
                 (lambda (f) (partial-deriv f (make-scalar x)))
                 (get-matrix fx))))
  (define (partial-deriv-scalar-over-tensor fx x)
    (cons (get-index x)
          (map-n (length (get-index x))
                 (lambda (x) (partial-deriv (make-scalar fx) x))
                 (get-matrix x))))
  (define (partial-deriv-tensor-over-tensor fx x)
    (cons (append (get-index fx) (get-index x))
          (map-n (length (get-index fx))
                 (lambda (f) (get-matrix (contents (partial-deriv f (tag x)))))
                 (get-matrix fx))))
  (put 'partial-deriv '(tensor scalar) (lambda (fx x) (tag (partial-deriv-tensor-over-scalar fx x))))
  (put 'partial-deriv '(scalar tensor) (lambda (fx x) (tag (partial-deriv-scalar-over-tensor fx x))))
  (put 'partial-deriv '(tensor tensor) (lambda (fx x) (tag (partial-deriv-tensor-over-tensor fx x))))
  
  (define (change-index aim-index-lst tnsr) (cons aim-index-lst (get-matrix tnsr)))
  ;For "switch-index", it seems work when two of the indices are identical (I may need a stronger argument for that).
  ;However, if "X_abc != X_acb", then "X_abb" just chooses one possibility to show, which doesn't matter if we
  ;finally take the trace for Einstein Summation.
  (define (switch-index aim-index-lst x)
    (define (switch-index-iter aim-index aim-index-lst orignal-index-lst contents-matrix)
      (if (> aim-index (- (length orignal-index-lst) 1))
          (cons aim-index-lst contents-matrix)
          (let ([original-index (index (list-ref aim-index-lst aim-index) orignal-index-lst)])
            (if (> original-index aim-index)
                (switch-index-iter (+ aim-index 1)
                                   aim-index-lst
                                   (move-index-withmat original-index aim-index orignal-index-lst)
                                   (move-index-mat original-index aim-index contents-matrix))
                (switch-index-iter (+ aim-index 1) aim-index-lst orignal-index-lst contents-matrix)))))
    (switch-index-iter 0 aim-index-lst (get-index x) (get-matrix x)))
  (put 'change-index '(expression tensor)
       (lambda (aim-index-lst x) (tag (change-index aim-index-lst x))))
  (put 'switch-index '(expression tensor)
       (lambda (aim-index-lst x) (tag (switch-index aim-index-lst x))))
  )

(install-tensor-package)
(define (make-tensor index-lst contents-matrix)
  ((get 'make-tensor 'tensor) index-lst contents-matrix))

(define (get-index x) (apply-generic 'get-index x))
(define (get-matrix x) (apply-generic 'get-matrix x))
(define (get-matrix-without-tag x) (apply-generic 'get-matrix-without-tag x))

(define (change-index aim-index-lst tnsr) (apply-generic 'change-index aim-index-lst tnsr))
(define (switch-index aim-index-lst tnsr) (apply-generic 'switch-index aim-index-lst tnsr))

(define (scalar-mul k x) (mul (make-scalar k) x))

;(define ts (make-tensor (list 'a 'b) (list (list '(+ c d) 2) (list 3 4))))
;ts
;(get-matrix-without-tag ts) ;'(((+ c d) 2) (3 4))
;(add ts ts) ;'(tensor (a b) ((scalar + (+ c d) (+ c d)) (scalar . 4)) ((scalar . 6) (scalar . 8)))
;(define ts (make-tensor (list 'a 'b) (list (list 1 2) (list 3 4))))
;(switch-index '(a b) ts)
;(switch-index '(b a) ts)
;(define tss (make-tensor '(a b c) (list (list (list 1 2) (list 3 4)) (list (list 5 6) (list 7 8)))))
;(add tss tss) ;work
;(add ts tss) ; Tensor dimensions don't match
;(switch-index '(a b c) tss)
;(switch-index '(b a c) tss)
;(switch-index '(a c b) tss)
;(switch-index '(b c a) tss)
;(switch-index '(c a b) tss)
;(change-index '(c b a) tss)
;(switch-index '(c b a) tss) ;'(tensor (c b a) (((scalar . 1) (scalar . 5)) ((scalar . 3) (scalar . 7))) (((scalar . 2) (scalar . 6)) ((scalar . 4) (scalar . 8))))
;(define xi (make-tensor (list 'd) (list 'x 'y)))
;(partial-deriv tss xi)

;(define tsss (make-tensor '(a a b) (list (list (list 1 2) (list 3 4)) (list (list 5 6) (list 7 8)))))
;(switch-index '(b a a) tsss)

;(define x (make-scalar 'x))
;(define ts (make-tensor (list 'a) (list '(+ x y z (* -1 x) x) '(* 2 w x))))
;(simplify-generic ts) ;'(tensor (a) (scalar + y x z) (scalar * 2 w x))
;(mul ts x) ;'(tensor (a) (scalar * (+ x y z) x) (scalar * (* 2 w x) x))
;(mul x ts) ;'(tensor (a) (scalar * (+ x y z) x) (scalar * (* 2 w x) x))
;(scalar-mul 'x ts)
;(partial-deriv ts x) ;'(tensor (a) (scalar . 1) (scalar * 2 w))
;(define yi (make-tensor (list 'a) (list 'x 'y 'z)))
;(define h (make-scalar '(* x y)))
;(partial-deriv h yi) ;'(tensor (a) (scalar . y) (scalar . x) (scalar . 0))
;(define gj (make-tensor (list 'b) (list '(+ (* y z) z) '(* x y))))
;(partial-deriv gj yi) ;'(tensor (b a) ((scalar . 0) (scalar . z) (scalar + 1 y)) ((scalar . y) (scalar . x) (scalar . 0)))
;(mul gj yi) ;correct

;(define ts (make-tensor (list '(_ a) '(^ b)) (list (list 1 2) (list 3 4))))
;(switch-index '((_ a) (^ b)) ts); works
;(switch-index '((^ b) (_ a)) ts); works
;(switch-index '((^ a) (_ b)) ts); ERROR
