===========
Schemannian
===========

As a scheme/Racket based package for symbolic mathematics for physicist, "Schemannian" currently supports a realization of Euler-Lagrangian Equation is classical physics, Riemannian geometry and General Relativity calculations, and simple Grassmannian Calculus.

"Schemannian" is a project submitted to `Lisp In Summer Projects 2013`_.

.. _Lisp In Summer Projects 2013: http://lispinsummerprojects.org/

Test Environment
================

"Schemannian" is written and debugged using a `Racket`_ v5.3.1 in a 64-bit Ubuntu 13.04 (Raring Ringtail) computer, and a v5.3.5 in a 32-bit Ubuntu 12.04 (Precise Pangolin) computer. Racket is installed by the default setting of ``sudo apt-get install racket``.

.. _Racket: http://racket-lang.org/

Highlights
==========

"Schemannian" can calculate the Lagrangian and the equation of motion (by Euler-Lagrangian equation) of a classical mechanical system. For example, this piece of code will give you the equation of motion of the double pendulum.

.. code:: scheme

    (define pendulum1
      (make-pendulum 'm1 'l1 'pivotX1 'pivotY1 (make-function 'theta1 't)))
    (define pendulum2
      (make-pendulum 'm2 'l2 (pendulum1 'X) (pendulum1 'Y) (make-function 'theta2 't)))

    (define L (lagrangian (list pendulum1 pendulum2)))
    (define euler-lagrangian-L
      (euler-lagrangian-equation L
                                 (list (make-function 'theta1 't) (make-function 'theta2 't))
                                 (list (deriv (make-function 'theta1 't) 't) 
                                       (deriv (make-function 'theta2 't) 't))
                                 't))

That is interesting, because Lagrangian formulation and Euler-Lagrangian equation are extremely important for loop calculations in quantum field theory. Those calculations are really tedious, and currently there is *NO* general propose package to do them.

"Schemannian" gives an interface to virtualize the motion of mechanical objects by Euler-Lagrangian equation.

"Schemannian" is capable to calculate typical General Relativity expressions such as Christoffel symbols, Riemann curvature tensor, Ricci curvature tensor, and Ricci scalar from the metric. For example, the following code calculate the curvature on the surface of a sphere.

.. code:: scheme

    (define g (make-tensor '((_ a) (_ b)) 
                           '(((** r 2) 0)
                             (0 (* (** r 2) (** (sin theta) 2))))))

    (define Gamma^a_bc (christoffel '((^ a) (_ b) (_ c)) g '(theta phi)))
    (define R^a_bcd (riemann-tensor '((^ a) (_ b) (_ c) (_ d)) Gamma^a_bc '(theta phi)))
    (define R_ab (ricci-curvature-tensor '((_ a) (_ b)) R^a_bcd))
    (ricci-scalar g R_ab)

The Schemannian Reference
=========================

Supported Math Functions
------------------------

`Expressions`_

`Virtualization of Expressions`_

`Simplification of Expressions`_

`Linear Algebra`_

`Equation Solving`_

`Basic Calculus`_

`Numerical Differential Equation Solving`_

`Data Virtualization`_

.. _Expressions: https://github.com/ozooxo/Schemannian/blob/master/docs/expressions.rst
.. _Virtualization of Expressions: https://github.com/ozooxo/Schemannian/blob/master/docs/virtualization-of-expressions.rst
.. _Simplification of Expressions: https://github.com/ozooxo/Schemannian/blob/master/docs/simplify.rst
.. _Linear Algebra: https://github.com/ozooxo/Schemannian/blob/master/docs/linear-algebra.rst
.. _Equation Solving: https://github.com/ozooxo/Schemannian/blob/master/docs/equation-solving.rst
.. _Basic Calculus: https://github.com/ozooxo/Schemannian/blob/master/docs/calculus.rst
.. _Numerical Differential Equation Solving: https://github.com/ozooxo/Schemannian/blob/master/docs/numerical-differential-equation.rst
.. _Data Virtualization: https://github.com/ozooxo/Schemannian/blob/master/docs/data-virtualization.rst

Physics Related Functions
-------------------------

`Euler Lagrangian Equation`_

`Riemannian Geometry and General Relativity`_

`Grassmannian Calculus`_

.. _Euler Lagrangian Equation: https://github.com/ozooxo/Schemannian/blob/master/docs/euler-lagrangian-equation.rst
.. _Riemannian Geometry and General Relativity: https://github.com/ozooxo/Schemannian/blob/master/docs/riemannian-geometry-general-relativity.rst
.. _Grassmannian Calculus: https://github.com/ozooxo/Schemannian/blob/master/docs/grassmannian-calculus.rst

Copyright and License
=====================

This program has been written by Cong-Xin Qiu. It is protected by the `"GNU Lesser General Public License"`_. 

.. _"GNU Lesser General Public License": http://www.gnu.org/copyleft/lesser.html
