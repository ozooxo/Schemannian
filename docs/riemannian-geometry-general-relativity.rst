The Schemannian Reference
=========================

Riemannian Geometry and General Relativity
------------------------------------------

"Schemannian" supports functions to calculate typical General Relativity expressions such as Christoffel symbols, Riemann curvature tensor, Ricci curvature tensor, and Ricci scalar from the metric. To support those calculations, it can also do some general tensor operations.

Tensor Operations
~~~~~~~~~~~~~~~~~

.. code:: scheme

    (make-scalar x) → scalar?
        x : expression?

    (make-tensor index-lst contents-matrix) → tensor?
        index-lst : list?
        contents-matrix : list?

The two constructing functions above are used to make scalars and tensors. In ``make-tensor``, ``contents-matrix`` is a ``(length index-lst)``-ranked nested list with elements of the tensor.

``scalar`` and ``tensor`` supports generic operations such ass ``add``, ``mul``, ``simplify-generic``, and ``partial-deriv``.

.. code:: scheme

    (add x y)
    (mul x y)
    (simplify-generic x)
    (partial-deriv fx x)

For ``add``, the two addends need to be either scalars or tensors of the same form (same rank and dimensions). ``mul`` actually means tensor product; to ``mul`` a tensor of rank ``m`` and a tensor of rank ``n``, you got a tensor of rank ``m*n``. ``simplify-generic`` just simplifies every scalar element individually. For ``(partial-deriv fx x)``, if both ``fx`` and ``x`` are scalars, it is just normal ``deriv``; for all the other combinations, if ``fx`` has rank ``m`` (scalar has rank ``1``), ``x`` has rank ``n``, the ``(partial-deriv fx x)`` is a ``m*n``-ranked tensor.

In addition, some other questions has been defined as below.

.. code:: scheme

    (switch-index aim-index-lst tnsr) → tensor?
        aim-index-lst : list?
        tnsr : tensor?

    (switch-index aim-index-lst tnsr) → tensor?
        aim-index-lst : list?
        tnsr : tensor?

    (scalar-mul k x) → tensor?
        k : expression?
        x : tensor?

``change-index`` just changes the indices of the tensor, but doesn't do anything for the content elements of the tensor. ``switch-index`` does not only change the indices of the tensor, but also transpose the content elements of tensor following the new order of the indices.

To use all those tensor related functions, you need to first

.. code:: scheme

    (require "tensor.rkt")

Riemannian Geometry
~~~~~~~~~~~~~~~~~~~

"Schemannian" has several useful functions in package

.. code:: scheme

    (require "riemannian.rkt")

for Riemannian geometry calculations. 

.. code:: scheme

    (einstein-summation tnsr) → tensor?
        tnsr : tensor?

sums over the repeated indices of a tensor.

``metric`` is just a rank-2 tensor. You can upper or lower its indices by 

.. code:: scheme

    (metric upper-lower-lst tnsr) → tensor?
        upper-lower-lst : list?
        tnsr : tensor?

in which ``upper-lower-lst`` is just a list of either ``'(_ _)``, ``'(_ ^)``, ``'(^ _)``, or ``'(^ ^)``. Therefore, `metric-einstein-summation.rkt`_ gives you identity.

.. _metric-einstein-summation.rkt: https://github.com/ozooxo/Schemannian/blob/master/examples/metric-einstein-summation.rkt

.. code:: scheme

    (require "tensor.rkt"
             "riemannian.rkt")

    (define g (make-tensor '((_ a) (_ b)) '((a b c d) (e f g h) (i j k l) (m n o p)))) 
    (einstein-summation (mul (change-index '((^ a) (^ b)) (metric '(^ ^) g)) 
                             (change-index '((_ b) (_ c)) (metric '(_ _) g))))

The General Relativity aimed functions are

.. code:: scheme

    (christoffel index-lst g-tensor coordinate-lst) → tensor?
        index-lst : list?
        g-tensor : tensor?
        coordinate-lst : list?

    (riemann-tensor index-lst christoffel-gamma coordinate-lst) → tensor?
        index-lst : list?
        christoffel-gamma : tensor?
        coordinate-lst : list?

    (ricci-curvature-tensor index-lst riemann-tnsr) → tensor?
        index-lst : list?
        riemann-tnsr : tensor?

    (ricci-scalar g-tnsr ricci-tnsr) → scalar?
        g-tnsr : tensor?
        ricci-tnsr : tensor?

For example, `curvature-surface-of-sphere.rkt`_ calculates the curvature on the surface of a sphere, which is ``'(scalar * 2 (** r -2))``.

.. _curvature-surface-of-sphere.rkt: https://github.com/ozooxo/Schemannian/blob/master/examples/curvature-surface-of-sphere.rkt

.. code:: scheme

    (require "tensor.rkt"
             "riemannian.rkt")

    (define g (make-tensor '((_ a) (_ b)) 
                           '(((** r 2) 0)
                             (0 (* (** r 2) (** (sin theta) 2))))))

    (define Gamma^a_bc (christoffel '((^ a) (_ b) (_ c)) g '(theta phi)))
    (define R^a_bcd (riemann-tensor '((^ a) (_ b) (_ c) (_ d)) Gamma^a_bc '(theta phi)))
    (define R_ab (ricci-curvature-tensor '((_ a) (_ b)) R^a_bcd))
    (ricci-scalar g R_ab)

And `curvature-schwarzschild.rkt`_ calculates the curvature of the Schwarzschild metric, which should give you ``'(scalar 0)`` (currently there are still bugs somewhere).

.. _curvature-schwarzschild.rkt: https://github.com/ozooxo/Schemannian/blob/master/examples/curvature-schwarzschild.rkt

.. code:: scheme

    (define g (make-tensor '((_ a) (_ b)) 
                           '(((+ 1 (* -1 rs (** r -1))) 0 0 0)
                             (0 (* -1 (** (+ 1 (* -1 rs (** r -1))) -1)) 0 0)
                             (0 0 (* -1 (** r 2)) 0)
                             (0 0 0 (* -1 (** r 2) (** (sin theta) 2))))))

    (define Gamma^a_bc (christoffel '((^ a) (_ b) (_ c)) g '(t r theta phi)))
    (define R^a_bcd (riemann-tensor '((^ a) (_ b) (_ c) (_ d)) Gamma^a_bc '(t r theta phi)))
    (define R_ab (ricci-curvature-tensor '((_ a) (_ b)) R^a_bcd))
    (ricci-scalar g R_ab)
