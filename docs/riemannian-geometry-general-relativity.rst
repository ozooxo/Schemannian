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

``scalar`` and ``tensor`` supports generic operations such ass ``add``, ``mul``, ``simplify-generic``, and ``partial-deriv``. For ``add``, the two addends need to be either scalars or tensors of the same form (same rank and dimensions). ``mul`` actually means tensor product; to ``mul`` a tensor of rank ``m`` and a tensor of rank ``n``, you got a tensor of rank ``m*n``. ``simplify-generic`` just simplifies every scalar element individually. For ``(partial-deriv fx x)``, if both ``fx`` and ``x`` are scalars, it is just normal ``deriv``; for all the other combinations, if ``fx`` has rank ``m`` (scalar has rank ``1``), ``x`` has rank ``n``, the ``(partial-deriv fx x)`` is a ``m*n`` dimensional tensor.

In addition, some other questions has been defined as below.

.. code:: scheme

    (switch-index aim-index-lst tnsr) → tensor?
        aim-index-lst : list?
        tnsr : tensor?

    (scalar-mul k x) → tensor?
        k : expression?
        x : tensor?
