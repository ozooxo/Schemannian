The Schemannian Reference
=========================

Linear Algebra
--------------

"Schemannian" can do basic symbolic and numerical linear algebra.

In "Schemannian", vectors are one-dimensional scheme list such as ``'(1 2 a 3 b)``, and matrices are two-dimensional list such as ``'((a 1) (2 b))``. Notice that every element in a vector/matrix is an expression, so ``'(1 (+ a b))`` is a vector. Current supported functions include

.. code:: scheme

    (dot-product-vector v w) → expression?
        v : linear-algebra-vector? 
        w : linear-algebra-vector? 

    (matrix-*-vector m v) → linear-algebra-vector? 
        m : linear-algebra-matrix? 
        v : linear-algebra-vector? 

    (transpose-mat m) → linear-algebra-matrix? 
        m : linear-algebra-matrix? 

    (matrix-*-matrix m n) → linear-algebra-matrix? 
        m : linear-algebra-matrix? 
        n : linear-algebra-matrix? 

    (mat-trace m) → expression?
        m : linear-algebra-matrix? 

    (mat-determinant m) → expression?
        m : linear-algebra-matrix? 

    (mat-inverse m) → linear-algebra-matrix? 
        m : linear-algebra-matrix? 

For example,

.. code:: scheme

    (require "linear-algebra.rkt")
    (define m '((a b c) (d e f) (g h i)))
    (mat-determinant m)

should give you 

.. code:: scheme

    '(+ (* (+ (* i e) (* -1 f h)) a) (* -1 (+ (* i b) (* -1 c h)) d) (* (+ (* f b) (* -1 c e)) g))
