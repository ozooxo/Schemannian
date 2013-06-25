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

(define (reverse torev-seq done-seq)
  (if (eq? torev-seq '())
      done-seq
      (reverse (cdr torev-seq) (cons (car torev-seq) done-seq))))

(define (index element lst) ;The first element has index 0
  (define (index-iter element lst passed-index)
    (cond ((null? lst) (error "Not find in list -- INDEX" element lst))
          ((equal? (car lst) element) passed-index)
          (else (index-iter element (cdr lst) (+ passed-index 1)))))
  (index-iter element lst 0))

;(index 5 (list 1 3 5 7)) ;2

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

(define (make-op op-func op-symb unit-num args)
  (let ([gathered-seq (gather-num op-func unit-num args)])
    (cond ((null? (cdr gathered-seq)) (car gathered-seq))
          ((and (= (car gathered-seq) unit-num) (null? (cddr gathered-seq)))
           (cadr gathered-seq))
          ((= (car gathered-seq) unit-num) (cons op-symb (cdr gathered-seq)))
          (else (cons op-symb gathered-seq)))))

(define (sum? x) (and (pair? x) (eq? (get-op x) '+)))
(define (make-sum args) (make-op + '+ 0 args))

;(make-sum (list 1 2 4)) ;7

(define (product? x) (and (pair? x) (eq? (get-op x) '*)))
(define (make-product args)
  (let ([result (make-op * '* 1 args)])
    (cond ((number? result) result)
          ((symbol? result) result)
          ((eq? (cadr result) '0) 0)
          (else result))))

;(make-product (list 1 'a 2 'b 4 'c 'd)) ;'(* 8 a b c d)
;(make-product (list '(+ a b c))) ;'(+ a b c)

;;;

(define (map-derivation proc op arg-lst)
  (define (map-derivation-iter prop arg-lst passed-arg-lst)
    (if (null? arg-lst)
        '()
        (cons 
         (reverse passed-arg-lst (cons (prop (car arg-lst)) (cdr arg-lst)))
         (map-derivation-iter prop (cdr arg-lst) (cons (car arg-lst) passed-arg-lst)))))
  (make-sum (map op
                 (map-derivation-iter proc arg-lst '()))))

;(map-derivation (lambda (x) (+ x 2)) (lambda (x) (cons '~ x)) '(1 2 3)) ;'(+ (~ 3 2 3) (~ 1 4 3) (~ 1 2 5))
