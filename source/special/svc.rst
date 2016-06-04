.. _svc-protocol:

SVC Protocol
------------

The AP Module is required to provide a CPort that uses the SVC
Protocol on an Interface. The AP Module does not have a control
connection, but instead implements the SVC protocol using the
reserved Control CPort ID. At initial power-on, the SVC sets up a
|unipro| connection from one of its CPorts to the AP Module
Interface's SVC CPort.

The SVC has direct control over and responsibility for the :ref:`Frame
<glossary-frame>`, including detecting when modules are present,
configuring the |unipro| switch, powering module Interfaces, providing
the frame-time and attaching and detaching modules.  The AP Module
controls the Frame through operations sent over the SVC connection.
And the SVC informs the AP Module about Frame events (such as the
presence of a new module, or notification of changing power
conditions).

Conceptually, the operations in the Greybus SVC Protocol are:

.. c:function:: int ping(void);

    See :ref:`greybus-protocol-ping-operation`.

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Refer to :ref:`greybus-protocol-version-operation`.

.. c:function:: int svc_hello(u16 frame_generation, u16 frame_variant, u8 intf_id);

    This Operation is used at initial power-on, sent by the SVC to
    inform the AP of its environment. After version negotiation,
    it is the next operation initiated by the SVC sent at
    initialization. The descriptor describes details of the Frame's
    environment such as number, placement, and features of interface
    blocks, etc.

.. c:function:: int dme_peer_get(u8 intf_id, u16 attribute, u16 selector, u16 *result_code, u32 *value);

    This Operation is used by the AP to direct the SVC to perform a
    |unipro| DME peer get on its behalf. The SVC returns the value
    of the DME attribute requested.

.. c:function:: int dme_peer_set(u8 intf_id, u16 attribute, u16 selector, u32 value, u16 *result_code);

    This Operation is used by the AP to direct the SVC to perform a
    |unipro| DME peer set on its behalf.

.. c:function:: int route_create(u8 intf1_id, u8 dev1_id, u8 intf2_id, u8 dev2_id);

    This Operation is used by the AP to direct the SVC to create
    a route for |unipro| traffic between two interfaces.

.. c:function:: int route_destroy(u8 intf1_id, u8 intf2_id);

    This Operation is used by the AP to direct the SVC to destroy
    a route for |unipro| traffic between two interfaces.

.. c:function:: int intf_device_id(u8 intf_id, u8 device_id);

    This operation is used by the AP Module to request that the SVC
    associate a Device ID with the given Interface.

.. c:function:: int intf_hotplug(u8 intf_id, u32 ddbl1_mfr_id, u32 ddbl1_prod_id, u32 ara_vend_id, u32 ara_prod_id, u64 serial_number);

    This operation is deprecated, and should not be used in new designs.
    See :ref:`lifecycles_boot` and :ref:`lifecycles_ms_exit`.

.. c:function:: int intf_hotunplug(u8 intf_id);

    This operation is deprecated, and should not be used in new designs.
    See the :ref:`svc-module-removed`.

.. c:function:: int intf_reset(u8 intf_id);

    The SVC sends this to inform the AP Module that an active
    Interface needs to be reset.  This might happen when the SVC has
    detected an error on the link, for example.

.. XXX This is nebulous at this point; my intention is to handle the
.. XXX case where a |unipro| "link down" indicates that a link *was*
.. XXX down at some point--since we have no way to discover this
.. XXX immediately.

.. c:function:: int intf_set_power_mode(u8 intf_id, struct unipro_link_cfg *cfg);

    The AP sends this to the SVC to request that a |unipro| power mode
    change be applied to an Interface.

.. c:function:: int connection_create(u8 intf1_id, u16 cport1_id, u8 intf2_id, u16 cport2_id, u8 tc, u8 flags);

    The AP Module uses this operation to request the SVC set up a
    |unipro| connection between CPorts on two Interfaces.

.. c:function:: int connection_destroy(u8 intf1_id, u16 cport1_id, u8 intf2_id, u16 cport2_id);

    The AP Module uses this operation to request the SVC tear down a
    previously created connection.

.. c:function:: int timesync_enable(u8 count, u64 frame_time, u32 strobe_delay, u32 refclk);

    The AP Module uses this operation to request the SVC to enable frame-time
    tracking.

.. c:function:: int timesync_disable(void);

    The AP Module uses this operation to request the SVC stop tracking
    frame-time. The SVC will immediately stop tracking frame-time.

.. c:function:: int timesync_authoritative(void);

    The AP Module uses this operation to request the SVC to send the
    authoritative frame-time at each TIME_SYNC strobe.

.. c:function:: int timesync_wake_pins_acquire(u32 strobe_mask);

    The AP Module uses this operation to request the SVC to take control
    of a bit-mask of wake lines associated with the bit-mask of
    Interface IDs specified by the strobe_mask parameter. This is done
    to establish an initial state on the relevant wake lines prior to
    generating timesync related events.

.. c:function:: int timesync_wake_pins_release(void);

    The AP Module uses this operation to request the SVC to release
    any wake lines currently reserved for time-sync operations.

.. c:function:: int timesync_ping(u64 *frame_time);

    The AP Module uses this operation to request the SVC to generate a single
    pulse on a bit-mask of wake lines communicated to SVC by a prior
    timesync_wake_pins_acquire() operation. SVC will return the authoritative
    frame-time of the timesync_ping() to the AP Module in the response phase of
    the operation.

.. c:function:: int module_eject(u8 primary_intf_id);

    The AP Module uses this operation to request the SVC to perform
    the necessary action to eject a Module having the given primary
    interface id.

.. c:function:: int key_event(u16 key_code, u8 key_event);

    The SVC sends this to inform the AP that a key with a specific code has
    generated an event.

.. c:function:: int pwrmon_rail_count_get(u8 *rail_count);

    The AP uses this operation to retrieve the number of power rails
    for which power measurements are available.

.. c:function:: int pwrmon_rail_names_get(u8 **rails_buf);

    The AP uses this operation to retrieve the list of names of all
    supported power rails.

.. c:function:: int pwrmon_sample_get(u8 rail_id, u8 type, u8 *result, u32 *measurement);

    The AP uses this operation to retrieve a single measurement
    (current, voltage or power) for a single rail.

.. c:function:: int pwrmon_intf_sample_get(u8 intf_id, u8 type, u8 *result, u32 *measurement);

    The AP uses this operation to retrieve a single measurement
    (current, voltage or power) for the specified interface.

.. c:function:: int power_down(void);

    The AP uses this operation to power down the SVC and all the devices it
    controls.

.. c:function:: int connection_quiescing(u8 intf1_id, u16 cport1_id, u8 intf2_id, u16 cport2_id);

    The AP uses this operation to notify the SVC that a connection
    being torn down is quiescing.

.. c:function:: int module_inserted(u8 primary_intf_id, u8 intf_count, u16 flags);

    The SVC uses this operation to notify the AP Module of the
    presence of a newly inserted Module.  It sends the request after
    it has determined the size and position of the Module in the
    Frame.

.. c:function:: int module_removed(u8 primary_intf_id);

    The SVC uses this operation to notify the AP Module that a
    Module that was previously the subject of a Greybus SVC Module

.. c:function:: int intf_vsys_enable(u8 intf_id, u8 *result);

   The AP uses this Operation to request the SVC to set Interface
   State intf_id's :ref:`hardware-model-vsys` to V_SYS_ON.

.. c:function:: int intf_vsys_disable(u8 intf_id, u8 *result);

   The AP uses this Operation to request the SVC to set Interface
   State intf_id's :ref:`hardware-model-vsys` to V_SYS_OFF.

.. c:function:: int intf_refclk_enable(u8 intf_id, u8 *result);

   The AP uses this Operation to request the SVC to set Interface
   State intf_id's :ref:`hardware-model-refclk` to REFCLK_ON.

.. c:function:: int intf_refclk_disable(u8 intf_id, u8 *result);

   The AP uses this Operation to request the SVC to set Interface
   State intf_id's :ref:`hardware-model-refclk` to REFCLK_OFF.

.. c:function:: int intf_unipro_enable(u8 intf_id, u8 *result);

   The AP uses this Operation to request the SVC to set Interface
   State intf_id's :ref:`hardware-model-unipro` to UPRO_DOWN.

.. c:function:: int intf_unipro_disable(u8 intf_id, u8 *result);

   The AP uses this Operation to request the SVC to set Interface
   State intf_id's :ref:`hardware-model-unipro` to UPRO_OFF.

.. c:function:: int intf_activate(u8 intf_id, u8 *intf_type);

   The AP uses this Operation to request that the SVC attempt
   to activate an Interface for communication via Greybus.

.. c:function:: int intf_resume(u8 intf_id);

   The AP uses this Operation to request that the SVC attempt to
   resume an Interface which is in a low power mode into a state where
   it can again communicate via Greybus.

.. c:function:: int intf_mailbox_event(u8 intf_id, u16 result_code, u32 mailbox);

   The SVC uses this Operation to inform the AP that an Interface
   State's :ref:`hardware-model-mailbox` has changed value.

Greybus SVC Operations
^^^^^^^^^^^^^^^^^^^^^^

All SVC Operations are contained within a Greybus SVC request
message. Every SVC request results in a matching response.  The
request and response messages for each SVC Operation are defined
below.

Table :num:`table-svc-operation-type` defines the Greybus SVC
Protocol Operation types and their values. Both the request type and
response type values are shown.

.. figtable::
    :nofig:
    :label: table-svc-operation-type
    :caption: SVC Operation Types
    :spec: l l l

    ==================================  =============  ==============
    SVC Operation Type                  Request Value  Response Value
    ==================================  =============  ==============
    Ping                                0x00           0x80
    Protocol Version                    0x01           0x81
    SVC Hello                           0x02           0x82
    Interface Device ID                 0x03           0x83
    Interface Hotplug (deprecated)      0x04           0x84
    Interface Hot Unplug (deprecated)   0x05           0x85
    Interface Reset                     0x06           0x86
    Connection Create                   0x07           0x87
    Connection Destroy                  0x08           0x88
    DME Peer Get                        0x09           0x89
    DME Peer Set                        0x0a           0x8a
    Route Create                        0x0b           0x8b
    Route Destroy                       0x0c           0x8c
    TimeSync Enable                     0x0d           0x8d
    TimeSync Disable                    0x0e           0x8e
    TimeSync Authoritative              0x0f           0x8f
    Interface Set Power Mode            0x10           0x90
    Module Eject                        0x11           0x91
    Key Event                           0x12           N/A
    Reserved                            0x13           0x93
    Power Monitor Get Rail Count        0x14           0x94
    Power Monitor Get Rail Names        0x15           0x95
    Power Monitor Get Sample            0x16           0x96
    Power Monitor Interface Get Sample  0x17           0x97
    TimeSync Wake Pins Acquire          0x18           0x98
    TimeSync Wake Pins Release          0x19           0x99
    TimeSync Ping                       0x1a           0x9a
    Power Down                          0x1d           0x9d
    Connection Quiescing                0x1e           0x9e
    Module Inserted                     0x1f           0x9f
    Module Removed                      0x20           0xa0
    Interface V_SYS Enable              0x21           0xa1
    Interface V_SYS Disable             0x22           0xa2
    Interface REFCLK Enable             0x23           0xa3
    Interface REFCLK Disable            0x24           0xa4
    Interface UNIPRO Enable             0x25           0xa5
    Interface UNIPRO Disable            0x26           0xa6
    Interface Activate                  0x27           0xa7
    Interface Resume                    0x28           0xa8
    Interface Mailbox Event             0x29           0xa9
    (all other values reserved)         0x2a..0x7e     0xaa..0xfe
    Invalid                             0x7f           0xff
    ==================================  =============  ==============

..

.. _svc-protocol-op-status:

Greybus SVC Protocol Operation Status
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The SVC Protocol defines a common set of status values which are embedded in
some Operation Response payload fields, and are defined in Table
:num:`table-svc-protocol-op-status-values`. These status values are used
to signal errors specific to SVC Protocol.

.. figtable::
    :nofig:
    :label: table-svc-protocol-op-status-values
    :caption: SVC Protocol Status Values
    :spec: l c l

    ===============================  ===============  ======================================
    Status                           Value            Meaning
    ===============================  ===============  ======================================
    GB_SVC_OP_SUCCESS                0x00             SVC Protocol Operation completed successfully
    GB_SVC_OP_UNKNOWN_ERROR          0x01             Unknown error occured
    GB_SVC_INTF_NOT_DETECTED         0x02             DETECT is not DETECT_ACTIVE
    GB_SVC_INTF_NO_UPRO_LINK         0x03             UNIPRO is not UPRO_UP
    GB_SVC_INTF_UPRO_NOT_DOWN        0x04             UNIPRO is not UPRO_DOWN
    GB_SVC_INTF_UPRO_NOT_HIBERNATED  0x05             UNIPRO is not UPRO_HIBERNATE
    GB_SVC_INTF_NO_V_SYS             0x06             V_SYS is not V_SYS_ON
    GB_SVC_INTF_V_CHG                0x07             V_CHG is V_CHG_ON
    GB_SVC_INTF_WAKE_BUSY            0x08             WAKE is not WAKE_UNSET
    GB_SVC_INTF_NO_REFCLK            0x09             REFCLK is not REFCLK_ON
    GB_SVC_INTF_RELEASING            0x0a             RELEASE is RELEASE_ASSERTED
    GB_SVC_INTF_NO_ORDER             0x0b             ORDER is ORDER_UNKNOWN
    GB_SVC_INTF_MBOX_SET             0x0c             MAILBOX is not MAILBOX_NONE
    GB_SVC_INTF_BAD_MBOX             0x0d             Interface set MAILBOX to illegal value
    GB_SVC_INTF_OP_TIMEOUT           0x0e             SVC Interface operation timed out
    GB_SVC_PWRMON_OP_NOT_PRESENT     0x0f             Measurable power rails are not present
    Reserved                         0x10 to 0xff     Reserved for future use
    ===============================  ===============  ======================================

..

.. _svc-ping:

Greybus SVC Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Ping Operation is the
:ref:`greybus-protocol-ping-operation` for the SVC Protocol.
It consists of a request containing no payload, and a response
with no payload that indicates a successful result.

.. _svc-protocol-version:

Greybus SVC Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Protocol Version Operation is the
:ref:`greybus-protocol-version-operation` for the SVC Protocol.

Greybus implementations adhering to the Protocol specified herein
shall specify the value |gb-major| for the version_major and
|gb-minor| for the version_minor fields found in this Operation's
request and response messages.

.. _svc-hello:

Greybus SVC Hello Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Hello Operation is sent by the SVC to the AP
at power-on to inform the AP of its environment.

Greybus SVC Hello Request
"""""""""""""""""""""""""

Table :num:`table-svc-hello-request` defines the Greybus SVC Hello
Request payload. This Operation is used at initial power-on, sent by
the SVC to inform the AP of its environment. After version
negotiation, it is the next Operation sent by the SVC sent at
initialization. The descriptor describes details of the :ref:`Frame
<glossary-frame>` environment and location of the AP interface.

.. figtable::
    :nofig:
    :label: table-svc-hello-request
    :caption: SVC Protocol SVC Hello Request
    :spec: l l c c l

    =======  ================  ===========  ===============  ===========================
    Offset   Field             Size         Value            Description
    =======  ================  ===========  ===============  ===========================
    0        frame_generation  2            Number           Frame Generation ID
    2        frame_variant     2            Number           Frame Variant within the Generation
    4        intf_id           1            Number           AP Interface ID
    =======  ================  ===========  ===============  ===========================

..

Before sending the SVC Hello Request, the SVC shall ensure that all
:ref:`hardware-model-interface-states` in the Greybus System are
either :ref:`hardware-model-lifecycle-attached` or
:ref:`hardware-model-lifecycle-detached`.

Greybus SVC Hello Response
""""""""""""""""""""""""""

The Greybus SVC Hello response contains no payload.

During the initialization of a Greybus System, after receiving a
successful SVC Hello Response from the AP, the SVC shall attempt to
exchange a sequence of :ref:`Module Inserted
<svc-module-inserted>` Operations with the AP.

.. _svc-dme-peer-get:

Greybus SVC DME Peer Get Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC DME Peer Get Operation is sent by the AP to the SVC
to direct the SVC to perform a |unipro| DME Peer Get on an Interface.

Greybus SVC DME Peer Get Request
""""""""""""""""""""""""""""""""

Table :num:`table-dme-peer-get-request` defines the Greybus SVC DME
Peer Get Request payload. This request may be sent by the AP to query
specific attributes located in the |unipro| stack of an Interface. The
SVC returns the value of the DME attribute requested.

.. figtable::
    :nofig:
    :label: table-dme-peer-get-request
    :caption: SVC Protocol DME Peer Get Request
    :spec: l l c c l

    =======  ==============  ===========  ===============  ===========================
    Offset   Field           Size         Value            Description
    =======  ==============  ===========  ===============  ===========================
    0        intf_id         1            Number           Interface ID
    1        attr            2            Number           |unipro| DME Attribute
    3        selector        2            Number           |unipro| DME selector
    =======  ==============  ===========  ===============  ===========================

..

Upon receiving the request, the SVC shall check that the
:ref:`Interface State <hardware-model-interface-states>` with ID
intf_id has DETECT equal to DETECT_ACTIVE, and UNIPRO equal to
UPRO_UP.

If these conditions do not hold, the SVC cannot satisfy the request,
and shall send a response signaling an error as described below. The
SVC shall take no further action related to such an unsatisfiable
request beyond sending the response.

Otherwise, the SVC shall attempt to retrieve the value of the |unipro|
DME attribute with Attribute ID given by the attr field, with selector
index given by the selector field.

Greybus SVC DME Peer Get Response
"""""""""""""""""""""""""""""""""

Table :num:`table-dme-peer-get-response` defines the Greybus SVC DME
Peer Get Operation Response payload. If the :ref:`greybus-operation-status`
is not GB_OP_SUCCESS, the values of the response payload fields are undefined
and shall be ignored.

If the status field in the Operation Response payload is not GB_SVC_OP_SUCCESS,
values in all other fields of the Operation Response payload are undefined and
shall be ignored. The SVC shall return the following errors in the status field
of the Operation Response payload depending on the sub-state values of the
:ref:`hardware-model-interface-states` with Interface ID given by intf_id in
the request payload:

- If DETECT is not DETECT_ACTIVE, the response shall have status
  GB_SVC_INTF_NOT_DETECTED.

- If UNIPRO is not UPRO_UP, the response shall have status
  GB_SVC_INTF_NO_UPRO_LINK.

If during the handling of the request, the SVC is unable to exchange
the |unipro| frames required to retrieve a ConfigResultCode or attribute value
from the peer identified in the request, the status field in Operation Response
payload shall be GB_SVC_OP_UNKNOWN_ERROR. When this occurs, the value of the
UNIPRO sub-state for the Interface identified in the request is unpredictable.

If the :ref:`greybus-operation-status` is GB_OP_SUCCESS and the status field
in Operation Response payload is GB_SVC_OP_SUCCESS, the Greybus DME Peer Get
response contains the ConfigResultCode as defined in the |unipro|
specification, as well as the value of the attribute, if applicable.

.. figtable::
    :nofig:
    :label: table-dme-peer-get-response
    :caption: SVC Protocol DME Peer Get Response
    :spec: l l c c l

    =======  ==============  ===========  ================  =========================================
    Offset   Field           Size         Value             Description
    =======  ==============  ===========  ================  =========================================
    0        status          1            Number            :ref:`svc-protocol-op-status`
    1        result_code     2            Number            |unipro| DME Peer Get ConfigResultCode
    3        attr_value      4            Number            |unipro| DME Peer Get DME Attribute value
    =======  ==============  ===========  ================  =========================================

..

.. _svc-dme-peer-set:

Greybus SVC DME Peer Set Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC DME Peer Set Operation is sent by the AP to the SVC
to direct the SVC to perform a |unipro| DME_PEER_SET on an Interface.

Greybus SVC DME Peer Set Request
""""""""""""""""""""""""""""""""

Table :num:`table-dme-peer-set-request` defines the Greybus SVC DME
Peer Set Request payload.  This request may be sent by the AP to set
specific attributes located in the |unipro| stack of an Interface.

.. figtable::
    :nofig:
    :label: table-dme-peer-set-request
    :caption: SVC Protocol DME Peer Set Request
    :spec: l l c c l

    =======  ==============  ===========  ===============  ===================================
    Offset   Field           Size         Value            Description
    =======  ==============  ===========  ===============  ===================================
    0        intf_id         1            Number           Interface ID
    1        attr            2            Number           |unipro| DME Attribute
    3        selector        2            Number           |unipro| DME selector
    5        value           4            Number           |unipro| DME Attribute value to set
    =======  ==============  ===========  ===============  ===================================

..


Upon receiving the request, the SVC shall check that the
:ref:`Interface State <hardware-model-interface-states>` with ID
intf_id has DETECT equal to DETECT_ACTIVE, and UNIPRO equal to
UPRO_UP.

If these conditions do not hold, the SVC cannot satisfy the request,
and shall send a response signaling an error as described below. The
SVC shall take no further action related to such an unsatisfiable
request beyond sending the response.

Otherwise, the SVC shall attempt to set the value of the |unipro| DME
attribute with Attribute ID given by the attr field, with selector
index given by the selector field, to the value given by the value
field.

Greybus SVC DME Peer Set Response
"""""""""""""""""""""""""""""""""

Table :num:`table-dme-peer-set-response` defines the Greybus SVC DME
Peer Set Response payload.  If the :ref:`greybus-operation-status` is not
GB_OP_SUCCESS, the values of the response payload fields are undefined
and shall be ignored.

If the status field in the Operation Response payload is not GB_SVC_OP_SUCCESS,
values in all other fields of the Operation Response payload are undefined and
shall be ignored. The SVC shall return the following errors in the status field
of the Operation Response payload depending on the sub-state values of the
:ref:`hardware-model-interface-states` with Interface ID given by intf_id
in the request payload:

- If DETECT is not DETECT_ACTIVE, the response shall have status
  GB_SVC_INTF_NOT_DETECTED.

- If UNIPRO is not UPRO_UP, the response shall have status
  GB_SVC_INTF_NO_UPRO_LINK.

If during the handling of the request, the SVC is unable to exchange
the |unipro| frames required to retrieve a ConfigResultCode or attribute value
from the peer identified in the request, the status field in Operation Response
payload shall be GB_SVC_OP_UNKNOWN_ERROR. When this occurs, the value of the
UNIPRO sub-state for the Interface identified in the request is unpredictable.

If the :ref:`greybus-operation-status` is GB_OP_SUCCESS and the status field in
Operation Response payload is GB_SVC_OP_SUCCESS, the Greybus DME Peer Set
response contains the ConfigResultCode for the attribute write as
defined in the |unipro| specification.

.. figtable::
    :nofig:
    :label: table-dme-peer-set-response
    :caption: SVC Protocol DME Peer Set Response
    :spec: l l c c l

    =======  ==============  ===========  ================  =========================================
    Offset   Field           Size         Value             Description
    =======  ==============  ===========  ================  =========================================
    0        status          1            Number            :ref:`svc-protocol-op-status`
    1        result_code     2            Number            |unipro| DME Peer Set ConfigResultCode
    =======  ==============  ===========  ================  =========================================

..

.. _svc-route-create:

Greybus SVC Route Create Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Protocol Route Create Operation allows the AP Module
to request a route be established for |unipro| traffic between two
Interfaces.

.. NB: the language here uses "UniPro Message" instead of "Greybus
   Operation" on purpose: we will still need routes for e.g. UFS.

While handling this Operation request, the SVC may attempt to create a
*route* within the Frame. This is a necessary condition for |unipro|
Messages to subsequently be exchanged between the UniPorts attached to
the Interface Blocks identified by the request.

However, creation of a route is not a sufficient condition for Message
exchange. In order to exchange |unipro| Messages between the two
Interfaces, a successful :ref:`svc-connection-create`
between the two interfaces is required as well. Additional Operations
are required to establish a Greybus Connection, as described in
:ref:`lifecycles_connection_management`.

Greybus SVC Route Create Request
""""""""""""""""""""""""""""""""

Table :num:`table-svc-route-create-request` defines the Greybus SVC
Route Create request payload. The request supplies the Interface IDs and Device
IDs of two Interfaces to be connected.

.. figtable::
    :nofig:
    :label: table-svc-route-create-request
    :caption: SVC Protocol Route Create Request
    :spec: l l c c l

    =======  ==============  ======  ==========  ===========================
    Offset   Field           Size    Value       Description
    =======  ==============  ======  ==========  ===========================
    0        intf1_id        1       Number      First Interface
    1        dev1_id         1       Number      First Interface Device ID
    2        intf2_id        1       Number      Second Interface
    3        dev2_id         1       Number      Second Interface Device ID
    =======  ==============  ======  ==========  ===========================

..

Upon receiving the request, the SVC shall check that the
:ref:`hardware-model-interface-states` with IDs intf1_id and intf2_id
have DETECT equal to DETECT_ACTIVE, and UNIPRO equal to UPRO_UP.

If these conditions do not hold, the SVC cannot satisfy the request,
and shall send a response signaling an error as described below. The
SVC shall take no further action related to such an unsatisfiable
request beyond sending the response.

Otherwise, the SVC shall attempt to create the specified route.

Greybus SVC Route Create Response
"""""""""""""""""""""""""""""""""

Table :num:`table-svc-route-create-response` defines the Greybus SVC Route
Create Response payload. If the :ref:`greybus-operation-status` is not
GB_OP_SUCCESS, the value of the Response payload field is undefined and shall
be ignored.

The SVC shall return the following errors in the status field of the Operation
Response payload depending on the sub-state values of the
:ref:`hardware-model-interface-states` with Interface ID given by intf1_id and
intf2_id in the Request payload.

- If DETECT is not DETECT_ACTIVE in both Interface States, the
  response shall have status GB_SVC_INTF_NOT_DETECTED.

- If DETECT is DETECT_ACTIVE in both Interface States, and UNIPRO is
  not UPRO_UP in both Interface States, the response shall have status
  GB_SVC_INTF_NO_UPRO_LINK.

Regardless of the Response status value, the Greybus SVC Route Create
Operation shall have no effect on either the UNIPRO sub-state of
either Interface identified by the request, or the value of any of the
|unipro| DME attributes for the Interfaces identified by the request.

.. figtable::
    :nofig:
    :label: table-svc-route-create-response
    :caption: SVC Protocol Route Create Response
    :spec: l l c c l

    =======  ==============  ===========  ================  =========================================
    Offset   Field           Size         Value             Description
    =======  ==============  ===========  ================  =========================================
    0        status          1            Number            :ref:`svc-protocol-op-status`
    =======  ==============  ===========  ================  =========================================

..


.. _svc-route-destroy:

Greybus SVC Route Destroy Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Protocol Route Destroy Operation allows the AP Module
to request a route be torn down for |unipro| traffic between two
Interfaces.

While handling this Operation, the SVC may tear down a previously
created *route* within the Frame. This is a sufficient condition for
preventing subsequent |unipro| Messages from being exchanged between
the UniPorts attached to the Interface Blocks identified by the
request; however, additional Operations are required to completely
release resources acquired during Greybus Connection establishment, as
described in :ref:`lifecycles_connection_management`.

Greybus SVC Route Destroy Request
"""""""""""""""""""""""""""""""""

Table :num:`table-svc-route-destroy-request` defines the Greybus SVC
Route Destroy request payload. The request supplies the Interface IDs
of two Interfaces between which the route should be destroyed.

.. figtable::
    :nofig:
    :label: table-svc-route-destroy-request
    :caption: SVC Protocol Route Destroy Request
    :spec: l l c c l

    =======  ==============  ======  ==========  ===========================
    Offset   Field           Size    Value       Description
    =======  ==============  ======  ==========  ===========================
    0        intf1_id        1       Number      First Interface
    1        intf2_id        1       Number      Second Interface
    =======  ==============  ======  ==========  ===========================

..

Upon receiving the request, the SVC shall attempt to destroy the
specified route.

Greybus SVC Route Destroy Response
""""""""""""""""""""""""""""""""""

The Greybus SVC Protocol Route Destroy response contains no payload.

Regardless of the response status value, the Greybus SVC Route Destroy
Operation shall have no effect on either the UNIPRO sub-state of
either Interface identified by the request, or the value of any of the
|unipro| DME attributes for the Interfaces identified by the request.

.. _svc-interface-device-id:

Greybus SVC Interface Device ID Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Interface Device ID Operation is used by the AP Module
to request the SVC associate a device id with an Interface.  The
device id is used by the |unipro| switch to determine how packets
should be routed through the network.  The AP Module is responsible
for managing the mapping between Interfaces and |unipro| device ids.

Greybus supports 5-bit |unipro| Device IDs. Device ID 0 and 1 are reserved
for the SVC and primary AP Interface respectively.

The AP shall manage Device IDs of any attached Modules using this
operation during :ref:`lifecycles_connection_management`.

Greybus SVC Interface Device ID Request
"""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-device-id-request` defines the Greybus SVC
Interface Device ID Request payload.

The Greybus SVC Interface Device ID Request shall only be sent by the
AP Module to the SVC.  It supplies the 5-bit Device ID that the SVC will
associate with the indicated Interface.  The AP Module can remove the
association of an Interface with a Device ID by setting the device_id field
in the request payload to zero. The AP shall not assign a (non-zero) Device ID to an
Interface that the SVC has already associated with an Interface, and
shall not clear the Device ID of an Interface that has no Device ID
assigned.

Note that assigning a Device ID to an Interface does not cause
the SVC to set up any routes for that Device ID.  Routes are
set up only as needed when a connection involving a Device ID
are created, and removed when an Interface's last connection is
destroyed.

.. figtable::
    :nofig:
    :label: table-svc-device-id-request
    :caption: SVC Protocol Device ID Request
    :spec: l l c c l

    =======  ==============  ======  ============    ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ===========================
    0        intf_id         1       Number          Interface ID whose Device ID is being assigned
    1        device_id       1       Number          5-bit |unipro| Device ID for Interface
    =======  ==============  ======  ============    ===========================

..

Upon receiving the request, the SVC shall check that the
:ref:`Interface State <hardware-model-interface-states>` with ID
intf_id has DETECT equal to DETECT_ACTIVE, and UNIPRO equal to
UPRO_UP.

If these conditions do not hold, the SVC cannot satisfy the request,
and shall send a response signaling an error as described below. The
SVC shall take no further action related to such an unsatisfiable
request beyond sending the response.

Otherwise, the SVC shall attempt to set the |unipro| Device ID of the
UniPort connected to corresponding Interface Block to device_id, and
to mark the |unipro| Device ID as valid. This sequence may change the
values of |unipro| DME attributes on the UniPort the Interface Block
identified in the request.

Greybus SVC Interface Device ID Response
""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-intf-device-id-response` defines the Greybus SVC
Interface Device ID Response payload. If the Response message header has
:ref:`greybus-operation-status` not equal to GB_OP_SUCCESS, the value of
the Response payload field is undefined and shall be ignored.

The SVC shall return the following errors in the status field of the Operation
Response payload depending on the sub-state values of the
:ref:`Interface State <hardware-model-interface-states>` with Interface ID
given by intf_id in the Request payload.

- If DETECT is not DETECT_ACTIVE, the response shall have status
  GB_SVC_INTF_NOT_DETECTED.

- If UNIPRO is not UPRO_UP, the response shall have status
  GB_SVC_INTF_NO_UPRO_LINK.

If the SVC fails to set the Device ID due to an error on a |unipro| link, the
status field in the Operation Response payload shall be
GB_SVC_OP_UNKNOWN_ERROR. When this occurs, the value of the Device ID, as well
as its validity, are unpredictable, as is the value of the UNIPRO sub-state of
the :ref:`Interface State <hardware-model-interface-states>` with Interface ID
given by the intf_id in Request payload.

.. figtable::
    :nofig:
    :label: table-svc-intf-device-id-response
    :caption: SVC Protocol Interface Device Id Response
    :spec: l l c c l

    =======  ==============  ===========  ================  =========================================
    Offset   Field           Size         Value             Description
    =======  ==============  ===========  ================  =========================================
    0        status          1            Number            :ref:`svc-protocol-op-status`
    =======  ==============  ===========  ================  =========================================

..

Greybus SVC Interface Hotplug Operation (Deprecated)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note:: This operation is deprecated, and should not be used in new designs.

          :ref:`lifecycles_boot` and :ref:`lifecycles_ms_exit` should be used for any new designs.

When the SVC first detects that a module is present on an Interface,
it sends an Interface Hotplug Request to the AP Module.  The hotplug
request is sent after the Interface's |unipro| link has been
established.  The request includes some additional information known by the SVC
about the discovered Interface (such as the vendor and product ID).

.. XXX SVC Protocol connections must have E2EFC enabled and CSD and
.. XXX CSV disabled to ensure these messages are delivered reliably

Greybus SVC Interface Hotplug Request
"""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-hotplug-request` defines the Greybus SVC
Interface Hotplug Request payload.

The Greybus SVC hotplug request is sent only by the SVC to the AP
Module.  The Interface ID informs the AP Module which Interface now
has a module present, and supplies information (such
as the vendor and model numbers) the SVC knows about the Interface.
Exactly one hotplug event shall be sent by the SVC for a module when
it has been inserted (or if it was found to be present at initial
power-on).

.. figtable::
    :nofig:
    :label: table-svc-hotplug-request
    :caption: SVC Protocol Hotplug Request
    :spec: l l c c l

    ======  ==============  ====  ==============  =======================================
    Offset  Field           Size  Value           Description
    ======  ==============  ====  ==============  =======================================
    0       intf_id         1     Number          Interface that now has a module present
    1       ddbl1_mfr_id    4     Number          |unipro| DDB Level 1 Manufacturer ID
    5       ddbl1_prod_id   4     Number          |unipro| DDB Level 1 Product ID
    9       ara_vend_id     4     Number          Ara Vendor ID
    13      ara_prod_id     4     Number          Ara Product ID
    17      serial_number   8     Number          Module serial number that uniquely identifies modules with same ARA VID/PIDs
    ======  ==============  ====  ==============  =======================================

..

Greybus SVC Interface Hotplug Response
""""""""""""""""""""""""""""""""""""""

The Greybus SVC hotplug response message contains no payload.

Greybus SVC Interface Hot Unplug Operation (Deprecated)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note:: This operation is deprecated, and should not be used in new designs.

          The :ref:`svc-module-removed` should be used for any new designs.

The SVC sends this to the AP Module to tell it that an Interface
that was previously the subject of an Interface Hotplug Operation is
no longer present.  The SVC sends exactly one hot unplug event, for
the Interface, to the AP when this occurs.

.. XXX CSD and CSV must not be enabled for SVC Protocol connections,
.. XXX to ensure these messages are delivered reliably.

Greybus SVC Interface Hot Unplug Request
""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-hot-unplug-request` defines the Greybus SVC
Interface Hot Unplug Request payload.

The Greybus SVC hot unplog request is sent only by the SVC to the AP
Module.  The Interface ID informs the AP which Interface no longer
has a module attached to it.  The SVC shall ensure the hotplug event
for the Interface has been successfully delivered to the AP Module
before sending a hot unplug.

.. figtable::
    :nofig:
    :label: table-svc-hot-unplug-request
    :caption: SVC Protocol Hot Unplug Request
    :spec: l l c c l

    =======  ==============  ======  ============    ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ===========================
    0        intf_id         1       Number          Interface that no longer has an attached module
    =======  ==============  ======  ============    ===========================

..

Greybus SVC Interface Hot Unplug Response
"""""""""""""""""""""""""""""""""""""""""

The Greybus SVC hot unplug response message contains no payload.

.. _svc-interface-reset:

Greybus SVC Interface Reset Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The SVC sends this to the AP Module to request it reset the
indicated link.

Greybus SVC Interface Reset Request
"""""""""""""""""""""""""""""""""""

Table :num:`table-svc-reset-request` defines the Greybus SVC Interface
Reset Request payload.

The Greybus SVC Interface Reset Request is sent only by the SVC to
the AP Module.  The Interface ID informs the AP Module which
Interface needs to be reset.

.. figtable::
    :nofig:
    :label: table-svc-reset-request
    :caption: SVC Protocol Reset Request
    :spec: l l c c l

    =======  ==============  ======  ============    ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ===========================
    0        intf_id         1       Number          Interface to reset
    =======  ==============  ======  ============    ===========================

..

Greybus SVC Interface Reset Response
""""""""""""""""""""""""""""""""""""

The Greybus SVC Interface Reset response message contains no payload.

.. _svc-interface-set-power-mode:

Greybus SVC Interface Set Power Mode Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP sends this to the SVC to request that it change the |unipro|
power mode for the |unipro| link on an Interface.

The AP may use this Operation while an :ref:`Interface
<hardware-model-interfaces>` is
:ref:`hardware-model-lifecycle-enumerated` to manage various features
of the Link established between the Switch and the attached
Module.

The AP shall additionally use this Operation in order to perform
:ref:`lifecycles_power_management` and certain
:ref:`lifecycles_error_handling` transitions in
:ref:`lifecycles_interface_lifecycle`.

.. _svc-interface-set-power-mode-request:

Greybus SVC Interface Set Power Mode Request
""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-set-power-mode-request` defines the
Greybus SVC Interface Set Power Mode Request payload.

The request message payload contains the interface ID for which the AP
requests the power mode change, fields specifying the power mode
change to apply, and a structure containing implementation-specific
configuration information associated with the power mode change.

.. figtable::
   :nofig:
   :label: table-svc-interface-set-power-mode-request
   :caption: SVC Protocol Interface Set Power Mode Request
   :spec: l l c c l

   =======  ==================    =========   ======================   =============================================
   Offset   Field                 Size        Value                    Description
   =======  ==================    =========   ======================   =============================================
   0        intf_id               1           Number                   Interface whose power mode to change
   1        hs_series             1           Number                   Frequency series in high speed mode; see Table :num:`table-svc-unipro-hs-series`
   2        tx_mode               1           Number                   Power mode for TX; see Table :num:`table-svc-unipro-pwrmode`
   3        tx_gear               1           Number                   Gear for TX lanes
   4        tx_nlanes             1           Number                   Number of active TX lanes
   5        tx_amplitude          1           Number                   TX signal amplitude; see Table :num:`table-svc-pwrm-tx-ampl`
   6        tx_hs_equalizer       1           Number                   HS TX signal de-emphasis; see Table :num:`table-svc-unipro-pwrm-tx-hs-equal`
   7        rx_mode               1           Number                   Power mode for RX; see Table :num:`table-svc-unipro-pwrmode`
   8        rx_gear               1           Number                   Gear for RX lanes
   9        rx_nlanes             1           Number                   Number of active RX lanes
   10       flags                 1           Bit mask                 See Table :num:`table-svc-pwrm-flags`
   11       quirks                4           Bit mask                 See Table :num:`table-svc-pwrm-quirks`
   15       local_l2timerdata     24          Number                   L2 timer configuration data for power mode change (local peer)
   39       remote_l2timerdata    24          Number                   L2 timer configuration data for power mode change (remote peer)
   =======  ==================    =========   ======================   =============================================

..

The hs_series field in the request payload allows the AP to control
which rate series is used when either direction of the link is in high
speed mode. The values of the hs_series field are defined in Table
:num:`table-svc-unipro-hs-series`.

.. figtable::
   :nofig:
   :label: table-svc-unipro-hs-series
   :caption: High Speed Frequency Series
   :spec: l l l

   ============================    ==============  =========================
   Frequency Series                         Value  Description
   ============================    ==============  =========================
   (Reserved)                      0               (Reserved for future use)
   A                               1               High speed series A
   B                               2               High speed series B
   (All other values reserved)     3-255           (Reserved for future use)
   ============================    ==============  =========================

..

The tx_mode and rx_mode fields in the request payload allow the AP to
specify a |unipro| power mode for each direction of the link. The
values of these fields, along with the corresponding modes, are
specified in Table :num:`table-svc-unipro-pwrmode`.

.. figtable::
   :nofig:
   :label: table-svc-unipro-pwrmode
   :caption: |unipro| power modes
   :spec: l r l

   =====================   =========    ===========================
   Mode                    Value        Description
   =====================   =========    ===========================
   (Reserved)              0x00         (Reserved for future use)
   UNIPRO_FAST_MODE        0x01         Fast (HS) mode
   UNIPRO_SLOW_MODE        0x02         Slow (PWM) mode
   (Reserved)              0x03         (Reserved for future use)
   UNIPRO_FAST_AUTO_MODE   0x04         Fast auto mode
   UNIPRO_SLOW_AUTO_MODE   0x05         Slow auto mode
   (Reserved)              0x06         (Reserved for future use)
   UNIPRO_MODE_UNCHANGED   0x07         Leave mode unchanged
   (Reserved)              0x08-0x10    (Reserved for future use)
   UNIPRO_HIBERNATE_MODE   0x11         Hibernate mode
   UNIPRO_OFF_MODE         0x12         Link is off
   (Reserved)              0x13-0xFF    (Reserved for future use)
   =====================   =========    ===========================

..

The tx_amplitude field in the request payload allows the AP to
specify the TX path signal amplitude of a |unipro| link. It applies to
both local and remote peers.
The values of this field, along with the corresponding modes, are
specified in Table :num:`table-svc-pwrm-tx-ampl`.

.. figtable::
   :nofig:
   :label: table-svc-pwrm-tx-ampl
   :caption: TX path signal amplitudes
   :spec: l r l

   =========================== =========    ================================
   Mode                        Value        Description
   =========================== =========    ================================
   (Reserved)                  0x0          (Reserved for future use)
   SMALL_AMPLITUDE             0x01         Select small TX signal amplitude
   LARGE_AMPLITUDE             0x02         Select large TX signal amplitude
   (all other values reserved) 0x03-0xFF    (Reserved for future use)
   =========================== =========    ================================

..

The tx_hs_equalizer field in the request payload allows the AP to
specify a de-emphasis value for the TX path of a |unipro| link. It applies to
both local and remote peers. It is only relevant in high speed (HS) mode, and
ignored in slow (PWM) mode.
The values of this field, along with the corresponding modes, are
specified in Table :num:`table-svc-unipro-pwrm-tx-hs-equal`.

.. figtable::
   :nofig:
   :label: table-svc-unipro-pwrm-tx-hs-equal
   :caption: HS TX signal de-emphasis modes
   :spec: l r l

   =========================== =========    ======================================
   Mode                        Value        Description
   =========================== =========    ======================================
   NO_DE_EMPHASIS              0x0          Disable de-emphasis on HS TX path
   SMALL_DE_EMPHASIS           0x01         Enable 3.5dB de-emphasis on HS TX path
   LARGE_DE_EMPHASIS           0x02         Enable 6dB de-emphasis on HS TX path
   (all other values reserved) 0x03-0xFF    (Reserved for future use)
   =========================== =========    ======================================

..

The flags field in the request payload is a bit mask which allows the
AP to request the SVC to update extra |unipro| power mode settings.
The mask values for the flags field are defined in
Table :num:`table-svc-pwrm-flags`.

.. figtable::
   :nofig:
   :label: table-svc-pwrm-flags
   :caption: Flags for SVC Interface Set Power Mode Request
   :spec: l r l

   =========================== =========    ===============================
   Mode                        Value        Description
   =========================== =========    ===============================
   RX_TERMINATION              0x01         Enable RX-direction termination
   TX_TERMINATION              0x02         Enable TX-direction termination
   LINE_RESET                  0x04         Request Line Reset
   (Reserved)                  0x08         (Reserved for future use)
   (Reserved)                  0x10         (Reserved for future use)
   SCRAMBLING                  0x20         Always set HS series
   (all other values reserved) 0x40-0x80    (Reserved for future use)
   =========================== =========    ===============================

..

The quirks field in the request payload is a bit mask which allows the
AP to request behavior from the SVC which may deviate in some way from
the |unipro| specification. The mask values for the quirks field are
defined in Table :num:`table-svc-pwrm-quirks`.

.. figtable::
   :nofig:
   :label: table-svc-pwrm-quirks
   :caption: Quirks for SVC Interface Set Power Mode Request
   :spec: l r l

   =========================== =====================    =========================
   Mode                        Value                    Description
   =========================== =====================    =========================
   SVC_PWRM_QUIRK_HSSER        0x00000001               Always set HS series
   (all other values reserved) 0x00000002-0x80000000    (Reserved for future use)
   =========================== =====================    =========================

..

The local_l2timerdata and remote_l2timerdata fields in the request payload
allow the AP to configure L2 timer values of the |unipro| link.
local_l2timerdata and remote_l2timerdata fields apply respectively to the local
and remote peers of the |unipro| link. The content of this structure is defined
in the |unipro| specification version 1.6, Table 102.
All integer values in Table 102 are stored as 16-bit little-endian values.

If one or more of the following list of conditions holds, the SVC
shall transmit a Greybus SVC Interface Set Power Mode Response message
with status byte GB_OP_INVALID. The SVC shall make no changes to the
link's power mode in any of these cases.

1. The request's hs_series field does not lie within the table of
   values given in Table :num:`table-svc-unipro-hs-series`.

2. The request's tx_mode or rx_mode field is not one of the values
   given in Table :num:`table-svc-unipro-pwrmode`.

3. The request's tx_mode, rx_mode, tx_gear, rx_gear, tx_nlanes, rx_nlanes,
   tx_amplitude and tx_hs_equalizer do not collectively lie within the ranges
   defined by the |unipro| specification.

4. The request's quirks field contains bits set which are reserved for
   future use or not supported by the SVC.

Upon receipt of a Greybus SVC Interface Set Power Mode Request, the
SVC shall determine if the intf_id field in the request payload is
valid, by determining if there is a |unipro| link associated with the
Interface given by intf_id, and whether that |unipro| link is up. If
so, the SVC shall attempt to change the power mode of the |unipro|
link at the given interface. If not, the SVC shall transmit a Greybus
SVC Interface Set Power Mode Response message with the
:ref:`greybus-operation-status` in the Response message header set to
GB_OP_INVALID. The SVC shall make no changes to the link's power mode in this
case.

The tx_mode and rx_mode fields in the Greybus SVC Interface Set Power
Mode Request determine the |unipro| Power Modes of the link's transmit
and receive directions, respectively. The transmit and receive
directions are defined with respect to the UniPort attached to the
|unipro| switch. For example, tx_mode determines the |unipro| power
mode of the transmitter which is attached to the |unipro| switch at
the Interface given by intf_id; tx_mode does not refer to the
transmitter within the switch itself.

If either of tx_mode or rx_mode equals UNIPRO_HIBERNATE_MODE, both
shall equal UNIPRO_HIBERNATE_MODE. Under this condition, the following
fields in the request payload shall be ignored: hs_series, tx_gear,
tx_nlanes, tx_amplitude, tx_hs_equalizer, rx_gear, rx_nlanes, flags,
quirks, local_l2timerdata, remote_l2timerdata.

When reconfiguring the link power mode as a result of receiving a
Greybus SVC Interface Set Power Mode Request, the SVC shall set the
|unipro| PA_HSSeries attribute for the link according to the hs_series
field in the request payload, as defined by Table
:num:`table-svc-unipro-hs-series`.

If the SVC_PWRM_QUIRK_HSSER bit is set in the quirks field of the
request payload, the SVC shall perform this setting regardless of
whether either tx_mode or rx_mode is UNIPRO_FAST_MODE or
UNIPRO_FAST_AUTO_MODE. If SVC_PWRM_QUIRK_HSSER is unset, the SVC shall
set PA_HSSeries if and only if one of tx_mode or rx_mode is
UNIPRO_FAST_MODE or UNIPRO_FAST_AUTO_MODE.

The tx_gear and rx_gear attributes specify the gear settings for the
transmit and receive directions in the new power mode
configuration. The valid values for the tx_gear and rx_gear fields
depend respectively on the values of tx_mode and rx_mode.

If tx_mode or rx_mode is UNIPRO_FAST_MODE or UNIPRO_FAST_AUTO_MODE,
then the valid values for tx_gear or rx_gear, respectively, are one,
two, and three.

If tx_mode or rx_mode is UNIPRO_SLOW_MODE or UNIPRO_SLOW_AUTO_MODE,
then the valid values for tx_gear or rx_gear, respectively, are the
range of integers between one and seven.

If tx_mode or rx_mode is UNIPRO_MODE_UNCHANGED, direction-specific
parameters (tx_gear, tx_nlanes, SVC_PWRM_TXTERMINATION or
rx_gear, rx_nlanes, SVC_PWRM_RXTERMINATION, respectively) will be ignored.

Upon receiving the request, the SVC shall check that the
:ref:`Interface State <hardware-model-interface-states>` with ID
intf_id has DETECT equal to DETECT_ACTIVE, and has a UNIPRO sub-state
equal to UPRO_UP or UPRO_HIBERNATE.

If these conditions do not hold, the SVC shall send a response
signaling an error as described below. The SVC shall take not attempt
to reconfigure any |unipro| links as a result of receiving such a
request.

Otherwise, the SVC shall attempt to reconfigure the power mode for the
|unipro| link identified by the request.

When reconfiguring the link power mode as a result of receiving a
Greybus SVC Interface Set Power Mode Request, the link's transmitter and/or
receiver power mode shall be set to the given configuration.
The :ref:`greybus-operation-status` in the Response message header of the
response to a Greybus SVC Interface Set Power Mode Request shall not be used
to check the result of the power mode change operation. It shall only be used
to indicate the result of the Greybus communication only. If the
:ref:`greybus-operation-status` in the Response message header of the
response to a Greybus SVC Interface Set Power Mode Request is different
than GB_OP_SUCCESS, it shall indicate that an error occurred and that the power
mode change could not be initiated; the targeted link shall be in the same
state as before the request was issued. If the
:ref:`greybus-operation-status` in the Response message header of response
to a Greybus SVC Interface Set Power Mode Request is GB_OP_SUCCESS, it shall
indicate that there was no Greybus communication error detected (Request and
Response were successfully exchanged). However, it shall not also be considered
as a successful power mode change. The status and pwr_change_result_code fields
as respectively described in Table
:num:`table-svc-interface-set-power-mode-response` shall be used for that
unique purpose. In other words, if and only if the
:ref:`greybus-operation-status` in the Response message header is
GB_OP_SUCCESS and the status field in the Greybus SVC Interface Set Power Mode
Response payload as described in Table
:num:`table-svc-interface-set-power-mode-response` is GB_SVC_OP_SUCCESS,
the pwr_change_result_code field in the Response payload indicates the actual
result of the power mode change request.

Greybus SVC Interface Set Power Mode Response
"""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-set-power-mode-response` defines the
Greybus SVC Interface Set Power Mode Response payload. If the Response message
header has the :ref:`greybus-operation-status` not equal to GB_OP_SUCCESS,
the values of the Response payload fields are undefined and shall be ignored.


.. figtable::
   :nofig:
   :label: table-svc-interface-set-power-mode-response
   :caption: SVC Protocol Interface Set Power Mode Response
   :spec: l l c c l

   =======  ======================     =========   ========   ==============================
   Offset   Field                      Size        Value      Description
   =======  ======================     =========   ========   ==============================
   0        status                     1           Number     :ref:`svc-protocol-op-status`
   1        pwr_change_result_code     1           Number     |unipro| PowerChangeResultCode
   =======  ======================     =========   ========   ==============================

..

If the status field in the Operation response payload as described in Table
:num:`table-svc-interface-set-power-mode-response` is not GB_SVC_OP_SUCCESS,
the value in the pwr_change_result_code field of the Response payload is
undefined and shall be ignored. The SVC shall return the following errors in
the status field of the Operation Response payload depending on the sub-state
values of the :ref:`Interface State <hardware-model-interface-states>` with
Interface ID given by intf_id in the Request payload:

- If DETECT is not DETECT_ACTIVE, the response shall have status
  GB_SVC_INTF_NOT_DETECTED.

- If UNIPRO is not UPRO_UP or UPRO_HIBERNATE, the response shall have
  status GB_SVC_INTF_NO_UPRO_LINK.

If the Response message header has the :ref:`greybus-operation-status`
equal to GB_OP_SUCCESS and the status field in the Operation Response payload
is GB_SVC_OP_SUCCESS, the pwr_change_result_code field in the Greybus Interface
Set Power Mode response message contains a PowerChangeResultCode as defined by
the |unipro| specification, version 1.6, Table 9. The pwr_change_result_code
field indicates a successful Operation or describes the reason for the
Operation failure. The values of the pwr_change_result_code field are defined
in Table
:num:`table-svc-interface-set-power-mode-response-pwr-change-result-code`.

.. figtable::
   :nofig:
   :label: table-svc-interface-set-power-mode-response-pwr-change-result-code
   :caption: PowerChangeResultCode Values
   :spec: l l l

   ============================    ==============  =========================
   PowerChangeResultCode           Value           Description
   ============================    ==============  =========================
   PWR_OK                          0               The request was accepted.
   PWR_LOCAL                       1               The local request was successfully applied.
   PWR_REMOTE                      2               The remote request was successfully applied.
   PWR_BUSY                        3               The request was aborted due to concurrent requests.
   PWR_ERROR_CAP                   4               The request was rejected because the requested configuration exceeded the Link’s capabilities.
   PWR_FATAL_ERROR                 5               The request was aborted due to a communication problem. The Link may be inoperable.
   (All other values reserved)     6-255           (Reserved for future use)
   ============================    ==============  =========================

..

.. _svc-connection-create:

Greybus SVC Connection Create Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP Module sends this Operation to the SVC to request that it
establish a |unipro| connection between the two indicated CPorts.
The SVC uses each (intf_id, cport_id) pair to determine the |unipro|
(DeviceID_Enc, CPortID_Enc) it represents.  It is an error to
attempt to create a connection using a CPort that is
already in use in another connection.

Greybus SVC Connection Create Request
"""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-connection-create-request` defines the Greybus
SVC Connection Create Request payload.

The Greybus SVC connection create request is sent only by the AP
Module to the SVC.  The first Interface ID and first CPort ID define
one end of the connection to be established, and the second
Interface ID and CPort ID define the other end.

CPort flags can be specified as a bitwise-or of flags in *flags*,
and are defined in table :num:`table-svc-connection-create-request-flags`.

.. figtable::
    :nofig:
    :label: table-svc-connection-create-request
    :caption: SVC Protocol Connection Create Request
    :spec: l l c c l

    =======  ==============  ======  ==================  ===========================
    Offset   Field           Size    Value               Description
    =======  ==============  ======  ==================  ===========================
    0        intf1_id        1       Number              First Interface
    1        cport1_id       2       Number              CPort on first Interface
    3        intf2_id        1       Number              Second Interface
    4        cport2_id       2       Number              CPort on second Interface
    6        tc              1       Traffic class       |unipro| traffic class
    7        flags           1       Connection flags    |unipro| connection flags
    =======  ==============  ======  ==================  ===========================

..

.. _svc-connection-create-flags:

.. figtable::
    :nofig:
    :label: table-svc-connection-create-request-flags
    :caption: SVC Protocol Connection Create Request Flags
    :spec: l l l

    =======  ==============  ============================================
    Value    Flag            Description
    =======  ==============  ============================================
    0x01     E2EFC           Enable |unipro| End-to-End Flow Control
    0x02     CSD_N           Disable |unipro| Controlled Segment Dropping
    0x04     CSV_N           Disable |unipro| CPort Safety Valve
    =======  ==============  ============================================

..

Upon receiving the request, the SVC shall check that the
:ref:`hardware-model-interface-states` with IDs intf1_id and intf2_id
both have DETECT equal to DETECT_ACTIVE, and UNIPRO equal to UPRO_UP.

If these conditions do not hold, the SVC cannot satisfy the request,
and shall send a response signaling an error as described below. The
SVC shall take no further action related to such an unsatisfiable
request beyond sending the response.

Otherwise, the SVC shall attempt to establish a |unipro| connection
between the CPort with ID cport1_id on Interface intf1_id, and CPort
with ID cport2_id on Interface intf2_id. The SVC shall attempt to
establish the connection using the Traffic Class and CPort features
given by the tc and flags field in the request, respectively. This
sequence may change the values of |unipro| DME attributes on the
UniPorts attached to each Interface Block identified in the request.

.. NB: the language "|unipro| DME attributes" is deliberately more
   general than "layer 4 DME attributes with selector indexes given by
   cport1_id, cport2_id [...]". We have to set other attributes
   sometimes for backwards compatibility with some systems
   (specifically, gen 1 bridge ASIC mailbox attributes, for boot ROM
   compatibility).

Greybus SVC Connection Create Response
""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-connection-create-response` defines the Greybus SVC
Connection Create Response. If the Response message header has the
:ref:`greybus-operation-status` not equal to GB_OP_SUCCESS, the value
of the status field in the Operation Response payload is undefined and shall
be ignored.

The SVC shall return the following errors in the status field of the
Operation Response payload depending on the sub-state values of the
:ref:`hardware-model-interface-states` with Interface IDs given by intf1_id
and intf2_id in the Request payload:

- If DETECT is not DETECT_ACTIVE in both Interface States, the
  response shall have status GB_SVC_INTF_NOT_DETECTED.

- If DETECT is DETECT_ACTIVE in both Interface States, and UNIPRO is
  not UPRO_UP in both Interface States, the response shall have status
  GB_SVC_INTF_NO_UPRO_LINK.

If the SVC fails to establish a |unipro| connection between the two
Interfaces due to an I/O or protocol error on the |unipro| links, the
status field in Operation Response payload shall equal GB_SVC_OP_UNKNOWN_ERROR.
When this occurs, the values of the |unipro| DME attributes of one or both of
the Interfaces is unpredictable, as are the values of the UNIPRO
sub-state of the :ref:`hardware-model-interface-states` with Interface IDs
given by intf1_id and intf2_id in Request payload.

.. figtable::
    :nofig:
    :label: table-svc-connection-create-response
    :caption: SVC Protocol Connection Create Response
    :spec: l l c c l

    =======  ==============  ===========  ================  =========================================
    Offset   Field           Size         Value             Description
    =======  ==============  ===========  ================  =========================================
    0        status          1            Number            :ref:`svc-protocol-op-status`
    =======  ==============  ===========  ================  =========================================

..

.. _svc-connection-quiescing:

Greybus SVC Connection Quiescing Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP Module sends this to the SVC to indicate that a connection
being torn down has entered its quiescing stage before being
disconnected. The AP shall ensure that no Operations are in flight on
the Connection before sending this request.

The SVC Connection Quiescing Operation allows the SVC to prepare the
underlying |unipro| connection for an orderly shutdown before it is
finally disconnected. In particular, it allows the AP to later ensure
that all |unipro| data flow associated with the connection has been
completed, allowing both users of the connection to later release any
resources consumed by that connection.

Greybus SVC Connection Quiescing Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-svc-connection-quiescing-request` defines the Greybus
SVC Connection Quiescing Request payload.  The Greybus SVC
Connection Quiescing request is sent only by the AP Module to the
SVC. The first Interface ID intf1_id and first CPort ID cport1_id define
one end of the connection to be quiesced, and the second
Interface ID intf2_id and CPort ID cport2_id define the other end.

.. figtable::
    :nofig:
    :label: table-svc-connection-quiescing-request
    :caption: SVC Protocol Connection Quiescing Request
    :spec: l l c c l

    =======  ==============  ======  ==================  ===========================
    Offset   Field           Size    Value               Description
    =======  ==============  ======  ==================  ===========================
    0        intf1_id        1       Number              First Interface
    1        cport1_id       2       Number              CPort on first Interface
    3        intf2_id        1       Number              Second Interface
    4        cport2_id       2       Number              CPort on second Interface
    =======  ==============  ======  ==================  ===========================

..

Before transmitting this request, the AP shall:

- Send a :ref:`control-disconnecting` request on the the Control
  Connection to intf1_id, unless intf1_id is an AP Interface ID, and
  receive a successful response.

- Send a :ref:`control-disconnecting` request on the the Control
  Connection to intf2_id, unless intf2_id is an AP Interface ID, and
  receive a successful response.

- Ensure that a :ref:`greybus-protocol-ping-operation` is successfully
  exchanged on the connection.

  If either intf1_id or intf2_id is an AP interface ID, the AP may
  ensure the Ping Operation is exchanged by sending the ping request
  from its end of the connection, and receiving the response.

This sequence is depicted in :ref:`lifecycles_connection_management`.

Upon receiving a Connection Quiescing request, the SVC shall check
that the :ref:`Interface State <hardware-model-interface-states>` with
ID intf_id has DETECT equal to DETECT_ACTIVE, and UNIPRO equal to
UPRO_UP.

If these conditions do not hold, the SVC cannot satisfy the request,
and shall send a response signaling an error as described below. The
SVC shall take no further action related to such an unsatisfiable
request beyond sending the response.

Otherwise, the SVC shall perform the *connection-quiesce sequence* by
temporarily disconnecting both ends of the Connection, then
reconfiguring them as follows before reconnecting them:

- ensuring :ref:`E2EFC, CSD, and CSV <svc-connection-create-flags>`
  are all disabled, and

- clearing estimates of local and peer buffer space, as well as credits
  to send.

Greybus SVC Connection Quiescing Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-svc-connection-quiescing-response` defines the Greybus SVC
Connection Quiescing Response payload. If the Response message header as the
:ref:`greybus-operation-status` not equal to GB_OP_SUCCESS, the value in
the status field in the Operation Response payload is undefined and shall be
ignored.

The SVC shall return the following errors in the status field of the Operation
Response payload depending on the sub-state values of the
:ref:`hardware-model-interface-states` with Interface IDs given by intf1_id
and intf2_id in the request payload:

- If DETECT is not DETECT_ACTIVE, the response shall have status
  GB_SVC_INTF_NOT_DETECTED.

- If UNIPRO is not UPRO_UP, the response shall have status
  GB_SVC_INTF_NO_UPRO_LINK.

If during the handling of the request, the SVC is unable to perform
the connection quiesce sequence due to fatal errors exchanging
|unipro| traffic with either end of the Connection, the status field in the
Operation Response payload shall equal GB_SVC_OP_UNKNOWN_ERROR. When this
occurs, the value of the UNIPRO sub-state of the
:ref:`hardware-model-interface-states` with Interface IDs given by intf1_id
and intf2_id in Request payload is unpredictable.

.. figtable::
    :nofig:
    :label: table-svc-connection-quiescing-response
    :caption: SVC Protocol Connection Quiescing Response
    :spec: l l c c l

    =======  ==============  ===========  ================  =========================================
    Offset   Field           Size         Value             Description
    =======  ==============  ===========  ================  =========================================
    0        status          1            Number            :ref:`svc-protocol-op-status`
    =======  ==============  ===========  ================  =========================================

..

.. _svc-connection-destroy:

Greybus SVC Connection Destroy Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP Module sends this to the SVC to request that a connection
that was previously set up by a Connection Create Operation be
torn down.  The AP Module shall have sent Disconnected Control
Operations to the two Interfaces prior to this call.  It is an error
to attempt to destroy a connection more than once.

Greybus SVC Connection Destroy Request
""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-connection-destroy-request` defines the Greybus
SVC Connection Destroy Request payload.

The Greybus SVC connection destroy request is sent only by the AP
Module to the SVC.  The two (Interface ID, CPort ID) pairs define
the connection to be destroyed.

.. figtable::
    :nofig:
    :label: table-svc-connection-destroy-request
    :caption: SVC Protocol Connection Destroy Request
    :spec: l l c c l

    =======  ==============  ======  ==================  ===========================
    Offset   Field           Size    Value               Description
    =======  ==============  ======  ==================  ===========================
    0        intf1_id        1       Number              First Interface
    1        cport1_id       2       Number              CPort on first Interface
    3        intf2_id        1       Number              Second Interface
    4        cport2_id       2       Number              CPort on second Interface
    =======  ==============  ======  ==================  ===========================

..

Upon receiving the request, the SVC shall check that the
:ref:`hardware-model-interface-states` with IDs intf1_id and intf2_id
both have DETECT equal to DETECT_ACTIVE, and UNIPRO equal to UPRO_UP.

If these conditions do not hold, the SVC cannot satisfy the request,
and shall send a response signaling an error as described below. The
SVC shall take no further action related to such an unsatisfiable
request beyond sending the response.

Otherwise, the SVC shall attempt to disable the |unipro| connection
between the CPort with ID cport1_id on Interface intf1_id, and CPort
with ID cport2_id on Interface intf2_id. This sequence may change the
values of |unipro| DME attributes on the UniPorts attached to each
Interface Block identified in the request.

Greybus SVC Connection Destroy Response
"""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-connection-destroy-response` defines the Greybus SVC
Connection Destroy Response payload. If the Response message header has the
:ref:`greybus-operation-status` not equal to GB_OP_SUCCESS, the value in
the status field in the Operation Response payload is undefined and shall be
ignored.

The SVC shall return the following errors in the status field of the Operation
Response payload depending on the sub-state values of the
:ref:`hardware-model-interface-states` with Interface IDs given by intf1_id
and intf2_id in the request payload:

- If DETECT is not DETECT_ACTIVE in both Interface State, the response
  shall have status GB_SVC_INTF_NOT_DETECTED.

- If DETECT is DETECT_ACTIVE for both Interface States, and UNIPRO is
  not UPRO_UP in both Interface States, the response shall have status
  GB_SVC_INTF_NO_UPRO_LINK.

If the SVC fails to destroy the |unipro| connection between the two
Interfaces due to an I/O or protocol error on the |unipro| links, the
status field in Operation Response payload shall equal GB_SVC_OP_UNKNOWN_ERROR.
When this occurs, the values of the |unipro| DME attributes of one or both of
the Interfaces is unpredictable, as are the values of the UNIPRO
sub-state of the :ref:`hardware-model-interface-states` with
Interface IDs given by intf1_id and intf2_id in Request payload.

.. figtable::
    :nofig:
    :label: table-svc-connection-destroy-response
    :caption: SVC Protocol Connection Destroy Response
    :spec: l l c c l

    =======  ==============  ===========  ================  =========================================
    Offset   Field           Size         Value             Description
    =======  ==============  ===========  ================  =========================================
    0        status          1            Number            :ref:`svc-protocol-op-status`
    =======  ==============  ===========  ================  =========================================

..

.. _svc-timesync-enable:

Greybus SVC TimeSync Enable Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP Module uses this operation to request the SVC to enable frame-time
tracking. After a successful timesync_enable operation the SVC will
generate a pulse-train of 'count' logical TIME_SYNC strobes to the bitmask
of WAKE_DETECT lines indicated by a previously communicated set of
Interfaces. A delay of 'strobe_delay' microseconds will be applied between
each TIME_SYNC strobe. The range of the count variable is from 1..4.
The 'frame_time' parameter informs the Interface to immediately seeds its
frame-time to a value given by the AP. 'frame-time. The 'refclk' parameter
informs the SVC of the required clock rate to run its frame-time tracking
counter at.

Greybus SVC TimeSync Enable Request
"""""""""""""""""""""""""""""""""""

Table :num:`table-svc-timesync-enable-request` defines the Greybus SVC
TimeSync Enable Request payload. The request supplies the number of
TIME_SYNC strobes to perform (count), the initial frame-time (frame_time),
the delay between each strobe (strobe_delay) and the required clock-rate
for frame-time (refclk).

.. figtable::
    :nofig:
    :label: table-svc-timesync-enable-request
    :caption: SVC Protocol TimeSync Enable Request
    :spec: l l c c l

    =======  ============  ======  ==========  ========================================
    Offset   Field         Size    Value       Description
    =======  ============  ======  ==========  ========================================
    0        count         1       Number      Number of TIME_SYNC pulses
    1        frame_time    8       Number      The initial frame-time to intiailze to
    9        strobe_delay  4       Number      Inter-strobe delay in milliseconds
    13       refclk        4       Number      The clock rate of the frame-time counter
    =======  ============  ======  ==========  ========================================

..

Greybus SVC TimeSync Enable Response
""""""""""""""""""""""""""""""""""""

The Greybus SVC Protocol TimeSync Enable response contains no payload.

If the Response message header status field :ref:`greybus-operation-status`
is not equal to GB_OP_SUCCESS the AP shall immediately issue a
:ref:`svc-timesync-disable` to the set of Interfaces previously
indicated in the 'strobe_mask' field of the
:ref:`svc-timesync-wake-pins-acquire`. The AP shall then issue a
:ref:`svc-timesync-wake-pins-release` to the SVC.

If the Response message header status field :ref:`greybus-operation-status`
is equal to GB_OP_SUCCESS the SVC shall set the
:ref:`hardware-model-timesync-pulse` sub-state for the indicated set of
Interfaces to WAKE_ASSERTED and WAKE_DEASSERTED repeatedly to indicate
'count' number of :ref:`TimeSync Pulse <glossary-timesync-pulse>` events.
The SVC may send the response before initiating or completing the set of
:ref:`TimeSync Pulse <glossary-timesync-pulse>` events.

.. _svc-timesync-disable:

Greybus SVC TimeSync Disable Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP Module uses this operation to request the SVC stop tracking
frame-time. The SVC will immediately stop tracking frame-time.

Greybus SVC TimeSync Disable Request
""""""""""""""""""""""""""""""""""""

The Greybus SVC Protocol TimeSync Disable request contains no payload.

Greybus SVC TimeSync Disable Response
"""""""""""""""""""""""""""""""""""""

The Greybus SVC Protocol TimeSync Disable response contains no payload.
The SVC shall always return GB_OP_SUCCESS to this Operation. This Greybus
Operation does not affect any Interface sub-states.

.. _svc-timesync-authoritative:

Greybus SVC TimeSync Authoritative Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP Module uses this operation to request the SVC to send the
authoritative frame-time at each TIME_SYNC strobe. The SVC will return the
authoritative frame-time at each TIME_SYNC in the response phase of this
operation. Unused entires in the response frame shall be initialized to
zero.

Greybus SVC TimeSync Authoritative Request
""""""""""""""""""""""""""""""""""""""""""

The Greybus SVC Protocol TimeSync Authoritative Request contains no payload.

Greybus SVC TimeSync Authoritative Response
"""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-timesync-authoritative-response` defines the Greybus SVC
TimeSync Authoritative Response payload. The response specifies the
authoritative frame-time at each TIME_SYNC strobe. Unused slots in the
response shall contain zero. If the Response message header status field
:ref:`greybus-operation-status` is not equal to GB_OP_SUCCESS the values
in the Operation Response payload are undefined and shall be ignored. This
Greybus Operation does not affect any Interface sub-states.

.. figtable::
    :nofig:
    :label: table-svc-timesync-authoritative-response
    :caption: SVC Protocol TimeSync Enable Response
    :spec: l l c c l

    =======  ============  ======  ==========  ======================================
    Offset   Field         Size    Value       Description
    =======  ============  ======  ==========  ======================================
    0        time_sync0    8       Number      Authoritative frame-time at TIME_SYNC0
    8        time_sync1    8       Number      Authoritative frame-time at TIME_SYNC1
    16       time_sync2    8       Number      Authoritative frame-time at TIME_SYNC2
    24       time_sync3    8       Number      Authoritative frame-time at TIME_SYNC3
    =======  ============  ======  ==========  ======================================

..

.. _svc-timesync-wake-pins-acquire:

Greybus SVC TimeSync Wake Pins Acquire Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP Module uses this operation to request the SVC to take ownership-of and
to establish an initial state on a set of wake lines associated with
the indicated bit-mask of Interface IDs specified by the strobe_mask
parameter in the Request phase of the Operation.

The SVC will take control of the wake lines specified in the Request and
set the outputs to logical 0.

Greybus SVC TimeSync Wake Pins Acquire Request
""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-timesync-wake-pins-acquire-request` defines the Greybus SVC
TimeSync Wake Pins Acquire Request payload. The request supplies the
bit-mask (strobe_mask) of Interface IDs which should have their wake
pins set to output with logical state 0.

.. figtable::
    :nofig:
    :label: table-svc-timesync-wake-pins-acquire-request
    :caption: SVC Protocol TimeSync Wake Pins Acquire Request
    :spec: l l c c l

    =======  ============  ======  ==========  ========================================================
    Offset   Field         Size    Value       Description
    =======  ============  ======  ==========  ========================================================
    0        strobe_mask   4       Number      Bit-mask of Interface IDs SVC should allocate as outputs
    =======  ============  ======  ==========  ========================================================

..

Greybus SVC TimeSync Wake Pins Acquire Response
"""""""""""""""""""""""""""""""""""""""""""""""

The Greybus SVC Protocol TimeSync Wake Pins Acquire Response contains no payload.

If the Response message header status field :ref:`greybus-operation-status`
is equal to GB_OP_SUCCESS then the SVC shall set the the
:ref:`hardware-model-timesync-pulse` sub-state for the indicated set of
Interfaces to WAKE_UNSET. After this Operation completes the
:ref:`hardware-model-wake-pulse` shall be re-interpreted as a
:ref:`hardware-model-timesync-pulse` subject to the restrictions defined in
the hardware model.

If the Response message header status field
:ref:`greybus-operation-status` is not equal to GB_OP_SUCCESS the AP
shall abandon further TimeSync activities.

.. _svc-timesync-wake-pins-release:

Greybus SVC TimeSync Wake Pins Release Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP Module uses this operation to request the SVC to release ownership of any
previously allocated wake pins. The SVC shall release all pins allocated for
wake purposes in a previous successful Greybus SVC TimeSync Wake Pins Acquire
operation.

Greybus SVC TimeSync Wake Pins Release Request
""""""""""""""""""""""""""""""""""""""""""""""
The Greybus SVC Protocol TimeSync Wake Pins Release request contains no payload.

Greybus SVC TimeSync Wake Pins Release Response
"""""""""""""""""""""""""""""""""""""""""""""""

The Greybus SVC Protocol TimeSync Wake Pins Release Response contains no payload.
The SVC shall always return GB_OP_SUCCESS to this Operation. Before
completion of this Operation the the SVC shall set the
:ref:`hardware-model-timesync-pulse` sub-state for the set of Interfaces
previously indicated in the :ref:`svc-timesync-wake-pins-acquire` to
WAKE_UNSET. After this Operation completes the
:ref:`hardware-model-timesync-pulse` shall be re-interpreted as a
:ref:`hardware-model-wake-pulse` subject to the restrictions defined in
the hardware-model.

.. _svc-timesync-ping:

Greybus SVC TimeSync Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP Module uses this Operation to request the SVC to send a single TimeSync
event on a bitmask of wake pins which must have previously been allocated
via Greybus SVC TimeSync Wake Pins Acquire.

On receipt of this request the SVC will immediately generate a single pulse and
capture the authoritative frame-time; this frame-time will then be returned in
the response phase of the TimeSync Ping Operation.

Greybus SVC TimeSync Ping Request
"""""""""""""""""""""""""""""""""

The Greybus SVC Protocol TimeSync Ping Request contains no payload.

Greybus SVC TimeSync Ping Response
""""""""""""""""""""""""""""""""""

Table :num:`table-svc-timesync-ping-response` defines the Greybus SVC
TimeSync Ping Response payload. The response specifies the
authoritative frame-time at the ping event generated. If the Response
message header status field :ref:`greybus-operation-status` is not
equal to GB_OP_SUCCESS the values in the Operation Response payload
are undefined and shall be ignored. This Greybus Operation does not affect
any Interface sub-states.

.. figtable::
    :nofig:
    :label: table-svc-timesync-ping-response
    :caption: SVC Protocol TimeSync Ping Response
    :spec: l l c c l

    =======  ============  ======  ==========  ======================================
    Offset   Field         Size    Value       Description
    =======  ============  ======  ==========  ======================================
    0        frame-time    8       Number      Authoritative frame-time at ping event
    =======  ============  ======  ==========  ======================================

..

.. _svc-module-eject:

Greybus SVC Module Eject Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Module Eject operation is sent by the AP Module
to request the SVC to execute the necessary actions to eject a
Module from the Frame.

Although the AP may send this Operation's request at any time
following a successful :ref:`svc-hello`, the AP should ensure that the
:ref:`Interface Lifecycle State <hardware-model-lifecycle-states>` of
each of the Interfaces in the attached Module is either
:ref:`hardware-model-lifecycle-attached` or
:ref:`hardware-model-lifecycle-off` before doing so. Otherwise, the
effect on the Greybus System is equivalent to a
:ref:`lifecycles_forcible_removal` of the Module, and may otherwise
disrupt the operation of the System.

Greybus SVC Module Eject Request
""""""""""""""""""""""""""""""""

The Greybus SVC Module Eject Request is defined in Table
:num:`table-svc-module-eject-request`.  The primary_intf_id field in
the request payload contains the Interface ID of the Primary
Interface to the Module which the SVC shall eject from the Frame.

.. figtable::
    :nofig:
    :label: table-svc-module-eject-request
    :caption: SVC Protocol Module Eject Request
    :spec: l l c c l

    =======  ===============  ====  ========    ===========================
    Offset   Field            Size  Value       Description
    =======  ===============  ====  ========    ===========================
    0        primary_intf_id  1     Number      Module location
    =======  ===============  ====  ========    ===========================

..

The SVC shall not perform any checking of the Interface State with ID
given by the primary_intf_id field beyond ensuring it is a valid
Interface ID.

After receiving the request, the SVC shall set the
:ref:`hardware-model-release` sub-state for that Interface State to
RELEASE_ASSERTED before sending a response back to the AP. The SVC may
send the result before setting RELEASE back to RELEASE_DEASSERTED;
that is, the RELEASE pulse may end after the AP has already received the
response.

Greybus SVC Module Eject Response
"""""""""""""""""""""""""""""""""

The Greybus SVC Module Eject response message contains no payload.

As described in :ref:`hardware-model-release`, a RELEASE pulse is only
an attempt to eject the Module. The Module may still be in the
MODULE_ATTACHED state after the AP receives the result. Furthermore,
the RELEASE pulse may fail to eject the Module.

If the release pulse is successful, the AP will receive a subsequent
notification from the SVC in the form of a :ref:`svc-module-removed`
request.

.. _svc-key-event:

Greybus SVC Key Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The SVC uses this operation to indicate that a key connected to the SVC
generated an event.

Greybus SVC Key Event Request
"""""""""""""""""""""""""""""

The Greybus SVC Protocol Key Event Request signals to the recipient that an
event has occurred on a Key attached to SVC.
Table :num:`table-svc-key-event-request` defines the request, in which it
supplies a key code and an event type.

.. figtable::
    :nofig:
    :label: table-svc-key-event-request
    :caption: SVC Protocol Key Event Request
    :spec: l l c c l

    =======  ============  ======  ==========  ======================================
    Offset   Field         Size    Value       Description
    =======  ============  ======  ==========  ======================================
    0        key_code      2       Number      :ref:`svc-key-code`
    2        key_event     1       Number      :ref:`svc-key-events`
    =======  ============  ======  ==========  ======================================

..

.. _svc-key-code:

Greybus SVC Key Codes
"""""""""""""""""""""

Table :num:`table-svc-key-codes` defines the values of allowed key codes to be
included in Key Event Request.

.. figtable::
    :nofig:
    :label: table-svc-key-codes
    :caption: SVC key codes
    :spec: l l l

    ====================  ====================================  ============
    Key Codes             Brief Description                     Value
    ====================  ====================================  ============
    GB_KEYCODE_ARA        Key code for Ara specific key         0x00
    |_|                   (all other values reserved)           0x01..0xFF
    ====================  ====================================  ============

..

.. _svc-key-events:

Greybus SVC Key Events
""""""""""""""""""""""

Table :num:`table-svc-key-events` defines the values of allowed key events to be
included in Key Event Request.

.. figtable::
    :nofig:
    :label: table-svc-key-events
    :caption: SVC key events
    :spec: l l l

    ====================  ====================================  ============
    Key Events            Brief Description                     Value
    ====================  ====================================  ============
    GB_SVC_KEY_RELEASED   Key event representing key release    0x00
    GB_SVC_KEY_PRESSED    Key event representing key pressed    0x01
    |_|                   (all other values reserved)           0x02..0xFF
    ====================  ====================================  ============
..

.. _svc-power-monitor-get-rail-count:

Greybus SVC Power Monitor Get Rail Count Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Power Monitor Get Rail Count operation retrieves the
number of power rails for which power measurement is supported.

Greybus SVC Power Monitor Get Rail Count Request
""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus SVC Power Monitor Get Rail Count request is sent from
the AP only. It has no payload.

Greybus SVC Power Monitor Get Rail Count Response
"""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus SVC Power Monitor Get Rail Count response contains
a 1-byte field 'rail_count'. The maximum supported number of rails
is 254, 255 (0xff) is an invalid value. The rail count can equal 0
in which case no rail can be measured by the SVC.

.. figtable::
    :nofig:
    :label: table-svc-powermon-get-rail-count-response
    :caption: SVC Power Monitor Get Rail Count Response
    :spec: l l l l l

    =======  ==============  ===========  ==========      ===========================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ===========================
    0        rail_count      1            Number          Number of power rails
    =======  ==============  ===========  ==========      ===========================

..

.. _svc-power-monitor-get-rail-names:

Greybus SVC Power Monitor Get Rail Names Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Power Monitor Get Rail Names operation requests
the names of all power rails for which power measurement is supported.

Greybus SVC Power Monitor Get Rail Names Request
""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus SVC Power Monitor Get Rail Names request is sent from
the AP only. It has no payload.

Greybus SVC Power Monitor Get Rail Names Response
"""""""""""""""""""""""""""""""""""""""""""""""""
Table :num:`table-svc-powermon-get-rail-names-response` defines the Greybus SVC
Power Monitor Get Rail Names Response payload. If the Response message header
has the :ref:`greybus-operation-status` not equal to GB_OP_SUCCESS, the
values in the Operation Response payload are undefined and shall be ignored.

Otherwise, If the status field in the Operation Response payload is not
GB_SVC_OP_SUCCESS, values in all other fields of the Operation Response payload
are undefined and shall be ignored.

The Greybus SVC Power Monitor Get Rail Names Response payload is comprised of
human-readable names for rails that support voltage, current and power
measurement. Each name consists of a fixed 32-byte sub-buffer
containing a rail name padded with zero bytes. A rail name is comprised of a
subset of [US-ASCII]_ characters: lower- and upper-case alphanumerics and the
character '_'. A rail name is 1-32 bytes long; a 32-byte name has no pad bytes.

The number of these buffers shall be exactly the number returned by
a prior Greybus SVC Power Monitor Get Rail Name Count operation.

If there are no measurable power rails on the platform, the status field in the
Operation Response payload shall be set to GB_SVC_PWRMON_OP_NOT_PRESENT.

Each rail has an implicit 'Rail ID' which is equal to its position in
the array of rail names returned by this response. The rail whose name
is first in the array shall have Rail ID 0, the second shall have Rail
ID 1, and so on. Despite using numeric IDs, the rail names returned by
this operation are guaranteed to be unique.

.. figtable::
    :nofig:
    :label: table-svc-powermon-get-rail-names-response
    :caption: SVC Power Monitor Get Rail Names Response
    :spec: l l l l l

    =======  ==============  ===========  ==========      ===========================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ===========================
    0        status          1            Number          :ref:`svc-protocol-op-status`
    1        rail_1_name     32           String          Rail #1 name
    33       rail_2_name     32           String          Rail #2 name
    (...)
    =======  ==============  ===========  ==========      ===========================

..

.. _svc-power-monitor-get-sample:

Greybus SVC Power Monitor Get Sample Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Power Monitor Get Sample operation shall be used by
the AP to retrieve a single measurement.

Greybus SVC Power Monitor Get Sample Request
""""""""""""""""""""""""""""""""""""""""""""

The Greybus SVC Power Monitor Get Sample request is sent from the AP
only. It contains the ID of the rail and the measurement type
(current, voltage, power).

.. figtable::
    :nofig:
    :label: table-svc-powermon-get-sample-request
    :caption: SVC Power Monitor Get Sample Request
    :spec: l l l l l

    =======  ==============  ===========  ==========      ===========================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ===========================
    0        rail_id         1            Number          ID of the rail that shall be measured
    1        type            1            Number          Measurement type indicator (:ref:`svc-pwrmon-measurement-types`)
    =======  ==============  ===========  ==========      ===========================

..

.. _svc-pwrmon-measurement-types:

Greybus SVC Power Monitor Get Sample Type Indicators
""""""""""""""""""""""""""""""""""""""""""""""""""""

.. figtable::
    :nofig:
    :label: table-svc-pwrmon-measurement-types
    :caption: SVC Power Monitor measurement types
    :spec: l l l

    ============================  ========================================  ============
    Measurement type              Brief Description                         Value
    ============================  ========================================  ============
    GB_SVC_PWRMON_TYPE_INVALID    Invalid request value                     0x00
    GB_SVC_PWRMON_TYPE_CURR       Current measurement in microamps (uA)     0x01
    GB_SVC_PWRMON_TYPE_VOL        Voltage measurement in microvolts (uV)    0x02
    GB_SVC_PWRMON_TYPE_PWR        Power measurement in microwatts (uW)      0x03
    |_|                           (all other values reserved)               0x04..0xFF
    ============================  ========================================  ============

..

Greybus SVC Power Monitor Get Sample Response
"""""""""""""""""""""""""""""""""""""""""""""

The Greybus SVC Power Monitor Get Sample response contains a 1-byte
result code and the measured value in a 4-byte unsigned integer. Units
in which the retrieved values are represented are as follows:
microvolts for voltage, microamps for current and microwatts for
power.

.. figtable::
    :nofig:
    :label: table-svc-powermon-get-sample-response
    :caption: SVC Power Monitor Get Sample Response
    :spec: l l l l l

    =======  ==============  ===========  ==========      ===========================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ===========================
    0        result          1            Number          Result code (:ref:`svc-pwrmon-get-sample-results`)
    1        measurement     4            Number          Measured value
    =======  ==============  ===========  ==========      ===========================

..

.. _svc-pwrmon-get-sample-results:

Greybus SVC Power Monitor Get Sample Result Codes
"""""""""""""""""""""""""""""""""""""""""""""""""

.. figtable::
    :nofig:
    :label: table-svc-pwrmon-get-sample-results
    :caption: SVC Power Monitor Get Sample result codes
    :spec: l l l

    ==================================  ========================================  ============
    Result code                         Brief Description                         Value
    ==================================  ========================================  ============
    GB_SVC_PWRMON_GET_SAMPLE_OK         Measurement OK                            0x00
    GB_SVC_PWRMON_GET_SAMPLE_INVAL      Invalid ID provided in request            0x01
    GB_SVC_PWRMON_GET_SAMPLE_NOSUPP     Measurement not supported for this ID     0x02
    GB_SVC_PWRMON_GET_SAMPLE_HWERR      Internal hardware error                   0x03
    |_|                                 (all other values reserved)               0x04..0xFF
    ==================================  ========================================  ============

..

.. _svc-power-monitor-interface-get-sample:

Greybus SVC Power Monitor Interface Get Sample Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Power Monitor Interface Get Sample operation shall be
used by the AP to retrieve a single measurement for the given
interface.

Unlike the Greybus SVC Power Monitor Get Sample operation it does not
require any preceding data exchange nor any prior knowledge about the
power rails layout. It retrieves a single power supply measurement of
the interface.

Greybus SVC Power Monitor Interface Get Sample Request
""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus SVC Power Monitor Interface Get Sample Request can only be
sent from the AP. It contains a 1-byte interface ID and 1-byte
measurement type (voltage, current, power).

.. figtable::
    :nofig:
    :label: table-svc-powermon-intf-get-sample-request
    :caption: SVC Power Monitor Interface Get Sample Request
    :spec: l l l l l

    =======  ==============  ===========  ==========      ===========================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ===========================
    0        intf_id         1            Number          ID of the interface
    1        type            1            Number          Measurement type indicator (:ref:`svc-pwrmon-measurement-types`)
    =======  ==============  ===========  ==========      ===========================

..

Greybus SVC Power Monitor Interface Get Sample Response
"""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus SVC Power Monitor Interface Get Sample response contains
a 1-byte operation result code and the measured value in a 4-byte
unsigned integer. Units in which the retrieved values are represented
are as follows: microvolts for voltage, microamps for current and
microwatts for power.

.. figtable::
    :nofig:
    :label: table-svc-powermon-intf-get-sample-response
    :caption: SVC Power Monitor Interface Get Sample Response
    :spec: l l l l l

    =======  ==============  ===========  ==========      ===========================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ===========================
    0        result          1            Number          Result code (:ref:`svc-pwrmon-get-sample-results`)
    1        measurement     4            Number          Measured value
    =======  ==============  ===========  ==========      ===========================

..

.. _svc-power-down:

Greybus SVC Power Down Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Power Down operation shall be used by the AP to request
the SVC to forcibly power down all the devices under its control and
then put itself in power down mode.  Prior to issuing such operation,
the AP shall close all Greybus communication with all interfaces and
then power all interfaces down.

When the SVC Power Down operation completes, the Greybus subsystem is no
more operational: hotplug detection is unavailable, no Greybus
communication with any interface is possible, and SVC is unable to
process any new Greybus operation or event.

The SVC shall be reset to recover from this state.

Greybus SVC Power Down Request
""""""""""""""""""""""""""""""

The Greybus SVC Power Down request message contains no payload.

Greybus SVC Power Down Response
"""""""""""""""""""""""""""""""

The Greybus SVC Power Down response message contains no payload.

..

.. _svc-module-inserted:

Greybus SVC Module Inserted Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Module Inserted request is sent by the SVC to the AP
Module to indicate that a new Module has been inserted into the Frame,
as well as during initialization of a Greybus System, to inform the AP
of Modules which were already attached to the Frame.

Greybus SVC Module Inserted Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-svc-module-inserted-request` defines the Greybus SVC
Module Inserted request payload.  The request specifies the location
of the :ref:`Primary Interface <glossary-primary-interface>` to the
newly inserted Module in the primary_intf_id field.  It also specifies
the number of Interfaces covered by the Module in the intf_count
field; this includes the Primary Interface, plus the total number of
:ref:`Secondary Interfaces <glossary-secondary-interface>` to the
Module, if any. The size of a Module (the value of the intf_count
field in the Module Inserted request payload) is thus always one or more.

.. figtable::
    :nofig:
    :label: table-svc-module-inserted-request
    :caption: SVC Protocol Module Inserted Request
    :spec: l l c c l

    =======  ===============  ====  ======  ====================
    Offset   Field            Size  Value   Description
    =======  ===============  ====  ======  ====================
    0        primary_intf_id  1     Number  Module location
    1        intf_count       1     Number  Number of Interfaces covered by Module
    2        flags            2     Number  See Table :num:`table-svc-module-inserted-flags`
    =======  ===============  ====  ======  ====================

..

The flags field in the request payload is a bit mask which allows the
SVC to notify the AP of additional conditions associated with the
insertion event. The mask values for the flags field are defined in
Table :num:`table-svc-module-inserted-flags`.

.. figtable::
   :nofig:
   :label: table-svc-module-inserted-flags
   :caption: Flags for SVC Module Inserted Request
   :spec: l r l

   =========================== =========    ===============================
   Flag                        Value        Description
   =========================== =========    ===============================
   NO_PRIMARY_INTERFACE        0x1          No Primary Interface to Module detected
   =========================== =========    ===============================

..

The NO_PRIMARY_INTERFACE mask for the flags field allows the SVC to
notify the AP when an error has occurred, and no Primary Interface to
the Module was detected.

If the NO_PRIMARY_INTERFACE flag is set in the Module Inserted
Request, the intf_count field shall equal one. The Interface State
with Interface ID primary_intf_id shall have
:ref:`hardware-model-order` equal to ORDER_SECONDARY.

If the NO_PRIMARY_INTERFACE flag is not set in the Module Inserted
request, then the Interface State with Interface ID primary_intf_id
has :ref:`hardware-model-order` equal to ORDER_PRIMARY. If intf_count
is greater than one, all Interface States with IDs from
(primary_intf_id + 1) through (primary_intf_id + intf_count - 1),
inclusive, have ORDER equal to ORDER_SECONDARY.

In all cases, regardless of the value of the flags field, every
Interface identified by the request is in the
:ref:`hardware-model-lifecycle-attached` :ref:`Lifecycle State
<hardware-model-lifecycle-states>`. After sending the response to this
request, the AP may thus subsequently attempt to :ref:`enumerate
<hardware-model-lifecycle-enumerated>` these Interfaces.

Additionally, the entire Module has transitioned to the
MODULE_ATTACHED state, as described in
:ref:`lifecycles_module_attach`.

The consequences of boot and enumeration when the NO_PRIMARY_INTERFACE
flag is set are unspecified.

During the initialization of a Greybus System, following a successful
:ref:`svc-hello`, the SVC shall attempt to exchange Module Inserted
Operations with the AP for each attached Module.

Unless an error occurs, there is a unique Primary Interface to each
Module attached to the Frame. The number of Operations exchanged
during initialization is thus at least the number of
:ref:`hardware-model-interface-states` that are
:ref:`hardware-model-lifecycle-attached` and whose
:ref:`hardware-model-order` is ORDER_PRIMARY. The primary_intf_id
fields in these requests shall be the Interface IDs of the Interface
States whose ORDER is ORDER_PRIMARY.

There may be additional Secondary Interfaces to each of these
Modules. The intf_count field in each such request shall thus equal
one plus the number of consecutive Interface States in the Greybus
System whose ORDER is ORDER_SECONDARY, starting from the Primary
Interfaces to each attached Module, up to the final Interface Block in
the :ref:`Slot <glossary-slot>`. This follows from the definitions of
the ORDER sub-state and the intf_count request field.

The SVC may also send additional Module Inserted Requests with the
NO_PRIMARY_INTERFACE flag set, as described above.

Greybus SVC Module Inserted Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Module Inserted response message contains no payload.

.. _svc-module-removed:

Greybus SVC Module Removed Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Module Removed request is sent by the SVC
to the AP Module.  It supplies the Interface ID for the Primary
Interface to the Module that is no longer present.  The Interface
ID shall have been the subject of a previous
:ref:`svc-module-inserted`.

Greybus SVC Module Removed Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-svc-module-removed-request` defines the Greybus SVC
Module Removed request payload.  The request specifies the Primary
Interface ID for the Module that is no longer present.

.. figtable::
    :nofig:
    :label: table-svc-module-removed-request
    :caption: SVC Protocol Module Removed Request
    :spec: l l c c l

    =======  ===============  ====  ======  ====================
    Offset   Field            Size  Value   Description
    =======  ===============  ====  ======  ====================
    0        primary_intf_id  1     Number  Module location
    =======  ===============  ====  ======  ====================

..

Using the most recent Module Inserted Operation on the SVC protocol
whose primary_intf_id field equaled the primary_intf_id field in this
request, the SVC notified the AP that one or more :ref:`Interfaces
<hardware-model-interfaces>` were
:ref:`hardware-model-lifecycle-attached`.

The current Lifecycle States of each of these Interfaces can be
determined as follows.

- If the Interface was :ref:`hardware-model-lifecycle-attached`
  or :ref:`hardware-model-lifecycle-off`, then the Interface is
  now :ref:`hardware-model-lifecycle-detached`.

- Otherwise, a forcible removal has occurred, as described in the
  :ref:`hardware-model-detect` section. When this occurs, the
  Interface's Lifecycle State is unpredictable.

Following a forcible removal, the AP and SVC shall proceed as
described in :ref:`lifecycles_forcible_removal`.

The Module is now in the MODULE_DETACHED state, as described in
:ref:`lifecycles_module_detach`.

Greybus SVC Module Removed Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Module Removed response message contains no payload.

.. _svc-interface-vsys-enable:

Greybus SVC Interface V_SYS Enable Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP uses this Operation to request the SVC to set an
:ref:`Interface State's <hardware-model-interface-states>`
:ref:`hardware-model-vsys` to V_SYS_ON.

Though the AP may send this request at any time, the AP should only do
so as part of the "boot" and "reboot" transitions in the
:ref:`Interface Lifecycle <hardware-model-lifecycle-states>` state
machine, as described in :ref:`lifecycles_boot` and
:ref:`lifecycles_reboot`.

The SVC shall not set V_SYS to V_SYS_ON except as a result of
receiving a Greybus V_SYS Enable Request.

Greybus SVC Interface V_SYS Enable Request
""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-vsys-enable-request` defines the Greybus SVC
Interface V_SYS Enable Request payload.

.. figtable::
    :nofig:
    :label: table-svc-interface-vsys-enable-request
    :caption: SVC Protocol Interface V_SYS Enable Request
    :spec: l l c c l

    =======  ==============  ======  ============    ============
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ============
    0        intf_id         1       Interface ID    Interface ID
    =======  ==============  ======  ============    ============
..

The SVC, on receiving this request, shall attempt to set the V_SYS
sub-state of the Interface State specified by the intf_id field to
V_SYS_ON.

.. _svc-interface-vsys-enable-response:

Greybus SVC Interface V_SYS Enable Response
"""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-vsys-enable-response` defines the Greybus SVC
Interface V_SYS Enable Response payload. The Operation Response payload
contains a one-byte result_code field.

.. figtable::
    :nofig:
    :label: table-svc-interface-vsys-enable-response
    :caption: SVC Protocol Interface V_SYS Enable Response
    :spec: l l c c l

    =======  ===========  ======  ==========  ===========
    Offset   Field        Size    Value       Description
    =======  ===========  ======  ==========  ===========
    0        result_code  1       Number      Result Code
    =======  ===========  ======  ==========  ===========
..

The :ref:`greybus-operation-status` in the Operation Response message
header shall not be used to determine the value of V_SYS sub-state after the
response is received. It shall only be used to indicate the result of the
Greybus communication.  If the Greybus SVC Interface V_SYS Enable Response
message header has the :ref:`greybus-operation-status` value different than
GB_OP_SUCCESS, a Greybus communication error has occurred; the V_SYS
sub-state identified in the Operation Request shall not have changed as a
result of processing the Request. If the Greybus SVC Interface V_SYS Enable
Response message header has the :ref:`greybus-operation-status` equal to
GB_OP_SUCCESS, it shall indicate that no Greybus communication error was
detected.

However, a :ref:`greybus-operation-status` in the Response message header
equal to GB_OP_SUCCESS alone does not imply the intended V_SYS is now V_SYS_ON.
When the Response message header has the :ref:`greybus-operation-status`
equal to GB_OP_SUCCESS, the value of V_SYS may be determined given the
result_code field in the Operation Response payload, as described in Table
:num:`table-svc-interface-vsys-result-code`. In particular, V_SYS is V_SYS_ON
if the Response message header has :ref:`greybus-operation-status` equal to
GB_OP_SUCCESS and the result_code in the Operation Response payload is
V_SYS_OK. V_SYS shall not have changed value as a result of processing the
Request in any other combination of these two fields.

.. figtable::
    :nofig:
    :label: table-svc-interface-vsys-result-code
    :caption: Interface V_SYS Enable and Interface V_SYS Disable result_code
    :spec: l l l

    ================  ========  ======================================================================
    Result Code       Value     Description
    ================  ========  ======================================================================
    V_SYS_OK          0         V_SYS enable/disable operation was successful.
    V_SYS_BUSY        1         V_SYS enable/disable operation cannot be attempted as the SVC is busy.
    V_SYS_FAIL        2         V_SYS enable/disable was attempted and failed.
    (Reserved)        3-255     (Reserved for future use)
    ================  ========  ======================================================================
..

.. _svc-interface-vsys-disable:

Greybus SVC Interface V_SYS Disable Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP uses this Operation to request the SVC to set an
:ref:`Interface State's <hardware-model-interface-states>`
:ref:`hardware-model-vsys` to V_SYS_OFF.

Though the AP may send this request at any time, the AP should only do
so under one of the following conditions:

- during the "power_down" and "early_power_down" transitions in the
  :ref:`Interface Lifecycle <hardware-model-lifecycle-states>` state
  machine, as described in :ref:`lifecycles_power_down` and
  :ref:`lifecycles_early_power_down`.

- during the "forcible_removal" transition in the Interface Lifecycle
  state machine, as described in :ref:`lifecycles_forcible_removal`.

The SVC shall set V_SYS to V_SYS_OFF without having received an
Interface V_SYS Disable Request only under the conditions specified in
:ref:`hardware-model-vsys`.

Greybus SVC Interface V_SYS Disable Request
"""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-vsys-disable-request` defines the Greybus SVC
Interface V_SYS Disable Request payload.

.. figtable::
    :nofig:
    :label: table-svc-interface-vsys-disable-request
    :caption: SVC Protocol Interface V_SYS Disable Request
    :spec: l l c c l

    =======  ==============  ======  ============    ============
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ============
    0        intf_id         1       Interface ID    Interface ID
    =======  ==============  ======  ============    ============
..

The SVC, on receiving this request, shall attempt to set the V_SYS
sub-state of the Interface State specified by the intf_id field to
V_SYS_OFF.

Greybus SVC Interface V_SYS Disable Response
""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-vsys-disable-response` defines the Greybus SVC
Interface V_SYS Disable Response payload. The Operation Response payload
contains a one-byte result_code field.

.. figtable::
    :nofig:
    :label: table-svc-interface-vsys-disable-response
    :caption: SVC Protocol Interface V_SYS Disable Response
    :spec: l l c c l

    =======  ===========  ======  ==========  ===========
    Offset   Field        Size    Value       Description
    =======  ===========  ======  ==========  ===========
    0        result_code  1       Number      Result Code
    =======  ===========  ======  ==========  ===========
..

The meaning of the :ref:`greybus-operation-status` in the Operation
Response message header and the result_code in the Operation Response payload
are analogous to the corresponding :ref:`greybus-operation-status` in the
Interface V_SYS Enable Response message header and the result_code field in the
Interface V_SYS Enable Operation Response payload.

That is, the :ref:`greybus-operation-status` of the Operation Response message
header shall only be used to indicate the result of the Greybus communication,
exactly as described in :ref:`svc-interface-vsys-enable-response`.

Similarly, when the Interface V_SYS Disable Response message header has the
:ref:`greybus-operation-status` equal to GB_OP_SUCCESS, the value of V_SYS
may be determined given the result_code field in the Operation Response
payload, as described in Table :num:`table-svc-interface-vsys-result-code`. In
particular, V_SYS is V_SYS_OFF if Response message header has the
:ref:`greybus-operation-status` equal to GB_OP_SUCCESS and the result_code
field in the Operation Response payload is V_SYS_OK. V_SYS shall not have
changed value as a result of processing the Request in any other combination of
these two fields.

.. _svc-interface-refclk-enable:

Greybus SVC Interface REFCLK Enable Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP uses this Operation to request the SVC to set an
:ref:`Interface State's <hardware-model-interface-states>`
:ref:`hardware-model-refclk` to REFCLK_ON.

Though the AP may send this request at any time, the AP should only do
so under one of the following conditions:

- during the "boot" and "reboot" transitions in the :ref:`Interface
  Lifecycle <hardware-model-lifecycle-states>` state machine, as
  described in :ref:`lifecycles_boot` and :ref:`lifecycles_reboot`.

- while the Interface is :ref:`hardware-model-lifecycle-enumerated`,
  if REFCLK is REFCLK_OFF and the AP has determined using
  application-specific means that REFCLK should be set to REFCLK_ON.

- if the Interface is :ref:`hardware-model-lifecycle-enumerated` and
  REFCLK is REFCLK_OFF, during the "ms_enter" transition in the
  Interface Lifecycle state machine, as described in
  :ref:`lifecycles_ms_enter`.

- during the "resume" transition in the Interface Lifecycle state
  machine, as described in :ref:`lifecycles_resume`.

The SVC shall not set REFCLK to REFCLK_ON except as a result of
receiving a Greybus REFCLK Enable Request.

Greybus SVC Interface REFCLK Enable Request
"""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-refclk-enable-request` defines the Greybus SVC
Interface REFCLK Enable Request payload.

.. figtable::
    :nofig:
    :label: table-svc-interface-refclk-enable-request
    :caption: SVC Protocol Interface REFCLK Enable Request
    :spec: l l c c l

    =======  ==============  ======  ============    ============
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ============
    0        intf_id         1       Interface ID    Interface ID
    =======  ==============  ======  ============    ============
..

The SVC, on receiving this request, shall attempt to set the REFCLK
sub-state of the Interface State specified by the intf_id field to
REFCLK_ON.

.. _svc-interface-refclk-enable-response:

Greybus SVC Interface REFCLK Enable Response
""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-refclk-enable-response` defines the
Greybus SVC Interface REFCLK Enable Response payload. The Operation
Response payload contains a one-byte result_code field.

.. figtable::
    :nofig:
    :label: table-svc-interface-refclk-enable-response
    :caption: SVC Protocol Interface REFCLK Enable Response
    :spec: l l c c l

    =======  ===========  ======  ==========  ===========
    Offset   Field        Size    Value       Description
    =======  ===========  ======  ==========  ===========
    0        result_code  1       Number      Result Code
    =======  ===========  ======  ==========  ===========
..

The :ref:`greybus-operation-status` in the Operation Response message
header shall not be used to determine the value of REFCLK sub-state after the
response is received. It shall only be used to indicate the result of the
Greybus communication.  If the Greybus SVC Interface REFCLK Enable Response
message header has the :ref:`greybus-operation-status` value different than
GB_OP_SUCCESS, a Greybus communication error has occurred; the REFCLK sub-state
identified in the Operation Request shall not have changed as a result of
processing the request. If the Greybus SVC Interface REFCLK Enable Response
message header has the :ref:`greybus-operation-status` equal to
GB_OP_SUCCESS, it shall indicate that no Greybus communication error was
detected.

However, a :ref:`greybus-operation-status` in the Response message header
equal to GB_OP_SUCCESS alone does not imply the intended REFCLK is now
REFCLK_ON. When the Response message header has the
:ref:`greybus-operation-status` equal to GB_OP_SUCCESS, the value of REFCLK
may be determined given the result_code field in the Operation Response
payload, as described in Table :num:`table-svc-interface-refclk-result-code`.
In particular, REFCLK is REFCLK_ON if the Response message header has the
:ref:`greybus-operation-status` equal to GB_OP_SUCCESS and the result_code
in the Operation Response payload is REFCLK_OK. REFCLK shall not have changed
value as a result of processing the request in any other combination of these
two fields.

.. figtable::
    :nofig:
    :label: table-svc-interface-refclk-result-code
    :caption: Interface REFCLK Enable and Interface REFCLK Disable result_code
    :spec: l l l

    ================  ========  ======================================================================
    Result Code       Value     Description
    ================  ========  ======================================================================
    REFCLK_OK         0         REFCLK enable/disable operation was successful.
    REFCLK_BUSY       1         REFCLK enable/disable operation cannot be attempted as the SVC is busy.
    REFCLK_FAIL       2         REFCLK enable/disable was attempted and failed.
    (Reserved)        3-255     (Reserved for future use)
    ================  ========  ======================================================================
..

.. _svc-interface-refclk-disable:

Greybus SVC Interface REFCLK Disable Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP uses this Operation to request the SVC to set an
:ref:`Interface State's <hardware-model-interface-states>`
:ref:`hardware-model-refclk` to REFCLK_OFF.

Though the AP may send this request at any time, the AP should only do
so under one of the following conditions:

- during "early_power_down" transition in the :ref:`Interface
  Lifecycle <hardware-model-lifecycle-states>` state machine, as
  described in :ref:`lifecycles_early_power_down`.

- while the Interface is :ref:`hardware-model-lifecycle-enumerated`,
  if REFCLK is REFCLK_ON and the AP has determined using
  application-specific means that REFCLK should be set to REFCLK_OFF.

- if the Interface is :ref:`hardware-model-lifecycle-enumerated`
  and REFCLK is REFCLK_ON, during the "power_down" transition in the
  Interface Lifecycle state machine, as described in
  :ref:`lifecycles_power_down`.

- if the Interface is :ref:`hardware-model-lifecycle-enumerated`
  and REFCLK is REFCLK_ON, during the "suspend" transition in the
  Interface Lifecycle state machine, as described in
  :ref:`lifecycles_suspend`.

- during the "forcible_removal" transition in the Interface Lifecycle
  state machine, as described in :ref:`lifecycles_forcible_removal`.

The SVC shall set REFCLK to REFCLK_OFF without having received an
Interface REFCLK Disable Request only under the conditions specified in
:ref:`hardware-model-refclk`.

Greybus SVC Interface REFCLK Disable Request
""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-refclk-disable-request` defines the Greybus SVC
Interface REFCLK Disable Request payload.

.. figtable::
    :nofig:
    :label: table-svc-interface-refclk-disable-request
    :caption: SVC Protocol Interface REFCLK Disable Request
    :spec: l l c c l

    =======  ==============  ======  ============    ============
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ============
    0        intf_id         1       Interface ID    Interface ID
    =======  ==============  ======  ============    ============
..

The SVC, on receiving this request, shall attempt to set the REFCLK
sub-state of the Interface State specified by the intf_id field to
REFCLK_OFF.

Greybus SVC Interface REFCLK Disable Response
"""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-refclk-disable-response` defines the
Greybus SVC Interface REFCLK Disable Response payload. The Operation
Response payload contains a one-byte result_code field.

.. figtable::
    :nofig:
    :label: table-svc-interface-refclk-disable-response
    :caption: SVC Protocol Interface REFCLK Disable Response
    :spec: l l c c l

    =======  ===========  ======  ==========  ===========
    Offset   Field        Size    Value       Description
    =======  ===========  ======  ==========  ===========
    0        result_code  1       Number      Result Code
    =======  ===========  ======  ==========  ===========
..

The meaning of the :ref:`greybus-operation-status` in the Operation
Response message header and the result_code in the Operation Response payload
are analogous to the corresponding :ref:`greybus-operation-status` in the
Interface REFCLK Enable Response message header and the result_code field in the
Interface REFCLK Enable Operation Response payload.

That is, the :ref:`greybus-operation-status` of the Operation Response message
header shall only be used to indicate the result of the Greybus communication,
exactly as described in :ref:`svc-interface-refclk-enable-response`.

Similarly, when the Interface REFCLK Disable Response message header has the
:ref:`greybus-operation-status` equal to GB_OP_SUCCESS, the value of REFCLK
may be determined given the result_code field in the Operation Response
payload, as described in Table :num:`table-svc-interface-refclk-result-code`.
In particular, REFCLK is REFCLK_OFF if the Response message header has
:ref:`greybus-operation-status` equal to GB_OP_SUCCESS and the result_code
field in the Operation Response payload is REFCLK_OK. REFCLK shall not have
changed value as a result of processing the Request in any other combination
of these two fields.

.. _svc-interface-unipro-enable:

Greybus SVC Interface UNIPRO Enable Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP uses this Operation to request the SVC to set an
:ref:`Interface State's <hardware-model-interface-states>`
:ref:`hardware-model-unipro` to UPRO_DOWN.

.. note:: Important:

          1. This operation will *not* result in UNIPRO being
             UPRO_UP. The |unipro| state machine requires
             communication between peers before entering the state
             modeled by the UPRO_UP value of a Greybus Interface
             State's UNIPRO sub-state. The process by which UNIPRO
             transitions from UPRO_DOWN to UPRO_UP is described in
             :ref:`lifecycles_boot`.

          2. There are additional UNIPRO sub-state values which
             similarly are not reachable using this operation alone.

Though the AP may send this request at any time, the AP should only do
so during the "boot" and "reboot" transitions in the :ref:`Interface
Lifecycle <hardware-model-lifecycle-states>` state machine, as
described in :ref:`lifecycles_boot` and :ref:`lifecycles_reboot`.

The SVC shall not set UNIPRO to UPRO_DOWN except as a result of
receiving a Greybus UNIPRO Enable Request.

Greybus SVC Interface UNIPRO Enable Request
"""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-unipro-enable-request` defines the Greybus SVC
Interface UNIPRO Enable Request payload.

.. figtable::
    :nofig:
    :label: table-svc-interface-unipro-enable-request
    :caption: SVC Protocol Interface UNIPRO Enable Request
    :spec: l l c c l

    =======  ==============  ======  ============    ============
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ============
    0        intf_id         1       Interface ID    Interface ID
    =======  ==============  ======  ============    ============
..

The SVC, on receiving this request, shall check the UNIPRO sub-state
of the Interface State with Interface ID intf_id. If UNIPRO is not
UPRO_OFF, the SVC shall not attemp to change the UNIPRO sub-state
value. The SVC shall signal an error to the AP in the response as
described below, and shall take no further action related to this
request.

If UNIPRO is UPRO_OFF, the SVC shall attempt to set the UNIPRO
sub-state of the Interface State specified by the intf_id field to
UPRO_DOWN.

.. _svc-interface-unipro-enable-response:

Greybus SVC Interface UNIPRO Enable Response
""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-unipro-enable-response` defines the
Greybus SVC Interface UNIPRO Enable Response payload. The Operation
Response payload contains a one-byte result_code field.

.. figtable::
    :nofig:
    :label: table-svc-interface-unipro-enable-response
    :caption: SVC Protocol Interface UNIPRO Enable Response
    :spec: l l c c l

    =======  ===========  ======  ==========  ===========
    Offset   Field        Size    Value       Description
    =======  ===========  ======  ==========  ===========
    0        result_code  1       Number      Result Code
    =======  ===========  ======  ==========  ===========
..

The :ref:`greybus-operation-status` in the Operation Response message
header shall not be used to determine the value of UNIPRO sub-state after the
response is received. It shall only be used to indicate the result of the
Greybus communication.  If the Greybus SVC Interface UNIPRO Enable Response
message header has the :ref:`greybus-operation-status` value different than
GB_OP_SUCCESS, a Greybus communication error has occurred; the UNIPRO sub-state
identified in the Operation Request shall not have changed as a result of
processing the Request. If the Greybus SVC Interface UNIPRO Enable Response
message header has the :ref:`greybus-operation-status` equal to
GB_OP_SUCCESS, it shall indicate that no Greybus communication error was
detected.

However, a :ref:`greybus-operation-status` in the Response message header
equal to GB_OP_SUCCESS alone does not imply the intended UNIPRO is now
UNIPRO_DOWN. When the Response message header has
:ref:`greybus-operation-status` equal to GB_OP_SUCCESS, the value of UNIPRO
may be determined given the result_code field in the Operation Response
payload, as described in Table :num:`table-svc-interface-unipro-result-code`.
In particular, if the Response message header has
:ref:`greybus-operation-status` equal to GB_OP_SUCCESS:

- UNIPRO is UPRO_DOWN if the result_code is UPRO_OK.
- UNIPRO shall not have changed value if the result_code is UPRO_BUSY or UPRO_NOT_OFF.
- UNIPRO is unpredictable if the result_code is UPRO_FAIL.

.. figtable::
    :nofig:
    :label: table-svc-interface-unipro-result-code
    :caption: Interface UNIPRO Enable and Interface UNIPRO Disable result_code
    :spec: l l l

    ================  ========  ======================================================================
    Result Code       Value     Description
    ================  ========  ======================================================================
    UPRO_OK           0         UNIPRO enable/disable operation was successful.
    UPRO_BUSY         1         UNIPRO enable/disable operation cannot be attempted as the SVC is busy.
    UPRO_FAIL         2         UNIPRO enable/disable was attempted and failed.
    UPRO_NOT_OFF      3         UNIPRO was not UPRO_OFF, attempt to set to UPRO_DOWN was not made.
    (Reserved)        4-255     (Reserved for future use)
    ================  ========  ======================================================================
..

.. _svc-interface-unipro-disable:

Greybus SVC Interface UNIPRO Disable Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP uses this Operation to request the SVC to set an
:ref:`Interface State's <hardware-model-interface-states>`
:ref:`hardware-model-unipro` to UPRO_OFF.

Though the AP may send this request at any time, the AP should only do
so under one of the following conditions:

- during "early_power_down" transition in the :ref:`Interface
  Lifecycle <hardware-model-lifecycle-states>` state machine, as
  described in :ref:`lifecycles_early_power_down`.

- during the "power_down" transition in the Interface Lifecycle state
  machine, as described in :ref:`lifecycles_power_down`.

- during the "forcible_removal" transition in the Interface Lifecycle
  state machine, as described in :ref:`lifecycles_forcible_removal`.

The SVC shall set UNIPRO to UPRO_OFF without having received an
Interface UNIPRO Disable Request only under the conditions specified in
:ref:`hardware-model-unipro`.

Greybus SVC Interface UNIPRO Disable Request
""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-unipro-disable-request` defines the Greybus SVC
Interface UNIPRO Disable Request payload.

.. figtable::
    :nofig:
    :label: table-svc-interface-unipro-disable-request
    :caption: SVC Protocol Interface UNIPRO Disable Request
    :spec: l l c c l

    =======  ==============  ======  ============    ============
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ============
    0        intf_id         1       Interface ID    Interface ID
    =======  ==============  ======  ============    ============
..

The SVC, on receiving this request, shall attempt to set the UNIPRO
sub-state of the Interface State specified by the intf_id field to
UPRO_OFF.

Greybus SVC Interface UNIPRO Disable Response
"""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-unipro-disable-response` defines the
Greybus SVC Interface UNIPRO Disable Response payload. The Operation
Response payload contains a one-byte result_code field.

.. figtable::
    :nofig:
    :label: table-svc-interface-unipro-disable-response
    :caption: SVC Protocol Interface UNIPRO Disable Response
    :spec: l l c c l

    =======  ===========  ======  ==========  ===========
    Offset   Field        Size    Value       Description
    =======  ===========  ======  ==========  ===========
    0        result_code  1       Number      Result Code
    =======  ===========  ======  ==========  ===========
..

The meaning of the :ref:`greybus-operation-status` in the Operation
Response message header and the result_code in the Operation Response payload
are analogous to the corresponding :ref:`greybus-operation-status` in the
Interface UNIPRO Enable Response message header and the result_code field in the
Interface UNIPRO Enable Operation Response payload.

That is, the :ref:`greybus-operation-status` of the Operation Response message
header shall only be used to indicate the result of the Greybus communication,
exactly as described in :ref:`svc-interface-unipro-enable-response`.

Similarly, when the Interface UNIPRO Disable Response message header has the
:ref:`greybus-operation-status` equal to GB_OP_SUCCESS, the value of UNIPRO
may be determined given the result_code field in the Operation Response
payload, as described in Table :num:`table-svc-interface-unipro-result-code`. In
particular, if the Response message header has
the :ref:`greybus-operation-status` equal to GB_OP_SUCCESS:

- UNIPRO is UPRO_OFF if the result_code is UPRO_OK.
- UNIPRO shall not have changed value if the result_code is UPRO_BUSY.
- UNIPRO is unpredictable if the result_code is UPRO_FAIL.

.. _svc-interface-activate:

Greybus SVC Interface Activate Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Interface Activate Operation allows the AP to request
the SVC to "activate" an Interface by initializing it and
determining if it is capable of communication via Greybus.

More precisely, use of this Operation is the final step in a sequence
of Greybus Operations which are used when transitioning an
:ref:`Interface <hardware-model-interfaces>` to the
:ref:`hardware-model-lifecycle-activated` Interface :ref:`Lifecycle
State <hardware-model-lifecycle-states>`, as defined in
:ref:`lifecycles_interface_lifecycle`.

Though the AP may send this request at any time, the AP should only do
so during the "boot" and "reboot" transitions in the Interface
Lifecycle state machine as defined in :ref:`lifecycles_boot` and
:ref:`lifecycles_reboot`. The effect of sending this request under
other conditions is unspecified.

The SVC shall not send this Operation request.

.. _svc-interface-activate-request:

Greybus SVC Interface Activate Request
""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-activate-request` defines the Greybus
SVC Interface Activate Request payload.

.. figtable::
    :nofig:
    :label: table-svc-interface-activate-request
    :caption: SVC Protocol Interface Activate Request
    :spec: l l c c l

    =======  ==============  ======  ============    =====================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    =====================
    0        intf_id         1       Interface ID    Interface to activate
    =======  ==============  ======  ============    =====================
..

Upon receiving this request, the SVC shall check the following
sub-states of the :ref:`Interface State
<hardware-model-interface-states>` with ID intf_id have these values:

- :ref:`hardware-model-detect` is DETECT_ACTIVE
- :ref:`hardware-model-vsys` is V_SYS_ON
- :ref:`hardware-model-vchg` is V_CHG_OFF
- :ref:`hardware-model-wake` is WAKE_UNSET
- :ref:`hardware-model-unipro` is UPRO_DOWN
- :ref:`hardware-model-refclk` is REFCLK_ON
- :ref:`hardware-model-release` is RELEASE_DEASSERTED
- :ref:`hardware-model-order` is ORDER_PRIMARY or ORDER_SECONDARY
- :ref:`hardware-model-mailbox` is MAILBOX_NONE

If any of these conditions does not hold, the SVC shall send a
response to the AP signaling an error as described below. The SVC
shall take no further action related to such a request beyond sending
the response.

Otherwise, the only Interface sub-state whose value is not constrained
is :ref:`hardware-model-intf-type`.

The SVC and Module shall now activate the Interface by following
these steps in the order specified.

If this sequence completes successfully, INTF_TYPE is one of
IFT_DUMMY, IFT_UNIPRO, or IFT_GREYBUS, and the Interface's
:ref:`Lifecycle State <hardware-model-lifecycle-states>` is
consequently :ref:`hardware-model-lifecycle-activated`. If this
sequence fails, INTF_TYPE is IFT_UNKNOWN, and the SVC shall signal an
error to the AP in the response, as described below.

This sequence is also depicted in :ref:`lifecycles_boot` and
:ref:`lifecycles_reboot`.

1. If the SVC is notified that UNIPRO is UPRO_LSS at any time,
   immediately proceed to step 6.

2. The SVC shall initiate a :ref:`WAKE pulse <hardware-model-wake>`
   for a duration greater than or equal to the WAKE Pulse Cold Boot
   Threshold.

3. After the WAKE Pulse completes, the SVC shall start a timer, for an
   implementation-defined duration.

   If the SVC detects the timer has expired and UNIPRO is UPRO_DOWN,
   the activation sequence is complete. The SVC shall set
   :ref:`hardware-model-intf-type` to IFT_DUMMY. The Interface
   is ACTIVATED, as described above.  When this occurs, immediately
   proceed to step 9.

4. Since DETECT is DETECT_ACTIVE, a Module is attached to the
   Interface Block. If the attached Module's Interface is capable of
   communication via |unipro|, it shall detect when the WAKE Pulse
   duration equals the WAKE Pulse Cold Boot Threshold, and perform an
   internal reset sequence to its initial state.

   Note that the Interface may draw power from the Frame, and make use
   of the reference clock supplied by the Frame, during this
   initialization, since V_SYS and REFCLK are respectively V_SYS_ON
   and REFCLK_ON.

5. If the Interface is capable of |unipro| communications, it shall
   set UNIPRO to UPRO_LSS during its initialization sequence.

   As stated in :ref:`hardware-model-unipro`, the SVC shall be
   notified if UNIPRO is set to UPRO_LSS, and if UNIPRO remains
   UPRO_LSS for too long, UNIPRO autonomously becomes UPRO_DOWN.

   Note that the Interface cannot set MAILBOX unless UNIPRO is
   UPRO_UP.

6. If the SVC receives the notification that UNIPRO is UPRO_LSS
   following any previous step, the SVC shall attempt to set UNIPRO to
   UPRO_UP, and start another timer, for another implementation
   defined duration.

   If the SVC detects this timer has expired and
   :ref:`hardware-model-mailbox` is MAILBOX_NONE, the activation
   sequence is complete. The SVC shall set INTF_TYPE to
   IFT_UNIPRO. The Interface is ACTIVATED, as described above.
   When this occurs, immediately proceed to step 9.

7. If the Interface is notified that UNIPRO is UPRO_UP and supports
   Greybus communications, it may set MAILBOX to MAILBOX_GREYBUS. The
   Interface shall not set MAILBOX to any other value.

   Before setting MAILBOX, the Interface shall ensure that the
   :ref:`greybus-interface-attributes` are set to their correct values
   and are available for retrieval, if they are supported.

   If the Interface sets MAILBOX, it shall subsequently respond to
   incoming :ref:`control-protocol` Operation Requests as defined in
   that section if the appropriate CPort is connected and used for
   Greybus communication.

8. As stated in :ref:`hardware-model-mailbox`, the SVC can detect if
   the MAILBOX value has changed, and if so, to what value.

   If this occurs and MAILBOX is MAILBOX_GREYBUS, the SVC shall set
   INTF_TYPE to IFT_GREYBUS. The SVC shall then attempt to clear the
   mailbox attribute by setting its value to zero, setting MAILBOX to
   MAILBOX_NONE as a result. If the SVC is unable to do so, the
   results are undefined. Immediately proceed to step 9.

   If this occurs and MAILBOX is not MAILBOX_GREYBUS, the SVC shall
   set INTF_TYPE to IFT_UNKNOWN, and signal an error to the AP as
   described below.

9. Regardless of the path to reach this step, the INTF_TYPE sub-state
   is now set. The activation sequence is complete.

   If the Interface is ACTIVATED, the SVC shall now send a
   successful response. Otherwise, it shall signal an error in the
   response.

Greybus SVC Interface Activate Response
"""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-activate-response` defines the Greybus
SVC Interface Activate Operation Response payload. If the Response message
header has :ref:`greybus-operation-status` not equal to GB_OP_SUCCESS,
the values in the Operation Response payload are undefined and shall be
ignored.

.. figtable::
    :nofig:
    :label: table-svc-interface-activate-response
    :caption: SVC Protocol Interface Activate Response
    :spec: l l c c l

    =======  ==============  ======  ============    ======================================================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ======================================================
    0        status          1       Number          :ref:`svc-protocol-op-status`
    1        intf_type       1       INTF_TYPE       :ref:`hardware-model-intf-type` of activated Interface
    =======  ==============  ======  ============    ======================================================
..

After receiving the request, the SVC first checks various sub-states before
starting the activation sequence. If any of these checks fail, the SVC shall
signal errors to the AP in the Operation Response payload by setting the status
field of the Operation Response payload as follows.

- If DETECT was not DETECT_ACTIVE, the status is
  GB_SVC_INTF_NOT_DETECTED.
- Otherwise, if V_SYS was not V_SYS_ON, the status is
  GB_SVC_INTF_NO_V_SYS.
- Otherwise, if V_CHG was not V_CHG_OFF, the status is
  GB_SVC_INTF_V_CHG.
- Otherwise, if WAKE was not WAKE_UNSET, the status is
  GB_SVC_INTF_WAKE_BUSY.
- Otherwise, if UNIPRO was not UPRO_DOWN, the status is
  GB_SVC_INTF_UPRO_NOT_DOWN.
- Otherwise, if REFCLK was not REFCLK_ON, the status is
  GB_SVC_INTF_NO_REFCLK.
- Otherwise, if RELEASE was not RELEASE_DEASSERTED, the status is
  GB_SVC_INTF_RELEASING.
- Otherwise, if ORDER was ORDER_UNKNOWN, the status is
  GB_SVC_INTF_NO_ORDER.
- Otherwise, if MAILBOX was not MAILBOX_NONE, the status is
  GB_SVC_INTF_MBOX_SET.

Also as described above, INTF_TYPE may be IFT_UNKNOWN due to the
Interface having set MAILBOX to an illegal value. If this occurred,
the SVC shall signal an error to the AP by setting the status field in
the Operation Response payload to GB_SVC_INTF_BAD_MBOX.

If the Interface is :ref:`hardware-model-lifecycle-activated`
and no other errors occur, the SVC shall set the
:ref:`greybus-operation-status` in the Response message header to
GB_OP_SUCCESS and the status field of the Operation Response payload to
GB_SVC_OP_SUCCESS. In this case, the intf_type field in the Operation Response
payload contains the numeric value of the INTF_TYPE as defined in
:ref:`hardware-model-intf-type`.

.. _svc-interface-resume:

Greybus SVC Interface Resume Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Interface Resume Operation allows the AP to request
the SVC to "resume" an Interface which was previously
:ref:`hardware-model-lifecycle-suspended`, allowing it to later be
:ref:`hardware-model-lifecycle-enumerated`.

More precisely, use of this Operation is one step in a sequence of
Greybus Operations which are used when transitioning an
:ref:`Interface <hardware-model-interfaces>` to the
:ref:`hardware-model-lifecycle-enumerated` Interface :ref:`Lifecycle
State <hardware-model-lifecycle-states>` from the
:ref:`hardware-model-lifecycle-suspended` Lifecycle State, as defined
in :ref:`lifecycles_interface_lifecycle`.

Though the AP may send this request at any time, the AP should only do
so during the "resume" transition in the Interface Lifecycle state
machine as defined in :ref:`lifecycles_resume`. The effect of sending
this request under other conditions is unspecified.

The SVC shall not send this Operation request.

.. _svc-interface-resume-request:

Greybus SVC Interface Resume Request
""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-resume-request` defines the Greybus
SVC Interface Resume Request payload.

.. figtable::
    :nofig:
    :label: table-svc-interface-resume-request
    :caption: SVC Protocol Interface Resume Request
    :spec: l l c c l

    =======  ==============  ======  ============    =====================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    =====================
    0        intf_id         1       Interface ID    Interface to resume
    =======  ==============  ======  ============    =====================
..

Upon receiving this request, the SVC shall check the following
sub-states of the :ref:`Interface State
<hardware-model-interface-states>` with ID intf_id have these values:

- :ref:`hardware-model-detect` is DETECT_ACTIVE
- :ref:`hardware-model-vsys` is V_SYS_ON
- :ref:`hardware-model-wake` is WAKE_UNSET
- :ref:`hardware-model-unipro` is UPRO_HIBERNATE
- :ref:`hardware-model-refclk` is REFCLK_ON
- :ref:`hardware-model-release` is RELEASE_DEASSERTED
- :ref:`hardware-model-intf-type` is IFT_GREYBUS
- :ref:`hardware-model-order` is ORDER_PRIMARY or ORDER_SECONDARY
- :ref:`hardware-model-mailbox` is MAILBOX_NONE

If any of these conditions does not hold, the SVC shall send a
response to the AP signaling an error as described below. The SVC
shall take no further action related to such a request beyond sending
the response.

The SVC and Module shall now resume the Interface by following
these steps in the order specified.

This sequence is also depicted in :ref:`lifecycles_resume`.

1. If the SVC detects at any time that :ref:`hardware-model-mailbox`
   is MAILBOX_GREYBUS, the resume sequence has succeeded. Go
   directly to step 6.

2. The SVC shall initiate a :ref:`WAKE Pulse <hardware-model-wake>`
   for a duration less than the WAKE Pulse Cold Boot Threshold.

   After the WAKE Pulse, the SVC shall delay in this step for an
   implementation-defined duration to allow the Interface to prepare
   for the sequence to continue.

3. Since INTF_TYPE is IFT_GREYBUS, the Interface is capable of
   |unipro| and Greybus communication.

   The Interface shall detect the WAKE Pulse, and that its duration
   was less than the Wake Pulse Cold Boot Threshold. As a result, it
   shall perform an implementation-specific resume sequence. This
   sequence shall ensure that the Interface receives a notification if
   the SVC attempts to set UNIPRO to UPRO_UP.

   Note that the Interface may draw power from the Frame, and make use
   of the reference clock supplied by the Frame, during this resume
   sequence, since V_SYS and REFCLK are respectively V_SYS_ON and
   REFCLK_ON.

4. As described in :ref:`hardware-model-unipro`, the SVC can attempt
   to set UNIPRO to UPRO_UP, and shall be notified if the attempt
   succeeds or fails.

   The SVC shall now attempt to set UNIPRO to UPRO_UP, and delay until
   it is notified whether the attempt succeeds or fails.

   If the attempt succeeds, the SVC sets a timer for an
   implementation-defined duration. If the SVC detects this timer has
   expired and :ref:`hardware-model-mailbox` is MAILBOX_NONE, the
   resume sequence has failed. The SVC shall signal an error to the AP
   as described below. Go directly to step 6.

   If the attempt fails, the resume sequence has failed. The SVC shall
   signal an error to the AP as described below. Go directly to
   step 6.

5. As described above, the Interface shall also be notified that
   UNIPRO has successfully been set to UNIPRO_UP. When this occurs,
   the Interface shall set MAILBOX to MAILBOX_GREYBUS. The Interface
   shall not set MAILBOX to any other value.

   After setting MAILBOX, the Interface shall subsequently respond to
   incoming :ref:`control-protocol` Operation Requests as defined in
   that section if the appropriate CPort is connected and used for
   Greybus communication.

   The SVC shall detect the new value of MAILBOX. The SVC shall then
   attempt to clear the mailbox attribute by setting its value to
   zero, setting MAILBOX to MAILBOX_NONE as a result. If the SVC is
   unable to do so, the results are undefined.

   Otherwise, the resume sequence has succeeded. The SVC shall signal
   this success to the AP in the response to this request as described
   below.

6. The resume sequence is now complete, and has succeeded or failed.
   The SVC shall signal completion and either success or failure to
   the AP as described below.

Greybus SVC Interface Resume Response
"""""""""""""""""""""""""""""""""""""
Table :num:`table-svc-interface-resume-response` defines the Greybus SVC
Interface Resume Response payload. If the Response message header has
:ref:`greybus-operation-status` not equal to GB_OP_SUCCESS, the value
in the Operation Response payload is undefined and shall be ignored.

After receiving the request, the SVC first checked various sub-states
before starting the resume sequence. If any of these checks fail, the
SVC shall signal errors to the AP in the Operation Response payload by setting
the status field of the Operation Response payload as follows.

- If DETECT was not DETECT_ACTIVE, the status is
  GB_SVC_INTF_NOT_DETECTED.
- Otherwise, if V_SYS was not V_SYS_ON, the status is
  GB_SVC_INTF_NO_V_SYS.
- Otherwise, if WAKE was not WAKE_UNSET, the status is
  GB_SVC_INTF_WAKE_BUSY.
- Otherwise, if UNIPRO was not UPRO_HIBERNATE, the status is
  GB_SVC_INTF_UPRO_NOT_HIBERNATED.
- Otherwise, if REFCLK was not REFCLK_ON, the status is
  GB_SVC_INTF_NO_REFCLK.
- Otherwise, if RELEASE was not RELEASE_DEASSERTED, the status is
  GB_SVC_INTF_RELEASING.
- Otherwise, if ORDER was ORDER_UNKNOWN, the status is
  GB_SVC_INTF_NO_ORDER.
- Otherwise, if MAILBOX was not MAILBOX_NONE, the status is
  GB_SVC_INTF_MBOX_SET.

If a protocol error occurs due to erroneous Interface behavior which
writes a different value than MAILBOX_GREYBUS to MAILBOX, the SVC
shall set the status field in Operation Response payload
to GB_SVC_INTF_BAD_MBOX.

If the resume sequence failed because the SVC detected in step 4 that
MAILBOX was MAILBOX_NONE, the SVC shall set the status field in the Operation
response payload to GB_SVC_INTF_OP_TIMEOUT.

If the resume sequence failed because the SVC was notified in step 4
that the attempt to set UPRO to UPRO_UP failed, the SVC shall set the
status field in the Operation Response payload to GB_SVC_INTF_NO_UPRO_LINK.

If the resume sequence succeeded and no other errors occurred, the SVC
shall set the :ref:`greybus-operation-status` in the Response message
header to GB_OP_SUCCESS and set the status field in Operation Response payload
to GB_SVC_OP_SUCCESS.

.. figtable::
    :nofig:
    :label: table-svc-interface-resume-response
    :caption: SVC Interface Resume Response
    :spec: l l c c l

    =======  ==============  ===========  ================  =========================================
    Offset   Field           Size         Value             Description
    =======  ==============  ===========  ================  =========================================
    0        status          1            Number            :ref:`svc-protocol-op-status`
    =======  ==============  ===========  ================  =========================================

..

.. _svc-interface-mailbox-event:

Greybus SVC Interface Mailbox Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Interface Mailbox Event Operation allows the SVC to
inform the AP that the :ref:`hardware-model-mailbox` of an
:ref:`Interface State <hardware-model-interface-states>` has changed
value.

Though this can occur at other times, it carries special meaning
during the "ms_exit" transition from the
:ref:`hardware-model-lifecycle-mode-switching` Interface
:ref:`Lifecycle State <hardware-model-lifecycle-states>` to
:ref:`hardware-model-lifecycle-enumerated`, as defined in
:ref:`lifecycles_interface_lifecycle`. This is described in
:ref:`lifecycles_ms_exit`.

Though an Interface can set the MAILBOX sub-state at other times, it
should only do so when explicitly required to do so by the Greybus
Specification. If a MAILBOX changes value due to other circumstances,
the SVC shall send this Operation Request subject to the restrictions
described below, with results that are implementation-defined.

The AP shall not send this Operation Request.

Greybus SVC Interface Mailbox Event Request
"""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-mailbox-event-request` defines the
Greybus SVC Interface Mailbox Event Request payload.

.. figtable::
    :nofig:
    :label: table-svc-interface-mailbox-event-request
    :caption: SVC Protocol Interface Mailbox Event Request
    :spec: l l c c l

    =======  ==============  ======  ============    =====================================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    =====================================
    0        intf_id         1       Interface ID    Interface State whose MAILBOX was set
    1        result_code     2       Number          |unipro| ConfigResultCode
    3        mailbox         4       Number          MAILBOX value
    =======  ==============  ======  ============    =====================================
..

As described in :ref:`hardware-model-mailbox`, under certain
circumstances, an Interface can set the MAILBOX sub-state for that
Interface State. This event can be detected by the SVC, and the SVC
can subsequently read the value written.

If the SVC detects such an attribute write, it shall attempt to send
an SVC Interface Mailbox Event Request to the AP if none of the
following conditions hold:

1. The SVC is currently activating that Interface, as described in
   :ref:`svc-interface-activate-request`.

2. The SVC is currently resuming that Interface, as described in
   :ref:`svc-interface-resume-request`.

3. The Interface is an :ref:`AP Interface
   <hardware-model-ap-module-requirements>`.

If any of the above conditions hold, the SVC shall not attempt to send
a Mailbox Event Request to the AP as a result of detecting that the
attribute was written.

The SVC shall attempt to exchange a Mailbox Event Request Operation
with the AP by sending this request under any other circumstances. If
the Operation fails, the SVC may take no further action as a result of
detecting the mailbox attribute write.

Before sending the request, the SVC shall:

1. Attempt to read the mailbox attribute, storing the ConfigResultCode
   as defined in the |unipro| specification, as well the mailbox
   attribute value if the read is successful.

2. If the mailbox attribute is read successfully, the SVC shall clear
   it by setting its value to zero, thus setting the MAILBOX Interface
   State sub-state to MAILBOX_NONE.

   If the SVC is unable to successfully clear the attribute, the
   results are undefined.

The SVC shall then send the request. The intf_id field in the request
payload shall equal the MAILBOX Interface State's Interface ID. The
result_code field in the request payload shall equal the previously
stored ConfigResultCode. The mailbox field in the request payload
shall be zero if the read failed, and otherwise shall equal the
mailbox attribute's value.

Greybus SVC Interface Mailbox Event Response
""""""""""""""""""""""""""""""""""""""""""""

The Greybus SVC Interface Mailbox Event Response has no payload.
