.. include:: defines.rst

Greybus Hardware Model
======================

An implementation of the Project Ara platform which complies with the
Greybus Specification is a *Greybus system*.

A Greybus system shall be composed of the following physical
components:

1. An “endoskeleton,” consisting of the following elements:

   - One or more |unipro| switches, which distribute |unipro| network
     traffic throughout the Greybus network.

   - One or more *interface blocks*. These are the connectors which
     expose the endoskeleton's communication interface to other
     elements in a Greybus system.

   - Exactly one Supervisory Controller, hereafter referred to as the
     “SVC.” The SVC administers the Greybus system, including the
     system's UniPro switches, its power bus, its wake/detect pins,
     and its RF bus.

2. One or more modules, which are physically inserted into slots on
   the endoskeleton. Modules shall implement communication protocols
   in accordance with this document's specifications.

2. Exactly one Application Processor module, hereafter referred to as
   the “AP.”

An example Greybus [#a]_ [#b]_ system using Bridge ASICs and native
|unipro| interfaces is shown in the following figure.

.. TODO: rework this diagram, which was done in a hurry for a MIPI SW
   working group meeting.

.. figure:: _static/example-system.png
   :alt: Example Greybus system
   :figwidth: 6in
   :align: center


.. rubric:: Footnotes

.. [#a] Also, is "Endpoint" in the diagram well-defined?  Does it
        represent what you're later referring to as a "function?"  If
        so I suggest you update the diagram that way also.

.. [#b] Answer:  "Endpoint" in this diagram is *not* well-defined.

