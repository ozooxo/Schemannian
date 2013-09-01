#lang racket

(require slideshow/pict)
(require racket/draw)

(provide plot listplot)

;;;

(define plot-width 400)
(define plot-height 300)

(define count-axis-marker 6)
(define axis-marker-size 5)
(define x-axis-size 20)
(define y-axis-size 40)

;;;

(define (list-scale const lst) (map (lambda (y) (* const y)) lst))
(define (list-translation const lst) (map (lambda (y) (+ const y)) lst))

(define (multisection min max howmany)
  (let ([gap (/ (- max min) howmany)])
    (define (multisection-recur num)
      (if (>= (+ num (* 1.001 gap)) max)
          '()
          (cons (+ num gap) (multisection-recur (+ num gap)))))
    (multisection-recur min)))

(define (scale-point-position point-lst x-min x-max y-min y-max)
  (let ([x (car point-lst)]
        [y (cadr point-lst)])
    (list (* (/ plot-width (- x-max x-min)) (- x x-min)) (- plot-height (* (/ plot-height (- y-max y-min)) (- y y-min))))))

(define (find-axis-marker-list min max)
  (let ([const (expt 10 (order-of-magnitude (* (/ (- max min) count-axis-marker) 0.5)))])
    (list-scale const (map round (list-scale (/ 1 const) (multisection min max count-axis-marker))))))

;(find-axis-marker-list 1.23 2.42)
;(find-axis-marker-list 0.00123 0.00242)
;(find-axis-marker-list 123 242)

;;;

(define canvas (frame (blank plot-width plot-height)))

(define (x-axis x-min x-max)
  (let* ([marker-lst (find-axis-marker-list x-min x-max)]
         [marker-lst-screen (list-scale (/ plot-width (- x-max x-min)) 
                                        (list-translation (- x-min) marker-lst))])
    (define (axis-marker-recur pict marker-lst marker-lst-screen)
      (if (null? marker-lst)
          pict
          (pin-over 
           (axis-marker-recur pict (cdr marker-lst) (cdr marker-lst-screen))
           (car marker-lst-screen) 0 (vl-append (vline 2 axis-marker-size) (text (number->string (car marker-lst)))))))
    (vl-append
     ;(hline plot-width 2)
     (axis-marker-recur (blank plot-width x-axis-size) marker-lst marker-lst-screen))))

(define (y-axis y-min y-max)
  (let* ([marker-lst (find-axis-marker-list y-min y-max)]
         [marker-lst-screen (map
                             (lambda (x) (- plot-height x))
                               (list-scale (/ plot-height (- y-max y-min)) 
                                           (list-translation (- y-min) marker-lst)))])
    (define (axis-marker-recur pict marker-lst marker-lst-screen)
      (if (null? marker-lst)
          pict
          (pin-over 
           (axis-marker-recur pict (cdr marker-lst) (cdr marker-lst-screen))
           0 (car marker-lst-screen) (ht-append (hline 2 axis-marker-size) (blank 2) (text (number->string (car marker-lst)))))))
    (hb-append
     ;(vline 2 plot-height)
     (axis-marker-recur (blank y-axis-size plot-height) marker-lst marker-lst-screen))))

;;;

(define plot-marker-size 10)

(define plot-marker (rectangle plot-marker-size plot-marker-size))

(define (listplot lst x-min x-max y-min y-max)
  (define (listplot-recur pict lst)
    (if (null? lst)
        pict
        (let ([point (scale-point-position (car lst) x-min x-max y-min y-max)]
              [other-points (cdr lst)]
              [shift (/ plot-marker-size 2)])
          (pin-over (listplot-recur pict other-points) (- (car point) shift) (- (cadr point) shift) plot-marker))))
  (ht-append
   (vl-append
    (listplot-recur canvas lst)
    (x-axis x-min x-max))
   (y-axis y-min y-max)))

;(listplot '((20 30) (40 50) (100 200) (100 220)) -100 200 -100 300)

;;;

(define curve-pixel 100)

(define (plot func x-min x-max y-min y-max)
  (let ([data-lst (map (lambda (x) (list x (func x))) (multisection x-min x-max curve-pixel))])
    (listplot data-lst x-min x-max y-min y-max)))

;(plot sin 0 10 -2 2)

