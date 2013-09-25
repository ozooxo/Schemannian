The Schemannian Reference
=========================

Expressions
-----------

Representation
~~~~~~~~~~~~~~

Following the Lisp family rule, "Schemannian" uses prefix notations for a representation of the symbolic expressions. Every value in a list can be either a number or a symbol. The current supported operations (which are noted as symbols) includes ``'=``, ``'+``, ``'*``, ``'**`` (exponential function), ``'log``, ``'sin``, and ``'cos``. To support differential equation related topics, there are two special tags includes ``'function`` and ``'deriv``.

For example, Newton's law of universal gravitation :math:`F = (G m1 m2)/r^2` can be expressed as

.. code:: scheme

    '(= F (* G m1 m2 (** r -2)))

One of the trigonometric identities :math:`sin(x+y) = sin(x) cos(y) + cos(x) sin(y)` can be expressed as

.. code:: scheme

    '(= (sin (+ x y)) (+ (* (sin x) (cos y)) (* (cos x) (sin y))))

And the Lagrangian of a simple pendulum can be expressed as

.. code:: scheme

    '(+ (* -1 g m1 (+ pivotY1 (* -1 l1 (cos (function theta1 t)))))
        (* 0.5 m1 (** l1 2) (** (deriv (function theta1 t) t) 2)))

Constructing Functions
~~~~~~~~~~~~~~~~~~~~~~

In addition, "Schemannian" supports several constructing functions. By using those functions, the functions can be independent of the detail of the representation we are chosen. Those functions can also do some preliminary simplification of the expressions. To use those functions, you need to first import the fundamental package.

.. code:: scheme

    (require "fundamental.rkt")

A incomplete list of the constructing functions are shown as below.

.. code:: scheme

    (get-op exp) → symbol?
        exp : expression?

    (get-arg-lst exp) → list?
        exp : expression?

    (get-arg exp) → symbol?
        exp : expression?

    (make-function f x) → function?
        f : expression?
        x : variable?

    (make-deriv f x) → deriv?
        f : expression?
        x : variable?

    (make-sum args) → expression?
        args : list?

    (make-product args) → expression?
        args : list?

    (make-exponentiation x n) → expression?
        x : expression?
        n : expression?

    (make-abs x) → expression?
    (make-log x) → expression?
    (make-sin x) → expression?
    (make-cos x) → expression?
        x : expression?
