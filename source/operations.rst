.. include:: defines.rst

Greybus Operations
==================

Greybus communication is built on the use of |unipro| messages to send
information between modules. And although |unipro| offers reliable
transfer of data frames between interfaces, it is often necessary for
the sender to know whether the effects of sending a message were what
was expected. For example, a request sent to a |unipro| switch
controller requesting a reconfiguration of the routing table could
fail, and proceeding as if a failure had not occurred in this case
leads to undefined (and possibly dangerous) behavior.  Similarly, the AP module
likely needs to retrieve information from other modules; this
requires that a message requesting information be paired with a
returned message containing the information requested.

For this reason, Greybus performs communication between modules using
Greybus Operations.  A Greybus Operation defines an activity (such as
a data transfer) initiated in one module that is implemented (or
executed) by another. The particular activity performed is defined by
the operation's type. An operation is implemented by a pair of
messages--one containing a request, and the other containing a
response. Both messages contain a simple header that includes the type
of the operation and size of the message. In addition, each operation has
a unique id, and both messages in an operation contain this value so
a response can be associated with its matching request. Finally, all
responses contain a byte in message header to communicate status of
the operation--either success or a reason for a failure.

Operations are performed over Greybus Connections.  A connection is a
communication path between two modules.  Each end of a connection is a
|unipro| CPort, associated with a particular interface in a Greybus
module.  A connection can be established once the AP learns of the
existence of a CPort in another module.  The AP shall allocate a CPort
for its end of the connection, and once the |unipro| network switch is
configured properly the connection can be used for data transfer (and
in particular, for operations).

Each CPort in a Greybus module has associated with it a protocol.  The
protocol dictates the way the CPort interprets incoming operation
messages.  Stated another way, the meaning of the operation type found
in a request message depends on which protocol the connection uses.
Operation type 5 might mean "receive data" in one protocol, while
operation 5 might mean "go to sleep" in another. When the AP
establishes a connection with a CPort in another module, that
connection uses the CPort's advertised protocol.

The Greybus Operations mechanism forms a base layer on which other
protocols are built. Protocols define the format of request messages,
their expected response data, and the effect of the request on state
in one or both modules. Users of a protocol can rely on the Greybus
core getting the operation request message to its intended target, and
transferring the operation status and any other data back. In the
explanations that follow, we refer to the interface through which a
request operation is sent as the source, and the interface from which
the response is sent as the destination.

Operation Messages
------------------

Operation request messages and operation response messages have the
same basic format. Each begins with a short header, and is followed by
payload data.  A response message records an additional status value
in the header, and both requests and responses may have a zero-byte
payload.

Operation Message Header
^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-operation-message-header` summarizes the format of an
operation message header.

.. figtable::
    :nofig:
    :label: table-operation-message-header
    :caption: Operation Message Header
    :spec: l l c c l

    ========  ==============  ======  ==========      ===========================
    Offset    Field           Size    Value           Description
    ========  ==============  ======  ==========      ===========================
    0         size            2       Number          Size of this operation message
    2         id              2       ID              Requestor-supplied unique request identifier
    4         type            1       Number          Type of Greybus operation (protocol-specific)
    5         status          1       Number          Operation result (response message only)
    ========  ==============  ======  ==========      ===========================

The *size* includes the operation message header as well as any
payload that follows it. As mentioned earlier, the meaning of a type
value depends on the protocol in use on the connection carrying the
message. Only 127 operations are available for a given protocol,
0x01..0x7f. Operation 0x00 is reserved as an invalid value for all
protocols.  The high
bit (0x80) of an operation type is used as a flag that distinguishes a
request operation from its response.  For requests, this bit is 0, for
responses, it is 1.  For example the request and response messages
for operation 0x0a contain 0x0a and 0x8a (respectively) in their type
fields.  The id allows many operations to be "in flight" on a
connection at once.

A connection protocol is defined by describing the format of the
operations supported by the protocol.  Each operation specifies the
payload portions of the request and response messages used for the
protocol, along with all actions or state changes that take place as a
result of the operation.
