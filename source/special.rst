.. _special_protocols:

Special Protocols
=================

This section defines three Protocols, each of which serves a special
purpose in a Greybus system.

The first is the :ref:`control-protocol`.  Every Interface shall provide
a CPort that uses the Control Protocol. It is used by the AP Module to
notify Interfaces when connections are available for them to use.

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

.. _control-protocol:

Control Protocol
----------------

All Interfaces are required to define a CPort that uses the Control
Protocol, and shall be prepared to receive Operation requests on that
CPort at any time. The CPort that uses the Control Protocol must have an
id of '0'. CPort id '0' is a reserved CPort address for the Control
Protocol. Similarly the bundle descriptor associated with the Control
CPort must have an id of '0'. Bundle id '0' is a reserved id for the
Control Protocol bundle descriptor.

A Greybus connection is established whenever a control connection is used,
but the Interface is never notified that such a connection exists. Only
the AP Module is able to send control requests.  Any other Interface
shall only send control response messages, and such messages shall
only be sent in reply to a request received on its control CPort.

Conceptually, the Operations in the Greybus Control Protocol are:

.. c:function:: int ping(void);

    See :ref:`greybus-protocol-ping-operation`.

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Refer to :ref:`greybus-protocol-version-operation`.

.. c:function:: int get_manifest_size(u16 *size);

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
    pulse on the wake-detect pin of a relevant Interface. This operation
    is used in conjunction with an SVC timesync-ping operation to verify
    the local time at a given Interface.

.. c:function:: int interface_version(u16 *major, u16 *minor);

    This Operation is used by the AP to get the current version of the
    interface.

.. c:function:: int bundle_version(u8 bundle_id, u8 *major, u8 *minor);

    This Operation is used by the AP to get the version of the Bundle Class
    implemented by a Bundle.

Greybus Control Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^

All control Operations are contained within a Greybus control
request message. Every control request results in a matching
response.  The request and response messages for each control
Operation are defined below.

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
    Interface Version            0x0a           0x8a
    Bundle Version               0x0b           0x8b
    Disconnecting                0x0c           0x8c
    TimeSync get last event      0x0d           0x8d
    (all other values reserved)  0x0e..0x7e     0x8e..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

Greybus Control Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Control Ping Operation is the
:ref:`greybus-protocol-ping-operation` for the Control Protocol.
It consists of a request containing no payload, and a response
with no payload that indicates a successful result.

Greybus Control Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Control Protocol Version Operation is the
:ref:`greybus-protocol-version-operation` for the Control Protocol.

Greybus implementations adhering to the Protocol specified herein
shall specify the value |gb-major| for the version_major and
|gb-minor| for the version_minor fields found in this Operation's
request and response messages.

Greybus Control Get Manifest Size Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control get manifest size Operation is used by the AP for
all non-AP Interfaces (other than interface zero, which belongs to the
SVC), on hotplug event, to determine the size of the manifest.

Greybus Control Get Manifest Size Request
"""""""""""""""""""""""""""""""""""""""""

The Greybus control get manifest size request is sent by the AP to all
non-AP modules.  The Greybus control get manifest size request message
has no payload.

Greybus Control Get Manifest Size Response
""""""""""""""""""""""""""""""""""""""""""

The Greybus control get manifest size response contains a two byte field
'size'.

.. figtable::
    :nofig:
    :label: table-control-get-manifest-size-response
    :caption: Control Protocol Get Manifest Size Response
    :spec: l l c c l

    =======  ==============  ===========  ==========      ===========================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ===========================
    0        size            2            Number          Size of the Manifest
    =======  ==============  ===========  ==========      ===========================

..

Greybus Control Get Manifest Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control get manifest Operation is used by the AP for all
non-AP Interfaces (other than interface zero, which belongs to the SVC),
on hotplug event, to determine the functionality provided by the
module via that interface.

Greybus Control Get Manifest Request
""""""""""""""""""""""""""""""""""""

The Greybus control get manifest request is sent by the AP to all non-AP
modules.  The Greybus control get manifest request message has no payload.

Greybus Control Get Manifest Response
"""""""""""""""""""""""""""""""""""""

The Greybus control get manifest response contains a block of data, that
describes the functionality provided by the module. This block of data is also
known as :ref:`manifest-description`.

.. figtable::
    :nofig:
    :label: table-control-get-manifest-response
    :caption: Control Protocol Get Manifest Response
    :spec: l l c c l

    =======  ==============  ===========  ==========      ===========================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ===========================
    0        manifest        *size*       Data            Manifest
    =======  ==============  ===========  ==========      ===========================

..

Greybus Control Connected Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Control Connected Operation is sent to notify an Interface
that one of its CPorts (other than control CPort) now has a connection
established.  The SVC sends this request when it has set up a Greybus
SVC connection with an AP Module Interface.  The AP Module sends this
request to other Interfaces when it has set up Greybus connections for
them to use.

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

Greybus Control Connected Response
""""""""""""""""""""""""""""""""""

The Greybus control connected response message contains no payload.

Greybus Control Disconnecting Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Control Disconnecting Operation is used by the AP Module
to inform an Interface that the disconnect process has begun for a
CPort that was previously the subject of a Greybus Control Connected
Operation.  After sending this request, the AP Module may issue
responses to requests from the Interface, but it shall send no
further requests on the CPort given in the Control Disconnecting
Operation request.  The Interface may send responses to the AP to
Operations whose requests it received before receiving the Control
Disconnecting Operation Request, but shall otherwise cease
transmission on the given CPort.  The AP Module may send a Control
Disconnecting Operation with a cport_id field equal to zero (i.e.,
when disconnecting the Control CPort itself), but only after all
other connections on the interface have been disconnected as
specified by the Control Protocol Disconnected Operation.

Greybus Control Disconnecting Request
"""""""""""""""""""""""""""""""""""""

The Greybus Control Disconnecting request supplies the CPort ID on the
receiving Interface that is being disconnected.

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

Greybus Control Disconnecting Response
""""""""""""""""""""""""""""""""""""""

The Greybus Control Disconnecting response message contains no payload.

Greybus Control Disconnected Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control disconnected Operation is sent to notify an
Interface that a CPort (other than control CPort) that was formerly
the subject of a Greybus Control Connected Operation shall no longer
be used.  No more messages may be sent over this connection, and any
messages received shall be discarded.

Greybus Control Disconnected Request
""""""""""""""""""""""""""""""""""""

The Greybus control disconnected request supplies the CPort ID on the
receiving Interface that is no longer connected.

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

Greybus Control Disconnected Response
"""""""""""""""""""""""""""""""""""""

The Greybus control disconnected response message contains no payload.

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

Greybus Control TimeSync Get Last Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP Module uses this operation to extract the last frame-time from an Interface
associated with a wake-detect event.

Greybus Control TimeSync Get Last Event Request
"""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Control Protocol TimeSync Get Last Event Request contains no payload.

Greybus Control TimeSync Get Last Event Response
""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-control-timesync-get-last-event-response` defines the Greybus
Control TimeSync Get Last Event Response payload. The frame-time at the last
wake-detect event is returned.

.. figtable::
    :nofig:
    :label: table-control-timesync-get-last-event-response
    :caption: Control Protocol TimeSync Get Last Event Response
    :spec: l l c c l

    =======  ==============  ======  ==========  ===================================================================
    Offset   Field           Size    Value       Description
    =======  ==============  ======  ==========  ===================================================================
    0        frame-time      8       Number      frame-time at the last wake-detect event.
    =======  ==============  ======  ==========  ===================================================================

Greybus Control Interface Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP uses this operation to retrieve the version of the interface.
The version is represented by two 2-byte numbers, major and minor.

Greybus Control Interface Version Request
"""""""""""""""""""""""""""""""""""""""""

The Greybus Control Interface Version request has no payload.

Greybus Control Interface Version Response
""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-control-interface-version-response` defines the
Greybus Control Interface Version Response payload. The response
contains two 2-byte numbers, major and minor.

.. figtable::
    :nofig:
    :label: table-control-interface-version-response
    :caption: Control Protocol Interface Version Response
    :spec: l l c c l

    =======  ============  ======  ==========  ===========================
    Offset   Field         Size    Value       Description
    =======  ============  ======  ==========  ===========================
    0        major         2       Number      Major number of the version
    2        minor         2       Number      Minor number of the version
    =======  ============  ======  ==========  ===========================
..

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
    associate a device ID with the given Interface.

.. c:function:: int intf_hotplug(u8 intf_id, u32 ddbl1_mfr_id, u32 ddbl1_prod_id, u32 ara_vend_id, u32 ara_prod_id, u64 serial_number);

    The SVC sends this to the AP Module to inform it that it has
    detected a module on the indicated Interface.  It supplies some information
    that describes the module that has been attached.

.. XXX We may need to adjust based on whether detect is associated
.. XXX with a module (as opposed to an Interface).

.. c:function:: int intf_hotunplug(u8 intf_id);

    The SVC sends this to the AP Module to tell it that a module is
    no longer present on an Interface.

.. c:function:: int intf_reset(u8 intf_id);

    The SVC sends this to inform the AP Module that an active
    Interface needs to be reset.  This might happen when the SVC has
    detected
    an error on the link, for example.

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

.. c:function:: int timesync_wd_pins_init(u32 strobe_mask);

    The AP Module uses this operation to request the SVC to take control
    of a bit-mask of SVC device-id wake-detect lines. This done to establish
    an initial state on the relevant wake-detect lines prior to generating
    timesync releated events.

.. c:function:: int timesync_wd_pins_fini(void);

    The AP Module uses this operation to request the SVC to release
    any wake-detect lines currently reserved for time-sync operations.

.. c:function:: int timesync_ping(u64 *frame_time);

    The AP Module uses this operation to request the SVC to generate a single
    pulse on a bit-mask of wake-detect lines communicated to SVC by a prior
    timesync_wd_pins_init() operation. SVC will return the authoritative
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

.. c:function:: int connection_quiescing(u8 intf_id, u16 cport_id);

    The AP uses this operation to notify the SVC that a connection
    being torn down is quiescing.

.. c:function:: int module_inserted(u8 primary_intf_id, u8 intf_count);

    The SVC uses this operation to notify the AP Module of the
    presence of a newly inserted Module.  It sends the request after
    it has determined the size and position of the Module in the
    Frame.

.. c:function:: int module_removed(u8 primary_intf_id);

    The SVC uses this operation to notify the AP Module that a
    Module that was previously the subject of a Greybus SVC Module

.. c:function:: int intf_power_state_set(u8 intf_id, u8 enable, u8 *result);

   The AP uses this operation to request the SVC to power ON or power
   OFF the Interface associated with the Interface ID.

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
    Interface device ID                 0x03           0x83
    Interface hotplug                   0x04           0x84
    Interface hot unplug                0x05           0x85
    Interface reset                     0x06           0x86
    Connection create                   0x07           0x87
    Connection destroy                  0x08           0x88
    DME peer get                        0x09           0x89
    DME peer set                        0x0a           0x8a
    Route create                        0x0b           0x8b
    Route destroy                       0x0c           0x8c
    TimeSync enable                     0x0d           0x8d
    TimeSync disable                    0x0e           0x8e
    TimeSync authoritative              0x0f           0x8f
    Interface set power mode            0x10           0x90
    Module Eject                        0x11           0x91
    Key Event                           0x12           N/A
    Reserved                            0x13           0x93
    Power Monitor get rail count        0x14           0x94
    Power Monitor get rail names        0x15           0x95
    Power Monitor get sample            0x16           0x96
    Power Monitor interface get sample  0x17           0x97
    TimeSync wake-detect pins init      0x18           0x98
    TimeSync wake-detect pins fini      0x19           0x99
    TimeSync ping                       0x1a           0x9a
    Power Down                          0x1d           0x9d
    Connection Quiescing                0x1e           0x9e
    Module Inserted                     0x1f           0x9f
    Module Removed                      0x20           0xa0
    Interface Power State Set           0x21           0xa1
    (all other values reserved)         0x22..0x7e     0xa2..0xfe
    Invalid                             0x7f           0xff
    ==================================  =============  ==============

..

Greybus SVC Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Ping Operation is the
:ref:`greybus-protocol-ping-operation` for the SVC Protocol.
It consists of a request containing no payload, and a response
with no payload that indicates a successful result.

Greybus SVC Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Protocol Version Operation is the
:ref:`greybus-protocol-version-operation` for the SVC Protocol.

Greybus implementations adhering to the Protocol specified herein
shall specify the value |gb-major| for the version_major and
|gb-minor| for the version_minor fields found in this Operation's
request and response messages.

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

Greybus SVC Hello Response
""""""""""""""""""""""""""

The Greybus SVC Hello response contains no payload.

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

Greybus SVC DME Peer Get Response
"""""""""""""""""""""""""""""""""

Table :num:`table-dme-peer-get-response` defines the Greybus SVC DME
Peer Get Response payload.  The Greybus DME Peer Get response contains
the ConfigResultCode as defined in the |unipro| specification, as well
as the value of the attribute, if applicable.

.. figtable::
    :nofig:
    :label: table-dme-peer-get-response
    :caption: SVC Protocol DME Peer Get Response
    :spec: l l c c l

    =======  ==============  ===========  ================  =========================================
    Offset   Field           Size         Value             Description
    =======  ==============  ===========  ================  =========================================
    0        result_code     2            Number            |unipro| DME Peer Get ConfigResultCode
    2        attr_value      4            Number            |unipro| DME Peer Get DME Attribute value
    =======  ==============  ===========  ================  =========================================

..

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

Greybus SVC DME Peer Set Response
"""""""""""""""""""""""""""""""""

Table :num:`table-dme-peer-set-response` defines the Greybus SVC DME
Peer Set Response payload. The Greybus DME Peer Set response contains
the ConfigResultCode as defined in the |unipro| specification.

.. figtable::
    :nofig:
    :label: table-dme-peer-set-response
    :caption: SVC Protocol DME Peer Set Response
    :spec: l l c c l

    =======  ==============  ===========  ================  =========================================
    Offset   Field           Size         Value             Description
    =======  ==============  ===========  ================  =========================================
    0        result_code     2            Number            |unipro| DME Peer Set ConfigResultCode
    =======  ==============  ===========  ================  =========================================

..

Greybus SVC Route Create Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Protocol Route Create Operation allows the AP Module
to request a route be established for |unipro| traffic between two
Interfaces.

Greybus SVC Route Create Request
""""""""""""""""""""""""""""""""

Table :num:`table-svc-route-create-request` defines the Greybus SVC
Route Create request payload. The request supplies the Interface IDs and device
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
    1        dev1_id         1       Number      First Interface device ID
    2        intf2_id        1       Number      Second Interface
    3        dev2_id         1       Number      Second Interface device ID
    =======  ==============  ======  ==========  ===========================

..

Greybus SVC Route Create Response
"""""""""""""""""""""""""""""""""

The Greybus SVC Protocol Route Create response contains no payload.

Greybus SVC Route Destroy Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Protocol Route Destroy Operation allows the AP Module
to request a route be torn down for |unipro| traffic between two
Interfaces.

Greybus SVC Route Destroy Request
""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-route-destroy-request` defines the Greybus SVC
Route Create request payload. The request supplies the Interface IDs
of two Interfaces to be disconnected.

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

Greybus SVC Route Destroy Response
""""""""""""""""""""""""""""""""""

The Greybus SVC Protocol Route Destroy response contains no payload.

Greybus SVC Interface Device ID Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Interface Device ID Operation is used by the AP Module
to request the SVC associate a device id with an Interface.  The
device id is used by the |unipro| switch to determine how packets
should be routed through the network.  The AP Module is responsible
for managing the mapping between Interfaces and |unipro| device ids.

Greybus supports 5-bit |unipro| device IDs. Device ID 0 and 1 are reserved
for the SVC and primary AP Interface respectively.

Greybus SVC Interface Device ID Request
"""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-device-id-request` defines the Greybus SVC
Interface Device ID Request payload.

The Greybus SVC Interface Device ID Request shall only be sent by the
AP Module to the SVC.  It supplies the 5-bit device ID that the SVC will
associate with the indicated Interface.  The AP Module can remove the
association of an Interface with a device ID by assigning device ID
value 0. The AP shall not assign a (non-zero) device ID to an
Interface that the SVC has already associated with an Interface, and
shall not clear the device ID of an Interface that has no device ID
assigned.

Note that assigning a device ID to an Interface does not cause
the SVC to set up any routes for that device ID.  Routes are
set up only as needed when a connection involving a device ID
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
    0        intf_id         1       Number          Interface ID whose device ID is being assigned
    1        device_id       1       Number          5-bit |unipro| device ID for Interface
    =======  ==============  ======  ============    ===========================

..

Greybus SVC Interface Device ID Response
""""""""""""""""""""""""""""""""""""""""

The Greybus SVC Interface Device ID response message contains no payload.

Greybus SVC Interface Hotplug Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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

Greybus SVC Interface Hot Unplug Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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

Greybus SVC Interface Set Power Mode Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP sends this to the SVC to request that it change the |unipro|
power mode for the |unipro| link on an Interface.

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
SVC Interface Set Power Mode Response message with status byte
GB_OP_INVALID. The SVC shall make no changes to the link's power mode
in this case.

The tx_mode and rx_mode fields in the Greybus SVC Interface Set Power
Mode Request determine the |unipro| Power Modes of the link's transmit
and receive directions, respectively. The transmit and receive
directions are defined with respect to the UniPort attached to the
|unipro| switch. For example, tx_mode determines the |unipro| power
mode of the transmitter which is attached to the |unipro| switch at
the Interface given by intf_id; tx_mode does not refer to the
transmitter within the switch itself.

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

When reconfiguring the link power mode as a result of receiving a
Greybus SVC Interface Set Power Mode Request, the link's transmitter and/or
receiver power mode shall be set to the given configuration.
The status field of the response to a Greybus SVC Interface Set Power Mode
Request shall not be used to check the result of the power mode change
operation. It shall only be used to indicate the result of the Greybus
communication only. If the response to a Greybus SVC Interface Set Power Mode
Request has status different than GB_OP_SUCCESS, it shall indicate that a
Greybus communication error occurred and that the power mode change could not be
initiated; the targeted link shall be in the same state as before the request
was issued. If the response to a Greybus SVC Interface Set Power Mode Request
has status GB_OP_SUCCESS, it shall indicate that there was no Greybus
communication error detected (request and response were successfully exchanged).
However, it shall not also be considered as a successful power mode change.
The pwr_change_result_code field in the response, as described in
Table :num:`table-svc-interface-set-power-mode-response-pwr-change-result-code`
shall be used for that unique purpose. In other words, if and only if response
status field is GB_OP_SUCCESS and pwr_change_result_code field in the response
is PWR_OK then the power mode change request shall be considered as successful.
Operation shall otherwise be considered as failed in any other
combination of these two fields.

Greybus SVC Interface Set Power Mode Response
"""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-set-power-mode-response` defines the
Greybus SVC Interface Set Power Mode Response payload.

.. figtable::
   :nofig:
   :label: table-svc-interface-set-power-mode-response
   :caption: SVC Protocol Interface Set Power Mode Response
   :spec: l l c c l

   =======  ======================     =========   ========   ==============================
   Offset   Field                      Size        Value      Description
   =======  ======================     =========   ========   ==============================
   0        pwr_change_result_code     1           Number     |unipro| PowerChangeResultCode
   =======  ======================     =========   ========   ==============================

..

The Greybus Interface Set Power Mode response message contains a field
which may contain a PowerChangeResultCode as defined by the |unipro|
specification, version 1.6, Table 9.
The pwr_change_result_code field in the response payload indicates a successful
operation or describes the reason for the operation failure. The values of the
pwr_change_result_code field are defined in
Table :num:`table-svc-interface-set-power-mode-response-pwr-change-result-code`.

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

Greybus SVC Connection Create Response
""""""""""""""""""""""""""""""""""""""

The Greybus SVC connection create response message contains no payload.

Greybus SVC Connection Quiescing Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP Module sends this to the SVC to indicate that a connection
being torn down has entered its quiescing stage before being
disconnected.  The AP shall have received a response to a Control
Disconnecting request from the Interface prior to this call.
This operation allows the SVC to prepare the underlying |unipro|
connection for an orderly shutdown before it is finally disconnected.

Greybus SVC Connection Quiescing Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-svc-connection-quiescing-request` defines the Greybus
SVC Connection Quiescing Request payload.  The Greybus SVC
Connection Quiescing request is sent only by the AP Module to the
SVC.  The (Interface ID, CPort ID) pair defines the Connection being
quiesced.

.. figtable::
    :nofig:
    :label: table-svc-connection-quiescing-request
    :caption: SVC Protocol Connection Quiescing Request
    :spec: l l c c l

    =======  ==============  ======  ==================  ===========================
    Offset   Field           Size    Value               Description
    =======  ==============  ======  ==================  ===========================
    0        intf_id         1       Number              Interface
    1        cport_id        2       Number              CPort on Interface
    =======  ==============  ======  ==================  ===========================

..

Greybus SVC Connection Quiescing Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Connection Quiescing response message contains no payload.

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

Greybus SVC Connection Destroy Response
"""""""""""""""""""""""""""""""""""""""

The Greybus SVC connection destroy response message contains no payload.

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
response shall contain zero.

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

Greybus SVC TimeSync Wake-Detect Pins Init Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP Module uses this operation to request the SVC to take ownership-of and
establish-an initial state on a bit-mask of SVC device-ids specified by the
strobe_mask parameter passed as part of the request phase of the operation.

The SVC will take control of the wake-detect lines specified in the request and
set the outputs to logical 0.

Greybus SVC TimeSync Wake-Detect Pins Init Request
""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-timesync-wd-pins-init-request` defines the Greybus SVC
TimeSync Wake-Detect Pins Init Request payload. The request supplies the
bit-mask (strobe_mask) of SVC device-ids which should have their wake-detect
pins set to output with logical state 0.

.. figtable::
    :nofig:
    :label: table-svc-timesync-wd-pins-init-request
    :caption: SVC Protocol TimeSync Wake-Detect Pins Init Request
    :spec: l l c c l

    =======  ============  ======  ==========  =================================================
    Offset   Field         Size    Value       Description
    =======  ============  ======  ==========  =================================================
    0        strobe_mask   4       Number      Bit-mask of devices SVC should allocate to output
    =======  ============  ======  ==========  =================================================

..

Greybus SVC TimeSync Wake-Detect Pins Init Response
"""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus SVC Protocol TimeSync Wake-Detect Pins Init response contains no payload.

Greybus SVC TimeSync Wake-Detect Pins Fini Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP Module uses this operation to request the SVC to release ownership of any
previously allocated wake-detect pins. SVC will release all pins allocated for
wake-detect purposes in a previous Greybus SVC TimeSync Wake-Detect Pins Init
operation.

Greybus SVC TimeSync Wake-Detect Pins Fini Request
""""""""""""""""""""""""""""""""""""""""""""""""""
The Greybus SVC Protocol TimeSync Wake-Detect Pins Fini request contains no payload.

Greybus SVC TimeSync Wake-Detect Pins Fini Response
"""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus SVC Protocol TimeSync Wake-Detect Pins Fini response contains no payload.

Greybus SVC TimeSync Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The AP Module uses this operation to request the SVC to send a single timesync
event on a bitmask of wake-detect pins which must have previously been allocated
via Greybus SVC TimeSync Wake-Detect Pins Init.

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
authoritative frame-time at the ping event generated.

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

Greybus SVC Module Eject Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Module Eject operation is sent by the AP Module
to request the SVC to execute the necessary actions to eject a
Module from the Frame.

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

Greybus SVC Module Eject Response
"""""""""""""""""""""""""""""""""

The Greybus SVC Module Eject response message contains no payload.

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
    0        key_code      2       Number      :ref:`svc_key_code`
    2        key_event     1       Number      :ref:`svc_key_events`
    =======  ============  ======  ==========  ======================================

..

.. _svc_key_code:

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

.. _svc_key_events:

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

The Greybus SVC Power Monitor Get Rail Names response is comprised of
human-readable names for rails that support voltage, current and power
measurement. Each name consists of a fixed 32-byte sub-buffer
containing a rail name padded with zero bytes. A rail name is
comprised of a subset of [US-ASCII]_ characters: lower- and upper-case
alphanumerics and the character '_'. A rail name is 1-32 bytes long;
a 32-byte name has no pad bytes.

The number of these buffers shall be exactly the number returned by
a prior Greybus SVC Power Monitor Get Rail Name Count operation.

If there are no measurable power rails on the platform,
the GB_OP_INVALID Greybus error shall be returned in response to this
request.

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
    0        rail_1_name     32           String          Rail #1 name
    32       rail_2_name     32           String          Rail #2 name
    (...)
    =======  ==============  ===========  ==========      ===========================

..

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
    1        type            1            Number          Measurement type indicator (:ref:`svc_pwrmon_measurement_types`)
    =======  ==============  ===========  ==========      ===========================

..

.. _svc_pwrmon_measurement_types:

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
    0        result          1            Number          Result code (:ref:`svc_pwrmon_get_sample_results`)
    1        measurement     4            Number          Measured value
    =======  ==============  ===========  ==========      ===========================

..

.. _svc_pwrmon_get_sample_results:

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
    1        type            1            Number          Measurement type indicator (:ref:`svc_pwrmon_measurement_types`)
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
    0        result          1            Number          Result code (:ref:`svc_pwrmon_get_sample_results`)
    0        measurement     4            Number          Measured value
    =======  ==============  ===========  ==========      ===========================

..

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

.. _greybus-svc-module-inserted-operation:

Greybus SVC Module Inserted Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Module Inserted request is sent by the SVC
to the AP Module to indicate that a new Module has been inserted
into the Frame.

Greybus SVC Module Inserted Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-svc-module-inserted-request` defines the Greybus SVC
Module Inserted request payload.  The request specifies the location
of the Primary Interface on the Frame for the inserted Module.  It
also specifies the number of Interfaces covered by the Module.

The location of each Interface ID on a Frame is well-defined:
Interface ID 1 represents the Interface Block at the top left of the
back (non-display) side of the Frame.  The next Interface ID is 2,
and it represents the Interface Block below (toward the bottom of
the Frame) Interface ID 1.  Interface IDs increase consecutively,
moving counter-clockwise around the Frame.  The size of a Module
(its interface count) is always 1 or more.

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
    =======  ===============  ====  ======  ====================

..

Greybus SVC Module Inserted Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Module Inserted response message contains no payload.

Greybus SVC Module Removed Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Module Removed request is sent by the SVC
to the AP Module.  It supplies the Interface ID for the Primary
Interface to the Module that is no longer present.  The Interface
ID shall have been the subject of a previous
:ref:`greybus-svc-module-inserted-operation`.

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

Greybus SVC Module Removed Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Module Removed response message contains no payload.

Greybus SVC Interface Power State Set Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP uses this operation to request the SVC to enable or disable power
to the Interface specified by the Interface ID. The SVC, on receiving
this operation, shall unconditionally perform the necessary actions to
power ON or power OFF the Interface.

Greybus SVC Interface Power State Set Request
"""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-power-state-set-request` defines the
Greybus SVC Interface Power State Set Request payload. The request
contains one-byte Interface ID and one-byte specifying the target
power state.

.. figtable::
    :nofig:
    :label: table-svc-interface-power-state-set-request
    :caption: SVC Protocol Interface Power State Set Request
    :spec: l l c c l

    =======  ==============  ======  ============    ============
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ============
    0        intf_id         1       Interface ID    Interface ID
    1        state           1       Number          Power State
    =======  ==============  ======  ============    ============
..

The state field in the request payload allows the AP to specify whether
the SVC shall power ON or power down the Interface.  Table
:num:`table-svc-interface-power-state-set-request-state` defines the
possible values for the state field.

.. figtable::
    :nofig:
    :label: table-svc-interface-power-state-set-request-state
    :caption: SVC Protocol Interface Power States
    :spec: l c l

    ===========  =====  ==============================
    POWER STATE  Value  Description
    ===========  =====  ==============================
    PWR_DISABLE  0      Disable Interface power
    PWR_ENABLE   1      Enable Interface power
    (Reserved)   2-255  Reserved
    ===========  =====  ==============================
..

A Greybus SVC Interface Power State Set Request with the "state" field
set to PWR_ENABLE means that the AP is requesting the SVC to power ON
the targeted Interface. The SVC, on receiving this request with
PWR_ENABLE state, shall unconditionally attempt to power ON the
Interface. The AP shall transition the Interface to PWR_ENABLE state
prior to initiating any new Greybus Operations on the Interface.

Similarly, a Greybus SVC Interface Power State Set Request with the
"state" field set to PWR_DISABLE means that the AP is requesting the
SVC to power OFF the targeted Interface. The SVC, on receiving this
request with PWR_DISABLE state, shall unconditionally attempt to power
OFF the Interface. The AP shall ensure that the Greybus connections
already established in the Interface are destroyed before issuing this
operation.

Greybus SVC Interface Power State Set Response
""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-interface-power-state-set-response` defines the
Greybus SVC Interface Power State Set Response payload. The response
contains a one-byte result code specifying the status.

.. figtable::
    :nofig:
    :label: table-svc-interface-power-state-set-response
    :caption: SVC Protocol Interface Power State Set Response
    :spec: l l c c l

    =======  ===========  ======  ==========  ===========
    Offset   Field        Size    Value       Description
    =======  ===========  ======  ==========  ===========
    0        result_code  1       Number      Result Code
    =======  ===========  ======  ==========  ===========
..

The status field of the response to a Greybus SVC Interface Power State
Set Request shall not be used to check the result of the operation. It
shall only be used to indicate the result of the Greybus communication.
If the response to a Greybus SVC Interface Power State Set Request has
status different than GB_OP_SUCCESS, it shall indicate that a Greybus
communication error occurred and that the targeted Interface could not
be powered ON or powered OFF; the targeted Interface shall be in the
same state as before the request was issued. If the response to a
Greybus SVC Interface Power State Set Request has status GB_OP_SUCCESS,
it shall indicate that there was no Greybus communication error detected
(request and response were successfully exchanged).  However, it shall
not also be considered as a successful power enable/disable.

The result_code field in the response, as described in Table
:num:`table-svc-interface-power-state-set-response` shall be used for
that unique purpose. In other words, if and only if the response status
field is GB_OP_SUCCESS and the result_code field in the response is
PWR_OK then the request shall be considered as successful. The operation
shall otherwise be considered as failed in any other combination of
these two fields.

The values of the result_code are defined in Table
:num:`table-interface-power-state-set-result-code`.

.. figtable::
    :nofig:
    :label: table-interface-power-state-set-result-code
    :caption: Interface Power State Set Result Code
    :spec: l l l

    ================  ========  =======================================================================================
    Result Code       Value     Description
    ================  ========  =======================================================================================
    PWR_OK            0         Power enable/disable operation was successful.
    PWR_BUSY          1         Power enable/disable operation cannot be attempted as the SVC is busy.
    PWR_FAIL          2         Power enable/disable was attempted and failed.
    (Reserved)        3-255     (Reserved for future use)
    ================  ========  =======================================================================================
..

.. _bootrom-protocol:

Bootrom Protocol
----------------

.. note:: Bootrom Protocol is deprecated for new designs requiring
          Firmware download to the Module.  It doesn't support
          downloading device processor firmware images and updating them
          on the Module.  Also, it doesn't include proper sequence of
          closing the CPorts, while switching from one Firmware stage to
          another.  It is already part of chips that went into
          production, and so its support can't be dropped from Greybus
          Specifications.

The Greybus Bootrom Protocol is used by a module's bootloader to communicate
with the AP and download firmware executables via |unipro| when a module does
not have its own firmware pre-loaded.

The operations in the Greybus Bootrom Protocol are:

.. c:function:: int ping(void);

    See :ref:`greybus-protocol-ping-operation`.

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Refer to :ref:`greybus-protocol-version-operation`.

.. c:function:: int ap_ready(void);

    The AP sends a request to the module in order to confirm that the AP
    is now ready to receive requests over its bootrom cport and the
    module can start firmware download process.  Until this request is
    received by the module, it shall not send any requests on the
    bootrom cport.

.. c:function:: int firmware_size(u8 stage, u32 *size);

    The module requests from the AP the size of the firmware it must
    load, specifying the stage of the boot sequence for which the module is
    requesting firmware.  The AP then locates a suitable firmware blob,
    associates that firmware blob with the requested boot stage until it next
    receives a firmware size request, and responds with the blob's size in
    bytes, which must be nonzero.

.. c:function:: int get_firmware(u32 offset, u32 size, void *data);

    The module requests a finite stream of bytes in the firmware blob
    from the AP, passing its current offset into the firmware blob, and the size
    of the stream it currently needs.  The AP responds with exactly the number
    of bytes requested, taken from the firmware blob currently associated with
    this connection at the specified offset.

.. c:function:: int ready_to_boot(u8 status);

    The module implementing the Protocol requests permission from the AP to jump
    into the firmware blob it has loaded.  The request sent to the AP includes a
    status indicating whether the retrieved firmware blob is valid and secure,
    valid but insecure, or invalid.  The AP decides whether to permit the module
    to boot in its current condition: if so, it sends a success code in its
    response's status byte, otherwise it sends an error code in its response's
    status byte.

Greybus Bootrom Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^
Table :num:`table-bootrom-operation-type` describes the Greybus Bootrom
operation types and their values.  A message type consists of an operation type
combined with a flag (0x80) indicating whether the operation is a request or a
response.

.. figtable::
    :nofig:
    :label: table-bootrom-operation-type
    :caption: Bootrom Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Bootrom Operation Type       Request Value  Response Value
    ===========================  =============  ==============
    Ping                         0x00           0x80
    Protocol Version             0x01           0x81
    Firmware Size                0x02           0x82
    Get Firmware                 0x03           0x83
    Ready to Boot                0x04           0x84
    AP Ready                     0x05           0x85
    (all other values reserved)  0x06..0x7e     0x86..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

Greybus Bootrom Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Bootrom Ping Operation is the
:ref:`greybus-protocol-ping-operation` for the Bootrom Protocol.  It
consists of a request containing no payload, and a response with no
payload that indicates a successful result.

Greybus Bootrom Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Bootrom Protocol Version Operation is the
:ref:`greybus-protocol-version-operation` for the Bootrom Protocol.

Greybus implementations adhering to the Protocol specified herein
shall specify the value |gb-major| for the version_major and
|gb-minor| for the version_minor fields found in this Operation's
request and response messages.


Greybus Bootrom Protocol AP Ready Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Bootrom Protocol AP Ready operation allows the AP to
indicate that it is ready to receive requests from the module over the
bootrom cport. Only after the module has received this request may it
start sending requests on the bootrom cport.

Greybus Bootrom Protocol AP Ready Request
"""""""""""""""""""""""""""""""""""""""""

The Greybus Bootrom AP Ready request message has no payload.

Greybus Bootrom Protocol AP Ready Response
""""""""""""""""""""""""""""""""""""""""""

The Greybus Bootrom AP Ready response message has no payload.

Greybus Bootrom Firmware Size Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Bootrom firmware size operation allows the requestor to submit a
boot stage to the AP, so that the AP can associate a firmware blob with that
boot stage and respond with its size.  The AP keeps the firmware blob associated
with the boot stage until it receives another Firmware Size Request on the same
connection, but is not required to send identical firmware blobs in response to
different requests with identical boot stages, even to the same module.

.. _firmware-size-request:

Greybus Bootrom Firmware Size Request
"""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-size-request` defines the Greybus Bootrom Firmware Size
request payload.  The request supplies the boot stage of the module implementing
the Protocol.

.. figtable::
    :nofig:
    :label: table-firmware-size-request
    :caption: Bootrom Protocol Firmware Size Request
    :spec: l l c c l

    ======  =========  ====  ======  ===============================================
    Offset  Field      Size  Value   Description
    ======  =========  ====  ======  ===============================================
    0       stage      1     Number  :ref:`firmware-boot-stages`
    ======  =========  ====  ======  ===============================================

..

.. _firmware-boot-stages:

Greybus Bootrom Firmware Boot Stages
""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-boot-stages` defines the boot stages whose firmware
can be requested from the AP via the Protocol.

.. figtable::
    :nofig:
    :label: table-firmware-boot-stages
    :caption: Bootrom Protocol Firmware Boot Stages
    :spec: l l l

    ================  ======================================================  ==========
    Boot Stage        Brief Description                                       Value
    ================  ======================================================  ==========
    BOOT_STAGE_ONE    Reserved for the boot ROM.                              0x01
    BOOT_STAGE_TWO    Firmware package to be loaded by the boot ROM.          0x02
    BOOT_STAGE_THREE  Module personality package loaded by Stage 2 firmware.  0x03
    |_|               (Reserved Range)                                        0x04..0xFF
    ================  ======================================================  ==========

..

.. _firmware-size-response:

Greybus Bootrom Firmware Size Response
""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-size-response` defines the Greybus firmware size
response payload.  The response supplies the size of the AP's firmware blob for
the module implementing the Protocol.

.. figtable::
    :nofig:
    :label: table-firmware-size-response
    :caption: Bootrom Protocol Firmware Size Response
    :spec: l l c c l

    ======  =====  ====  ======  =========================
    Offset  Field  Size  Value   Description
    ======  =====  ====  ======  =========================
    0       size   4     Number  Size of the blob in bytes
    ======  =====  ====  ======  =========================

..

Greybus Bootrom Get Firmware Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Bootrom get firmware operation allows the requester to retrieve a
stream of bytes at an offset within the firmware blob from the AP.  The AP
responds with the requested number of bytes from the connection's associated
firmware blob at the requested offset, or with an error status without payload
if no firmware blob has yet been associated with this connection or if the
requested stream size exceeds the firmware blob's size minus the requested
offset.

Greybus Bootrom Get Firmware Request
""""""""""""""""""""""""""""""""""""

Table :num:`table-bootrom-get-firmware-request` defines the Greybus Bootrom
get firmware request payload.  The request specifies an offset into the firmware
blob, and the size of the stream of bytes requested.  The stream size requested
must be less than or equal to the size given by the most recent firmware size
response (:ref:`firmware-size-response`) minus the offset; when it is not, the
AP shall signal an error in its response.  The module is responsible for
tracking its offset into the firmware blob as needed.

.. figtable::
    :nofig:
    :label: table-bootrom-get-firmware-request
    :caption: Bootrom Protocol Get Firmware Request
    :spec: l l c c l

    ======  ====== ====  ======  =================================
    Offset  Field  Size  Value   Description
    ======  ====== ====  ======  =================================
    0       offset 4     Number  Offset into the firmware blob
    4       size   4     Number  Size of the byte stream requested
    ======  ====== ====  ======  =================================

..

Greybus Bootrom Get Firmware Response
"""""""""""""""""""""""""""""""""""""

Table :num:`table-bootrom-get-firmware-response` defines the Greybus Bootrom
get firmware response payload.  The response includes the stream of bytes
requested by the module.  In the case that the AP cannot fulfill the request,
such as when the requested stream size was greater than the total size of the
firmware blob, it shall signal an error in the status byte of the response
header.

.. figtable::
    :nofig:
    :label: table-bootrom-get-firmware-response
    :caption: Bootrom Protocol Get Firmware Response
    :spec: l l c c l

    ======  =====  ====== ======  =================================
    Offset  Field  Size   Value   Description
    ======  =====  ====== ======  =================================
    4       data   *size* Data    Data from the firmware blob
    ======  =====  ====== ======  =================================

..

Greybus Bootrom Ready to Boot Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Bootrom ready to boot operation lets the requesting module notify
the AP that it has successfully loaded the connection's currently associated
firmware blob and is able to hand over control of the processor to that blob,
indicating the status of its firmware blob.  The AP shall then send a response
empty of payload, indicating via the header's status byte whether or not it
permits the module to continue booting.

The module shall send a ready to boot request only when it has successfully
loaded a firmware blob and can execute that firmware.

Greybus Bootrom Ready to Boot Request
"""""""""""""""""""""""""""""""""""""

Table :num:`table-bootrom-ready-to-boot-request` defines the Greybus Bootrom
ready to boot request payload.  The request gives the security status of its
firmware blob.

.. figtable::
    :nofig:
    :label: table-bootrom-ready-to-boot-request
    :caption: Bootrom Protocol Ready to Boot Request
    :spec: l l c c l

    ======  ======  ====  ======  ===========================
    Offset  Field   Size  Value   Description
    ======  ======  ====  ======  ===========================
    0       status  1     Number  :ref:`firmware-blob-status`
    ======  ======  ====  ======  ===========================

..

.. _firmware-blob-status:

Greybus Bootrom Ready to Boot Firmware Blob Status
""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-blob-status` defines the constants by which the
module can indicate the status of its firmware blob to the AP in a Greybus
Bootrom Ready to Boot Request.

.. figtable::
    :nofig:
    :label: table-firmware-blob-status
    :caption: Bootrom Ready to Boot Firmware Blob Statuses
    :spec: l l l

    ====================  ====================================  ============
    Firmware Blob Status  Brief Description                     Status Value
    ====================  ====================================  ============
    BOOT_STATUS_INVALID   Firmware blob could not be validated  0x00
    BOOT_STATUS_INSECURE  Firmware blob is valid but insecure   0x01
    BOOT_STATUS_SECURE    Firmware blob is valid and secure     0x02
    |_|                   (Reserved Range)                      0x03..0xFF
    ====================  ====================================  ============

..

Greybus Bootrom Ready to Boot Response
""""""""""""""""""""""""""""""""""""""

If the AP permits the module to boot in its current status, the Greybus Bootrom
Ready to Boot response message shall have no payload.  In the case that the AP
forbids the module from booting, it shall signal an error in the status byte of
the response message's header.
