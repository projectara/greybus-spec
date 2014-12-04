.. include:: defines.rst

.. _control-protocol:

Control Protocol
================

This section defines the operations used on an interface using the
Greybus Control protocol. This protocol is different from all other
protocols, because it operates over a pseudo connection rather than a
“real” connection. Every interface must have a control CPort running
the control protocol, and any module interface can send control
protocol operation requests from its own control CPort to the control
CPort on another interface.  In order to allow this multiplexing of
the control CPort, every control protocol request begins with a
one-byte source device id so the destination of the request knows
where the response to a request should be sent.

The control protocol is used to inform an interface of the device it
it has been assigned, and thereafter it is used to set up and tear
down connections between CPorts.

Conceptually, the operations in the Greybus control protocol are:

::

    int identify(u8 svc_device_id, u16 endo_id, u8 module_id,
                 u8 interface_id, u8 device_id, u8 *extra_device_ids,
                 u16 *id_data_size, u8 *id_data);

..

    The SVC initiates this operation after it has first determined
    a |unipro| link is up. The request informs the interface of its
    whereabouts, including the type of endo it resides in, where
    the module resides on that endo, which interface it is on that
    module, as well as the |unipro| device id assigned to the
    interface. The destination supplies in its response the
    number [#bv]_ of additional device ids it requires [#bw]_ to
    represent the range of CPort ids it supports. The destination
    also provides additional identifying information in its
    response. All versions of the control protocol support the
    identify operation, so this operation can be sent prior to
    performing a handshake between interfaces.

::

    int handshake(u8 src_device_id, u8 src_major, u8 src_minor,
                  u8 *major, u8 *minor);

..

    Connections between interfaces are set up using the control
    protocol. Once an interface has been identified by the SVC, it can
    initiate a handshake operation with the SVC interface in order to
    have both sides agree on the version of the control connection
    they will use. The source sends the highest version of the control
    protocol it supports. The destination responds with its own
    version, or if that is higher than what was sent it responds with
    (and thereafter uses) the source interface’s version. The SVC uses
    the version found in the response. If each of two interfaces
    simultaneously initiates a handshake with the other, the one with
    the lower device id will proceed; the interface with the higher
    device id will fail. Once a handshake has succeeded, either
    interface can send operations to the other.

::

    int register_ap(u8 src_device_id);

..

    This operation is sent by the AP (on one of its interfaces) to the
    SVC, in order to tell the SVC where it should send subsequent event
    notifications. The device id serves both to indicate where the
    response should go and to tell the SVC which interface should be
    sent (e.g.) hotplug and link status change indications.

::

    int register_battery(u8 src_device_id);

..

    This operation is sent by a module to the SVC to tell the SVC this
    interface is associated with a battery. The SVC can then use battery
    protocol operations in order to further inquire about the battery’s
    status. The device id indicates where the response should go and and
    tells the SVC the interface through which a battery connection can
    be established.

::

    int connect(u8 src_device_id, u16 src_cport_id, u16 dst_cport_id,
                u8 src_major, u8 src_minor, u8 *major, u8 *minor);

..

    This operation is used to establish a connection between two
    interfaces. It is most often sent by the AP to set up a connection
    with another interface, but this can also be initiated between two
    peer interfaces using a separate (peer_connect) operation initiated by
    the AP.  The protocol used for the connection is the one associated
    with the destination CPort, and the version of the protocol used is
    agreed to as a result of the message exchange. As with the handshake
    operation, the sender supplies the highest version of the protocol it
    supports.  The receiver supplies in its response the highest version
    it supports, or if that exceeds what the sender supports it supplies
    the sender’s version. The version in the response is the version that
    will be used by both sides thereafter.

::

    int disconnect(u8 src_device_id, u16 dst_cport_id);

..

    This operation is used to tear down a previously-established
    connection between two interfaces. The CPort id on the destination
    is sufficient to identify the connection to be torn down. Either
    end of a connection can initiate the operation.

::

    int connect_peer(u8 src_device_id, u16 dst_cport_id,
                     u8 peer_device_id, u16 peer_cport_id);

..

    This operation is used by the AP to request the destination
    interface establish a connection with an interface in another peer
    module. The destination interface responds to this request by
    initiating a connection request between the indicated destination
    CPort [#bx]_ [#by]_ and the one on the indicated peer interface.

::

    int disconnect_peer(u8 src_device_id, u16 dst_cport_id);

..

    This operation is used to tear down a previously-established
    connection [#bz]_ [#ca]_ between a CPort on the destination interface and a
    CPort on one of its peer interfaces. The CPort id on the
    destination [#cb]_ [#cc]_ [#cd]_ is sufficient to identify the connection
    to be torn down. The destination will complete a disconnect of its
    peer connection before responding to the disconnect_peer request.

.. note::

   The following additional operations are also defined to be part of
   the control protocol.  They are only exchanged between the SVC and
   AP, and may be segregated into a separate “SVC protocol” in the
   future. As with all control protocol operations, the first value is
   the |unipro| device id of the source of the request.

::

    int hotplug(u8 svc_device_id, u8 module_id, u16 id_data_size,
                u8 id_data[]);

..

    This operation is sent by the SVC to the AP to inform it that a
    module has been inserted and is now present in the endo. The module
    id indicates the subject of the request. The hotplug notification
    provides identifying data that the SVC acquired from the module in
    its response to the SVC identify request.

::

    int hotunplug(u8 svc_device_id, u8 module_id);

..

    This operation is sent by the SVC to the AP to inform it that a
    module that had previously been subject of a hotplug operation has
    been removed from the endo.

::

    int link_up(u8 svc_device_id, u8 module_id, u8 interface_id,
                u8 device_id);

..

   This operation is sent by the SVC to the AP to inform it that an
   interface on a module has indicated its link is functioning. The
   module will have previously been the subject of a hotplug
   operation. A module can have more than one interface; the interface
   id (whose value is normally 0) is used to distinguish among them if
   there is more than one. The device id tells the AP what |unipro|
   device id is assigned to that interface.

::

    int link_down(u8 svc_device_id, u8 device_id);

..

    This operation is sent by the SVC to the AP to report that an
    interface that was previously reported to be up is no longer
    functional.  The device id is sufficient to identify the link that
    has gone down.

::

    int set_route(u8 ap_device_id, u8 from_device_id, u8 to_device_id);

..

    This operation is sent by the AP to the SVC to request that a
    bidirectional route be set up in the |unipro| switching network that
    allows traffic to flow between the two indicated device
    ids. Initially routes are in a disabled state; traffic flow will
    only be allowed when the route has been enabled. **Note: in ES1,
    routing is based only on destination address, and it is not
    possible to disable a route [#ce]_ [#cf]_.**

::

    int enable_route(u8 ap_device_id, u8 from_device_id, u8 to_device_id);

..

    This operation is sent by the AP to the SVC to request that a
    route defined by an earlier set route call should be enabled,
    allowing traffic to flow.

::

    int disable_route(u8 ap_device_id, u8 from_device_id, u8 to_device_id);

..

    This operation is sent by the AP to the SVC to request that a
    route defined by an earlier set route call should be disabled,
    preventing any further traffic flow between the indicated
    interfaces.

Greybus Control Message Types
-----------------------------

This table describes the Greybus control operation types and their
values. A message type consists of an operation type combined with a
flag (0x80) indicating whether the operation is a request or a
response.

.. list-table::
   :header-rows: 1

   * - Descriptor Type
     - Request Value
     - Response Value
   * - Invalid
     - 0x00
     - 0x80
   * - Identify
     - 0x01
     - 0x81
   * - Handshake
     - 0x02
     - 0x82
   * - Register AP
     - 0x03
     - 0x83
   * - Register battery
     - 0x04
     - 0x84
   * - Connect
     - 0x05
     - 0x85
   * - Disconnect
     - 0x06
     - 0x87
   * - Connect peer
     - 0x07
     - 0x87
   * - Disconnect peer
     - 0x08
     - 0x88
   * - (reserved)
     - 0x09..0x0f
     - 0x89..0x8f
   * - Hotplug
     - 0x10
     - 0x90
   * - Hot unplug
     - 0x11
     - 0x91
   * - Link up
     - 0x12
     - 0x92
   * - Link down
     - 0x13
     - 0x93
   * - Set route
     - 0x14
     - 0x94
   * - Enable route
     - 0x15
     - 0x95
   * - Disable route
     - 0x16
     - 0x96
   * - (All other values reserved)
     - 0x09..0x7f
     - 0x89..0xff

Greybus Control Identify Operation
----------------------------------

The Greybus control protocol identify operation is sent by the SVC to
supply an interface with information about its physical location, as
well the |unipro| device id it has been assigned. The physical location
is partially defined by the unique Endo type that contains the
system. The request indicates where within the Endo the module
resides, and which of a module’s interfaces is the destination of the
request. Finally, the request tells the interface the |unipro| device id
that it has been assigned.

Normally an interface (with a single |unipro| device id) supports up to
32 CPorts.  It is possible to support more than that by allotting a
contiguous range of more than one device id to a single interface.
Two device ids can support 64 CPorts, three can support 96, and so
on. The response to an identify request allows an interface to
indicate how many additional device ids it requires to support its
CPorts.  The SVC can then account for this as it allocates additional
device ids.

The identify response finally allows an interface to supply an
additional block of identifying information of an arbitrary size (up
to 64KB). This information will be supplied to the AP with a hotplug
event the SVC sends associated with the interface.

Greybus Control Identify Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Like all control protocol requests, the Greybus control identify
request begins with a one-byte source device id field. In this case,
only the SVC sends this request, and the field name reflects
that. This request also contains the endo, module, and interface ids
that represent the physical location of the destination interface.  It
finally contains the device id that has been assigned to the
destination interface.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - SVC device id
     - 1
     -
     - Device id for response to SVC
   * - 1
     - Endo id
     - 2
     -
     - Unique id for the Endo configuration
   * - 3
     - Module id
     - 1
     -
     - Location of the module within the Endo
   * - 4
     - Interface id
     - 1
     -
     - Module-relative interface number
   * - 5
     - Device id
     - 1
     -
     - |unipro| device id assigned to destination

Greybus Control Identify Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control identify response begins with a status byte.  If
the value of the status byte is non-zero, all other bytes in the
response shall be ignored.  Following the status byte is a one-byte
value indicating how many additional device ids the interface requires
to account for its range of CPort ids (normally this is 0). Finally,
the response contains additional data to identify the interface,
beginning with a two-byte size field.  The identity data is padded if
necessary [#cg]_to ensure the response payload size is a multiple of 4
bytes.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     -
     - Success, or reason for failure
   * - 1
     - Extra device ids
     - 1
     -
     - Number of additional device ids required
   * - 2
     - Identity data size
     - 2 [#ch]_
     - N
     - Number of bytes of identity data
   * - 4
     - Identity data [#ci]_ [#cj]_ [#ck]_
     - N
     -
     - Identity data from the interface (padded)

Greybus Control Handshake Operation
-----------------------------------

Once an interface has been identified it can arrange to connect with
other interfaces. Connections are established using the Greybus
control protocol, and the handshake operation is used to agree on a
version of that protocol to use between interfaces. No connections may
be established until a handshake between the involved interfaces has
been completed. If handshake operations between two interfaces are
initiated by interfaces at the same time, the one initiated by the
interface with the higher assigned device id will fail.

Greybus Control Handshake Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The first byte of a handshake request is the device id to which the
response should be sent. The other two bytes are the highest version
of the control protocol the source interface supports.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Source device id
     - 1
     -
     - Device id of source for response
   * - 1
     - Source major version
     - 1
     -
     - Source control protocol major version
   * - 2
     - Source minor version
     - 1
     -
     - Source control protocol minor version

Greybus Control Handshake Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control handshake response begins with a status byte.  If
the value of the status byte is non-zero, all other bytes in the
response shall be ignored.  The major and minor version in the
response message are the highest control protocol version that are
mutually usable by the source and destination interfaces.  It will be
the same as what was in the handshake request, or something lower if
the destination interface cannot support that version. Both ends of
the connection shall use the version of the control protocol indicated
in the response.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     -
     - Success, or reason for failure
   * - 1
     - Major version
     - 1
     -
     - Agreed-to control protocol major version
   * - 2
     - Minor version
     - 1
     -
     - Agreed-to control protocol minor version

Greybus Control Register AP Operation
-------------------------------------

This operation is used by an AP to register itself with the SVC as the
single legitimate AP. The SVC uses this to determine where to send
event notifications (such as hotplug events). More generally, this can
be used to control whether certain requests (such as switch
configuration) are allowed.  This request includes a block of data
intended to ensure only an authenticated AP can successfully complete
this operation. Details about the content of this data is not yet
specified [#cl]_.

Greybus Control Register AP Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Like all control protocol requests, this request begins with a byte
indicating where the response should be directed.  This is followed by
a two-byte size field, which defines how many bytes of authentication
data follow.  This is allowed to have value 0.  The authentication
data itself is of arbitrary length, but this field is implicitly
padded with zero bytes sufficient to make the size of the payload a
multiple of four bytes.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Source device id
     - 1
     -
     - Device id of source for response
   * - 1
     - Authentication data size
     - 2
     - N
     - Number of bytes of authentication data
   * - 3
     - Authentication data
     - N
     -
     - Authentication data (padded)

Greybus Control Register AP Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The register AP response contains only the status byte.  The SVC uses
the authentication data in the request to determine whether to accept
the AP as legitimate; it responds with an error if not.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     -
     - Success, or reason for failure

Greybus Control Register Battery Operation
------------------------------------------

This operation is used by a battery module to register itself with the
SVC as a legitimate battery. More than one battery can be
registered. The SVC uses this to know which modules can supply power.
This request includes a block of data intended to ensure only an
authenticated battery can successfully complete this
operation. Details about the content of this data is not yet specified
[#cm]_ [#cn]_ [#co]_.

Greybus Control Register Battery Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Source device id
     - 1
     -
     - Device id of source for response
   * - 1
     - Authentication data size
     - 2
     - N
     - Number of bytes of authentication data
   * - 3
     - Authentication data
     - N
     -
     - Authentication data (padded)

Greybus Control Register Battery Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The register battery response contains only the status byte.  The SVC
uses the authentication data in the request to determine whether to
accept the battery as legitimate; it responds with an error if not.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     - .
     - Success, or reason for failure

Greybus Control Connect Operation
---------------------------------

The Greybus control connect operation is used to establish a
connection between a CPort associated with one interface with a CPort
associated with another interface [#cp]_ [#cq]_. The protocol used
over the connection is the one advertised in the module manifest as
being associated with the destination CPort. The connect operation
allows the version of that protocol to be used over the connection to
be determined.  Operations defined for the protocol can only be
performed on the connection when a connection has been established.  A
connection is defined by a CPort and device id for one interface and a
CPort and device id for another interface.

Greybus Control Connect Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The connect request begins with the source device id.  This is
required for control operations, but it also is used in this case to
identify to the destination the device id used for the “other end” of
the connection. The CPort ids for both ends of the connection are
supplied in the request as well. The source supplies the major and
minor version number of the highest version of the protocol it
supports.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Source device id [#cr]_ [#cs]_
     - 1
     -
     - Device id of source
   * - 1
     - Source CPort id
     - 2
     -
     - CPort id to connect with
   * - 3
     - Destination CPort Id
     - 2
     -
     - CPort id to connect to
   * - 5
     - Source major version
     - 1
     -
     - Source protocol major version
   * - 6
     - Source minor version
     - 1
     -
     - Source protocol minor version

Greybus Control Connect Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The connect response contains the status byte, and if it is non-zero
the remainder of the response shall be ignored. The major and minor
version contained in the response is the same as those supplied in the
request, or the highest version supported by the destination if it is
not able to support the source’s version.  Both ends of the connection
shall use the version of the protocol in the response once it has been
received.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     -
     - Success, or reason for failure
   * - 1
     - Major version
     - 1
     -
     - Agreed-to protocol major version
   * - 2
     - Minor version
     - 1
     -
     - Agreed-to protocol minor version

Greybus Control Disconnect Operation
------------------------------------

The Greybus control disconnect operation abolishes a connection that
was previously established by a connect operation.  Either end of a
connection can issue the disconnect operation. All that’s required to
identify the connection to be abolished is the CPort id on the
destination interface used by the connection. Disconnect requests can
only be issued by an interface involved in the connection.

Greybus Control Disconnect Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The first byte of the disconnect request is the device id for the
response. This device id is also used to ensure the disconnect request
is coming from an interface used by the connection. The second byte
identifies which connection should be torn down.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Source device id
     - 1
     -
     - Device id of source for response
   * - 1
     - Destination CPort Id
     - 2
     -
     - CPort id to disconnect

Greybus Control Disconnect Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The disconnect response contains only the status byte, indicating
whether the connection was successfully torn down.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     -
     - Success, or reason for failure

Greybus Control Connect Peer Operation
--------------------------------------

The Greybus control connect peer operation is used to request a
connection be established between CPorts on two other interfaces
[#ct]_--separate from the interface over which the request is
sent. This is used by the AP only, to set up a direct communication
channel between CPorts on two other modules. Before responding, the
destination will initiate a connection with the peer interface, using
the destination CPort id at its end of the connection and the peer’s
CPort id at the other end.  If necessary, the destination will first
perform a handshake with the peer interface. Once the connection has
been established between the destination and its peer, the destination
will reply to the source with the status of the request.

Greybus Control Connect Peer Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The connect peer request is only initiated by the AP, and this fact is
reflected in the name of the “respond-to” device id that begins the
request message.  The connection to be established will use the
destination interface, and the CPort id on that interface.  The
destination will initiate a connect request with the peer device and
device id specified.  Note that the protocol that will be used on the
connection is defined by the peer CPort’s protocol (listed in its
module manifest), and the destination and its peer will independently
negotiate the version of that protocol to use.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - AP device id
     - 1
     -
     - Device id of source for response
   * - 1
     - Destination CPort id [#cu]_ [#cv]_
     - 2
     -
     - CPort at destination to use for connection
   * - 3
     - Peer device id
     - 1
     -
     - Device id of peer interface for connection
   * - 4
     - Peer CPort id
     - 2
     -
     - CPort at peer to use for connection

Greybus Control Connect Peer Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The connect peer response contains only the status byte, indicating
whether the peer connection was successfully established.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     -
     - Success, or reason for failure

Greybus Control Disconnect Peer Operation
-----------------------------------------

Greybus Control Disconnect Peer Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control disconnect peer operation requests that the
destination interface disconnect a connection that was previously
established as a result of a peer connect operation.  This operation
must be sent to the same interface that received its corresponding
connect peer operation. All that’s required to identify the connection
to be abolished is the CPort id on the destination interface used by
the connection. Disconnect requests can only be issued by an AP
interface.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - AP device id
     - 1
     -
     - Device id of source for response
   * - 1
     - Destination CPort Id
     - 2
     -
     - CPort id to disconnect

Greybus Control Disconnect Peer Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The disconnect peer response contains only the status byte, indicating
whether the connection was successfully torn down.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     -
     - Success, or reason for failure

Greybus Control Hotplug Operation
---------------------------------

The Greybus control hotplug operation is sent by the SVC to the AP to
notify it that a module has been inserted and is present in the Endo.

Greybus Control Hotplug Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The first byte of the hotplug request is the SVC device id, for the
response. The second byte indicates which module’s presence is being
reported. The identifying data is the data that the SVC originally
collected in the “identify” operation it performed when it first
detected the module was present. The SVC will not send any “link up”
messages for interfaces on a module until after the module’s hotplug
request has completed.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - SVC device id
     - 1
     -
     - Device id of SVC, for the response
   * - 1
     - Module id
     - 1
     -
     - Module id whose presence is detected
   * - 2
     - Data size
     - 2
     - N
     - Size of module identifying data (can be 0)
   * - 4
     - Data
     - N
     -
     - Module identifying data

Greybus Control Hotplug Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The hotplug response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     -
     - Success, or reason for failure

Greybus Control Hot Unplug Operation
------------------------------------

The Greybus control hotplug operation is sent by the SVC to the AP to
notify it that a module has been inserted and is present in the Endo.

Greybus Control Hot Unplug Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The first byte of the disconnect request is the SVC device id, for the
response. The second byte indicates which module has become unplugged.
The hot unplug request will not occur until “link down” operations for
all interfaces on the module have completed.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - SVC device id
     - 1
     -
     - Device id of SVC, for the response
   * - 1
     - Module id
     - 1
     -
     - Module id whose presence is detected

Greybus Control Hot Unplug Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The hotplug response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     -
     - Success, or reason for failure

Greybus Control Link Up Operation
---------------------------------

The Greybus control link up operation is sent by the SVC to the AP to
notify it that an interface on a module that was the subject of a
previous hotplug message reports it has a functioning |unipro| link.

Greybus Control Link Up Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The first byte of the link up request is the SVC device id, for the
response. The second byte indicates which module contains the
interface whose link up condition is being reported. The third byte is
used for modules with more than one interface to indicate which
interface on the module now has a functioning |unipro| link. The final
byte indicates the |unipro| device id that was assigned to that link.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - SVC device id
     - 1
     - .
     - Device id of SVC, for the response
   * - 1
     - Module id
     - 1
     -
     - Id for module containing the interface
   * - 2
     - Interface id
     - 1
     -
     - Which interface within the module
   * - 4
     - Device id
     -
     -
     - |unipro| device id for this link

Greybus Control Link Up Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The link up response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     -
     - Success, or reason for failure

Greybus Control Link Down Operation
-----------------------------------

The Greybus control link down operation is sent by the SVC to the AP
to notify it that an interface on a module that was previously
reported “up” no longer has a functional |unipro| link.

Greybus Control Link Down Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The first byte of the link down request is the SVC device id, for the
response. The second byte indicates device id of the link that has
gone down.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - SVC device id
     - 1
     - .
     - Device id of SVC, for the response
   * - 1
     - Device id
     - 1
     - .
     - |unipro| device id for this link

Greybus Control Link Down Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The link down response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     -
     - Success, or reason for failure

Greybus Control Set Route Operation
-----------------------------------

The Greybus control set route operation is sent by the AP to the SVC
to request it that the |unipro| switch network be configured to allow
traffic to flow between two interfaces.

Greybus Control Set Route Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The first byte of the set route request is the AP interface device id,
for the response. The second and third bytes indicate the device ids
of the interfaces between which traffic should be routed. Switch
routing is always configured to be bidirectional. A configured route
is by default in a disabled state; this means that despite the route
existing, no traffic will be allowed until that route has been
enabled. Note: ES1 does not support disabled routes; all routes will
be enabled.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - AP device id
     - 1
     -
     - Device id of AP interface, for the response
   * - 1
     - From device id
     - 1
     -
     - First |unipro| device id
   * - 2
     - To device id
     - 1
     -
     - Second |unipro| device id

Greybus Control Set Route Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The set route response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     -
     - Success, or reason for failure

Greybus Control Enable Route Operation
--------------------------------------

The Greybus control enable route operation is sent by the AP to the
SVC to request it that a route that was previously set between two
interfaces be enabled.

Greybus Control Enable Route Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The first byte of the enable route request is the AP interface device
id, for the response. The second and third bytes indicate the device
ids of the interfaces whose route is to allow traffic flow.  Note: ES1
does not support disabled routes; all routes will be enabled.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - AP device id
     - 1
     -
     - Device id of AP interface, for the response
   * - 1
     - From device id
     - 1
     -
     - First |unipro| device id
   * - 2
     - To device id
     - 1
     -
     - Second |unipro| device id

Greybus Control Enable Route Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The enable route response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     -
     - Success, or reason for failure

Greybus Control Disable Route Operation
---------------------------------------

The Greybus control disable route operation is sent by the AP to the
SVC to request it that a previously enabled |unipro| switch network
route be disabled, preventing further traffic flow.

Greybus Control Disable Route Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The first byte of the disable route request is the AP interface device
id, for the response. The second and third bytes indicate the device
ids of the interfaces between which traffic flow should be
stopp. Note: ES1 does not support disabled routes; all routes will be
enabled.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - AP device id
     - 1
     -
     - Device id of AP interface, for the response
   * - 1
     - From device id
     - 1
     -
     - First |unipro| device id
   * - 2
     - To device id
     - 1
     -
     - Second |unipro| device id

Greybus Control Disable Route Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The disable route response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - Status
     - 1
     -
     - Success, or reason for failure

.. Footnotes
.. =========

.. rubric:: Footnotes


.. [#bv] There are 2^12 unique CPort ids (defined by 7-bit encoded
         device id and 5-bit CPort id). The absolute maximum number
         required by an interface would be half that.  That means no
         more than 64 device ids can be assigned to an interface.

.. [#bw] What happens if the response contains an invalid number of
         additional device ids?

         What happens if we are unable to allocate the number that are
         required?  This protocol assumes the response is acceptable.
         (This is why a revoke operation might be needed.)

         We could resolve this with a weird nested request--where the
         destination requests more before responding to the
         assign_device_id request.

.. [#bx] Should this be src_cport_id?

.. [#by] No.

         There are three interfaces involved here.  The "source" (the
         AP); the "destination" (to which the request is sent); and
         the "peer" (the one with which the destination will establish
         a connection).

         The source device id defines where the destination should
         send its response.

         The destination device id is implied, because the destination
         receives the request and knows its own device id.

         The destination CPort id names the "local" (with respect to
         the destination interface) end of the connection.

         The peer device id and peer CPort id define the "remote"
         (again with respect to the destination interface) end of the
         connection to be established.

.. [#bz] Is this really any different from disconnect()? You seem to be
           providing the same amount of data

.. [#ca] Yes.

         A normal disconnect is a structured tear-down (as opposed to
         one end simply becoming unresponsive) of a connection,
         initiated by one of the interfaces involved in the connection.

         A peer disconnect is requesting another interface begin the
         tear-down of a connection it has with a (third) peer
         interface.

         They have the same parameters but they have different
         semantics.

.. [#cb] The term destination here makes this seem somewhat
         directional. Do you really have to disconnect the destination
         side of the connection as set up? Or does disconnecting the
         connected cport on either device side of the connection
         suffice?

.. [#cc] Your observation is correct, it's really generally intended
         to be a symmetric relationship.

         I was using "sender" and "receiver" initially, but Matt
         requested I use "source" and "destination" because it was a
         pair of terms he thought were very familiar and frequently
         used.

         I never did like the implication of direction that "source"
         and "destination" have, so if people feel some other terms
         are better I'm very open to switching.

.. [#cd] Oh, and to answer your question, unless it turns out to not
         be possible in implementation, my intention is to allow
         either end of a connection to send a disconnect to the other.

.. [#ce] TBC: the destination device can be disabled in the attributes;
         it is possible to re-route the traffic to the SVC's port.

.. [#cf] The reason why I said it can't be disabled is that disabling
         a particular (from, to) route is not possible in ES1.  If you
         want to disable one path through the switch to a destination,
         you have to disable them all.

         I'm not sure what you mean by re-routing the traffic to the
         SVC (nor why you'd want to do that).

.. [#cg] Is this actually important? I don't really think so.  Already
         the header is making the alignment unpredictable.

.. [#ch] I would like to make the identity data be fairly
         limited--like the vendor id, product id, version, and maybe
         unique id.  In that case I would want to switch this size
         field to be one byte, to emphasize it's intended to be a
         small amount of data.

.. [#ci] This would be the module manifest as currently specified.

.. [#cj] What is the expected size of the manifest data? Should it be
         sent in multiple messages?

.. [#ck] We've talked about this. Most of the data is small-on the
         order of a few bytes.  But strings can be 255 bytes each, and
         there could be dozens of CPorts.  So I'd say on the order of
         1KB would be reasonable.

         Everything we send will be done using a single |unipro|
         message.  This will be broken up by |unipro| into segments as
         needed.

.. [#cl] These details need to be nailed down.

.. [#cm] These details need to be nailed down.

.. [#cn] The folowing info is needed: battery capacity, charge (%) so
         that the SVC knows if there is sufficient power for the boot
         sequence

.. [#co] Yes, this is the subject of an ongoing e-mail thread.  The
         power information might be exchanged during an earlier
         pre-boot phase of operation.  Or, we may include this in the
         "identify" operation described earlier.

.. [#cp] This doesn't apply to ES1

.. [#cq] Do you say this because ES1 can't support it, or because our
        schedule dictates that we won't be doing this for the upcoming demo?

.. [#cr] Is the destination device id also needed? Ditto for the
         disconnect message

.. [#cs] The message is sent to the destination device (by specifying
         its device id in the |unipro| header).  So it's sort of
         implied, and not part of the message itself.

.. [#ct] This doesn't apply to ES1

.. [#cu] Is the source device id is also needed (aka 'Destination
         device id' in the table)? Ditto for the disconnect message

.. [#cv] The request will be sent to the destination device.  Each
         interface knows its own device id, so the destination device
         is implied.
