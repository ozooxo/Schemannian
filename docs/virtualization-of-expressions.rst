Virtualization of Expressions
-----------------------------

"Schemannian" has a small package to virtualize expressions. By using this package, you can turn the quite confusing prefix notations to something which is quite clear and human readable. To use this package, you need to first

.. code:: scheme

    (require "show-expression.rkt")

To use that, you have the function ``show-expression``.

.. code:: scheme

    (show-expression exp) → pict?
        exp : expression? 

For example,

.. code:: scheme

    (show-expression '(= (+ (* (+ 1 (sin x) (cos x)) (** (+ 1 (sin x) (* -1 (cos x))) -1))
                            (* (+ 1 (sin x) (* -1 (cos x))) (** (+ 1 (sin x) (cos x)) -1)))
                         (* 2 (** (cos x) -1))))

will gives you

.. image:: https://raw.github.com/ozooxo/Schemannian/master/docs/virtualization-of-expressions.png
   :height: 63 px
   :width: 508 px
   :scale: 100 %
   :alt: alternate text
   :align: center


