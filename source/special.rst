.. _special_protocols:

Special Protocols
=================

This section defines two protocols, each of which serves a special
purpose in a Greybus system.

The first is the control protocol.  Every interface shall provide a
CPort that uses the control protocol.  It's used by the SVC to do
initial probes of interfaces at system power on.  It is also used by
the AP to notify interfaces when connections are available for them
to use.

The second is the SVC protocol, which is used only between the SVC
and AP.  The SVC provides low-level control of the |unipro|
network.  The SVC performs almost all of its activities under
direction of the AP, and the SVC protocol is used by the AP to
exert this control.  The SVC also uses this protocol to notify the
AP of events, such as the insertion or removal of a module.

.. _control-protocol:

Control Protocol
----------------

All interfaces are required to define a CPort that uses the control
protocol, and shall be prepared to receive operation requests on that
CPort at any time.  A Greybus connection is established whenever a
control connection is used, but the interface is never notified that
such a connection exists.  Only the SVC and AP are able to send
control requests.  Any other interface shall only send control
response messages, and such messages shall only be sent in reply to
a request received its control CPort.

Conceptually, the operations in the Greybus control protocol are:

.. c:function:: int probe(u16 endo_id, u8 intf_id, u16 *auth_size, u8 *auth_data);

    This operation is used at initial power-on, sent by the SVC to
    discover which module contains the AP.  The Endo ID supplied by
    the SVC defines the type of Endo used by the Greybus system,
    including the size of the Endo and the positions and sizes of
    modules that it holds.  The interface ID supplied by the SVC
    indicates which interface block on the Endo is being probed.
    Together these two values define the location of the module
    containing the interface.  Interface ID 0 represents the SVC
    itself; other values are defined in the *Project Ara Module
    Developers Kit*.  The response to this operation contains a
    block of data used by a module to identify itself as
    authentically containing an AP.  Non-AP modules respond with no
    authentication data (*auth_size* is 0).

.. c:function:: int connected(u16 cport_id);

    This operation is used to notify an interface that a Greybus
    connection has been established using the indicated CPort.
    Upon receiving this request, an interface shall be prepared to
    receive messages on the indicated CPort.  The interface may send
    messages over the indicated CPort once it has sent a response
    to the connected request.

.. c:function:: int disconnected(u16 cport_id);

    This operation is used to notify an interface that a previously
    established Greybus connection may no longer be used.

Greybus Control Message Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All control operations are contained within a Greybus control
request message. Every control request results in a matching
response.  The request and response messages for each control
operation are defined below.

Table :num:`table-control-operation-type` defines the Greybus
control protocol operation types and their values. Both the request
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
    Probe                        0x01           0x81
    Connected                    0x02           0x82
    Disconnected                 0x03           0x83
    (all other values reserved)  0x04..0x7f     0x84..0xff
    ===========================  =============  ==============

Greybus Control Probe Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control probe operation is sent by the SVC to all
interfaces at power-on to determine which module contains the AP.
Once the AP has been found, the SVC begins a process that transfers
full control of the |unipro| network to the AP.

Greybus Control Probe Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control probe request is sent only by the SVC.  It
supplies the Endo ID, which defines the size of the Endo and
the positions available to hold modules.  It also informs the module
via the interface ID the module location of the interface that
receives the request.

.. figtable::
    :nofig:
    :label: table-control-probe-request
    :caption: Control Protocol Probe Request
    :spec: l l c c l

    =======  ==============  ======  ============    ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ============    ===========================
    0        endo_id         2       Endo ID         Defines Endo geometry
    2        intf_id         1       Interface ID    Position of receiving interface on Endo
    =======  ==============  ======  ============    ===========================

Greybus Control Probe Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control probe response contains a block of
authentication data.  The AP module responds with data that
identifies it as containing the AP.  All other modules respond
with no data (*auth_size* is 0).

.. figtable::
    :nofig:
    :label: table-control-probe-response
    :caption: Control Protocol Probe Response
    :spec: l l c c l

    =======  ==============  ===========  ==========      ===========================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ===========================
    0        auth_size       2            Number          Size of authentication data that follows
    2        auth_data       *auth_size*  Data            Authentication data
    =======  ==============  ===========  ==========      ===========================

Greybus Control Connected Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control connected operation is sent to notify an
interface that one of its CPorts now has a connection established.
The SVC sends this request when it has set up a Greybus SVC
connection with an AP interface.  The AP sends this request to other
interfaces when it has set up Greybus connections for them to use.

Greybus Control Connected Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control connected request supplies the CPort ID on the
receiving interface that has been connected.

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

Greybus Control Connected Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control connected response message contains no payload.

Greybus Control Disconnected Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control disconnected operation is sent to notify an
interface that a CPort that was formerly the subject of a Greybus
control connected operation shall no longer be used.  No more
messages may be sent over this connection, and any messages received
shall be discarded.

Greybus Control Disconnected Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control disconnected request supplies the CPort ID on the
receiving interface that is no longer connected.

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

Greybus Control Disconnected Response
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus control disconnected response message contains no payload.
