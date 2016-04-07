.. _lifecycles:

Module and Interface Lifecycles
===============================

Chapters :ref:`hardware_model` and :ref:`special_protocols` have
respectively defined the :ref:`Interface Lifecycle
<glossary-interface-lifecycle>` and various :ref:`Operations
<glossary-operation>` which affect the :ref:`Interface States
<glossary-interface-state>` in a :ref:`Greybus System
<glossary-greybus-system>`.

Using these definitions, this chapter describes an additional state
machine, the *Module Lifecycle*, as well as the transitions between
nodes in the Interface Lifecycle state machine in more detail.

The Module Lifecycle
^^^^^^^^^^^^^^^^^^^^

The Module Lifecycle state machine diagram is as follows.

.. image:: /img/dot/module-lifecycle.png
   :align: center

A :ref:`Module's <glossary-module>` relationship with the
:ref:`Greybus System <glossary-greybus-system>` is simple: the module
is either attached to the :ref:`Frame <glossary-frame>` via one or
more :ref:`Interface Blocks <glossary-interface-block>` in exactly one
:ref:`Slot <glossary-slot>`, in which case the entire Module is in the
MODULE_ATTACHED state, or it has been detached entirely, in which case
it is not considered a part of the Greybus System.

The following sections describe the relationship between these states,
the transitions between them, and certain Greybus :ref:`Operations
<glossary-operation>`.

.. _lifecycles_module_attach:

Module Attach
"""""""""""""

TODO

.. _lifecycles_module_detach:

Module Detach
"""""""""""""

TODO

.. _lifecycles_interface_lifecycle:

The Interface Lifecycle
^^^^^^^^^^^^^^^^^^^^^^^

The :ref:`hardware_model` defined the concept of an :ref:`Interface
State <hardware-model-interface-states>`, and
:ref:`hardware-model-lifecycle-states` introduced a related set of
*Lifecycle States*, along with a state machine which operates on
Lifecycle States, the Interface Lifecycle.

A subsequent chapter defined the :ref:`special_protocols`, which
include Operation definitions that may affect Interface and Lifecycle
States.

This section describes the relationships between these Protocols and
the Interface Lifecycle in more detail, and specifies Operation
sequences which must be successfully exchanged to cause Interface
States to change Lifecycle States.

The following sections describe the relationship between these states,
as well as how transitions between them may occur in a Greybus System.

For convenience, the Interface Lifecycle state machine diagram and the
definitions of the Lifecycle States are reproduced here:

.. image:: /img/dot/interface-lifecycle.png
   :align: center

ATTACHED is the following group of Interface States:

.. include:: lifecycle-states/attached.txt

ACTIVATED is the following group of Interface States:

.. include:: lifecycle-states/activated.txt

ENUMERATED is the following group of Interface States:

.. include:: lifecycle-states/enumerated.txt

MODE_SWITCHING is the following group of Interface States:

.. include:: lifecycle-states/mode-switching.txt

SUSPENDED is the following group of Interface States:

.. include:: lifecycle-states/suspended.txt

OFF is the following group of Interface States:

.. include:: lifecycle-states/off.txt

DETACHED is the following group of Interface States:

.. include:: lifecycle-states/detached.txt

.. _lifecycles_connection_management:

Connection Management
"""""""""""""""""""""

This section describes the sequences required to manage Greybus
Connections during the Interface Lifecycle. Since all Greybus
Operations are exchanged via |unipro| Messages, these requirements are
a superset of those required by |unipro| for establishing
communication via CPorts.

.. _lifecycles_control_establishment:

Control Connection Establishment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_connection_establishment:

Non-Control Connection Establishment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_connection_closure:

Non-Control Connection Closure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_control_closure_ms_enter:

Control Connection Closure for ms_enter
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_control_closure_power_down:

Control Connection Closure for power_down
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_control_closure_suspend:

Control Connection Closure for suspend
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_boot_enumeration:

Boot and Enumeration
""""""""""""""""""""

.. _lifecycles_boot:

Boot (DETECTED → ACTIVATED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_enumerate:

Enumerate (ACTIVATED → ENUMERATED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_power_management:

Power Management
""""""""""""""""

.. _lifecycles_suspend:

Suspend (ENUMERATED → SUSPENDED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_resume:

Resume (SUSPENDED → ENUMERATED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_power_down:

Power Down (ENUMERATED → OFF)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_reboot:

Reboot (OFF → ACTIVATED)
~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_eject:

Eject (OFF → DETACHED)
""""""""""""""""""""""

TODO

.. _lifecycles_mode_switching:

Mode Switching
""""""""""""""

.. _lifecycles_ms_enter:

Mode Switch Enter (ENUMERATED → MODE_SWITCHING)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_ms_exit:

Mode Switch Exit (MODE_SWITCHING → ENUMERATED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_error_handling:

Error Handling
""""""""""""""

.. _lifecycles_early_eject:

Early Eject (ATTACHED → DETACHED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_early_power_down:

Early Power Down (ACTIVATED → OFF)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_mode_switch_fail:

Mode Switch Fail (MODE_SWITCHING → ACTIVATED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

.. _lifecycles_forcible_removal:

Forcible Removal (Any → DETACHED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO
