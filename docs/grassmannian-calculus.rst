The Schemannian Reference
=========================

Grassmannian Calculus
---------------------

"Schemannian" can do some easy Grassmannian calculus. To use that, you want to first include the relavent file.

.. code:: scheme

    (require "grassmannian-calculus.rkt")

In the current design, Grassmannian numbers are made by ``make-grassmannian``; however, they add and multiple normal numbers by normal expressions (i.e., it doesn't cover the normal numbers by further tag system).

.. code:: scheme

    (make-grassmannian x) → grassmannian?
        x : expression?

Current supported functions include

.. code:: scheme

    (simplify-grassmannian exp) → grassmannian?
        exp : grassmannian?

    (grassmannian-integrate exp var) → expression?
        exp : expression?
        var : grassmannian?

    (grassmannian-deriv exp var) → expression?
        exp : expression?
        var : grassmannian?

in which the ``exp`` is basically some superfield, or say, normal expressions with some elements in it are grassmannian numbers.

For example, here is a piece of code about a two-dimensional superfield

.. code:: scheme

    (require "grassmannian-calculus.rkt")

    (define theta1 (make-grassmannian 'theta1))
    (define theta2 (make-grassmannian 'theta2))

    (define superfield (make-sum (list 'a
                                       (make-product (list theta1 'b1))
                                       (make-product (list theta2 'b2))
                                       (make-product (list theta1 theta2 'c)))))

    (grassmannian-integrate superfield theta1)



