The Schemannian Reference
=========================

Equation Solving
----------------

"Schemannian" can currently a solve equation symbolically, if in which the unknown appears only once.

.. code:: scheme

    (solve eqn var) → expression?
        eqn : expression?
        var : expression?

In function ``solve``, the argument ``eqn`` is a expression with the outest level operator ``'=``. For example, ``'(= x 3)`` describes a equation, while ``'(+ x 3)`` does not.

Here is an example.

.. code:: scheme

    (require "solve.rkt")
    (solve '(= (** x z) y) 'z)

gives you 

.. code:: scheme

    '(= z (* (log y) (** (log x) -1)))
