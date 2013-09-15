#lang racket

(require "fundamental.rkt"
         2htdp/image
         2htdp/universe)

;;;

(define scene-background (rectangle 600 480 "solid" "orange"))

(define (show-pendulum p)
  (add-line (circle (p 'mass) "solid" "black") (- (p 'mass) (p 'deltaX)) (- (p 'mass) (p 'deltaY)) (p 'mass) (p 'mass) "black"))

(define (show-pendulum-in-scene p)
  (underlay/xy scene-background
               (- (p 'pivotX) (max (- (p 'mass) (p 'deltaX)) 0)) 
               (- (p 'pivotY) (max (- (p 'mass) (p 'deltaY)) 0)) 
               (show-pendulum p)))

(define (create-pendulum-moving time)
  (lambda (p solution-next)
    (show-pendulum-in-scene (make-pendulum (p 'mass) (p 'length) (p 'pivotX) (p 'pivotY) (cadr (solution-next))))))

(define (shoe-multi-pendulum-in-scene p-lst)
  (if (null? p-lst)
      scene-background
      (let ([p (car p-lst)])
        (underlay/xy (shoe-multi-pendulum-in-scene (cdr p-lst))
                     (- (p 'pivotX) (max (- (p 'mass) (p 'deltaX)) 0))
                     (- (p 'pivotY) (max (- (p 'mass) (p 'deltaY)) 0))
                     (show-pendulum p)))))

;;;

(require "calculus.rkt"
         "mechanical-objects.rkt"
         "lagrangian.rkt"
         "solve.rkt"
         "numerical-differential-equation.rkt")

;(define p1 (make-pendulum 20 250 300 50 -0.3))
;(define p2 (make-pendulum 30 150 300 100 0.3))
;(show-pendulum-in-scene p1)
;(shoe-multi-pendulum-in-scene (list p1 p2))

(define pendulum1 (make-pendulum 20 250 300 50 (make-function 'theta1 't)))

(define L1 (lagrangian (list pendulum1)))
(define euler-lagrangian-L1 (euler-lagrangian-equation L1 (list (make-function 'theta1 't)) (list (deriv (make-function 'theta1 't) 't)) 't))
;euler-lagrangian-L1 
;(solve (car euler-lagrangian-L1) '(deriv (deriv (function theta1 t) t) t))

(define euler-lagrangian-solution (numerical-solve (solve (car euler-lagrangian-L1) '(deriv (deriv (function theta1 t) t) t)) 
                                     '((function theta1 t) (deriv (function theta1 t) t))
                                     '(0.3 0) 
                                     0
                                     0.1)) ;how quickly the times goes can be adjusted.
;(stream-take 10 euler-lagrangian-solution)

;(stream-first euler-lagrangian-solution)
;(stream-first euler-lagrangian-solution)

;(sequence-generate euler-lagrangian-solution)
;(sequence-generate* euler-lagrangian-solution)

;(define next (stream-next euler-lagrangian-solution))

;(define next
;  (generator ()
;             (let loop ([x euler-lagrangian-solution])
;               (if (null? x)
;                   0
;                   (begin
;                     (yield (stream-first x))
;                     (loop (stream-rest x)))))))

;(next)
;(next)
;(next-solution)

(define solution-next (stream-next euler-lagrangian-solution))
(animate (lambda (time) ((create-pendulum-moving time) pendulum1 solution-next)))

;(define (create-pendulum-moving time)
;  (lambda (p solution)
;    (show-pendulum-in-scene (make-pendulum (p 'mass) (p 'length) (p 'pivotX) (p 'pivotY) (cadr (list-ref solution time))))))

;((create-pendulum-moving 5) pendulum1 (stream-take 10 euler-lagrangian-solution))

;(animate (lambda (time) ((create-pendulum-moving time) pendulum1 (stream-take 100 euler-lagrangian-solution))))