#lang racket

(require 2htdp/image
         2htdp/universe
         "mechanical-objects.rkt")

;;;

(define scene-background (rectangle 600 480 "solid" "orange"))

(define (show-pendulum p)
  (add-line (circle (p 'mass) "solid" "black") (- (p 'mass) (p 'deltaX)) (- (p 'mass) (p 'deltaY)) (p 'mass) (p 'mass) "black"))

(define (show-pendulum-in-scene p)
  (underlay/xy scene-background (- (p 'pivotX) (max (- (p 'mass) (p 'deltaX)) 0)) (p 'pivotY) (show-pendulum p)))

(define (shoe-multi-pendulum-in-scene p-lst)
  (if (null? p-lst)
      scene-background
      (let ([p (car p-lst)])
        (underlay/xy (shoe-multi-pendulum-in-scene (cdr p-lst)) (- (p 'pivotX) (max (- (p 'mass) (p 'deltaX)) 0)) (p 'pivotY) (show-pendulum p)))))

(define pendulum1 (make-pendulum 20 250 300 50 -0.3))
(define pendulum2 (make-pendulum 30 150 300 100 0.3))
;(show-pendulum-in-scene pendulum1)
(shoe-multi-pendulum-in-scene (list pendulum1 pendulum2))
