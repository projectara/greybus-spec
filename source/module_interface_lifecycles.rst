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

When an Interface is TIME_SYNCING, the following Interface States are
possible:

.. include:: lifecycle-states/time-syncing.txt

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
- The Interface ID of the other Interface is interface_id.

1. The AP shall initiate a :ref:`svc-connection-create` to establish the
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

2. The sequence is now complete and has succeeded or failed.

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
   fails, this sequence has failed. If it has failed, go directly to
   step 5.

2. The :ref:`lifecycles_connection_closure_epilogue` sub-sequence is
   followed. The Closing Connection for that sub-sequence is the
   Control Connection for the other Interface. If the sub-sequence
   fails, this sequence has failed. If it has failed, go directly to
   step 5.

3. The AP shall exchange a :ref:`svc-interface-set-power-mode` with
   the SVC.

   The intf_id field in the request payload shall equal interface_id.
   The tx_mode and rx_mode fields shall both equal
   UNIPRO_HIBERNATE_MODE.

   If the Operation fails, this procedure has failed. Go directly to
   step 5.

   If it succeeds, the SVC shall set the UNIPRO Interface State to
   UPRO_HIBERNATE. The SVC shall wait an implementation-defined
   duration in this step to allow the Interface to power down
   internally in the next step.

   If the Operation succeeds, this procedure has succeeded.

4. The Interface shall be capable of receiving notification that
   UNIPRO became UPRO_HIBERNATE. The Interface may now perform
   implementation-defined procedures used during shutdown. No
   provision is made within the Greybus Specification to determine
   whether these procedures, if any, are complete, other than the
   delay in the previous step.

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
   fails, this sequence has failed. If it has failed, go directly to
   step 5.

2. The :ref:`lifecycles_connection_closure_epilogue` sub-sequence is
   followed. The Closing Connection for that sub-sequence is the
   Control Connection for the other Interface. If the sub-sequence
   fails, this sequence has failed. If it has failed, go directly to
   step 5.

3. The AP shall exchange a :ref:`svc-interface-set-power-mode` with
   the SVC.

   The intf_id field in the request payload shall equal interface_id.
   The tx_mode and rx_mode fields shall both equal
   UNIPRO_HIBERNATE_MODE.

   If the Operation fails, this procedure has failed. Go directly to
   step 5.

   If it succeeds, the SVC shall set the UNIPRO Interface State to
   UPRO_HIBERNATE. The SVC shall wait an implementation-defined
   duration in this step to allow the Interface to power down
   internally in the next step.

   If the Operation succeeds, this procedure has suceeded.

4. The Interface shall be capable of receiving notification that
   UNIPRO became UPRO_HIBERNATE. The Interface may now perform
   implementation-defined procedures used during shutdown.

   The Interface shall have previously been notified that the change
   to UPRO_HIBERNATE denotes suspend rather than power down as
   described below in :ref:`lifecycles_suspend`.

   The Interface shall perform implementation-specific procedures to
   ensure it can be resumed successfully if it remains SUSPENDED, then
   the procedure defined in :ref:`lifecycles_resume` is subsequently
   followed.

5. The sequence is now complete, and has succeeded or failed.

.. _lifecycles_boot_enumeration:

Boot and Enumeration
""""""""""""""""""""

This section describes the procedures required to initialize an
:ref:`hardware-model-lifecycle-attached` Interface, putting it in the
:ref:`hardware-model-lifecycle-activated` Lifecycle State.

If an ACTIVATED :ref:`Interface State's
<hardware-model-interface-states>` :ref:`hardware-model-intf-type` is
IFT_GREYBUS, the Interface can be enumerated, as outlined in
:ref:`hardware-model-lifecycle-enumerated`. The enumeration procedure
under these conditions is also defined in this section.

.. _lifecycles_boot:

Boot (ATTACHED → ACTIVATED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces

.. note::

   The content in this section is defined under the assumption that
   there is exactly one :ref:`AP Interface
   <hardware-model-ap-module-requirements>` in the Greybus System.

   The results if there are multiple AP Interfaces are undefined.

.. TODO add an MSC here for the successful case

The following procedure can be initiated by the AP when an Interface
is ATTACHED, in order to attempt to follow the "boot" transition from
ATTACHED to ACTIVATED.

To perform this procedure, the following conditions shall hold.

- The AP Interface and SVC shall have established a Connection
  implementing the :ref:`svc-protocol`. This is the SVC Connection in
  this procedure.

- An Interface shall be provided, whose Interface Lifecycle State is
  ATTACHED. No other actions shall have been taken to affect the
  Interface's Lifecycle State or its corresponding Interface State
  since the Interface became ATTACHED, except as defined in this
  procedure.

If these conditions do not all hold, the procedure shall not be
followed. The results of following this procedure in this case are
undefined.

The following value is used in this procedure:

- The Interface ID of the Interface being activated is interface_id.

1. The AP shall exchange an :ref:`svc-interface-vsys-enable` with the
   SVC. The intf_id field in the request payload shall equal
   interface_id.

   If the Operation fails, this procedure has failed. Go to step 8.

2. The AP shall exchange an :ref:`svc-interface-refclk-enable` with
   the SVC. The intf_id field in the request payload shall equal
   interface_id.

   If the Operation fails, this procedure has failed. Go to step 7.

3. The AP shall exchange an :ref:`svc-interface-unipro-enable` with
   the SVC. The intf_id field in the request payload shall equal
   interface_id.

   If the Operation fails, this procedure has failed. Go to step 6.

4. The AP shall exchange an :ref:`svc-interface-activate` with the
   SVC. The intf_id field in the request payload shall equal
   interface_id.

   If the Operation fails, this procedure has failed. Go to step 5.

   If the Operation succeeds, this procedure has succeeded. The
   Interface is now ACTIVATED. Go to step 8.

5. The AP shall exchange a :ref:`svc-interface-unipro-disable` with
   the SVC. The intf_id field in the request payload shall equal
   interface_id.

6. The AP shall exchange a :ref:`svc-interface-refclk-disable` with
   the SVC. The intf_id field in the request payload shall equal
   interface_id.

7. The AP shall exchange a :ref:`svc-interface-vsys-disable` with the
   SVC. The intf_id field in the request payload shall equal
   interface_id.

8. The procedure is complete and has succeeded or failed. If the
   procedure failed and all of the steps 5, 6, and 7 which were
   reached succeeded, the Interface is now ATTACHED.

.. _lifecycles_enumerate:

Enumerate (ACTIVATED → ENUMERATED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces

.. note::

   The content in this section is defined under the assumption that
   there is exactly one :ref:`AP Interface
   <hardware-model-ap-module-requirements>` in the Greybus System.

   The results if there are multiple AP Interfaces are undefined.

.. TODO add an MSC here for the successful case

The following procedure can be initiated by the AP when an Interface
is ACTIVATED and its :ref:`hardware-model-intf-type` is IFT_GREYBUS,
in order to attempt to follow the "enumerate" transition from
ACTIVATED to ENUMERATED.

To perform this procedure, the following conditions shall hold.

- The AP Interface and SVC shall have established a Connection
  implementing the :ref:`svc-protocol`. This is the SVC Connection in
  this procedure.

- An Interface shall be provided, whose Interface Lifecycle State is
  ACTIVATED, and whose INTF_TYPE is IFT_GREYBUS. No other actions
  shall have been taken to affect the Interface's Lifecycle State or
  its corresponding Interface State since the Interface became
  ACTIVATED.

If these conditions do not all hold, the procedure shall not be
followed. The results of following this procedure in this case are
undefined.

The following values are used in this procedure:

- The AP Interface Device ID is ap_device_id.
- The Interface ID of the Interface being enumerated is interface_id.

.. TODO add an MSC here for the successful case

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
   failed. Go directly to step 9.

2. The AP shall initiate a :ref:`svc-route-create` to establish a
   route within the :ref:`Switch <glossary-switch>` between an AP
   Interface and the Interface.

   The intf1_id and dev1_id fields in the request payload shall
   respectively equal ap_interface_id and ap_device_id. The intf2_id
   field in the request payload shall equal interface_id.  The dev2_id
   field in the request payload shall have the same value as the
   device_id field from step 1.

   If this Operation fails, the sequence is complete and has
   failed. Go directly to step 9.

3. The sequence to establish a Control Connection to the Interface
   described in :ref:`lifecycles_control_establishment` shall be
   followed.

   If the sequence fails, this procedure has failed. Go to step 8.

4. The AP shall exchange a :ref:`control-get-manifest-size` via the
   Control Connection. If the Operation is successful, the value of
   the manifest_size field in the response payload is
   interface_manifest_size.

   If the Operation fails, this procedure has failed. Go to step 7.

5. The AP shall exchange a :ref:`control-get-manifest` via the Control
   Connection. If the Operation is successful, the Manifest's value is
   interface_manifest.

   If the Operation fails, this procedure has failed. Go to step 7.

6. The AP shall perform implementation-defined procedures to parse the
   :ref:`components of the Manifest <manifest-description>`.

   The Interface is now ENUMERATED. Go to step 9.

7. The AP shall attempt to close the Control Connection to the
   Interface as described in
   :ref:`lifecycles_control_closure_power_down`. Regardless of the
   Operation's success or failure, go to the next step.

8. The AP shall perform the procedure described in below in
   :ref:`lifecycles_early_power_down`. If the Early Power Down procedure
   succeeds, and step 7 succeeded if it was reached, the Interface is
   :ref:`hardware-model-lifecycle-off`. Its Interface State's INTF_TYPE
   is still IFT_GREYBUS, and its ORDER has not changed its value
   since before this Enumerate procedure was followed.

9. The procedure is complete and has succeeded or failed.

If the Interface is now ENUMERATED, additional Connections to the
Interface may be established using the sequence defined in
:ref:`lifecycles_connection_establishment`, and closed using the
sequence defined in :ref:`lifecycles_connection_closure`; if no errors
occur, the Interface remains ENUMERATED.

.. _lifecycles_power_management:

Power Management
""""""""""""""""

.. _lifecycles_suspend:

Suspend (ENUMERATED → SUSPENDED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces, and
   SW-4660 + any sub-tasks track adding module/module connections.

.. note::

   The content in this section is defined under the following assumptions:

   - there is exactly one :ref:`AP Interface
     <hardware-model-ap-module-requirements>` in the Greybus System.

   - The Non-Control Connections given below are each between that AP
     Interface and another Interface in the System.

   The results if there are multiple AP Interfaces, or in the case of
   non-AP to non-AP Interfaces, are undefined.

.. TODO add an MSC here for the successful case

The following procedure can be initiated by the AP when an Interface
is ENUMERATED, in order to attempt to follow the "suspend" transition
from ENUMERATED to SUSPENDED.

To perform this procedure, the following conditions shall hold.

- The AP Interface and SVC shall have established a Connection
  implementing the :ref:`svc-protocol`. This is the SVC Connection in
  this procedure.

- An Interface shall be provided, whose Interface Lifecycle State is
  ENUMERATED.

- Zero or more additional Non-Control Connections shall be provided,
  which comprise all such established Connections involving the
  Interface, and shall each have been established by following the
  sequence defined in :ref:`lifecycles_connection_establishment`.

If these conditions do not all hold, the procedure shall not be
followed. The results of following this procedure in this case are
undefined.

The following values are used in this procedure:

- The AP Interface's ID is ap_interface_id.
- The Interface ID of the Interface being suspended is interface_id.

.. XXX input from the power management team is required to better
   define the error handling here.

.. XXX input from the power management team is required to add calls
   to other proposed Control Operations which act on the Interface's
   Bundles and the Interface itself in the right places when those
   proposed operations are merged.

1. The AP Interface and the Interface being suspended shall exchange
   Protocol-specific Operations which inform the Interface the
   subsequent steps in this Procedure shall be performed next.

2. The sequence defined :ref:`lifecycles_connection_closure` shall be
   followed to attempt to close all of the provided Non-Control
   Connections.

   If any attempt fails, this procedure has failed. The results are
   undefined.

3. The sequence defined in
   :ref:`lifecycles_control_closure_suspend` shall be followed to
   close the Control Connection to the Interface.

   If the sequence fails, this procedure has failed. The results are
   undefined.

4. The AP shall exchange an :ref:`svc-route-destroy` with the SVC. The
   intf1_id and intf2_id fields in the request payload shall
   respectively equal ap_interface_id and interface_id.

   If the Operation fails, this procedure has failed. The results are
   undefined.

5. The AP shall exchange an :ref:`svc-interface-set-power-mode` with
   the SVC.

   The intf_id field in the request payload shall equal interface_id.
   The tx_mode and rx_mode fields shall both equal
   UNIPRO_HIBERNATE_MODE.

   If the Operation fails, this procedure has failed. The results are
   undefined.

   If it succeeds, the SVC shall set the UNIPRO Interface State to
   UPRO_HIBERNATE. The SVC shall wait an implementation-defined
   duration in this step to allow the Interface to enter a low-power
   state in the next step.

6. The Interface shall be capable of receiving notification that
   UNIPRO became UPRO_HIBERNATE. The Interface shall now enter an
   implementation-defined suspend state, during which it should
   attempt to draw minimal power from the Frame.

7. The AP shall exchange an :ref:`svc-interface-unipro-disable` with
   the SVC.  The intf_id field in the request payload shall equal
   interface_id.

   If the Operation fails, this procedure has failed. The results are
   undefined.

8. The AP shall exchange an :ref:`svc-interface-refclk-disable` with
   the SVC.  The intf_id field in the request payload shall equal
   interface_id.

   If the Operation succeeds, this procedure has succeeded.

   If the Operation fails, this procedure has failed. The results are
   undefined.

9. This procedure is now complete, and has either succeeded or
   failed. If it succeeded, the Interface is now SUSPENDED.

.. _lifecycles_resume:

Resume (SUSPENDED → ENUMERATED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces, and
   SW-4660 + any sub-tasks track adding module/module connections.

.. note::

   The content in this section is defined under the following assumptions:

   - there is exactly one :ref:`AP Interface
     <hardware-model-ap-module-requirements>` in the Greybus System.

   - The Non-Control Connections given below were each between that AP
     Interface and another Interface in the System.

   The results if there are multiple AP Interfaces, or in the case of
   non-AP to non-AP Interfaces, are undefined.

.. TODO add an MSC here for the successful case

The following procedure can be initiated by the AP when an Interface
is SUSPENDED, in order to attempt to follow the "resume" transition
from SUSPENDED to ENUMERATED.

To perform this procedure, the following conditions shall hold.

- The AP Interface and SVC shall have established a Connection
  implementing the :ref:`svc-protocol`. This is the SVC Connection in
  this procedure.

- An Interface shall be provided, whose Interface Lifecycle State is
  SUSPENDED. The Interface shall have transitioned to the SUSPENDED
  Lifecycle State by following the suspend procedure defined in
  :ref:`lifecycles_suspend`.

- Zero or more additional Non-Control Connections shall be provided,
  which comprise all such established Connections involving the
  Interface when the suspend procedure was followed.

- A Device ID value shall be provided, which is the SUSPENDED
  Interface's Device ID previously assigned Device ID used to destroy
  any Routes to the Interface as defined in :ref:`lifecycles_suspend`.

- A CPort ID value shall be provided, which was the AP CPort ID which
  was previously used for the Interface Control Connection before the
  Interface was suspended.

If these conditions do not all hold, the procedure shall not be
followed. The results of following this procedure in this case are
undefined.

The following values are used in this procedure:

- The AP Interface's ID is ap_interface_id.
- The AP Interface Device ID is ap_device_id.
- The Provided AP CPort ID used for the Interface Control Connection
  is ap_cport_id.
- The Interface ID of the Interface being resumed is interface_id.
- The provided Device ID of the Interface being resumed is
  interface_device_id.

.. XXX input from the power management team is required to better
   define the error handling here.

.. XXX input from the power management team is required to add calls
   to other proposed Control Operations which act on the Interface's
   Bundles and the Interface itself in the right places when those
   proposed operations are merged.

1. The AP shall exchange an :ref:`svc-interface-refclk-enable` with the
   SVC. The intf_id field in the request payload shall equal
   interface_id.

   If the Operation fails, this procedure has failed. The results are
   undefined.

2. The AP shall exchange an :ref:`svc-interface-unipro-enable` with the
   SVC. The intf_id field in the request payload shall equal
   interface_id.

   If the Operation fails, this procedure has failed. The results are
   undefined.

3. The AP shall exchange an :ref:`svc-interface-resume` with the
   SVC. The intf_id field in the request payload shall equal
   interface_id.

   If the Operation fails, this procedure has failed. The results are
   undefined.

4. The AP shall exchange an :ref:`svc-route-create` with the SVC.  The
   intf1_id and dev1_id fields in the request payload shall
   respectively equal ap_interface_id and ap_device_id. The intf2_id
   and dev2_id fields in the request payload shall respectively equal
   interface_id and interface_device_id.

   If the Operation fails, this procedure has failed. The results are
   undefined.

5. The sequence to establish a Control Connection to the Interface
   described in :ref:`lifecycles_control_establishment` shall be
   followed.

   If the sequence fails, this procedure has failed.  The results are
   undefined.

   If it succeeds, the procedure has succeeded. The Interface is
   ENUMERATED. The requirements specified in
   :ref:`svc-interface-resume` guarantee that the Interface has the
   same Manifest defined as that it made available to the AP Interface
   the most recent time it was ENUMERATED.

6. The procedure is complete and has succeeded or failed.

.. _lifecycles_power_down:

Power Down (ENUMERATED → OFF)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces, and
   SW-4660 + any sub-tasks track adding module/module connections.

.. note::

   The content in this section is defined under the following assumptions:

   - there is exactly one :ref:`AP Interface
     <hardware-model-ap-module-requirements>` in the Greybus System.

   - The Non-Control Connections given below are each between that AP
     Interface and another Interface in the System.

   The results if there are multiple AP Interfaces, or in the case of
   non-AP to non-AP Interfaces, are undefined.

.. TODO add an MSC here for the successful case

The following procedure can be initiated by the AP when an Interface
is ENUMERATED, in order to attempt to follow the "suspend" transition
from ENUMERATED to SUSPENDED.

To perform this procedure, the following conditions shall hold.

- The AP Interface and SVC shall have established a Connection
  implementing the :ref:`svc-protocol`. This is the SVC Connection in
  this procedure.

- An Interface shall be provided, whose Interface Lifecycle State is
  ENUMERATED.

- Zero or more additional Non-Control Connections shall be provided,
  which comprise all such established Connections involving the
  Interface, and shall each have been established by following the
  sequence defined in :ref:`lifecycles_connection_establishment`.

If these conditions do not all hold, the procedure shall not be
followed. The results of following this procedure in this case are
undefined.

The following values are used in this procedure:

- The AP Interface's ID is ap_interface_id.
- The Interface ID of the Interface being powered off is interface_id.

.. XXX input from the power management team is required to better
   define the error handling here.

.. XXX input from the power management team is required to add calls
   to other proposed Control Operations which act on the Interface's
   Bundles and the Interface itself in the right places when those
   proposed operations are merged.

1. The sequence defined :ref:`lifecycles_connection_closure` shall be
   followed to attempt to close all of the provided Non-Control
   Connections.

   If any attempt fails, this procedure has failed. The results are
   undefined.

2. The sequence defined in
   :ref:`lifecycles_control_closure_power_down` shall be followed to
   close the Control Connection to the Interface.

   If the sequence fails, this procedure has failed. The results are
   undefined.

3. The AP shall exchange a :ref:`svc-route-destroy` with the SVC. The
   intf1_id and intf2_id fields in the request payload shall
   respectively equal ap_interface_id and interface_id.

   If the Operation fails, this procedure has failed. The results are
   undefined.

4. The AP shall exchange a :ref:`svc-interface-set-power-mode` with
   the SVC.

   The intf_id field in the request payload shall equal interface_id.
   The tx_mode and rx_mode fields shall both equal
   UNIPRO_HIBERNATE_MODE.

   If the Operation fails, this procedure has failed. The results are
   undefined.

   If it succeeds, the SVC shall set the UNIPRO Interface State to
   UPRO_HIBERNATE. The SVC shall wait an implementation-defined
   duration in this step to allow the Interface to power down in the
   next step.

5. The AP shall exchange an :ref:`svc-interface-unipro-disable` with
   the SVC to disable UNIPRO within the Switch.

   If the Operation fails, this procedure has failed. The results are
   undefined.

7. The AP shall exchange an :ref:`svc-interface-refclk-disable` with
   the SVC.  The intf_id field in the request payload shall equal
   interface_id.

   If the Operation succeeds, this procedure has succeeded.

   If the Operation fails, this procedure has failed. The results are
   undefined.

7. The AP shall exchange an :ref:`svc-interface-vsys-disable` with
   the SVC.  The intf_id field in the request payload shall equal
   interface_id.

   If the Operation succeeds, this procedure has succeeded.

   If the Operation fails, this procedure has failed. The results are
   undefined.


8. This procedure is now complete, and has either succeeded or
   failed. If it succeeded, the Interface is now OFF.

.. _lifecycles_reboot:

Reboot (OFF → ACTIVATED)
~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces

.. note::

   The content in this section is defined under the assumption that
   there is exactly one :ref:`AP Interface
   <hardware-model-ap-module-requirements>` in the Greybus System.

   The results if there are multiple AP Interfaces are undefined.

.. TODO add an MSC here for the successful case

The following procedure can be initiated by the AP when an Interface
is OFF, in order to attempt to follow the "reboot" transition from
OFF to ACTIVATED.

To perform this procedure, the following conditions shall hold.

- The AP Interface and SVC shall have established a Connection
  implementing the :ref:`svc-protocol`. This is the SVC Connection in
  this procedure.

- An Interface shall be provided, whose Interface Lifecycle State is
  OFF.

If these conditions do not all hold, the procedure shall not be
followed. The results of following this procedure in this case are
undefined.

Other than the initial state which led to the transition, this
procedure is otherwise identical to that defined in
:ref:`lifecycles_boot`.

The following value is used in this procedure:

- The Interface ID of the Interface being rebooted is interface_id.

1. The AP shall exchange an :ref:`svc-interface-vsys-enable` with the
   SVC. The intf_id field in the request payload shall equal
   interface_id.

   If the Operation fails, this procedure has failed. Go to step 8.

2. The AP shall exchange an :ref:`svc-interface-refclk-enable` with
   the SVC. The intf_id field in the request payload shall equal
   interface_id.

   If the Operation fails, this procedure has failed. Go to step 7.

3. The AP shall exchange an :ref:`svc-interface-unipro-enable` with
   the SVC. The intf_id field in the request payload shall equal
   interface_id.

   If the Operation fails, this procedure has failed. Go to step 6.

4. The AP shall exchange an :ref:`svc-interface-activate` with the
   SVC. The intf_id field in the request payload shall equal
   interface_id.

   If the Operation fails, this procedure has failed. Go to step 5.

   If the Operation succeeds, this procedure has succeeded. The
   Interface is now ACTIVATED. Go to step 8.

5. The AP shall exchange a :ref:`svc-interface-unipro-disable` with
   the SVC. The intf_id field in the request payload shall equal
   interface_id.

6. The AP shall exchange a :ref:`svc-interface-refclk-disable` with
   the SVC. The intf_id field in the request payload shall equal
   interface_id.

7. The AP shall exchange a :ref:`svc-interface-vsys-disable` with the
   SVC. The intf_id field in the request payload shall equal
   interface_id.

8. The procedure is complete and has succeeded or failed. If the
   procedure failed and all of the steps 5, 6, and 7 which were
   reached succeeded, the Interface is now OFF.

.. _lifecycles_eject:

Eject (OFF → DETACHED)
""""""""""""""""""""""

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces

.. note::

   The content in this section is defined under the assumption that
   there is exactly one :ref:`AP Interface
   <hardware-model-ap-module-requirements>` in the Greybus System.

   The results if there are multiple AP Interfaces are undefined.

.. TODO add an MSC here for the successful case

The following procedure can be initiated by the AP when an Interface
is OFF, in order to attempt to follow the "eject" transition from
OFF to DETACHED.

To perform this procedure, the following conditions shall hold.

- The AP Interface and SVC shall have established a Connection
  implementing the :ref:`svc-protocol`. This is the SVC Connection in
  this procedure.

- A Module shall be provided which is MODULE_ATTACHED.

- The Interface Lifecycle State is OFF for all Interfaces in the
  Module.

If these conditions do not all hold, the procedure shall not be
followed. The results of following this procedure in this case are
undefined.

The following value is used in this procedure:

- The Interface ID of the Primary Interface to the Module being
  ejected is primary_interface_id.

1. If the AP receives an :ref:`svc-module-removed` Request from the
   SVC with primary_intf_id field equal to primary_interface_id, the
   procedure has succeeded. Immediately go to to step 4.

2. The AP shall exchange an :ref:`svc-module-eject` with the SVC.
   The primary_intf_id field in the request payload shall equal
   primary_interface_id.

   If this Operation fails, the procedure has failed. Go to step 4.

3. After the SVC Interface Eject Response is received, the AP shall
   start a timer, for an implementation-defined duration.

   If the AP detects the timer has expired and has not received an SVC
   Module Removed Request from the SVC with primary_intf_id field
   equal to primary_interface_id, the procedure has failed. Go to the
   next step.

4. The procedure is now complete and has succeeded or failed. If the
   procedure succeeded, all Interfaces formerly present in the removed
   Module are now DETACHED. If the procedure failed, the Interfaces
   are all still OFF, and the Module is still MODULE_ATTACHED, and the
   Interfaces are all still OFF.

.. _lifecycles_mode_switching:

Mode Switching
""""""""""""""

.. _lifecycles_ms_enter:

Mode Switch Enter (ENUMERATED → MODE_SWITCHING)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces, and
   SW-4660 + any sub-tasks track adding module/module connections.

.. note::

   The content in this section is defined under the following assumptions:

   - there is exactly one :ref:`AP Interface
     <hardware-model-ap-module-requirements>` in the Greybus System.

   - The Non-Control Connections given below are each between that AP
     Interface and another Interface in the System.

   The results if there are multiple AP Interfaces, or in the case of
   non-AP to non-AP Interfaces, are undefined.

.. TODO add an MSC here for the successful case

The following procedure can be initiated by the AP when an Interface
is ENUMERATED, in order to attempt to follow the "ms_enter" transition
from ENUMERATED to MODE_SWITCHING.

To perform this procedure, the following conditions shall hold.

- The AP Interface and SVC shall have established a Connection
  implementing the :ref:`svc-protocol`. This is the SVC Connection in
  this procedure.

- An Interface shall be provided, whose Interface Lifecycle State is
  ENUMERATED.

- Zero or more additional Non-Control Connections shall be provided,
  which comprise all such established Connections involving the
  Interface, and shall each have been established by following the
  sequence defined in :ref:`lifecycles_connection_establishment`.

If these conditions do not all hold, the procedure shall not be
followed. The results of following this procedure in this case are
undefined.

The following values are used in this procedure:

- The AP Interface's ID is ap_interface_id.
- The Interface ID of the Interface entering MODE_SWITCHING is interface_id.

.. XXX input from the Greybus core and firmware update teams is
   required to better define the error handling here.

.. XXX input from the power management teams is required to add calls
   to other proposed Control Operations which act on the Interface's
   Bundles and the Interface itself in the right places when those
   proposed operations are merged.

1. Through Protocol-specific means, the AP and Interface shall
   establish that the remaining steps in the Mode Switch Enter
   procedure shall be followed.

2. The sequence defined in :ref:`lifecycles_connection_closure` shall be
   followed to attempt to close all of the provided Non-Control
   Connections.

   If any attempt fails, this procedure has failed. The results are
   undefined.

3. The sequence defined in :ref:`lifecycles_control_closure_ms_enter`
   shall be followed to inform the Interface its Control Connection is
   closing and it is entering MODE_SWITCHING.

   If the sequence succeeds, this procedure has succeeded. The
   Interface is MODE_SWITCHING.

   If the sequence fails, this procedure has failed. The results are
   undefined.

4. The procedure is now complete and has either succeeded or failed.

.. _lifecycles_ms_exit:

Mode Switch Exit (MODE_SWITCHING → ENUMERATED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. SW-4659 + any sub-tasks track adding multiple AP Interfaces, and
   SW-4660 + any sub-tasks track adding module/module connections.

.. note::

   The content in this section is defined under the following assumptions:

   - there is exactly one :ref:`AP Interface
     <hardware-model-ap-module-requirements>` in the Greybus System.

   - The Non-Control Connections given below were each between that AP
     Interface and another Interface in the System.

   The results if there are multiple AP Interfaces, or in the case of
   non-AP to non-AP Interfaces, are undefined.

.. TODO add an MSC here for the successful case

The following procedure can be initiated by the Interface when it is
is MODE_SWITCHING, in order to attempt to follow the "ms_exit"
transition from MODE_SWITCHING to ENUMERATED.

To perform this procedure, the following condition shall hold.

- An Interface shall be provided, whose Interface Lifecycle State is
  MODE_SWITCHING. The Interface shall have transitioned to the
  MODE_SWITCHING Lifecycle State by following the ms_enter procedure
  defined in :ref:`lifecycles_ms_enter`.

- Another value, ap_cport_id, shall also be provided. The AP Interface
  shall contain a CPort with CPort ID ap_cport_id. This CPort on the
  AP Interface shall not be part of an established |unipro|
  connection.

If these conditions do not all hold, the procedure shall not be
followed. The results of following this procedure in this case are
undefined.

The following values are used in this procedure:

- The AP Interface ID is ap_interface_id.
- The Interface ID of the Interface which is MODE_SWITCHING is
  interface_id.

.. XXX input from the firmware update team is required to better
   define the error handling here if it can be improved.

1. The Interface shall conclude any implementation-specific procedures
   needed while it is in the MODE_SWITCHING Lifecycle State, and write
   MAILBOX as described in :ref:`control-mode-switch`.

2. The SVC shall detect this write, and exchange an
   :ref:`svc-interface-mailbox-event` Operation with the AP.
   The intf_id field in the request payload shall equal interface_id.

   If the Operation is not successful, this procedure has failed. The
   results are undefined.

3. The :ref:`lifecycles_connection_closure_epilogue` sub-sequence is
   followed. The Closing Connection for that sub-sequence is the
   Control Connection to the Module which was MODE_SWITCHING.

   If the sub-sequence succeeds, the Control Connection to the
   Interface is now closed.

   If the sub-sequence fails, this procedure has failed. The results
   are undefined.

4. The sequence to establish a Control Connection to the Interface
   described in :ref:`lifecycles_control_establishment` shall be
   followed.

   If the sequence fails, this procedure has failed. The results are
   undefined.

5. The AP shall exchange a :ref:`control-get-manifest-size` via the
   Control Connection. If the Operation is successful, the value of
   the manifest_size field in the response payload is
   interface_manifest_size.

   If the Operation fails, this procedure has failed. The results are
   undefined.

6. The AP shall exchange a :ref:`control-get-manifest` via the Control
   Connection. If the Operation is successful, the Manifest's value is
   interface_manifest.

   If the Operation fails, this procedure has failed. The results are
   undefined.

7. The AP shall perform implementation-defined procedures to parse the
   :ref:`components of the Manifest <manifest-description>`.

   The procedure is now complete. The Interface is ENUMERATED once
   more.

No special provision is made within the Greybus Specification for
recovery from failure. The AP and Interface may use implementation- or
protocol-specific timeouts to detect errors and attempt to recover.

.. _lifecycles_error_handling:

Error Handling
""""""""""""""

.. _lifecycles_early_eject:

Early Eject (ATTACHED → DETACHED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. TODO add an MSC here for the successful case

.. _lifecycles_early_power_down:

Early Power Down (ACTIVATED → OFF)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. TODO add an MSC here for the successful case

Make sure cleanup when jumping from failure to enumerate is covered:

- tear down routes
- destroy Device ID
- unipro, refclk, vsys from activation -> off

.. _lifecycles_mode_switch_fail:

Mode Switch Fail (MODE_SWITCHING → ACTIVATED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. TODO add an MSC here for the successful case

.. _lifecycles_forcible_removal:

Forcible Removal (Any → DETACHED)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. TODO add an MSC here for the successful case
