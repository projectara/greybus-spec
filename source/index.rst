.. ----------------------------------------------------------------------
.. Notes for Project Ara Internal Team Use

.. Go look at README FIRST before doing anything else:
   https://docs.google.com/a/projectara.com/document/d/1-g9uymGyxUrVKOfuJrYCMkl2kqoMvu-GGvqIw3extPE/edit

.. Before reading this document, try to get a basic working knowledge
   of the MIPI UniPro v1.6 specification:
   https://docs.google.com/a/projectara.com/file/d/0BxTh4XIogG2qbm1PaEo5M1ZES1U/edit>`_.

   At a bare minimum, read chapter 4 for an architecture overview.
.. ----------------------------------------------------------------------

.. highlight:: none

.. include:: defines.rst

.. Headers and footers

.. footer::

   Google Confidential/Restricted. ###Page###/###Total###

.. header::

   Greybus Specification Version: |gb-major|.\ |gb-minor|


.. warning::

   This document contains a preliminary specification for various
   aspects of a Greybus system's communication. It is important to
   note that the information contained within is in a draft stage, and
   has not yet been fully implemented. The specifications defined
   herein are **unstable**, and may change incompatibly in future
   versions of this document.

.. toctree::
   :maxdepth: 2

   terminology
   glossary
   introduction
   hardware_model
   module_info
   operations
   control
   connection
   device_class
   bridged_phy
