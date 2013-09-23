Simplification of Expressions
-----------------------------

"Schemannian" supports a function called ``simplify``, which have some ability on the simplification of algebraic expressions, such as combining like terms by distributive property of multiplication, using Pythagorean trigonometric identity to simplify ``(+ (** (sin x) 2) (** (cos x) 2))`` to ``1``, removing common factors for "fractions" whose numerator and denominator are both functions, etc.

Here is the function ``simplify``.

.. code:: scheme

    (simplify exp) → expression?
        exp : expression? 

To use it, for example, if we do

.. code:: scheme

    (require "simplify.rkt")
    (simplify '(+ x y 1 (* 5 a) (* 6 a (** (cos (* z w)) 2)) (* 6 (** (sin (* z w)) 2) a)))

it will give us ``'(+ 1 y x (* 11 a))``. There are several more relastic examples while using other functions (e.g., while calculating the Euler-Lagrangian equation, or the Ricci scalar).
