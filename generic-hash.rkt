#lang racket

(provide (all-defined-out))

(define (attach-tag type-tag contents) (cons type-tag contents))
(define (type-tag datum)
  (cond ((pair? datum) (car datum))
        (else (error "Bad tagged datum -- TYPE-TAG" datum))))
(define (contents datum)
  (cond ((pair? datum) (cdr datum))
        (else (error "Bad tagged datum -- CONTENTS" datum))))

(define *table* (make-hash))
(define (get op type) (hash-ref *table* (list op type)))
(define (put op type val) (hash-set! *table* (list op type) val))

(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
          (error
            "No method for these types -- APPLY-GENERIC"
            (list op type-tags))))))