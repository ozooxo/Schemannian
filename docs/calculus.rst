The Schemannian Reference
=========================

Basic Calculus
--------------

"Schemannian" can do chain rule level derivations and kindergarten level integrals. It has two functions ``deriv`` and ``integrate``.

.. code:: scheme

    (deriv exp var) → expression?
        exp : expression?
        var : expression?

    (integrate exp var) → expression?
        exp : expression?
        var : variable?

Notice that in ``deriv``, the independent variable ``var`` can not only be a variable, but also be a complicated expression (e.g., a function).

Examples of using those two functions are shown as below.

.. code:: scheme

    (require "calculus.rkt")

    (deriv '(** (+ 3 (* x 2) y) (sin x)) 'x)
    (integrate '(+ (** x 3) y 2) 'x)
