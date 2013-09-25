The Schemannian Reference
=========================

Riemannian Geometry and General Relativity
------------------------------------------

"Schemannian" supports functions to calculate typical General Relativity objects such as Christoffel symbols, Riemann curvature tensor, Ricci curvature tensor, and Ricci scalar from the metric. To support those calculations, it can also do some general tensor operations.

Tensor Operations
~~~~~~~~~~~~~~~~~

.. code:: scheme

    (deriv exp var) → expression?
        exp : expression?
        var : expression?

    (integrate exp var) → expression?
        exp : expression?
        var : variable?

