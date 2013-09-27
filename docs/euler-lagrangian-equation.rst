The Schemannian Reference
=========================

Euler-Lagrangian Equation
-------------------------

Symbolic Calculations
~~~~~~~~~~~~~~~~~~~~~

"Schemannian" can do some symbolic and numerical calculations of the Euler-Lagrangian Equation in classical mechanics. The key functions are ``lagrangian`` and ``euler-lagrangian-equation``, which are defined in ``lagrangian.rkt``.

.. code:: scheme

    (lagrangian object-lst) → expression?
        object-lst : list?

    (euler-lagrangian-equation L coordi-lst coordi-dot-lst time) → expression?
        L : expression?
        coordi-lst : list?
        coordi-dot-lst : list?
        time : variable?

In function ``lagrangian``, ``object-lst`` is a list of closures of mechanical objects with dispatching ``kinetic-energy`` and ``potential-energy``. To make those two functions useful, we defined an example closure ``make-pendulum`` in ``mechanical-objects.rkt``.

.. code:: scheme

    (make-pendulum mass string-length pivotX pivotY amplitude) → mechanical-object?
        mass : expression?
        string-length : expression?
        pivotX : expression?
        pivotY : expression?
        amplitude : expression?

For example, the following code can give you the equation of motion of a symbolic simple pendulum,

.. code:: scheme

    (require "fundamental.rkt"
             "calculus.rkt"
             "lagrangian.rkt"
             "mechanical-objects.rkt"
             "solve.rkt")

    (define pendulum1 (make-pendulum 'm1 'l1 'pivotX1 'pivotY1 (make-function 'theta1 't)))

    (define L1 (lagrangian (list pendulum1)))
    (define euler-lagrangian-L1 (euler-lagrangian-equation L1
                                                           (list (make-function 'theta1 't))
                                                           (list (deriv (make-function 'theta1 't) 't))
                                                           't))

    euler-lagrangian-L1 

which equals

.. code:: scheme

    '((= (+ (* m1 (** l1 2) (deriv (deriv (function theta1 t) t) t)) (* 9.8 m1 l1 (sin (function theta1 t)))) 0))

And this will give you the equation of motion of the double pendulum,

.. code:: scheme

    (define pendulum1 (make-pendulum 'm1 'l1 'pivotX1 'pivotY1 (make-function 'theta1 't)))
    (define pendulum2 (make-pendulum 'm2 'l2 (pendulum1 'X) (pendulum1 'Y) (make-function 'theta2 't)))

    (define L (lagrangian (list pendulum1 pendulum2)))
    (define euler-lagrangian-L
      (euler-lagrangian-equation L
                                 (list (make-function 'theta1 't) (make-function 'theta2 't))
                                 (list (deriv (make-function 'theta1 't) 't)
                                       (deriv (make-function 'theta2 't) 't))
                                 't))

    euler-lagrangian-L

which are two really complicated equations.

These two examples can be find in `symbolic-simple-pendulum.rkt`_ and `symbolic-double-pendulum.rkt`_.

.. _symbolic-simple-pendulum.rkt: https://github.com/ozooxo/Schemannian/blob/master/examples/symbolic-simple-pendulum.rkt
.. _symbolic-double-pendulum.rkt: https://github.com/ozooxo/Schemannian/blob/master/examples/symbolic-double-pendulum.rkt

Virtualization of the Motions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

"Schemannian" includes an interface which can help you virtualize the motion of the mechanical objects. In order to use this interface, you need to define how your mechanical object looks like in the screen. ``show-mechanical-objects.rkt`` gives an example for single and double pendulum. Roughly speeking, the following functions are being defined.

.. code:: scheme

    (show-pendulum-in-scene p) → pict?
        p : mechanical-object?

    (shoe-multi-pendulum-in-scene p-lst) → pict?
        p : list?

    (create-pendulum-moving time) → procedure?
        time : number?

``p-lst`` is a list of mechanical objects (pendulums). ``create-pendulum-moving`` basically returns a lambda expression which is used together with ``animate`` in the Racket package ``2htdp/universe``. When those things are successfully defined, the following piece of code

.. code:: scheme

    (require 2htdp/universe
             "fundamental.rkt"
             "calculus.rkt"
             "mechanical-objects.rkt"
             "lagrangian.rkt"
             "solve.rkt"
             "numerical-differential-equation.rkt"
             "show-mechanical-objects.rkt")

    (define pendulum1 (make-pendulum 20 250 300 50 (make-function 'theta1 't)))

    (define L1 (lagrangian (list pendulum1)))
    (define euler-lagrangian-L1 
      (euler-lagrangian-equation L1 
                                 (list (make-function 'theta1 't)) 
                                 (list (deriv (make-function 'theta1 't) 't)) 
                                 't))

    (define euler-lagrangian-solution 
      (numerical-solve 
       (solve (car euler-lagrangian-L1) '(deriv (deriv (function theta1 t) t) t)) 
       '((function theta1 t) (deriv (function theta1 t) t))
       '(0.3 0) 
       0
       0.1))

    (define solution-next (stream-next euler-lagrangian-solution))
    (animate (lambda (time) ((create-pendulum-moving time) pendulum1 solution-next)))

can generate the following cartoon.

.. image:: https://raw.github.com/ozooxo/Schemannian/master/examples/numerical-visualization-simple-pendulum.gif
   :height: 528 px
   :width: 640 px
   :scale: 100 %
   :alt: alternate text
   :align: center

This example can be find in `numerical-visualization-simple-pendulum.rkt`_.

.. _numerical-visualization-simple-pendulum.rkt: https://github.com/ozooxo/Schemannian/blob/master/examples/numerical-visualization-simple-pendulum.rkt

People may also expect "Schemannian" to virtualize some more fancy mechanical process, such as the double pendulum. This is still quite hard until now, although it is easy to draw two pendulums together in the screen (we already realized that by the function ``shoe-multi-pendulum-in-scene`` in ``show-mechanical-objects.rkt``).

The reason is that double pendulum gives a quite complicated equation of motion, in which `d^2 theta1 / d t^2` and `d^2 theta2 / d t^2` are entangled to each other. So "Schemannian" need to know first how to solve a set of simultaneous equations in general. In addition, it also need to know how to numerically solve simultaneous differential equations. It currently doesn't have both support functions.
