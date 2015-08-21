.. _special_protocols:

Special Protocols
=================

This section defines three Protocols, each of which serves a special
purpose in a Greybus system.

The first is the Control Protocol.  Every Interface shall provide a
CPort that uses the Control Protocol. It is used by the AP Module to
notify Interfaces when connections are available for them to use.

The second is the SVC Protocol, which is used only between the SVC
and AP Module.  The SVC provides low-level control of the |unipro|
network.  The SVC performs almost all of its activities under
direction of the AP Module, and the SVC Protocol is used by the AP
Module to exert this control.  The SVC also uses this protocol to
notify the AP Module of events, such as the insertion or removal of
a Module.

The third is the Firmware Protocol, which is used between the AP Module and any
other module's bootloader to download firmware executables to the module.  When
a module's manifest includes a CPort using the Firmware Protocol, the AP can
connect to that CPort and download a firmware executable to the module.

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

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the Protocol used for
    communication over the connection.  The AP offers the
    version of the Protocol it supports.  The Interface replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the Protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

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
    Reserved                     0x02           0x82
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
Protocol on an Interface. The AP Module does not have a control
connection, but instead implements the SVC protocol using the
reserved Control CPort ID. At initial power-on, the SVC sets up a
|unipro| connection from one of its CPorts to the AP Module
Interface's SVC CPort.

The SVC has direct control over and responsibility for the Endo,
including detecting when modules are present, configuring the
|unipro| switch, powering module Interfaces, and attaching and
detaching modules.  The AP Module controls the Endo through
operations sent over the SVC connection.  And the SVC informs the AP
Module about Endo events (such as the presence of a new module, or
notification of changing power conditions).

Conceptually, the operations in the Greybus SVC Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the Protocol used for
    communication over the connection.  The SVC offers the
    version of the Protocol it supports.  The AP replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the Protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

.. c:function:: int svc_hello(u16 endo_id, u8 intf_id);

    This Operation is used at initial power-on, sent by the SVC to
    inform the AP of its environment. After version negotiation,
    it is the next operation initiated by the SVC sent at
    initialization. The descriptor describes details of the endo
    environment such as number, placement, and features of interface
    blocks, etc.

.. c:function:: int dme_peer_get(u8 intf_id, u16 attribute, u16 selector, u16 *result_code, u32 *value);

    This Operation is used by the AP to direct the SVC to perform a
    |unipro| DME peer get on its behalf. The SVC returns the value
    of the DME attribute requested.

.. c:function:: int dme_peer_set(u8 intf_id, u16 attribute, u16 selector, u32 value, u16 *result_code);

    This Operation is used by the AP to direct the SVC to perform a
    |unipro| DME peer set on its behalf.

.. c:function:: int intf_device_id(u8 intf_id, u8 device_id);

    This operation is used by the AP Module to request that the SVC
    associate a device ID with the given Interface.

.. c:function:: int intf_hotplug(u8 intf_id, u32 unipro_mfg_id, u32 unipro_prod_id, u32 ara_vend_id, u32 ara_prod_id);

    The SVC sends this to the AP Module to inform it that it has
    detected a module on the indicated Interface.  It supplies a
    block of data that describes the module that been attached.

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
    Protocol Version             0x07           0x87
    SVC Hello                    0x08           0x88
    DME peer get                 0x09           0x89
    DME peer set                 0x0a           0x8a
    (all other values reserved)  0x0b..0x7f     0x8b..0xff
    ===========================  =============  ==============

..

Greybus SVC Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Protocol version operation allows the Protocol
handling software on both ends of a connection to negotiate the version
of the SVC Protocol to use. It is sent by the SVC at initial
power-on.

Greybus SVC Protocol Version Request
""""""""""""""""""""""""""""""""""""

Table :num:`table-svc-version-request` defines the Greybus SVC
Protocol version request payload. The request supplies the greatest
major and minor version of the SVC Protocol supported by the SVC.

.. figtable::
    :nofig:
    :label: table-svc-version-request
    :caption: SVC Protocol Version Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Offered SVC Protocol major version
    1        version_minor   1       |gb-minor|      Offered SVC Protocol minor version
    =======  ==============  ======  ==========      ===========================

..

Greybus SVC Protocol Version Response
"""""""""""""""""""""""""""""""""""""

The Greybus SVC Protocol version response payload contains two
one-byte values, as defined in table
:num:`table-svc-protocol-version-response`. A Greybus SVC
controller adhering to the Protocol specified herein shall report
major version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-svc-protocol-version-response
    :caption: SVC Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      SVC Protocol major version
    1        version_minor   1       |gb-minor|      SVC Protocol minor version
    =======  ==============  ======  ==========      ===========================

..

Greybus SVC Hello Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC Hello Operation is sent by the SVC to the AP
at power-on to inform the AP of its environment.

Greybus SVC Hello Request
"""""""""""""""""""""""""

This Operation is used at initial power-on, sent by the SVC to
inform the AP of its environment. After version negotiation, it is
the next Operation sent by the SVC sent at initialization. The
descriptor describes details of the endo environment and location of
the AP interface.

.. figtable::
    :nofig:
    :label: table-svc-hello-request
    :caption: SVC Protocol SVC Hello Request
    :spec: l l c c l

    =======  ==============  ===========  ===============  ===========================
    Offset   Field           Size         Value            Description
    =======  ==============  ===========  ===============  ===========================
    0        endo_id         2            Endo ID          Endo ID
    2        intf_id         1            AP Interface ID  AP Interface ID
    =======  ==============  ===========  ===============  ===========================

..

Greybus SVC Hello Response
""""""""""""""""""""""""""

The Greybus SVC Hello response contains no payload.

Greybus DME Peer Get Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC DME Peer Get Operation is sent by the SVC to the AP
to direct the SVC to perform a |unipro| DME Peer Get on an Interface.

Greybus DME Peer Get Request
""""""""""""""""""""""""""""
This can be used by the AP to query specific attributes located in
the |unipro| stack of an Interface. The SVC returns the value of the
DME attribute requested.

.. figtable::
    :nofig:
    :label: table-dme-peer-get-request
    :caption: SVC Protocol DME Peer Get Request
    :spec: l l c c l

    =======  ==============  ===========  ===============  ===========================
    Offset   Field           Size         Value            Description
    =======  ==============  ===========  ===============  ===========================
    0        intf_id         1            Interface ID     Interface ID
    1        attr            2            DME Attribute    |unipro| DME Attribute
    3        selector        2            Selector index   |unipro| DME selector
    =======  ==============  ===========  ===============  ===========================

..

Greybus DME Peer Get Response
"""""""""""""""""""""""""""""

The Greybus DME Peer Get response contains the ConfigResultCode as
defined in the |unipro| specification, as well as the value of the
attribute, if applicable.

.. figtable::
    :nofig:
    :label: table-dme-peer-get-response
    :caption: SVC Protocol DME Peer Get Response
    :spec: l l c c l

    =======  ==============  ===========  ================  =========================================
    Offset   Field           Size         Value             Description
    =======  ==============  ===========  ================  =========================================
    0        result_code     2            ConfigResultCode  |unipro| DME Peer Get ConfigResultCode
    2        attr_value      4            Attribute value   |unipro| DME Peer Get DME Attribute value
    =======  ==============  ===========  ================  =========================================

..

Greybus DME Peer Set Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SVC DME Peer Set Operation is sent by the SVC to the AP
to direct the SVC to perform a |unipro| DME_PEER_SET on an Interface.

Greybus DME Peer Set Request
""""""""""""""""""""""""""""
This can be used by the AP to set specific attributes located in
the |unipro| stack of an Interface.

.. figtable::
    :nofig:
    :label: table-dme-peer-set-request
    :caption: SVC Protocol DME Peer Set Request
    :spec: l l c c l

    =======  ==============  ===========  ===============  ===================================
    Offset   Field           Size         Value            Description
    =======  ==============  ===========  ===============  ===================================
    0        intf_id         1            Interface ID     Interface ID
    1        attr            2            DME Attribute    |unipro| DME Attribute
    3        selector        2            Selector index   |unipro| DME selector
    5        value           4            Attribute value  |unipro| DME Attribute value to set
    =======  ==============  ===========  ===============  ===================================

..

Greybus DME Peer Set Response
"""""""""""""""""""""""""""""

The Greybus DME Peer Set response contains the ConfigResultCode as
defined in the |unipro| specification.

.. figtable::
    :nofig:
    :label: table-dme-peer-set-response
    :caption: SVC Protocol DME Peer Set Response
    :spec: l l c c l

    =======  ==============  ===========  ================  =========================================
    Offset   Field           Size         Value             Description
    =======  ==============  ===========  ================  =========================================
    0        result_code     2            ConfigResultCode  |unipro| DME Peer Set ConfigResultCode
    =======  ==============  ===========  ================  =========================================

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
Interface (such as the vendor and product ID).

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

    ======  ==============  ====  ============  =======================================
    Offset  Field           Size  Value         Description
    ======  ==============  ====  ============  =======================================
    0       intf_id         1     Interface ID  Interface that now has a module present
    1       unipro_mfg_id   4     |unipro| VID  |unipro| DDB Level 1 Manufacturer ID
    5       unipro_prod_id  4     |unipro| PID  |unipro| DDB Level 1 Product ID
    9       ara_vend_id     4     Ara VID       Ara Vendor ID
    13      ara_prod_id     4     Ara PID       Ara Product ID
    ======  ==============  ====  ============  =======================================

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

.. _firmware-protocol:

Firmware Protocol
-----------------

The Greybus Firmware Protocol is used by a module's bootloader to communicate
with the AP and download firmware executables via |unipro| when a module does
not have its own firmware pre-loaded.

The operations in the Greybus Firmware Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the Protocol used for
    communication over the connection.  The AP sends the request offering the
    version of the Protocol it supports.  The module responds with the version
    that shall be used--either the one offered if supported, or its own lower
    version.  Protocol handling code adhering to the Protocol specified here
    supports major version |gb-major|, minor version |gb-minor|.

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

Greybus Firmware Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Table :num:`table-firmware-operation-type` describes the Greybus firmware
operation types and their values.  A message type consists of an operation type
combined with a flag (0x80) indicating whether the operation is a request or a
response.

.. figtable::
    :nofig:
    :label: table-firmware-operation-type
    :caption: Firmware Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Firmware Operation Type      Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Firmware Size                0x02           0x82
    Get Firmware                 0x03           0x83
    Ready to Boot                0x04           0x84
    (all other values reserved)  0x05..0x7f     0x85..0xff
    ===========================  =============  ==============

..

Greybus Firmware Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus firmware Protocol version operation allows the Protocol handling
software on both ends of a connection to negotiate the version of the firmware
Protocol to use.

Greybus Firmware Protocol Version Request
"""""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-version-request` defines the Greybus firmware version
request payload.  The request supplies the greatest major and minor version of
firmware Protocol supported by the sender (the AP).

.. figtable::
    :nofig:
    :label: table-firmware-version-request
    :caption: Firmware Protocol Version Request
    :spec: l l c c l

    ======  =====   ====    ==========  =======================================
    Offset  Field   Size    Value       Description
    ======  =====   ====    ==========  =======================================
    0       major   1       |gb-major|  Offered firmware Protocol major version
    1       minor   1       |gb-minor|  Offered firmware Protocol minor version
    ======  =====   ====    ==========  =======================================

..

Greybus Firmware Protocol Version Response
""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-version-response` defines the Greybus firmware
version response payload.  A Greybus module implementing the Protocol described
herein shall report major version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-firmware-version-response
    :caption: Firmware Protocol Version Response
    :spec: l l c c l

    ======  =====   ====    ==========  ===============================
    Offset  Field   Size    Value       Description
    ======  =====   ====    ==========  ===============================
    0       major   1       |gb-major|  Firmware Protocol major version
    1       minor   1       |gb-minor|  Firmware Protocol minor version
    ======  =====   ====    ==========  ===============================

..

Greybus Firmware Firmware Size Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Firmware firmware size operation allows the requestor to submit a
boot stage to the AP, so that the AP can associate a firmware blob with that
boot stage and respond with its size.  The AP keeps the firmware blob associated
with the boot stage until it receives another Firmware Size Request on the same
connection, but is not required to send identical firmware blobs in response to
different requests with identical boot stages, even to the same module.

.. _firmware-size-request:

Greybus Firmware Firmware Size Request
""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-size-request` defines the Greybus firmware size
request payload.  The request supplies the boot stage of the module implementing
the Protocol.

.. figtable::
    :nofig:
    :label: table-firmware-size-request
    :caption: Firmware Protocol Firmware Size Request
    :spec: l l c c l

    ======  =========  ====  ======  ===============================================
    Offset  Field      Size  Value   Description
    ======  =========  ====  ======  ===============================================
    0       stage      1     Number  :ref:`firmware-boot-stages`
    ======  =========  ====  ======  ===============================================

..

.. _firmware-boot-stages:

Greybus Firmware Boot Stages
""""""""""""""""""""""""""""

Table :num:`table-firmware-boot-stages` defines the boot stages whose firmware
can be requested from the AP via the Protocol.

.. figtable::
    :nofig:
    :label: table-firmware-boot-stages
    :caption: Firmware Protocol Boot Stages
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

Greybus Firmware Firmware Size Response
"""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-size-response` defines the Greybus firmware size
response payload.  The response supplies the size of the AP's firmware blob for
the module implementing the Protocol.

.. figtable::
    :nofig:
    :label: table-firmware-size-response
    :caption: Firmware Protocol Firmware Size Response
    :spec: l l c c l

    ======  =====  ====  ======  =========================
    Offset  Field  Size  Value   Description
    ======  =====  ====  ======  =========================
    0       size   4     Number  Size of the blob in bytes
    ======  =====  ====  ======  =========================

..

Greybus Firmware Get Firmware Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Firmware get firmware operation allows the requestor to retrieve a
stream of bytes at an offset within the firmware blob from the AP.  The AP
responds with the requested number of bytes from the connection's associated
firmware blob at the requested offset, or with an error status without payload
if no firmware blob has yet been associated with this connection or if the
requested stream size exceeds the firmware blob's size minus the requested
offset.

Greybus Firmware Get Firmware Request
"""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-get-firmware-request` defines the Greybus Firmware
get firmware request payload.  The request specifies an offset into the firmware
blob, and the size of the stream of bytes requested.  The stream size requested
must be less than or equal to the size given by the most recent firmware size
response (:ref:`firmware-size-response`) minus the offset; when it is not, the
AP shall signal an error in its response.  The module is responsible for
tracking its offset into the firmware blob as needed.

.. figtable::
    :nofig:
    :label: table-firmware-get-firmware-request
    :caption: Firmware Protocol Get Firmware Request
    :spec: l l c c l

    ======  ====== ====  ======  =================================
    Offset  Field  Size  Value   Description
    ======  ====== ====  ======  =================================
    0       offset 4     Number  Offset into the firmware blob
    4       size   4     Number  Size of the byte stream requested
    ======  ====== ====  ======  =================================

..

Greybus Firmware Get Firmware Response
""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-get-firmware-response` defines the Greybus Firmware
get firmware response payload.  The response includes the stream of bytes
requested by the module.  In the case that the AP cannot fulfill the request,
such as when the requested stream size was greater than the total size of the
firmware blob, it shall signal an error in the status byte of the response
header.

.. figtable::
    :nofig:
    :label: table-firmware-get-firmware-response
    :caption: Firmware Protocol Get Firmware Response
    :spec: l l c c l

    ======  =====  ====== ======  =================================
    Offset  Field  Size   Value   Description
    ======  =====  ====== ======  =================================
    4       data   *size* Data    Data from the firmware blob
    ======  =====  ====== ======  =================================

..

Greybus Firmware Ready to Boot Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Firmware ready to boot operation lets the requesting module notify
the AP that it has successfully loaded the connection's currently-associated
firmware blob and is able to hand over control of the processor to that blob,
indicating the status of its firmware blob.  The AP shall then send a response
empty of payload, indicating via the header's status byte whether or not it
permits the module to continue booting.

The module shall send a ready to boot request only when it has successfully
loaded a firmware blob and can execute that firmware.

Greybus Firmware Ready to Boot Request
""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-ready-to-boot-request` defines the Greybus Firmware
ready to boot request payload.  The request gives the boot stage the module has
achieved and the security status of its firmware blob.

.. figtable::
    :nofig:
    :label: table-firmware-ready-to-boot-request
    :caption: Firmware Protocol Ready to Boot Request
    :spec: l l c c l

    ======  ======  ====  ======  ===========================
    Offset  Field   Size  Value   Description
    ======  ======  ====  ======  ===========================
    0       stage   1     Number  Boot stage
    1       status  1     Number  :ref:`firmware-blob-status`
    ======  ======  ====  ======  ===========================

..

.. _firmware-blob-status:

Greybus Firmware Ready to Boot Firmware Blob Status
"""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-blob-status` defines the constants by which the
module can indicate the status of its firmware blob to the AP in a Greybus
Firmware Ready to Boot Request.

.. figtable::
    :nofig:
    :label: table-firmware-blob-status
    :caption: Firmware Ready to Boot Firmware Blob Statuses
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

Greybus Firmware Ready to Boot Response
"""""""""""""""""""""""""""""""""""""""

If the AP permits the module to boot in its current status, the Greybus Firmware
Ready to Boot response message shall have no payload.  In the case that the AP
forbids the module from booting, it shall signal an error in the status byte of
the response message's header.
