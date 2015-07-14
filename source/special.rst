.. _special_protocols:

Special Protocols
=================

This section defines two Protocols, each of which serves a special
purpose in a Greybus system.

The first is the Control Protocol.  Every Interface shall provide a
CPort that uses the Control Protocol.  It's used by the SVC to do
initial probes of Interfaces at system power on.  It is also used by
the AP Module to notify Interfaces when connections are available
for them to use.

The second is the SVC Protocol, which is used only between the SVC
and AP Module.  The SVC provides low-level control of the |unipro|
network.  The SVC performs almost all of its activities under
direction of the AP Module, and the SVC Protocol is used by the AP
Module to exert this control.  The SVC also uses this protocol to
notify the AP Module of events, such as the insertion or removal of
a Module.

.. _control-protocol:

Control Protocol
----------------

All Interfaces are required to define a CPort that uses the Control
Protocol, and shall be prepared to receive Operation requests on that
CPort at any time. The CPort that uses the Control Protocol must have an
id of '2'. CPort id '2' is a reserved CPort address for the Control
Protocol. Similarly the bundle descriptor associated with the Control
CPort must have an id of '0'. Bundle id '0' is a reserved id for the
Control Protocol bundle descriptor.

A Greybus connection is established whenever a control connection is used,
but the Interface is never notified that such a connection exists. Only
the SVC and AP Module are able to send control requests.  Any other
Interface shall only send control response messages, and such messages
shall only be sent in reply to a request received its control CPort.

Conceptually, the Operations in the Greybus Control Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the Protocol used for
    communication over the connection.  The sender offers the
    version of the Protocol it supports.  The receiver replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the Protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

.. c:function:: int probe_ap(u16 endo_id, u8 intf_id, u16 *auth_size, u8 *auth_data);

    This Operation is used at initial power-on, sent by the SVC to
    discover which Module contains the AP.  The Endo ID supplied by
    the SVC defines the type of Endo used by the Greybus system,
    including the size of the Endo and the positions and sizes of
    Modules that it holds.  The Interface ID supplied by the SVC
    indicates which Interface Block on the Endo is being probed.
    Together these two values define the location of the Module
    containing the Interface.  Interface ID 0 represents the SVC
    itself; other values are defined in the *Project Ara Module
    Developers Kit*.  The response to this Operation contains a
    block of data used by a Module to identify itself as
    authentically containing an AP.  Non-AP Modules respond with no
    authentication data (*auth_size* is 0).

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

.. c:function:: int disconnected(u16 cport_id);

    This Operation is used to notify an Interface that a previously
    established Greybus connection may no longer be used.  This
    operation is never used for control CPort.

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
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Probe AP                     0x02           0x82
    Get Manifest Size            0x03           0x83
    Get Manifest                 0x04           0x84
    Connected                    0x05           0x85
    Disconnected                 0x06           0x86
    (all other values reserved)  0x07..0x7f     0x87..0xff
    ===========================  =============  ==============

..

Greybus Control Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Control Protocol version operation allows the Protocol
handling software on both ends of a connection to negotiate the version
of the Control Protocol to use.

Greybus Control Protocol Version Request
""""""""""""""""""""""""""""""""""""""""

Table :num:`table-control-version-request` defines the Greybus Control
version request payload. The request supplies the greatest major and
minor version of the Control Protocol supported by the sender.

.. figtable::
    :nofig:
    :label: table-control-version-request
    :caption: Control Protocol Version Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Offered Control Protocol major version
    1        version_minor   1       |gb-minor|      Offered Control Protocol minor version
    =======  ==============  ======  ==========      ===========================

..

Greybus Control Protocol Version Response
"""""""""""""""""""""""""""""""""""""""""

The Greybus Control Protocol version response payload contains two
one-byte values, as defined in table
:num:`table-control-protocol-version-response`.
A Greybus Control controller adhering to the Protocol specified herein
shall report major version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-control-protocol-version-response
    :caption: Control Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Control Protocol major version
    1        version_minor   1       |gb-minor|      Control Protocol minor version
    =======  ==============  ======  ==========      ===========================

..

Greybus Control Probe AP Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control probe AP Operation is sent by the SVC to all
Interfaces at power-on to determine which Module contains the AP.
Once the AP Module has been found, the SVC begins a process that
transfers full control of the |unipro| network to the AP Module.

Greybus Control Probe AP Request
""""""""""""""""""""""""""""""""

The Greybus control probe AP request is sent only by the SVC.  It
supplies the Endo ID, which defines the size of the Endo and
the positions available to hold Modules.  It also informs the Module
via the Interface ID the Module location of the Interface that
receives the request.

.. figtable::
    :nofig:
    :label: table-control-probe-ap-request
    :caption: Control Protocol Probe AP Request
    :spec: l l c c l

    =======  ==============  ======  ============    ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ===========================
    0        endo_id         2       Endo ID         Defines Endo geometry
    2        intf_id         1       Interface ID    Position of receiving Interface on Endo
    =======  ==============  ======  ============    ===========================

..

Greybus Control Probe AP Response
"""""""""""""""""""""""""""""""""

The Greybus control probe AP response contains a block of
authentication data.  The AP Module responds with data that
identifies it as containing the AP.  All other Modules respond
with no data (*auth_size* is 0).

.. figtable::
    :nofig:
    :label: table-control-probe-ap-response
    :caption: Control Protocol Probe AP Response
    :spec: l l c c l

    =======  ==============  ===========  ==========      ===========================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ===========================
    0        auth_size       2            Number          Size of authentication data that follows
    2        auth_data       *auth_size*  Data            Authentication data
    =======  ==============  ===========  ==========      ===========================

..

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

    =======  ==============  ======  ============    ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ===========================
    0        cport_id        2       CPort ID        CPort that is now connected
    =======  ==============  ======  ============    ===========================

..

Greybus Control Connected Response
""""""""""""""""""""""""""""""""""

The Greybus control connected response message contains no payload.

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

    =======  ==============  ======  ============    ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ===========================
    0        cport_id        2       CPort ID        CPort that is now disconnected
    =======  ==============  ======  ============    ===========================

..

Greybus Control Disconnected Response
"""""""""""""""""""""""""""""""""""""

The Greybus control disconnected response message contains no payload.

.. _svc-protocol:

SVC Protocol
------------

The AP Module is required to provide a CPort that uses the SVC
Protocol on an Interface.  During system initialization the SVC uses
Probe AP Operations to find an Interface on the AP Module.  Once that
Interface is found, the SVC sets up a |unipro| connection from
one of its CPorts to the AP Module Interface's SVC CPort.  It sends
a Control Protocol connected operation to the Interface, notifying
it that the SVC CPort is connected and ready to use.

The SVC has direct control over and responsibility for the Endo,
including detecting when modules are present, configuring the
|unipro| switch, powering module Interfaces, and attaching and
detaching modules.  The AP Module controls the Endo through
operations sent over the SVC connection.  And the SVC informs the AP
Module about Endo events (such as the presence of a new module, or
notification of changing power conditions).

Conceptually, the operations in the Greybus SVC Protocol are:

.. c:function:: int intf_device_id(u8 intf_id, u8 device_id);

    This operation is used by the AP Module to request that the SVC
    associate a device ID with the given Interface.

.. c:function:: int intf_hotplug(u8 intf_id, u16 size, u8 *data);

.. XXX We may need to adjust based on whether detect is associated
.. XXX with a module (as opposed to an Interface).

    The SVC sends this to the AP Module to inform it that it has
    detected a module on the indicated Interface.  It supplies a
    block of data that describes the module that been attached.

.. c:function:: int intf_hotunplug(u8 intf_id);

    The SVC sends this to the AP Module to tell it that a module is
    no longer present on an Interface.

.. c:function:: int intf_reset(u8 intf_id);

    The SVC sends this to inform the AP Module that an active
    Interface needs to be reset.  This might happen when the SVC has
    detected
    an error on the link, for example.

.. XXX This is nebulous at this point; my intention is to handle the
.. XXX case where a UniPro "link down" indicates that a link *was*
.. XXX down at some point--since we have no way to discover this
.. XXX immediately.

.. c:function:: int connection_create(u8 intf1_id, u16 cport1_id, u8 intf2_id, u16 cport2_id);

    The AP Module uses this operation to request the SVC set up a
    |unipro| connection between CPorts on two Interfaces.

.. c:function:: int connection_destroy(u8 intf1_id, u16 cport1_id, u8 intf2_id, u16 cport2_id);

    The AP Module uses this operation to request the SVC tear down a
    previously created connection.

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

    ===========================  =============  ==============
    SVC Operation Type           Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Interface device ID          0x01           0x81
    Interface hotplug            0x02           0x82
    Interface hot unplug         0x03           0x83
    Interface reset              0x04           0x84
    Connection create            0x05           0x85
    Connection destroy           0x06           0x86
    (all other values reserved)  0x07..0x7f     0x87..0xff
    ===========================  =============  ==============

..

Greybus SVC Interface Device ID Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Interface Device ID Operation is used by the AP
Module to request the SVC associate a device id with an Interface.
The device id is used by the |unipro| switch to determine how
packets should be routed through the network.  The AP Module is
responsible for managing the mapping between Interfaces and UniPro
device ids.  Note that the SVC always uses device ID 0, and the AP
Module always uses device ID 1.

Greybus SVC Interface Device ID Request
"""""""""""""""""""""""""""""""""""""""

The Greybus SVC Interface device ID request is sent only by the AP
Module to the SVC.  It supplies the device ID that the SVC should
associate with the indicated Interface.  The AP Module can remove
the association of an Interface with a device ID by assigning device
ID value 0.  It is an error to assign a (non-zero) device ID to an
Interface that already has one, or to clear the device ID of an
Interface that has no device ID assigned.

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
    0        intf_id         1       Interface ID    Interface ID whose device ID is being assigned
    1        device_id       1       Device ID       |unipro| device ID for Interface
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
established.  The size and data values describe a structured block
of additional information known by the SVC about the discovered
Interface (such as the vendor and product ID).  The format of
this data is TBD.

.. XXX SVC Protocol connections must have E2EFC enabled and CSD and
.. XXX CSV disabled to ensure these messages are delivered reliably

Greybus SVC Interface Hotplug Request
"""""""""""""""""""""""""""""""""""""

The Greybus SVC hotplug request is sent only by the SVC to the AP
Module.  The Interface ID informs the AP Module which Interface now
has a module present, and a block of data supplies information (such
as the vendor and model numbers) the SVC knows about the Interface.
Exactly one hotplug event shall be sent by the SVC for a module when
it has been inserted (or if it was found to be present at initial
power-on).

.. figtable::
    :nofig:
    :label: table-svc-hotplug-request
    :caption: SVC Protocol Hotplug Request
    :spec: l l c c l

    =======  ==============  ======  ============    ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ===========================
    0        intf_id         1       Interface ID    Interface that now has a module present
    1        size            1       Number          Size of descriptive data
    2        data            *size*  Data            Descriptive data
    =======  ==============  ======  ============    ===========================

..

Greybus SVC Interface Hotplug Response
""""""""""""""""""""""""""""""""""""""

The Greybus SVC hotplug response message contains no payload.

Greybus SVC Interface Hot Unplug Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The SVC sends this to the AP Module to tell it that an Interface
that was previously the subject of an Interface Hotplug Operation is
no longer present.  The SVC sends exactly Interface one hot unplug
event to the AP Module when this occurs.

.. XXX CSD and CSV must not be enabled for SVC Protocol connections,
.. XXX to ensure these messages are delivered reliably.

Greybus SVC Interface Hot Unplug Request
""""""""""""""""""""""""""""""""""""""""

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
    0        intf_id         1       Interface ID    Interface that no longer has an attached module
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
    0        intf_id         1       Interface ID    Interface to reset
    =======  ==============  ======  ============    ===========================

..

Greybus SVC Interface Reset Response
""""""""""""""""""""""""""""""""""""

The Greybus SVC Interface Reset response message contains no payload.

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

The Greybus SVC connection create request is sent only by the AP
Module to the SVC.  The first Interface ID and first CPort ID define
one end of the connection to be established, and the second
Interface ID and CPort ID define the other end.

.. figtable::
    :nofig:
    :label: table-svc-connection-create-request
    :caption: SVC Protocol Connection Create Request
    :spec: l l c c l

    =======  ==============  ======  ==================  ===========================
    Offset   Field           Size    Value               Description
    =======  ==============  ======  ==================  ===========================
    0        intf1_id        1       Interface ID        First Interface
    1        cport1_id       2       CPort ID            CPort on first Interface
    3        intf2_id        1       Interface ID        Second Interface
    4        cport2_id       2       CPort ID            CPort on second Interface
    =======  ==============  ======  ==================  ===========================

..

Greybus SVC Connection Create Response
""""""""""""""""""""""""""""""""""""""

The Greybus SVC connection create response message contains no payload.

Greybus SVC Connection Destroy Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP Module sends this to the SVC to request that a connection
that was previously set up by a Connection Create Operation be
torn down.  The AP Module shall have sent Disconnected Control
Operations to the two Interfaces prior to this call.  It is an error
to attempt to destroy a connection more than once.

Greybus SVC Connection Destroy Request
""""""""""""""""""""""""""""""""""""""

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
    0        intf1_id        1       Interface ID        First Interface
    1        cport1_id       2       CPort ID            CPort on first Interface
    3        intf2_id        1       Interface ID        Second Interface
    4        cport2_id       2       CPort ID            CPort on second Interface
    =======  ==============  ======  ==================  ===========================

..

Greybus SVC Connection Destroy Response
"""""""""""""""""""""""""""""""""""""""

The Greybus SVC connection destroy response message contains no payload.
