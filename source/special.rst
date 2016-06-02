.. _special_protocols:

Special Protocols
=================

This section defines three Protocols, each of which serves a special
purpose in a Greybus system.

The first is the :ref:`control-protocol`.  Interfaces may provide a
CPort whose user implements the Control Protocol.  The AP may
establish a Connection between one of its Interfaces' CPorts and such
CPorts. If it does, the AP may subsequently send Operations on that
Connection to perform basic initialization of the Interface, configure
it, send it notifications, and otherwise interact with the Interface
at a high level. The AP may also use Control Connections while
establishing and closing other Connections to CPorts declared in the
Interface's :ref:`Manifest <manifest-description>`.

The second is the :ref:`svc-protocol`, which is used only between the
SVC and AP Module.  The SVC provides low-level control of the |unipro|
network.  The SVC performs almost all of its activities under
direction of the AP Module, and the SVC Protocol is used by the AP
Module to exert this control.  The SVC also uses this protocol to
notify the AP Module of events, such as the insertion or removal of
a Module.

The third is the :ref:`bootrom-protocol`, which is used between the AP
Module and any other module's bootloader to download firmware
executables to the module.  When a module's manifest includes a CPort
using the Bootrom Protocol, the AP can connect to that CPort and
download a firmware executable to the module.  Bootrom protocol is
deprecated for new designs requiring Firmware download to the Module.
The :ref:`firmware-download-protocol` should be used for any new
designs.

.. toctree::
    :maxdepth: 2

    special/control.rst
    special/svc.rst
    special/bootrom.rst
