#lang racket

(require "fundamental.rkt"
         "mechanical-objects.rkt"
         2htdp/image
         2htdp/universe)

(provide (all-defined-out))

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

;(define p1 (make-pendulum 20 250 300 50 -0.3))
;(define p2 (make-pendulum 30 150 150 100 0.3))
;(show-pendulum-in-scene p1)
;(shoe-multi-pendulum-in-scene (list p1 p2))

