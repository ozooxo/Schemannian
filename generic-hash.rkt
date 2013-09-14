#lang racket

(require (only-in "fundamental.rkt" index list-take))

(provide (all-defined-out))

(define (attach-tag type-tag contents) (cons type-tag contents))
(define (type-tag datum)
  (cond ((pair? datum) (car datum))
        (else (error "Bad tagged datum -- TYPE-TAG" datum))))
(define (contents datum)
  (cond ((pair? datum) (cdr datum))
        (else (error "Bad tagged datum -- CONTENTS" datum))))

(define *table* (make-hash))
(define (get op type) (hash-ref *table* (list op type) false))
(define (put op type val) (hash-set! *table* (list op type) val))

(define (apply-generic op . args)
  (define (get-untag-procs op type-tags)
    (map
     (lambda (i) (get op (append (list-take type-tags i) (cons 'expression (list-tail type-tags (+ i 1))))))
     ;If something do not have a tag, we tag it as 'expression.
     ;Currently, only one 'expression is allowed for a list of arguments.
     (range (length type-tags))))
  (let ([type-tags (map type-tag args)])
    (let ([proc (get op type-tags)])
      (if proc
          (apply proc (map contents args))
          (let ([proc-lst (get-untag-procs op type-tags)])
            (define (search-proc-lst lst)
              (cond ((null? lst) (error "No method for these types -- APPLY-GENERIC" (list op type-tags)))
                    ((car lst) (let ([ind (index (car lst) proc-lst)])
                                (apply (car lst) (append (map contents (list-take args ind))
                                                         (cons (list-ref args ind)
                                                               (map contents (list-tail args (+ ind 1))))))))
                    (else (search-proc-lst (cdr lst)))))
            (search-proc-lst proc-lst))))))
