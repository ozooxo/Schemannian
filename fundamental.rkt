#lang racket

(provide (all-defined-out))

;;;

(define (variable? x) (symbol? x))
(define (same-variable? v1 v2)
  (and (variable? v1) (variable? v2) (eq? v1 v2)))

(define (=number? exp num)
  (and (number? exp) (= exp num)))

(define (get-op exp) (car exp))
(define (get-arg-lst exp) (cdr exp))
(define (get-arg exp) (cadr exp))

;;;

;It is not the same as the Racket "reverse", as it has two arguments.
(define (list-reverse torev-seq done-seq)
  (if (eq? torev-seq '())
      done-seq
      (list-reverse (cdr torev-seq) (cons (car torev-seq) done-seq))))

;To be consistent with "list-ref" in Racket, The first element has index 0.
(define (list-delete lst pos) 
  (cond ((null? lst) (error "Index out of range"))
        ((= 0 pos) (cdr lst))
        (else (cons (car lst) (list-delete (cdr lst) (- pos 1))))))

;(list-delete '(a b c d) 2) ;'(a b d)
;(list-delete '(a b c d) 5) ;Index out of range

;It works exactly the same as the function "take" while (require racket/list).
(define (list-take lst pos)
  (define (list-flip new-lst old-lst count)
    (cond ((= 0 count) new-lst)
          ((null? old-lst) (error "Position doesn't exist in list" pos lst))
          (else (list-flip (cons (car old-lst) new-lst) (cdr old-lst) (- count 1)))))
  (reverse (list-flip '() lst pos)))

;(list-take '(1 2 3 4) 3) ;'(1 2 3)
;(list-take '(1 2 3 4) 6) ;error

(define (list-remove ele lst)
  (define (list-flip new-lst old-lst)
    (cond ((null? old-lst) false)
          ((eq? ele (car old-lst)) (list-reverse new-lst (cdr old-lst)))
          (else (list-flip (cons (car old-lst) new-lst) (cdr old-lst)))))
  (list-flip '() lst))

;(list-remove 2 '(1 2 3 4)) ;'(1 3 4)
;(list-remove 5 '(1 2 3 4)) ;#f

(define (members v-lst lst)
  (define (members-iter v-lst lst)
    (if (null? v-lst)
        true
        (if (member (car v-lst) lst)
            (members-iter (cdr v-lst) lst)
            false)))
  (members-iter v-lst lst))

;(members '(1 2 3) '(2 3 1 4 5)) ;#t
;(members '(1 2 3) '(2 3 4 5 6)) ;#f

(define (removes v-lst lst)
  (define (removes-iter v-lst lst)
    (if (null? v-lst)
        lst
        (removes-iter (cdr v-lst) (remove (car v-lst) lst))))
  (removes-iter v-lst lst))

;(removes '(1 3 5) '(3 4 5 1 2)) ;'(4 2)

(define (index element lst) ;The first element has index 0
  (define (index-iter element lst passed-index)
    (cond ((null? lst) false) ;(error "Not find in list -- INDEX" element lst))
          ((equal? (car lst) element) passed-index)
          (else (index-iter element (cdr lst) (+ passed-index 1)))))
  (index-iter element lst 0))

;(index 5 (list 1 3 5 7)) ;2
;(index 0 (list 1 3 5 7)) ;#f

;(index '(x y) '(w z (x y) 1 2)) ;2 ;It also works for complicated case.

(define (index-in element nested-lst)
  (define (index-in-iter nested-lst passed-index)
    (cond ((null? nested-lst) false)
          ((not (eq? (index element (car nested-lst)) false)) passed-index)
          (else (index-in-iter (cdr nested-lst) (+ passed-index 1)))))
  (index-in-iter nested-lst 0))

;(index-in 'c '((a b) (c d) (e f))) ;1
;(index-in 'g '((a b) (c d) (e f))) ;#f

;(define (map-n dim prop lst)
;  (if (= dim 1)
;      (map prop lst)
;      (map (lambda (lst) (map-n (- dim 1) prop lst)) lst)))
;In the above form, "prop" can only have one argument.
;In the bottom form, arbitrary number of arguments are okay.
(define (map-n dim prop . lst)
  (if (= dim 1)
      (apply map (cons prop lst))
      (apply map (cons (lambda lst (apply map-n (append (list (- dim 1) prop) lst))) lst))))

;(define fx (lambda (x) (+ 2 x)))
;(map-n 1 fx (list 1 2)) ;'(3 4)
;(map-n 1 + (list 3 4) (list 1 2)) ;'(4 6)
;(map-n 2 fx (list (list 1 2) (list 3 4))) ;'((3 4) (5 6))
;(map-n 2 + (list (list 1 2) (list 3 4)) (list (list 5 6) (list 7 8))) ;'((6 8) (10 12))

(define (accumulate op initial sequence)
  (if (null? sequence)
      initial
      (op (car sequence)
          (accumulate op initial (cdr sequence)))))

(define (accumulate-n op init seqs)
  (if (null? (car seqs))
      '()
      (cons (accumulate op init (accumulate (lambda (x y) (cons (car x) y)) '() seqs))
            (accumulate-n op init (accumulate (lambda (x y) (cons (cdr x) y)) '() seqs)))))

(define (gather-num op-for-num unit-num sequence)
  (define (gather-num-recur sequence)
    (if (null? sequence)
        (list unit-num)
        (let ([sequence-after (gather-num-recur (cdr sequence))])
          (if (number? (car sequence))
              (cons (op-for-num (car sequence) (car sequence-after)) (cdr sequence-after))
              (cons (car sequence-after) (cons (car sequence) (cdr sequence-after)))))))
  (gather-num-recur sequence))

;(gather-num + 0 (list 1 'a 2 'b 3 'c 'd)) ;'(6 a b c d)

;;;

;A function can have only one argument. It is fine for equation of motion
;(which has only a "t"), but not enough for other proposes.
(define (make-function f x) (list 'function f x))
(define (function? exp) (and (pair? exp) (eq? (get-op exp) 'function)))
(define (get-function-arg exp) (caddr exp))

(define (make-deriv exp var) (list 'deriv exp var))

;;;

(define (merge-same-op is-op? args)
  (define (merge-same-op-recur args)
    (cond ((null? args) '())
          ((is-op? (car args)) (append (get-arg-lst (car args)) (merge-same-op-recur (cdr args))))
          (else (cons (car args) (merge-same-op-recur (cdr args))))))
  (merge-same-op-recur args))

(define (make-op op-func op-symb unit-num args)
  (let ([gathered-seq (gather-num op-func unit-num args)])
    (cond ((null? (cdr gathered-seq)) (car gathered-seq))
          ((and (= (car gathered-seq) unit-num) (null? (cddr gathered-seq)))
           (cadr gathered-seq))
          ((= (car gathered-seq) unit-num) (cons op-symb (cdr gathered-seq)))
          (else (cons op-symb gathered-seq)))))

(define (sum? x) (and (pair? x) (eq? (get-op x) '+)))
(define (make-sum args) (make-op + '+ 0 (merge-same-op sum? args)))

;(merge-same-op sum? '(1 2 (+ 3 4) (* 5 6))) ;'(1 2 3 4 (* 5 6))
;(make-sum '(a b (+ 1 c) 3 (* 2 b))) ;'(+ 4 a b c (* 2 b))

;(make-sum '(2 3 (grassmannian . x) x (grassmannian . z) 4)) ;It also works with elements which has tags.

(define (product? x) (and (pair? x) (eq? (get-op x) '*)))
(define (make-product args)
  (let ([result (make-op * '* 1 (merge-same-op product? args))])
    (cond ((number? result) result)
          ((symbol? result) result)
          ((eq? (cadr result) '0) 0)
          (else result))))

;(make-product '(1 a (* 2 f e) b 4 c (+ 4 d))) ;'(* 8 a f e b c (+ 4 d))
;(make-product (list '(+ a b c))) ;'(+ a b c)

(define (exponentiation? x) (and (pair? x) (eq? (car x) '**)))
(define (base p) (cadr p))
(define (exponent p) (caddr p))
(define (make-exponentiation x n)
  (cond ((=number? n 0) 1)
        ((=number? n 1) x)
        ((and (number? x) (number? n)) (expt x n))
        (else (list '** x n))))

(define (make-abs x) (if (number? x) (abs x) (list 'abs x)))
(define (make-log x) (if (number? x) (log x) (list 'log x)))
(define (make-sin x) (if (number? x) (sin x) (list 'sin x)))
(define (make-cos x) (if (number? x) (cos x) (list 'cos x)))

;(make-abs -3) ;3
;(make-abs '(+ a b)) ;'(abs (+ a b))

(define (sign n)
  (if (number? n)
      (if (even? n) 1 -1)
      (make-exponentiation -1 n)))

;The simplification of elementary arithmetic is really hard to write ...
;Need to think carefully for a more organized way to do that ...

;;;

(define (map-derivation proc op arg-lst)
  (define (map-derivation-iter prop arg-lst passed-arg-lst)
    (if (null? arg-lst)
        '()
        (cons 
         (list-reverse passed-arg-lst (cons (prop (car arg-lst)) (cdr arg-lst)))
         (map-derivation-iter prop (cdr arg-lst) (cons (car arg-lst) passed-arg-lst)))))
  (make-sum (map op
                 (map-derivation-iter proc arg-lst '()))))

;(map-derivation (lambda (x) (+ x 2)) (lambda (x) (cons '~ x)) '(1 2 3)) ;'(+ (~ 3 2 3) (~ 1 4 3) (~ 1 2 5))
