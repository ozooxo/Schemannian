===========
Schemannian
===========

As a scheme/Racket based package for symbolic mathematics for physicist, "Schemannian" currently supports basic calculus and linear algebra, Riemannian geometry and General Relativity calculations.

Installation
============

"Schemannian" is written and debugged using Racket v5.3.1. You can download and install Racket from http://racket-lang.org/download/ .

Currently, to run examples (or try calculating something new) using this package, you can just uncomment the debug code and run the relevant files. To run Racket files, you can either use DrRacket, or run commands like

::

    $ racket riemannian.rkt

Reference Manual
================

Expressions
-----------

Following the Lisp family rule, "Schemennian" uses prefix notations. Every value in a list can be either a number or a symbol. It currently has only limited number of operations (which are noted as symbols), including ``'+``, ``'*``, ``'**`` (exponential function), ``'log``, ``'sin``, and ``'cos``.

For example, :math:`(3 a \sin c)^2 + d` can be written as

.. code:: scheme

    '(+ (** (* 3 a ('sin c)) 2) d)

Basic Calculus
--------------

"Schemannian" can do chain rule level derivations and kindergarten level integrals. However, as it currently only have extremely weak ability to simplify arithmetic expression, it sometimes gives really overcomplicated results. Examples for functions ``deriv`` and ``integrate`` are show as below.

.. code:: scheme

    (require "calculus.rkt")

    (deriv '(** (+ 3 (* x 2) y) x) 'x)
    (integrate '(+ (** x 3) y 2) 'x)

Linear Algebra
--------------

"Schemannian" vectors are one-dimensional scheme list such as ``'(1 2 a 3 b)``, and matrices are two-dimensional list such as ``'((a 1) (2 b))``. Current supported functions include

.. code:: scheme

    (require "linear-algebra.rkt")

    (dot-product-vector <vector> <vector>)
    (matrix-*-vector <matrix> <vector>)
    (transpose-mat <matrix>)
    (matrix-*-matrix <matrix> <matrix>)

    (mat-trace <matrix>)
    (mat-determinant <matrix>)
    (mat-inverse <matrix>)

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

Copyright and License
=====================

This program has been written by Cong-Xin Qiu. It is protected by the `"GNU Lesser Public License"`_ .

.. _"GNU Lesser Public License": http://www.gnu.org/copyleft/lesser.html
