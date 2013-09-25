===========
Schemannian
===========

As a scheme/Racket based package for symbolic mathematics for physicist, "Schemannian" currently supports a realization of Euler-Lagrangian Equation is classical physics, Riemannian geometry and General Relativity calculations, and simple Grassmannian (Berezin) Calculus.

"Schemannian" is a project submitted to `Lisp In Summer Projects 2013`_.

.. _Lisp In Summer Projects 2013: http://lispinsummerprojects.org/

Test Environment
================

"Schemannian" is written and debugged using `Racket`_ v5.3.1 in a 64-bit Ubuntu 13.04 (Raring Ringtail) computer. Racket is installed by the default setting of ``sudo apt-get install racket``.

.. _Racket: http://racket-lang.org/

Highlights
==========

Tensor Operations
-----------------

You can make scalar and tensor objects by using ``(make-scalar <expression>)`` and ``(make-tensor <index-lst> <components-as-nested-lst-of-expressions>)``. ``<index-lst>`` can be any possible scheme list, form the most simplified case ``'(a b c)`` to the more Einstein notation friendly list, such as ``'((^ a) (_ b) (_ c))``. To use the above function, you need to

.. code:: scheme

    (require "tensor.rkt")

Tensor operations includes: ``add``, which can add two scalars or two tensors with the same form; ``mul``, which can multiply two scalars, one scalar and one tensor (by means of scalar multiplication), and two tensors (by means of tensor product); and ``partial-deriv``, which results higher ranked tensors.

Riemannian Geometry and General Relativity Calculations
-------------------------------------------------------

"Schemannian" is capable to calculate Riemann curvature tensor, Ricci curvature tensor, and Ricci scalar from the metric (which is treated as a rank-2 tensor). However, it currently still doesn't know how to simplify the result.

Here is an example to calculate the Ricci scalar of the Schwarzschild metric:

.. code:: scheme

    (require "tensor.rkt")
    (require "riemannian.rkt")

    (define g (make-tensor '((_ a) (_ b)) 
                           '(((+ 1 (* -1 rs (** r -1))) 0 0 0)
                             (0 (* -1 (** (+ 1 (* -1 rs (** r -1))) -1)) 0 0)
                             (0 0 (* -1 (** r 2)) 0)
                             (0 0 0 (* -1 (** r 2) (** (sin theta) 2))))))
    (define Gamma^a_bc (christoffel '((^ a) (_ b) (_ c)) g '(t r theta phi)))
    (define R^a_bcd (riemann-tensor '((^ a) (_ b) (_ c) (_ d)) Gamma^a_bc '(t r theta phi)))
    (define R_ab (ricci-curvature-tensor '((_ a) (_ b)) R^a_bcd))
    (ricci-scalar g R_ab)

Grassmannian (Berezin) Calculus
-------------------------------

"Schemannian" can do some easy Grassmannian calculus. In the current design, Grassmannian numbers are made by ``make-grassmannian``; however, they add and multiple normal numbers by normal expressions (i.e., it doesn't cover the normal numbers by further tag system). For example, you do a general two-dimensional superfield by

.. code:: scheme

    (require "grassmannian-calculus.rkt")

    (define theta1 (make-grassmannian 'theta1))
    (define theta2 (make-grassmannian 'theta2))

    (define superfield (list '+ 'a 
                                (list '* theta1 'b1)
                                (list '* theta2 'b2)
                                (list '* theta1 theta2 'c)))

Current supported functions include

.. code:: scheme

    (simplify-grassmannian (list '* 3 'x theta1 2 theta2 theta1)) ;It should give you zero
    (grassmannian-integrate superfield theta1)
    (grassmannian-deriv superfield theta1)

The Schemannian Reference
=========================

Supported Math Functions
------------------------

`Expressions`_
.. _Expressions: https://github.com/ozooxo/Schemannian/blob/master/docs/expressions.rst

`Virtualization of Expressions`_
.. _Virtualization of Expressions: https://github.com/ozooxo/Schemannian/blob/master/docs/virtualization-of-expressions.rst

`Simplification of Expressions`_
.. _Simplification of Expressions: https://github.com/ozooxo/Schemannian/blob/master/docs/simplify.rst

`Linear Algebra`_
.. _Linear Algebra: https://github.com/ozooxo/Schemannian/blob/master/docs/linear-algebra.rst

`Equation Solving`_
.. _Equation Solving: https://github.com/ozooxo/Schemannian/blob/master/docs/equation-solving.rst

`Basic Calculus`_
.. _Basic Calculus: https://github.com/ozooxo/Schemannian/blob/master/docs/calculus.rst

`Numerical Differential Equation Solving`_
.. _Numerical Differential Equation Solving: https://github.com/ozooxo/Schemannian/blob/master/docs/numerical-differential-equation.rst

`Data Virtualization`_
.. _Data Virtualization: https://github.com/ozooxo/Schemannian/blob/master/docs/data-virtualization.rst

Physics Related Functions
-------------------------

`Euler Lagrangian Equation`_
.. _Euler Lagrangian Equation: https://github.com/ozooxo/Schemannian/blob/master/docs/euler-lagrangian-equation.rst

`Riemannian Geometry and General Relativity`_
.. _Riemannian Geometry and General Relativity: https://github.com/ozooxo/Schemannian/blob/master/docs/riemannian-geometry-general-relativity.rst

Copyright and License
=====================

This program has been written by Cong-Xin Qiu. It is protected by the `"GNU Lesser General Public License"`_. 

.. _"GNU Lesser Public License": http://www.gnu.org/copyleft/lesser.html
