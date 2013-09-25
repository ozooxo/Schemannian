The Schemannian Reference
=========================

Numerical Differential Equation Solving
---------------------------------------

"Schemannian" can currently numerically solve a differential equation of arbitrary order.

.. code:: scheme

    (numerical-solve eqn initial-exp-lst initial-lst num-var num-dvar) → stream?
        eqn : expression?
        initial-exp-lst : list?
        initial-lst : list?
        num-var : number?
        num-dvar : number?

In function ``numerical-solve``, the argument ``eqn`` is a expression with the outest level operator ``'=``, ``initial-exp-lst`` is a list of expressions, i.e., the unknown function (dependent variable) and its derivatives, and ``initial-lst`` is a list of numbers.

The output is a stream of pairs, with ``car`` as a stream of numbers of the independent variable, and ``cdr`` as a stream of lists with elements as the values of the unknown function and its derivatives, starts from the ``initial-lst``.

Here is an example.

.. code:: scheme

    (require "numerical-differential-equation.rkt")
    (define solution (numerical-solve '(= (deriv (deriv (function theta1 t) t) t) (* -1 (sin (function theta1 t))))
                                      '((function theta1 t) (deriv (function theta1 t) t))
                                      '(1 0)
                                      0
                                      0.1))
