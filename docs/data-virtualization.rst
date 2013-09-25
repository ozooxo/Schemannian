The Schemannian Reference
=========================

Data Virtualization
-------------------

"Schemannian" supports two functions ``plot`` and ``listplot`` for plotting and data visualization.

.. code:: scheme

    (plot func x-min x-max y-min y-max) → pict?
        func : procedure?
        x-min : real?
        x-max : real?
        y-min : real?
        y-max : real?

    (listplot lst x-min x-max y-min y-max) → pict?
        lst : list? 
        x-min : real?
        x-max : real?
        y-min : real?
        y-max : real?

For ``listplot``, every element in ``lst`` is a list of two numbers (so you can get them by ``car`` and ``cadr``), as the x and y coordinate of the plotting point.

For example,

.. code:: scheme

    (require "plot.rkt")
    (plot cos 0 10 -2 2)

gives you a cosine curve of ``y = cos(x)`` in the plotting region ``0 < x < 10`` and ``-2 < y < 2``.
