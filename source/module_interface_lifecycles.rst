.. highlight:: text

.. _lifecycles:

Module and Interface Lifecycles
===============================

Chapters :ref:`hardware_model` and :ref:`special_protocols` have
respectively defined the :ref:`Interface Lifecycle
<glossary-interface-lifecycle>` and various :ref:`Operations
<glossary-operation>` which affect the related :ref:`Interfaces
<hardware-model-interfaces>` within Modules and :ref:`Interface States
<hardware-model-interface-states>` within the Frame in a :ref:`Greybus
System <glossary-greybus-system>`.

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
<hardware-model-interfaces>`, and
:ref:`hardware-model-lifecycle-states` introduced a related set of
*Interface Lifecycle States*, along with a state machine which
operates on Lifecycle States, the Interface Lifecycle.

A subsequent chapter defined the :ref:`special_protocols`, which
include Operation definitions that affect Interfaces' Lifecycle
States.

This section describes the relationships between these Protocols and
the Interface Lifecycle in more detail, and specifies Operation
sequences which may be successfully exchanged to cause Interfaces to
change Lifecycle States.

The following sections describe the relationship between these states,
as well as how transitions between them may occur in a Greybus System.

For convenience, the Interface Lifecycle state machine diagram and the
Interface States associated with each Interface Lifecycle State are
reproduced here:

.. image:: /img/dot/interface-lifecycle.png
   :align: center

When an Interface is ATTACHED, the following Interface States are
possible:

.. include:: lifecycle-states/attached.txt

When an Interface is ACTIVATED, the following Interface States are
possible:

.. include:: lifecycle-states/activated.txt

When an Interface is ENUMERATED, the following Interface States are
possible:

.. include:: lifecycle-states/enumerated.txt

When an Interface is MODE_SWITCHING, the following Interface States are
possible:

.. include:: lifecycle-states/mode-switching.txt

When an Interface is SUSPENDED, the following Interface States are
possible:

.. include:: lifecycle-states/suspended.txt

When an Interface is OFF, the following Interface States are
possible:

.. include:: lifecycle-states/off.txt

In the DETACHED Interface Lifecycle State, no Module is attached to
the Interface Block. The unique Interface State in this Lifecycle
State is:

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

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces

.. note::

   The content in this section is defined under the assumption that
   there is exactly one :ref:`AP Interface
   <hardware-model-ap-module-requirements>` in the Greybus System.

   The results if there are multiple AP Interfaces are undefined.

.. TODO: add an MSC here for the successful case

During SVC Protocol Operation processing defined in
:ref:`svc-interface-activate` and :ref:`svc-interface-resume`, an
Interface may signal to the Frame that it is capable of Greybus
Communication, and that its Control CPort user is ready to respond to
:ref:`control-protocol` Operations. This can also occur during the
processing of a :ref:`control-mode-switch`.

The following sequence may be used to establish a Control Connection
to an Interface for subsequent use.

Though the AP may follow this sequence at any time, the AP should only
do so during one of the following transitions in the Interface
Lifecycle state machine:

- "enumerate", as described in :ref:`lifecycles_enumerate`,
- "resume", as described in :ref:`lifecycles_resume`, or
- "ms_exit", as described in :ref:`lifecycles_ms_exit`.

If the AP follows this sequence at other times, the results are
undefined.

To perform this sequence, the following conditions shall hold.

- The AP Interface and SVC shall have established a Connection
  implementing the :ref:`svc-protocol`. This is the SVC Connection in
  this sequence. This implies the AP Interface has a Device ID set.

- Another Interface shall be provided, which has a Control CPort.

If these conditions do not all hold, the sub-sequence shall not be
followed. The results of following this sub-sequence in this case are
undefined.

The following values are used in this sub-sequence:

- The AP Interface ID is ap_interface_id.
- The CPort ID of a CPort on the AP Interface which is used to
  establish the Control Connection is ap_cport_id.
- The AP Interface Device ID is ap_device_id.
- The Interface ID of the other Interface is interface_id.

1. The AP shall initiate a :ref:`svc-interface-device-id` to assign a
   Device ID to the Interface.

   The intf_id in the request payload shall equal interface_id.

   The device_id field in the request payload shall be unique among
   all values assigned to Interfaces in the Greybus System.

   Additionally, the AP shall ensure that no other Interface shall
   currently have been assigned a Device ID within the following
   inclusive range::

       device_id, device_id + 1, ..., device_id + (max_conn / 32)

   Where max_conn is the maximum value of the Interface's CPort ID for
   any Connection the AP subsequently intends to establish with the
   Interface, including the Control Connection, and "/" denotes
   division with remainder truncated towards zero.

   If this Operation fails, the sequence is complete and has
   failed. Go directly to step 4.

2. The AP shall initiate a :ref:`svc-route-create` to establish a
   route within the :ref:`Switch <glossary-switch>` between an AP
   Interface and the Interface.

   The intf1_id and dev1_id fields in the request payload shall
   respectively equal ap_interface_id and ap_device_id. The intf2_id
   field in the request payload shall equal interface_id.  The dev2_id
   field in the request payload shall have the same value as the
   device_id field from step 1.

   If this Operation fails, the sequence is complete and has
   failed. Go directly to step 4.

3. The AP shall initiate a :ref:`svc-connection-create` to establish the
   Control Connection.

   The intf1_id and cport1_id fields in the request payload shall
   respectively equal ap_interface_id and ap_cport_id. The intf2_id
   and cport2_id fields in the request payload shall respectively
   equal interface_id and zero.

   The tc field in the request payload shall equal zero.  The
   :ref:`flags field <svc-connection-create-flags>` in the request
   payload should equal 0x7 (E2EFC | CSD_N | CSV_N).

   The sequence is complete.  If this Operation fails, the sequence
   has failed. If it succeeds, the sequence has succeeded.

4. The sequence is now complete and has succeeded or failed.

If the sequence succeeds, the AP Interface may inititate
:ref:`control-protocol` Operations with the Interface by sending
requests using CPort ap_cport_id.

If the sequence fails, the AP should not attempt to initiate Control
Protocol Operations with the Interface. If the AP does so under this
condition, the results are undefined.

.. _lifecycles_connection_establishment:

Non-Control Connection Establishment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces, and
   SW-4660 + any sub-tasks track adding module/module connections.

.. note::

   The content in this section is defined under the following assumptions:

   - there is exactly one :ref:`AP Interface
     <hardware-model-ap-module-requirements>` in the Greybus System.

   - The Connection being established is between that AP Interface and
     another Interface in the System.

   The results if there are multiple AP Interfaces, or in the case of
   non-AP to non-AP Interfaces, are undefined.

.. TODO add an MSC here for the successful case

If an Interface is :ref:`hardware-model-lifecycle-enumerated`, the AP
can establish additional Connections to the Interface in addition to
the existing Control Connection.

The following sequence may be used to establish such a Connection to
an Interface for subsequent use.

Though the AP may follow this sequence at any time, the AP should only
do so if the Interface is ENUMERATED. If the AP follows this sequence
at other times, the results are undefined.

A CPort ID value interface_cport_id shall be provided for a CPort on
the Interface, and is used in this sequence. The value shall have been
given in the "id" field of a :ref:`cport-descriptor` in the Interface
:ref:`manifest-description` in the response payload of the
:ref:`control-get-manifest` Operation which was exchanged during the
most recent enumeration of the Interface.  The AP should additionally
ensure that the CPort on the Interface with CPort ID
interface_cport_id is not already at one end of an established Greybus
Connection.

Another value, ap_cport_id, shall also be provided. The AP Interface
shall contain a CPort with CPort ID ap_cport_id. The AP should ensure
that this CPort is not part of an established |unipro| connection.

The following values are used in this sub-sequence:

- The AP's Interface ID is ap_interface_id.
- The Interface ID of the ENUMERATED Interface is interface_id.

1. The AP shall initiate a :ref:`svc-connection-create` to establish
   the Connection.

   The intf1_id and cport1_id fields in the request payload shall
   respectively equal ap_interface_id and ap_cport_id. The intf2_id
   and cport2_id fields in the request payload shall respectively
   equal interface_id and interface_cport_id. The tc field in the
   request payload shall equal zero.

   The flags field in the request payload is :ref:`Protocol
   <glossary-connection-protocol>`\-specific.

   If this Operation fails, the sequence is complete and has
   failed. Go directly to step 4.

2. The AP shall initiate a :ref:`control-connected` request on the
   Interface's Control Connection. The cport_id field in the request
   payload shall equal interface_cport_id.

   If this Operation fails, the sequence has failed.

   If it succeeds, the sequence has succeeded. Go directly to step 4.

3. Since the sequence has failed, the AP initiates a
   :ref:`svc-connection-destroy` Operation to disconnect the CPort
   which was connected in step 1.

   The intf1_id, cport1_id, intf2_id, and cport2_id fields in the
   request payload shall respectively equal ap_interface_id,
   ap_cport_id, interface_id, and interface_cport_id.

4. The sequence is now complete and has succeeded or failed.

If the sequence succeeds, the AP, and on a protocol-specific basis,
the Interface, may initiate Greybus Operations on the newly
established Connection. In this case, the Greybus Protocol used shall
correspond to the "protocol" field for the CPort descriptor referenced
in step 1, as defined by Table :num:`table-cport-protocol`.

If the sequence fails, the AP should not, and the Interface shall not,
initiate Greybus communication on any of the CPorts referenced in
step 1. If this occurs, the results are undefined.

.. _lifecycles_connection_closure_prologue:

Connection Closure Prologue
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces, and
   SW-4660 + any sub-tasks track adding module/module connections.

.. note::

   The content in this section is defined under the following assumptions:

   - there is exactly one :ref:`AP Interface
     <hardware-model-ap-module-requirements>` in the Greybus System.

   - The Connection being closed is between that AP Interface and
     another Interface in the System.

   The results if there are multiple AP Interfaces, or in the case of
   non-AP to non-AP Interfaces, are undefined.

.. TODO add an MSC here for the successful case

This section defines a common sub-sequence, the connection closure
prologue sub-sequence, which is used by following sections in order to
close a Greybus Connection.

To perform this sub-sequence, the following conditions shall hold.

- The AP Interface and SVC shall have established a Connection
  implementing the :ref:`svc-protocol`. This is the SVC Connection in
  this sub-sequence.

- A Connection between the AP Interface and another Interface shall be
  defined, which is now being closed.

  This is the Closing Connection here. The Closing Connection may be
  the Control Connection, or some other Greybus Connection between the
  AP Interface and the other Interface.

- The AP Interface and the other Interface shall have established a
  Control Connection. This is the Control Connection in this
  sub-sequence.

If these conditions do not all hold, the sub-sequence shall not be
followed. The results of following this sub-sequence in this case are
undefined.

The following values are used in this sub-sequence:

- The AP Interface ID is ap_interface_id.
- The CPort ID of the CPort on the AP Interface which is at one end of
  the Closing Connection is ap_cport_id.
- The Interface ID of the other Interface is interface_id.
- The CPort ID on the other Interface which is at the other end of the
  Closing Connection is interface_cport_id. If the Closing Connection
  is the Control Connection, interface_cport_id is zero.

1. The AP Interface shall exchange a :ref:`control-disconnecting` with
   the Interface on the Control Connection. The cport_id field in the
   request payload shall equal interface_cport_id.

2. The AP Interface may now issue responses to requests it has already
   received on the Closing Connection. It shall not issue any such
   responses after this step.

3. The AP Interface shall exchange a
   :ref:`greybus-protocol-ping-operation` with the Interface on the
   Closing Connection.

4. The AP Interface shall initiate a :ref:`svc-connection-quiescing`
   on the SVC Connection.

   The intf1_id and cport1_id fields in the request payload shall
   respectively equal ap_interface_id and ap_cport_id.  The intf2_id
   and cport2_id fields in the request payload shall respectively
   equal interface_id and interface_cport_id.

   If this Operation fails, the connection closure prologue
   sub-sequence has failed. Go directly to step 6.

5. The AP shall exchange a :ref:`greybus-protocol-ping-operation` with the
   Interface on the Closing Connection.

   The connection closure prologue sub-sequence has succeeded.

6. The connection closure prologue sub-sequence is complete, and has
   succeeded or failed.

.. _lifecycles_connection_closure_epilogue:

Connection Closure Epilogue
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces

.. note::

   The content in this section is defined under the assumption that
   there is exactly one :ref:`AP Interface
   <hardware-model-ap-module-requirements>` in the Greybus System.

   The results if there are multiple AP Interfaces are undefined.

.. TODO add an MSC here for the successful case

This section defines a common sub-sequence, the connection closure
epilogue sub-sequence, which is used by following sections in order
to close a Greybus Connection.

To perform this sub-sequence, the following conditions shall hold.

- The AP Interface and SVC shall have established a Connection
  implementing the :ref:`svc-protocol`. This is the SVC Connection in
  this sub-sequence.

- A Connection between the AP Interface and another Interface shall be
  provided. This is the Closing Connection in this sub-sequence.

If these conditions do not all hold, the sub-sequence shall not be
followed. The results of following this sub-sequence in this case are
undefined.

The following values are used in this sub-sequence:

- The AP Interface ID is ap_interface_id.
- The CPort ID of the CPort on the AP Interface which is at one end of
  the Closing Connection is ap_cport_id.
- The Interface ID of the other Interface is interface_id.
- The CPort ID on the other Interface which is at the other end of the
  Closing Connection is interface_cport_id.

1. The AP Interface shall initiate a :ref:`svc-connection-destroy` on
   the SVC Connection.

   The intf1_id and cport1_id fields in the request payload shall
   respectively equal ap_interface_id and ap_cport_id. The intf2_id
   and cport2_id fields in the request payload shall respectively
   equal interface_id and interface_cport_id.

   If this Operation fails, the connection closure epilogue
   sub-sequence has failed. Go to the next step.

2. The AP Interface shall perform any implementation-defined
   procedures required to make the CPort with ID ap_cport_id usable if
   a Greybus Connection is later reestablished on that CPort.

   The AP Interface may set local |unipro| attributes related to that
   CPort to implementation-defined values as part of this process.  If
   such procedures are required by the AP Interface, it shall complete
   them before going to the next step.

   If the connection closure epilogue sub-sequence did not fail in
   step 1, it has now succeeded.

3. The connection closure epilogue sub-sequence is now complete, and
   has succeeded or failed.

.. _lifecycles_connection_closure:

Non-Control Connection Closure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces, and
   SW-4660 + any sub-tasks track adding module/module connections.

.. note::

   The content in this section is defined under the following assumptions:

   - there is exactly one :ref:`AP Interface
     <hardware-model-ap-module-requirements>` in the Greybus System.

   - The Connection being closed is between that AP Interface and
     another Interface in the System.

   The results if there are multiple AP Interfaces, or in the case of
   non-AP to non-AP Interfaces, are undefined.

.. TODO add an MSC here for the successful case

If an Interface is :ref:`hardware-model-lifecycle-enumerated` and a
Non-Control Connection has been established between the AP and the
Interface as described in :ref:`lifecycles_connection_establishment`,
the AP can subsequently close the Connection to the Interface.

The following sequence may be used to close such a Connection to an
Interface.

Though the AP may follow this sequence at any time, the AP should only
do so if the Interface whose Connection is being closed is ENUMERATED,
or during one of the following Interface Lifecycle state machine
transitions which cause the Interface to exit the ENUMERATED Lifecycle
State:

- "power_down", as described in :ref:`lifecycles_power_down`
- "suspend", as described in :ref:`lifecycles_suspend`
- "ms_enter", as described in :ref:`lifecycles_ms_enter`

If the AP follows this sequence at other times, the results are
undefined.

The following values are used in this sub-sequence:

- The AP Interface ID is ap_interface_id.
- The CPort ID of the CPort on the AP Interface which is at one end of
  the Closing Connection is ap_cport_id.
- The Interface ID of the other Interface is interface_id.
- The CPort ID on the other Interface which is at the other end of the
  Closing Connection is interface_cport_id.

1. The :ref:`lifecycles_connection_closure_prologue` sub-sequence is
   followed. The Closing Connection for that sub-sequence is the one
   being closed in this sequence.  If the sub-sequence fails, this
   sequence has failed. Go directly to step 4.

2. The AP exchanges a :ref:`control-disconnected` on the Interface's
   Control Connection. The cport_id field in the request payload shall
   equal interface_cport_id.

3. The :ref:`lifecycles_connection_closure_epilogue` sub-sequence is
   followed. The Closing Connection for that sub-sequence is the one
   being closed in this sequence.  If the sub-sequence fails, this
   sequence has failed. Otherwise, it has succeeded.

4. The sequence is now complete, and has succeeded or failed.


If the sequence succeeds, the AP Interface and the other Interface
shall respectively not transmit on CPorts ap_cport_id and
interface_cport_id unless a Greybus Connection is subsequently
established using either of the two CPorts. Any |unipro| Messages
received by those Interfaces shall be discarded.

Regardless of success or failure, the AP Interface shall not initiate
any communication on the CPort unless it is at one end of a Connection
which is successfully established subsequently.

If the sequence fails, the results are undefined.

.. _lifecycles_control_closure_ms_enter:

Control Connection Closure for ms_enter
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces

.. note::

   The content in this section is defined under the assumption that
   there is exactly one :ref:`AP Interface
   <hardware-model-ap-module-requirements>` in the Greybus System.

   The results if there are multiple AP Interfaces are undefined.

.. TODO add an MSC here for the successful case

If an Interface is :ref:`hardware-model-lifecycle-enumerated`, its
Control Connection is established.  The AP can subsequently close the
Control Connection to the Interface.

The following sequence may be used to close the Control Connection to
an Interface while the Interface is entering the MODE_SWITCHING state,
and also to signal to the Interface that its Control Connection is
closing and it has entered MODE_SWITCHING.

Though the AP may follow this sequence at any time, the AP should only
do so if the Interface is ENUMERATED, during the "ms_enter" Interface
Lifecycle state machine transition, which causes the Interface to exit
the ENUMERATED Lifecycle State as described in
:ref:`lifecycles_ms_enter`.

If the AP follows this sequence at other times, the results are
undefined.

1. The :ref:`lifecycles_connection_closure_prologue` sub-sequence is
   followed. The Closing Connection for that sub-sequence is the
   Control Connection for the Interface.  If the sub-sequence
   fails, this sequence has failed. Go directly to step 3.

2. The AP shall send a :ref:`control-mode-switch` to the
   Interface. The Operation is unidirectional; this step
   succeeds. This sequence has succeeded.

3. The sequence is now complete and has succeeded or failed.

If the sequence fails, the results are undefined.

.. _lifecycles_control_closure_power_down:

Control Connection Closure for power_down
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces, and
   SW-4660 + any sub-tasks track adding module/module connections.

.. note::

   The content in this section is defined under the following assumptions:

   - there is exactly one :ref:`AP Interface
     <hardware-model-ap-module-requirements>` in the Greybus System.

   - The Connection being closed is between that AP Interface and
     another Interface in the System.

   The results if there are multiple AP Interfaces, or in the case of
   non-AP to non-AP Interfaces, are undefined.

.. TODO add an MSC here for the successful case

If an Interface is :ref:`hardware-model-lifecycle-enumerated`, its
Control Connection is established.  The AP can subsequently close the
Control Connection to the Interface.

The following sequence may be used to close the control Connection to
an Interface while the Interface is entering the OFF state.

Though the AP may follow this sequence at any time, the AP should only
do so if the Interface is ENUMERATED, during the "power_down" Interface
Lifecycle state machine transition, which causes the Interface to exit
the ENUMERATED Lifecycle State as described in
:ref:`lifecycles_power_down`.

If the AP follows this sequence at other times, the results are
undefined.

The following value is used in this sub-sequence:

- The Interface ID of the other Interface is interface_id.

1. The :ref:`lifecycles_connection_closure_prologue` sub-sequence is
   followed. The Closing Connection for that sub-sequence is the
   Control Connection for the other Interface.  If the sub-sequence
   fails, this sequence has failed. Go directly to step 5.

2. The AP shall exchange an :ref:`svc-interface-set-power-mode` with
   the SVC.

   The intf_id field in the request payload shall equal interface_id.
   The tx_mode and rx_mode fields shall both equal
   UNIPRO_HIBERNATE_MODE.

   If the Operation fails, this procedure has failed. Go directly to
   step 5.

   If it succeeds, the SVC shall set the UNIPRO Interface State to
   UPRO_HIBERNATE. The SVC shall wait an implementationed-defined
   duration in this step to allow the Interface to power down
   internally in the next step.

3. The Interface shall be capable of receiving notification that
   UNIPRO became UPRO_HIBERNATE. The Interface may now perform
   implementation-defined procedures used during shutdown. No
   provision is made within the Greybus Specification to determine
   whether these procedures, if any, are complete, other than the
   delay in the previous step.

4. The :ref:`lifecycles_connection_closure_epilogue` sub-sequence is
   followed. The Closing Connection for that sub-sequence is the
   Control Connection for the other Interface. If the sub-sequence
   fails, this sequence has failed. Otherwise, it has succeeded.

5. The sequence is now complete, and has succeeded or failed.

.. _lifecycles_control_closure_suspend:

Control Connection Closure for suspend
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces, and
   SW-4660 + any sub-tasks track adding module/module connections.

.. note::

   The content in this section is defined under the following assumptions:

   - there is exactly one :ref:`AP Interface
     <hardware-model-ap-module-requirements>` in the Greybus System.

   - The Connection being closed is between that AP Interface and
     another Interface in the System.

   The results if there are multiple AP Interfaces, or in the case of
   non-AP to non-AP Interfaces, are undefined.

.. TODO add an MSC here for the successful case

If an Interface is :ref:`hardware-model-lifecycle-enumerated`, its
Control Connection is established.  The AP can subsequently close the
Control Connection to the Interface.

The following sequence may be used to close the control Connection to
an Interface while the Interface is entering the SUSPENDED state.

Though the AP may follow this sequence at any time, the AP should only
do so if the Interface is ENUMERATED, during the "suspend" Interface
Lifecycle state machine transition, which causes the Interface to exit
the ENUMERATED Lifecycle State as described in
:ref:`lifecycles_suspend`.

If the AP follows this sequence at other times, the results are
undefined.

The following value is used in this sub-sequence:

- The Interface ID of the other Interface is interface_id.

1. The :ref:`lifecycles_connection_closure_prologue` sub-sequence is
   followed. The Closing Connection for that sub-sequence is the
   Control Connection for the other Interface.  If the sub-sequence
   fails, this sequence has failed. Go directly to step 5.

2. The AP shall exchange an :ref:`svc-interface-set-power-mode` with
   the SVC.

   The intf_id field in the request payload shall equal interface_id.
   The tx_mode and rx_mode fields shall both equal
   UNIPRO_HIBERNATE_MODE.

   If the Operation fails, this procedure has failed. Go directly to
   step 5.

   If it succeeds, the SVC shall set the UNIPRO Interface State to
   UPRO_HIBERNATE. The SVC shall wait an implementationed-defined
   duration in this step to allow the Interface to power down
   internally in the next step.

3. The Interface shall be capable of receiving notification that
   UNIPRO became UPRO_HIBERNATE. The Interface may now perform
   implementation-defined procedures used during shutdown.

   The Interface shall have previously been notified that the change
   to UPRO_HIBERNATE denotes suspend rather than power down as
   described below in :ref:`lifecycles_suspend`.

   The Interface shall perform implementation-specific procedures to
   ensure it can be resumed successfully if it remains SUSPENDED, then
   the procedure defined in :ref:`lifecycles_resume` is subsequently
   followed.

4. The :ref:`lifecycles_connection_closure_epilogue` sub-sequence is
   followed. The Closing Connection for that sub-sequence is the
   Control Connection for the other Interface. If the sub-sequence
   fails, this sequence has failed. Otherwise, it has succeeded.

5. The sequence is now complete, and has succeeded or failed.

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
