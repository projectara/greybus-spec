Greybus Operations
==================

Greybus communication is built on the use of |unipro| messages to send
information between Modules. And although |unipro| offers reliable
transfer of data frames between interfaces, it is often necessary for
the sender to know whether the effects of sending a message were what
was expected. For example, a request sent to a |unipro| switch
controller requesting a reconfiguration of the routing table could
fail, and proceeding as if a failure had not occurred in this case
leads to undefined (and possibly dangerous) behavior.  Similarly, the
AP Module likely needs to retrieve information from other Modules;
this requires that a message requesting information be paired with a
returned message containing the information requested.

For this reason, Greybus performs communication between Modules using
Greybus Operations.  A Greybus Operation defines an activity (such as
a data transfer) initiated in one Module that is implemented (or
executed) by another. The particular activity performed is defined by
the operation's type. An operation is generally implemented by a pair of
messages--one containing a request, and the other containing a response, but
*unidirectional* operations (i.e. requests without matching responses) are also
supported. Both messages contain a simple header that includes the type of the
operation and size of the message. In addition, each operation has a unique ID,
and both messages in an operation contain this value so a response can be
associated with its matching request (unidirectional operations use a reserved
ID). Finally, all responses contain a byte in message header to communicate
status of the operation--either success or a reason for a failure.

Whether a particular operation has a response message or not (i.e. is
unidirectional) is protocol dependent. It usually makes sense for operations
which may be initiated by the AP Module to have responses as any errors can be
logged and often also reported up the stack (e.g. to userspace).

Operations are performed over Greybus Connections.  A connection is a
communication path between two Modules.  Each end of a connection is a
|unipro| CPort, associated with a particular interface in a Greybus
Module.  A connection can be established once the AP Module learns of
the existence of a CPort in another Module.  The AP Module shall
allocate a CPort for its end of the connection, and once the |unipro|
network switch is configured properly the connection can be used for
data transfer (and in particular, for operations).

Each CPort in a Greybus Module has associated with it a Protocol.  The
Protocol dictates the way the CPort interprets incoming operation
messages.  Stated another way, the meaning of the operation type found
in a request message depends on which Protocol the connection uses.
Operation type 5 might mean "receive data" in one Protocol, while
operation 5 might mean "go to sleep" in another. When the AP Module
establishes a connection with a CPort in another Module, that
connection uses the CPort's advertised Protocol.

Each Greybus Protocol has a two-byte version associated with it.
This allows Protocols to evolve, and provides a way for Protocol
handling software to correctly handle messages transferred over a
connection.  A Protocol version, for example 0.1, consists of a
major and minor part (0 and 1 in this case).  The major version is
changed (increased) if new features of the Protocol are incompatible
with existing Protocol handling code.  Protocol changes (such as the
addition of optional features) that do not require software changes
are indicated by a change to the minor version number.

Greybus Protocol handling code shall record the maximum Protocol
version it can support.  It shall also support all versions (major
and minor) of the Protocol lower than that maximum.  The Protocol
handlers on the two ends of the connection negotiate the version of
the Protocol to use when a connection is established.  Every
Protocol implements a *version* operation for this purpose.  The
version request message contains the major and minor Protocol
version supported by the sending side.  The receiving end decides
whether that version should be used, or if a different (lower)
version that it supports should be used instead.  Both sides use
the version of the Protocol contained in the response.

The Greybus Operations mechanism forms a base layer on which other
Protocols are built. Protocols define the format of request messages,
their expected response data, and the effect of the request on state
in one or both Modules. Users of a Protocol can rely on the Greybus
core getting the operation request message to its intended target, and
transferring the operation status and any other data back. In the
explanations that follow, we refer to the interface through which a
request operation is sent as the source, and the interface from which
the response is sent as the destination.

.. _message-data-requirements:

Message Data Requirements
-------------------------

All data found in message structures defined below shall adhere to
the following general requirements:

* All numeric values shall be unsigned unless explicitly stated otherwise.
* All numeric field values shall have little endian format.
* Numeric values prefixed with 0x are hexadecimal; they are decimal otherwise.
* All offset and size values are expressed in units of bytes unless
  explicitly stated otherwise.
* All string values shall consist of UTF-8 encoded characters.
* String values shall be paired with a numeric value indicating the
  number of characters in the string.
* String values shall not include terminating NUL characters.
* Any reserved space in a message structure shall be
  ignored when read, and zero-filled when written.
* All Protocols shall be versioned, to allow future extensions (or
  fixes) to be added and recognized.

Fields within a message payload have no specific alignment
requirements.  Message headers are padded to fill 8 bytes,
so the alignment of a message's payload is comparable to
that of its header.  If alignment is required, it is achieved
using explicitly defined reserved fields.

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
    2         id              2       Number          Requestor-supplied unique request identifier
    4         type            1       Number          Type of Greybus operation (Protocol-specific)
    5         status          1       Number          Operation result (response message only)
    6         (pad)           2       0               Reserved (pad to 8 bytes)
    ========  ==============  ======  ==========      ===========================

The *size* includes the operation message header as well as any
payload that follows it. As mentioned earlier, the meaning of a type
value depends on the Protocol in use on the connection carrying the
message. Only 127 operations are available for a given Protocol,
0x01..0x7f. Operation 0x00 is reserved as an invalid value for all
Protocols.  The high
bit (0x80) of an operation type is used as a flag that distinguishes a
request operation from its response.  For requests, this bit is 0, for
responses, it is 1.  For example the request and response messages
for operation 0x0a contain 0x0a and 0x8a (respectively) in their type
fields.  The ID allows many operations to be "in flight" on a
connection at once. The special ID 0 is reserved for unidirectional operations.

A connection Protocol is defined by describing the format of the
operations supported by the Protocol.  Each operation specifies the
payload portions of the request and response messages used for the
Protocol, along with all actions or state changes that take place as a
result of the operation.
