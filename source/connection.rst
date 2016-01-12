Connection Protocols
====================

The following sections define the request and response message formats
for all operations for specific connection Protocols. Requests are
most often (but not always) initiated by the AP Module. Each request has a
unique identifier, supplied by the requestor, and each response
includes the identifier of the request with which it is associated.
This allows operations to complete asynchronously, so multiple
operations can be "in flight" between the AP Module and a |unipro|-attached
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

A Protocol can define its own status values if needed. These status
values shall lie within the range defined by the "(Reserved for
Protocol use)" table entry in Table
:num:`table-connection-status-values`. Every status byte with a MSB set
to one other than 0xff is a valid Protocol status value.

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
    Reserved for Protocol use     0x80 to 0xfd     Status defined by the Protocol in use
    GB_OP_UNKNOWN_ERROR           0xfe             Unknown error occured
    GB_OP_INTERNAL                0xff             Invalid initial value.
    ============================  ===============  =======================

Values marked *Reserved for Protocol use* are to be used by the
individual Protocols as defined in the :ref:`device-class-protocols` and
:ref:`bridged-phy-protocols` sections below.

Note that *GB_OP_INTERNAL* shall not be used in a response message. It
is reserved for internal use by the Greybus application stack only.

All Protocols defined herein are subject to the
:ref:`message-data-requirements` listed above.

Protocol Versions
-----------------

Every Protocol has a version, which comprises two one-byte values,
major and minor. A Protocol definition can evolve to add new
capabilities, and as it does so, its version changes. If existing (or
old) Protocol handling code which complies with this specification can
function properly with the new feature in place, only the minor
version of the Protocol shall change. Any time a Protocol changes in a
way that requires the handling code be updated to function properly,
the Protocol's major version shall change.

Two Modules may implement different versions of a Protocol, and as a
result they shall negotiate a common version of the Protocol to
use. This is done by each side exchanging information about the
version of the Protocol it supports at the time a connection
between Module interfaces is set up.
The version of a particular Protocol advertised by a
Module is the same as the version of the document that defines the
Protocol (so for Protocols defined herein, the version is |gb-major|.\
|gb-minor|).  In the future, if the Protocol specifications are removed from
this document, the versions will become independent of the
overall Greybus Specification document.

To agree on a Protocol, an operation request supplies the (greatest)
major and minor version of the Protocol supported by the source of a
request. The request destination compares that version with the
(greatest) version of the Protocol it supports.  The version that is the
largest common version number of the Protocol sent by both sides shall
be the version that is to be used in communication between the devices.
This chosen version is returned back as a response of the
request.  As a consequence of this, Protocol handlers shall be capable of
handling all prior versions of the Protocol.

