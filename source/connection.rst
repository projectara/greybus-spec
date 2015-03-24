Connection Protocols
====================

The following sections define the request and response message formats
for all operations for specific connection protocols. Requests are
most often (but not always) initiated by the AP. Each request has a
unique identifier, supplied by the requestor, and each response
includes the identifier of the request with which it is associated.
This allows operations to complete asynchronously, so multiple
operations can be "in flight" between the AP and a |unipro|-attached
adapter at once.

Each response includes a status byte in its message header, which
communicates whether any error occurred in delivering or processing a
requested operation. If the operation completed successfully, the
status value is zero.  Otherwise, the reason it was not successful is
conveyed by one of the positive values defined in Table
:num:`table-connection-status-values`.

.. _greybus-protocol-error-codes:

Protocol Status
---------------

A protocol can define its own status values if needed. These status
values shall lie within the range defined by the "(Reserved for
protocol use)" table entry in Table
:num:`table-connection-status-values`. Every status byte with a MSB set
to one other than 0xff is a valid protocol status value.

.. figtable::
    :nofig:
    :label: table-connection-status-values
    :caption: Connection Status Values
    :spec: l c l

    ============================  ===============  =======================
    Status                        Value            Meaning
    ============================  ===============  =======================
    GB_OP_SUCCESS                 0x00             Operation completed successfully
    GB_OP_INTERRUPTED             0x01             Operation processing was interrupted
    GB_OP_TIMEOUT                 0x02             Operation processing timed out
    GB_OP_NO_MEMORY               0x03             Memory exhaustion prevented operation completion
    GB_OP_PROTOCOL_BAD            0x04             Protocol is not supported by this Greybus implementation
    GB_OP_OVERFLOW                0x05             Request message was too large
    GB_OP_INVALID                 0x06             Invalid argument supplied
    GB_OP_RETRY                   0x07             Request should be retried
    GB_OP_NONEXISTENT             0x08             The device does not exist
    Reserved                      0x09 to 0x7f     Reserved for future use
    Reserved for protocol use     0x80 to 0xfd     Status defined by the protocol in use
    GB_OP_UNKNOWN_ERROR           0xfe             Unknown error occured
    GB_OP_INTERNAL                0xff             Invalid initial value.
    ============================  ===============  =======================

Values marked *Reserved for protocol use* are to be used by the
individual protocols as defined in the :ref:`device-class-protocols` and
:ref:`bridged-phy-protocols` sections below.

Note that *GB_OP_INTERNAL* should never be used in a response message. It
is reserved for internal use by the Greybus application stack only.

All protocols defined herein are subject to the
:ref:`message-data-requirements` listed above.

Protocol Versions
-----------------

Every protocol has a version, which comprises two one-byte values,
major and minor. A protocol definition can evolve to add new
capabilities, and as it does so, its version changes. If existing (or
old) protocol handling code which complies with this specification can
function properly with the new feature in place, only the minor
version of the protocol shall change. Any time a protocol changes in a
way that requires the handling code be updated to function properly,
the protocol's major version shall change.

Two modules may implement different versions of a protocol, and as a
result they shall negotiate a common version of the protocol to
use. This is done by each side exchanging information about the
version of the protocol it supports at the time a connection
between module interfaces is set up.
The version of a particular protocol advertised by a
module is the same as the version of the document that defines the
protocol (so for protocols defined herein, the version is |gb-major|.\
|gb-minor|).  In the future, if the protocol specifications are removed from
this document, the versions will become independent of the
overall Greybus Specification document.

To agree on a protocol, an operation request supplies the (greatest)
major and minor version of the protocol supported by the source of a
request. The request destination compares that version with the
(greatest) version of the protocol it supports.  The version that is the
largest common version number of the protocol sent by both sides shall
be the version that is to be used in communication between the devices.
This chosen version is returned back as a response of the
request.  As a consequence of this, protocol handlers shall be capable of
handling all prior versions of the protocol.

