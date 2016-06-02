.. _control-protocol:

Control Protocol
----------------

Interfaces with :ref:`hardware-model-intf-type` equal to IFT_GREYBUS
shall provide a CPort that responds to the Operations defined in this
section. Such a CPort is a :ref:`Control CPort
<glossary-control-cport>`.  If an Interface provides a Control CPort,
its CPort ID shall be zero.

Such Interfaces shall be prepared to receive Operation requests on
that CPort under conditions defined later in this chapter.  In
particular, this may occur as a result of successful :ref:`Interface
Activate <svc-interface-activate>` and :ref:`Interface Resume
<svc-interface-resume>` Operations, which are defined below in the
:ref:`svc-protocol`.

Also using a sequence of SVC Protocol Operations, the AP may establish
a Greybus Connection to a Control CPort if it has determined that the
Interface is prepared for incoming Operations on that CPort, and the
Connection is not already established. Any such Connection is a
:ref:`Control Connection <glossary-control-connection>`. This sequence
is defined in :ref:`lifecycles_control_establishment`.

Interfaces are not notified when Control Connections are
established.

Only the AP shall send requests on a Control Connection. Other
Interfaces shall only send response messages. An Interface shall send
a response on a Control Connection only after receiving a request from
the AP.

Conceptually, the Operations in the Greybus Control Protocol are:

.. c:function:: int ping(void);

    See :ref:`greybus-protocol-ping-operation`.

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Refer to :ref:`greybus-protocol-version-operation`.

.. c:function:: int get_manifest_size(u16 *manifest_size);

    This Operation is used by the AP to discover the size of a module's
    Interface Manifest.  This is used after the SVC has discovered which
    Module contains the AP.  The response to this Operation contains the
    size of the manifest, which is used by the AP to fetch the manifest
    later.  This operation is only initiated by the AP.

.. c:function:: int get_manifest(u8 *manifest);

    This Operation is used by the AP after the SVC has discovered
    which Module contains the AP.  The response to this Operation
    contains the manifest of the Module, which is used by the AP to
    determine the functionality module provides.  This operation is only
    initiated by the AP.

.. c:function:: int connected(u16 cport_id);

    This Operation is used to notify an Interface that a Greybus
    connection has been established using the indicated CPort.
    Upon receiving this request, an Interface shall be prepared to
    receive messages on the indicated CPort.  The Interface may send
    messages over the indicated CPort once it has sent a response
    to the connected request.  This operation is never used for
    control CPort.

.. c:function:: int disconnecting(u16 cport_id);

    This Operation is used by the AP Module to inform an Interface
    that the process of disconnecting a previously established Greybus
    connection has begun.

.. c:function:: int disconnected(u16 cport_id);

    This Operation is used to notify an Interface that a previously
    established Greybus connection may no longer be used.  This
    operation is never used for control CPort.

.. c:function:: int timesync_enable(u8 count, u64 frame_time, u32 strobe_delay, u32 refclk);

    The AP Module uses this operation to inform the Interface that
    frame-time is being enabled.

.. c:function:: int timesync_disable(void);

    The AP Module uses this operation to switch off frame-time logic in an
    Interface.

.. c:function:: int timesync_authoritative(u64 *frame_time);

    The AP Module uses this operation to inform an Interface of the
    authoritative frame-time reported by the SVC for each TIME_SYNC strobe.

.. c:function:: int timesync_get_last_event(u64 *frame_time);

    The AP Module uses this operation to get the frame-time at the last
    pulse on the wake pin of a relevant Interface. This operation
    is used in conjunction with an SVC timesync-ping operation to verify
    the local time at a given Interface.

.. c:function:: int bundle_version(u8 bundle_id, u8 *major, u8 *minor);

    This Operation is used by the AP to get the version of the Bundle Class
    implemented by a Bundle.

.. c:function:: void mode_switch(void);

    This Operation can be used by the AP to signal to the Interface
    that it may reinitialize itself and alter the Bundles it
    previously described to the AP by sending it an Interface
    :ref:`Manifest <manifest-description>`.

Greybus Control Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^

All control Operations are contained within a Greybus control
request message. Most of control requests results in a matching
response, except mode_switch which is unidirectional.  The request and
response messages for each control Operation are defined below.

Table :num:`table-control-operation-type` defines the Greybus
Control Protocol Operation types and their values. Both the request
type and response type values are shown.

.. figtable::
    :nofig:
    :label: table-control-operation-type
    :caption: Control Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Control Operation Type       Request Value  Response Value
    ===========================  =============  ==============
    Ping                         0x00           0x80
    Protocol Version             0x01           0x81
    Reserved                     0x02           0x82
    Get Manifest Size            0x03           0x83
    Get Manifest                 0x04           0x84
    Connected                    0x05           0x85
    Disconnected                 0x06           0x86
    TimeSync enable              0x07           0x87
    TimeSync disable             0x08           0x88
    TimeSync authoritative       0x09           0x89
    Reserved                     0x0a           0x8a
    Bundle Version               0x0b           0x8b
    Disconnecting                0x0c           0x8c
    TimeSync get last event      0x0d           0x8d
    Mode Switch                  0x0e           N/A
    (all other values reserved)  0x0f..0x7e     0x8f..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

.. _control-ping:

Greybus Control Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Control Ping Operation is the
:ref:`greybus-protocol-ping-operation` for the Control Protocol.
It consists of a request containing no payload, and a response
with no payload that indicates a successful result.

.. _control-protocol-version:

Greybus Control Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Control Protocol Version Operation is the
:ref:`greybus-protocol-version-operation` for the Control Protocol.

Greybus implementations adhering to the Protocol specified herein
shall specify the value |gb-major| for the version_major and
|gb-minor| for the version_minor fields found in this Operation's
request and response messages.

.. _control-get-manifest-size:

Greybus Control Get Manifest Size Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Control Get Manifest Size Operation is used by the AP to
ensure an Interface's :ref:`Manifest <manifest-description>` is
available for retrieval via Greybus. After this Operation is
successfully exchanged, the AP may retrieve the Manifest using
the :ref:`control-get-manifest`.

Although the AP may send this request at any time, it should only do
so while enumerating an Interface, as defined in
:ref:`hardware-model-lifecycle-enumerated`. The effect of this
Operation under other conditions is unspecified.

Greybus Control Get Manifest Size Request
"""""""""""""""""""""""""""""""""""""""""

The Greybus Control Get Manifest Size Request has no payload.

The Greybus Control Get Manifest Size Request is sent by the AP to the
Interface in order to request that the Interface ensure its Manifest
data structure is available for subsequent retrieval.

If an Interface is being enumerated, the Interface shall ensure an
Interface Manifest is available for later retrieval by the AP as a
result of receiving this request. It shall then notify the AP of the
size of this Manifest in the response, as described below.

Greybus Control Get Manifest Size Response
""""""""""""""""""""""""""""""""""""""""""

The Greybus Control Get Manifest Size Response contains a two byte
field, manifest_size. If the response status is not GB_OP_SUCCESS, the
value of manifest_size is undefined and shall be ignored.

.. figtable::
    :nofig:
    :label: table-control-get-manifest-size-response
    :caption: Control Protocol Get Manifest Size Response
    :spec: l l c c l

    =======  ==============  ===========  ==========      ===========================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ===========================
    0        manifest_size   2            Number          Size of the Manifest
    =======  ==============  ===========  ==========      ===========================

..

The manifest_size field in the response payload shall contain the size
in bytes of the Interface Manifest which may be subsequently retrieved
by the AP. If an Interface is being enumerated when it sends this
response, the Interface shall not alter the size of this Interface
Manifest as long as it continues being enumerated.

.. _control-get-manifest:

Greybus Control Get Manifest Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Control Get Manifest Operation is used by the AP to
retrieve an Interface's :ref:`Manifest <manifest-description>` via its
Control Connection.

Though the AP may send this request at any time, it should only do so
while enumerating an Interface, as defined in
:ref:`hardware-model-lifecycle-enumerated`. The effect of this
Operation under other conditions is unspecified.

Greybus Control Get Manifest Request
""""""""""""""""""""""""""""""""""""

The Greybus Control Get Manifest Request has no payload.

If the Interface is being enumerated, its Manifest is available for
retrieval by the AP. The Interface shall send it in the response to
this request.

Greybus Control Get Manifest Response
"""""""""""""""""""""""""""""""""""""

The Greybus Control Get Manifest Response contains a block of data
that describes the functionality provided by the Interface. The
contents of this data are defined in :ref:`manifest-description`. If
the response status is not GB_OP_SUCCESS, the response payload should
be empty and shall be ignored.

.. figtable::
    :nofig:
    :label: table-control-get-manifest-response
    :caption: Control Protocol Get Manifest Response
    :spec: l l c c l

    =======  ==============  ===========  ==========      ===========================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ===========================
    0        manifest        variable     Data            Manifest
    =======  ==============  ===========  ==========      ===========================

..

If the Interface is being enumerated when it sends this response, the
size of the Manifest returned by the Interface in this response shall
equal the manifest_size field in the preceding Get Manifest Size
Response payload. The size is otherwise not specified.

The Interface shall ensure that if it is being enumerated and the
response status is GB_OP_SUCCESS, the following shall hold:

1. If the Interface provides CPort Descriptors in the Manifest, then it
   shall respond to incoming Operation Requests on those CPorts after
   the AP establishes Greybus Connections using those CPorts as
   described in :ref:`lifecycles_connection_management`.

2. The Greybus :ref:`Protocols <glossary-connection-protocol>`
   implemented by the CPort users of any such CPorts shall be as
   defined in the Manifest.

An Interface's Lifecycle State is ENUMERATED when the AP receives
such a successful response. The enumeration procedure guarantees that
the Interface State is in one of two possible values, as follows::

  (DETECT=DETECT_ACTIVE, V_SYS=V_SYS_ON,
   V_CHG=V_CHG_OFF,
   WAKE=WAKE_UNSET, UNIPRO=UPRO_UP,
   REFCLK=REFCLK_ON,
   RELEASE=RELEASE_DEASSERTED,
   INTF_TYPE=IFT_GREYBUS,
   ORDER=<ORDER_PRIMARY or ORDER_SECONDARY>,
   MAILBOX=MAILBOX_GREYBUS)

The Interface shall ensure that as long as the Interface State remains
this value, that the above list of two conditions in this section
shall continue to hold.

The AP and Interface may subsequently, through Protocol-specific
means, change the values of some of these sub-states without relaxing
these requirements.

.. _control-connected:

Greybus Control Connected Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. SW-4660 + any sub-tasks track adding module/module connections.

.. note::

   The Control Connected Operation is currently defined under the
   assumption that all Connections in the Greybus System are between
   an AP Interface and another, non-AP Interface in the System.

   The results in the case of Connections between two Interfaces,
   neither or both of which are AP Interfaces, are undefined.

The AP may establish Connections between Interfaces in the Greybus
System. If the :ref:`Interface State
<hardware-model-interface-states>` of an Interface has
:ref:`hardware-model-intf-type` IFT_GREYBUS, the AP shall only attempt
to establish non-Control Connections to that Interface if its
Lifecycle State is :ref:`hardware-model-lifecycle-enumerated`.

Connection establishment is performed by the AP using a sequence of
Operations in the Control and SVC Protocols, as defined in this
chapter. A later chapter, :ref:`lifecycles`, provides procedures using
these Operations which establish connections in
:ref:`lifecycles_connection_management`.  As part of these procedures,
the AP uses a Greybus Control Connected Operation to notify Interfaces
when Connections are established.

Greybus Control Connected Request
"""""""""""""""""""""""""""""""""

The Greybus control connected request supplies the CPort ID on the
receiving Interface that has been connected.

.. figtable::
    :nofig:
    :label: table-control-connected-request
    :caption: Control Protocol Connected Request
    :spec: l l c c l

    =======  ==============  ======  =======    ===========================
    Offset   Field           Size    Value      Description
    =======  ==============  ======  =======    ===========================
    0        cport_id        2       Number     CPort that is now connected
    =======  ==============  ======  =======    ===========================

..

The AP should ensure that the CPort ID given by cport_id in the
request payload was given in the id field of a :ref:`cport-descriptor`
in the Interface's :ref:`Manifest <manifest-description>`. The results
of this Operation under other circumstances are undefined.

Interfaces shall not transmit any |unipro| Segments on any CPorts
identified in their Manifests' CPort Descriptors before receiving a
Control Connected Request indicating that the CPort is now connected,
regardless of whether the Segments contain L4 payload.

After receiving this request, the Interface may transmit Segments on
the CPort given by cport_id, as described in
:ref:`connection-tx-restrictions`.

Greybus Control Connected Response
""""""""""""""""""""""""""""""""""

The Greybus control connected response message contains no payload.

If the AP receives a Control Connected response with status
GB_OP_SUCCESS, it shall store information indicating that the CPort is
now connected on that Interface.

The AP may later close the Greybus Connection and disconnect the CPort
using a sequence of Operations in the Control and SVC Protocols. This
procedure is defined in :ref:`lifecycles_connection_management`, and
uses Greybus Operations defined in this chapter. If this procedure
succeeds, the AP no longer needs to store the information that the
CPort is connected.

The AP also no longer needs to store information indicating that a
CPort on an Interface is connected if subsequent Operations guarantee
that the Interface's Lifecycle State is
:ref:`hardware-model-lifecycle-attached`,
:ref:`hardware-model-lifecycle-activated`,
:ref:`hardware-model-lifecycle-off`, or
:ref:`hardware-model-lifecycle-detached`.

The AP should not send a Control Connected Request to an Interface
with a cport_id field if it has stored information indicating that the
CPort is connected. If this occurs, the results are undefined.

The AP Interface shall not transmit |unipro| Segments to a CPort
identified by an Interface Manifest's CPort Descriptors unless it
successfully exchanges a Control Connected Operation with the
Interface as part of Greybus Connection establishment, as described in
:ref:`lifecycles_connection_establishment`. After this successful
exchange of a Control Connected Operation, the AP Interface may
transmit Segments on the CPort at its end of the Connection, as
described in :ref:`connection-tx-restrictions`.

.. _control-disconnecting:

Greybus Control Disconnecting Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. SW-4660 + any sub-tasks track adding module/module connections.

.. note::

   The Control Disconnected Operation is currently defined under the
   assumption that all Connections in the Greybus System are between
   an AP Interface and another, non-AP Interface in the System.

   The results in the case of Connections between two Interfaces,
   neither or both of which are AP Interfaces, are undefined.

After establishing a Greybus Connection from an AP Interface to
another Interface, the AP may later use the Greybus Control
Disconnecting Operation to notify the Interface that the Connection is
being closed, and thus that the CPort will later be disconnected.

Procedures the AP may use to establish and close Greybus Connections
are provided in :ref:`lifecycles_connection_management`. Use of this
Operation is part of those procedures.

Greybus Control Disconnecting Request
"""""""""""""""""""""""""""""""""""""

The Greybus Control Disconnecting request supplies the CPort ID on the
receiving Interface that is being closed.

.. figtable::
    :nofig:
    :label: table-control-disconnecting-request
    :caption: Control Protocol Disconnecting Request
    :spec: l l c c l

    =======  ==============  ======  =======    ===========================
    Offset   Field           Size    Value      Description
    =======  ==============  ======  =======    ===========================
    0        cport_id        2       Number     CPort that is being disconnected
    =======  ==============  ======  =======    ===========================

..

After sending this request to notify the Interface that a Connection
is closing, the AP Interface may transmit Segments on the CPort at its
end of the Connection as defined in :ref:`connection-tx-restrictions`
if one or more of the following conditions hold:

- when issuing responses to requests it has already received on the
  Connection,
- when exchanging :ref:`Ping Operations <greybus-protocol-ping-operation>`
  with the Interface, or
- when transmitting |unipro| Flow Control Tokens.

The AP Interface shall otherwise halt Segment transmission on the CPort.

The AP Interface may send a Control Disconnecting Operation with a cport_id
field equal to zero when disconnecting a Control Connection, but
should not do so if it has stored information indicating that other
CPorts on that Interface are connected.

After receiving the request, the Interface may transmit Segments on
the CPort at its end of the Connection as defined in
:ref:`connection-tx-restrictions` if one or more of the following
conditions hold:

- when issuing responses on the Connection to Operations whose
  requests it received before the Control Disconnecting Operation
  Request,
- when exchanging Ping Operations with the AP, or
- when transmitting |unipro| Flow Control Tokens.

The receiving Interface shall otherwise halt Segment transmission on
the CPort.

Greybus Control Disconnecting Response
""""""""""""""""""""""""""""""""""""""

The Greybus Control Disconnecting response message contains no payload.

The response status shall equal GB_OP_SUCCESS.

Before issuing a response to a Disconnecting request, the Interface
shall ensure that any further |unipro| Messages received on the CPort
associated with its side of the Connection are immediately discarded,
unless the Messages are well-formed Greybus Ping requests.

.. _control-disconnected:

Greybus Control Disconnected Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. SW-4660 + any sub-tasks track adding module/module connections.

.. note::

   The Control Disconnected Operation is currently defined under the
   assumption that all Connections in the Greybus System are between
   an AP Interface and another, non-AP Interface in the System.

   The results in the case of Connections between two Interfaces,
   neither or both of which are AP Interfaces, are undefined.

The Greybus Control Disconnected Operation is sent to notify an
Interface that a Greybus Connection has been closed. The users of the
CPorts at each end of the Connection shall no longer transmit data on
their respective CPorts unless a new Connection is established using
those CPorts. Any messages received by the Interface on the CPort
after the Control Disconnected Request is received shall be discarded,
unless a Greybus Connection is later reestablished on that CPort.

Greybus Control Disconnected Request
""""""""""""""""""""""""""""""""""""

The Greybus Control Disconnected Request supplies the CPort ID on the
receiving Interface for the Greybus Connection which is now closed.
The |unipro| CPort on the Interface which was at one end of the
Connection may subsequently be disconnected by the SVC.

.. figtable::
    :nofig:
    :label: table-control-disconnected-request
    :caption: Control Protocol Disconnected Request
    :spec: l l c c l

    =======  ==============  ======  =======    ===========================
    Offset   Field           Size    Value      Description
    =======  ==============  ======  =======    ===========================
    0        cport_id        2       Number     CPort that is now disconnected
    =======  ==============  ======  =======    ===========================

..

After receiving the request, the Interface shall perform any
implementation-defined procedures required to make the CPort usable if
a Greybus Connection is later reestablished on that CPort. The
Interface may set local |unipro| attributes related to that CPort to
implementation-defined values as part of this process.  If such
procedures are required by the Interface, it shall complete them
before sending the response.

Before sending the response, the receiving Interface shall halt
Segment transmission on the CPort given by cport_id as described in
:ref:`connection-tx-restrictions`.

Greybus Control Disconnected Response
"""""""""""""""""""""""""""""""""""""

The Greybus Control Disconnected Response message contains no payload.

The response status shall equal GB_OP_SUCCESS.

After receiving the response, the AP shall halt Segment transmission
on the CPort which was at its end of the Connection which is now
closed, as defined in :ref:`connection-tx-restrictions`.

.. _control-timesync-enable:

Greybus Control TimeSync Enable Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP Module uses this operation to inform the Interface of an upcoming
pulse-train of TIME_SYNC strobes. The 'count' parameter informs the
Interface of how many TIME_SYNC strobes will be issued. The range of the
count variable is from 1..4. The 'frame_time' parameter informs the
Interface to immediately seeds its frame-time to a value given by the AP.
The 'strobe_delay' parameter informs the Interface of the expected delay
between each TIME_SYNC strobe. The 'refclk' parameter informs the Interface
of the required clock rate to run its frame-time tracking counter at.

A later operation initiated by the AP will inform the Interface of the
authoritative frame-time at each TIME_SYNC strobe.

Greybus Control TimeSync Enable Request
"""""""""""""""""""""""""""""""""""""""

Table :num:`table-control-timesync-enable-request` defines the Greybus
Control TimeSync Enable Request payload. The request supplies the number
of TIME_SYNC strobes to come (count), the initial time (frame_time) the
delay between each strobe (strobe_delay) and the required clock rate to run
the local timer at (refclk).

.. figtable::
    :nofig:
    :label: table-control-timesync-enable-request
    :caption: Control Protocol TimeSync Enable Request
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

Greybus Control TimeSync Enable Response
""""""""""""""""""""""""""""""""""""""""

The Greybus Control Protocol TimeSync Enable response contains no payload.

.. _control-timesync-disable:

Greybus Control TimeSync Disable Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP Module uses this operation to inform an Interface to stop tracking
frame-time. The Interface will immediately stop tracking frame-time.

Greybus Control TimeSync Disable Request
""""""""""""""""""""""""""""""""""""""""

The Greybus Control Protocol TimeSync Disable request contains no payload.

Greybus Control TimeSync Disable Response
"""""""""""""""""""""""""""""""""""""""""

The Greybus Control Protocol TimeSync Disable response contains no payload.

.. _control-timesync-authoritative:

Greybus Control TimeSync Authoritative Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP Module uses this operation to inform the Interface of the previous
authoritative frame-time at each TIME_SYNC strobe. The AP will store and
forward this data to an Interface after interrogating this data from the
SVC. Unused entires in the request shall be initialized to zero.

Greybus Control TimeSync Authoritative Request
""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-control-timesync-authoritative-request` defines the Greybus
Control TimeSync Authoritative Request payload. The authoritative frame-time
at each TIME_SYNC strobe as reported by the SVC to the AP Module is
stipulated. Unused slots in the response shall contain zero.

.. figtable::
    :nofig:
    :label: table-control-timesync-authoritative-request
    :caption: Control Protocol TimeSync Authoritative Request
    :spec: l l c c l

    =======  ==============  ======  ==========  ===================================================================
    Offset   Field           Size    Value       Description
    =======  ==============  ======  ==========  ===================================================================
    0        time_sync0      8       Number      Authoritative frame-time at TIME_SYNC0
    8        time_sync1      8       Number      Authoritative frame-time at TIME_SYNC1
    16       time_sync2      8       Number      Authoritative frame-time at TIME_SYNC2
    24       time_sync3      8       Number      Authoritative frame-time at TIME_SYNC3
    =======  ==============  ======  ==========  ===================================================================
..

Greybus Control TimeSync Authoritative Response
"""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Control Protocol TimeSync Authoritative Response contains no payload.

.. _control-timesync-get-last-event:

Greybus Control TimeSync Get Last Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP Module uses this operation to extract the last frame-time from an Interface
associated with a wake event.

Greybus Control TimeSync Get Last Event Request
"""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Control Protocol TimeSync Get Last Event Request contains no payload.

Greybus Control TimeSync Get Last Event Response
""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-control-timesync-get-last-event-response` defines the Greybus
Control TimeSync Get Last Event Response payload. The frame-time at the last
wake event is returned.

.. figtable::
    :nofig:
    :label: table-control-timesync-get-last-event-response
    :caption: Control Protocol TimeSync Get Last Event Response
    :spec: l l c c l

    =======  ==============  ======  ==========  ===================================================================
    Offset   Field           Size    Value       Description
    =======  ==============  ======  ==========  ===================================================================
    0        frame-time      8       Number      frame-time at the last wake event.
    =======  ==============  ======  ==========  ===================================================================

.. _control-bundle-version:

Greybus Control Bundle Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP uses this operation to retrieve the version of the Bundle Class
implemented by a Bundle. The version is represented by two 1-byte numbers,
major and minor.

The version of a particular Bundle Class advertised by an Interface
is the same as the version of the document that defines the
Bundle Class and its subprotocols (so for Bundle Classes defined herein, the
version is |gb-major|.\ |gb-minor|). In the future, if the Bundle Class
specifications are removed from this document, the versions will become
independent of the overall Greybus Specification document.

Greybus Control Bundle Version Request
""""""""""""""""""""""""""""""""""""""

Table :num:`table-control-bundle-version-request` defines the
Greybus Control Bundle Version Request payload. The request contains the ID of
the Bundle whose Bundle Class version is to be returned.

.. figtable::
    :nofig:
    :label: table-control-bundle-version-request
    :caption: Control Protocol Bundle Version request
    :spec: l l c c l

    =======  ============  ======  ==========  ===========================
    Offset   Field         Size    Value       Description
    =======  ============  ======  ==========  ===========================
    0        bundle_id     1       Number      Bundle ID
    =======  ============  ======  ==========  ===========================
..

Greybus Control Bundle Version Response
"""""""""""""""""""""""""""""""""""""""

Table :num:`table-control-bundle-version-response` defines the
Greybus Control Bundle Version Response payload. The response
contains two 1-byte numbers, major and minor.

.. figtable::
    :nofig:
    :label: table-control-bundle-version-response
    :caption: Control Protocol Bundle Version Response
    :spec: l l c c l

    =======  ============  ======  ==========  ===========================
    Offset   Field         Size    Value       Description
    =======  ============  ======  ==========  ===========================
    0        major         1       Number      Major number of the version
    1        minor         1       Number      Minor number of the version
    =======  ============  ======  ==========  ===========================
..

.. _control-mode-switch:

Greybus Control Mode Switch Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP can use this Operation to notify the Interface of the
following:

- The Control Connection is closed
- The Interface may now alter its Bundles

Although the AP may send this request at any time, it should only do
so during the "ms_enter" transition from the
:ref:`hardware-model-lifecycle-enumerated` Interface :ref:`Lifecycle
State <hardware-model-lifecycle-states>` to
:ref:`hardware-model-lifecycle-mode-switching`, as defined in
:ref:`lifecycles_interface_lifecycle`. This is described in
:ref:`lifecycles_ms_enter`. The effect of this Operation under other
conditions is unspecified.

Note that the Greybus Control Mode Switch Operation is unidirectional
and has no response. This is a necessary consequence of the fact that
the AP uses this Operation Request to inform the Interface that the
Control Connection is now closed, since Interfaces shall not transmit
data on CPorts whose Greybus Connections are closed.

Instead, when the Interface is ready to signal completion of its
handling of this Operation, it shall do so by setting the
:ref:`hardware-model-mailbox` sub-state of its associated Interface
State. The SVC shall detect when MAILBOX is set and, other than in
certain special circumstances, shall subsequently notify the AP using
a :ref:`svc-interface-mailbox-event`. This indirect mechanism allows the
Interface to notify the AP when the processing that results from a
Mode Switch Request has completed.

Any timeouts limiting the duration between the receipt of the Mode
Switch request and a subsequent MAILBOX write by the Interface are
implementation-defined.

Greybus Control Mode Switch Request
"""""""""""""""""""""""""""""""""""

The Greybus Control Mode Switch Request contains no payload.

The AP shall send this request only as the final step in the procedure
defined below in :ref:`lifecycles_control_closure_ms_enter`. When the
Interface receives the request, its Control Connection is now closed.

After receiving the request, the Interface shall perform any
implementation-defined procedures required to make the Control CPort
usable if a Greybus Connection is later reestablished on that
CPort. The Interface may set local |unipro| attributes related to that
CPort to implementation-defined values as part of these procedures.

The Interface may now release any internal resources it had acquired
in response to Control Get Manifest Size or Control Get Manifest
Operations. In particular, the Interface may now stop responding to
incoming Operation requests on CPorts whose users previously had been
configured to implement Greybus Protocols other than the Control
Protocol. The effects of the AP subsequently establishing Greybus
Connections and attempting to exchange data with any such CPorts are,
other than the constraints defined in this version of the Greybus
Specification, not specified.

After any such procedures are complete, the Interface shall write the
value MAILBOX_GREYBUS to its Interface State's MAILBOX
attribute. Before doing so, the Interface shall ensure it can
subsequently respond to incoming :ref:`control-protocol` Operation
Requests if its Control Connection is reestablished. If the Interface
cannot ensure this, it shall not set the MAILBOX state as a result of
receiving this request.