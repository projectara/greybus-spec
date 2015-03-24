.. include:: defines.rst

Greybus Hardware Model
======================

An implementation of the Project Ara platform which complies with the
Greybus Specification is a *Greybus system*.

A Greybus system shall be composed of the following physical
components:

1. An "endoskeleton" (or *Endo*), consisting of the following elements:

   - One or more |unipro| switches, which distribute |unipro| network
     traffic throughout the Greybus network.

   - One or more *interface blocks*. These are the connectors which
     expose the Endo's communication interface to other
     elements in a Greybus system.

   - Exactly one Supervisory Controller, hereafter referred to as the
     "SVC." The SVC administers the Greybus system, including the
     system's |unipro| switches, its power bus, its wake/detect pins,
     and its RF bus.

2. One or more modules, which are physically inserted into slots on
   the Endo. Modules shall implement communication protocols
   in accordance with this document's specifications.

3. Exactly one Application Processor module, hereafter referred to as
   the "AP."

For a full description of the Project Ara platform, please see the
*Project Ara Module Developers Kit* specification.
