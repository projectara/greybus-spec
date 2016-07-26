.. _greybus-connection-protocols:

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
status value is *GB_OP_SUCCESS*.  Otherwise, the reason it was not successful is
conveyed by one of the positive values defined in Table
:num:`table-operation-status-values`. All Protocols defined herein are subject
to the :ref:`message-data-requirements` listed above.

.. _greybus-protocol-version:

Protocol Versions
-----------------

.. note::

    Greybus no longer supports a common Version Operation for Individual
    Protocols, except for the :ref:`svc-protocol`, the
    :ref:`control-protocol`, and the :ref:`bootrom-protocol`.

The Protocol version comprises of two one-byte values, major and minor.
A Protocol definition can evolve to add new capabilities, and as it does
so, its version changes. If existing (or old) Protocol handling code
which complies with this specification can function properly with the
new feature in place, only the minor version of the Protocol shall
change. Any time a Protocol changes in a way that requires the handling
code be updated to function properly, the Protocol's major version shall
change.

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
request.

.. _greybus-protocol-version-operation:

Common Greybus Protocol Version Operation
-----------------------------------------

Some Connection Protocols specify an Operation which allows the
Protocol handling software on both ends of a connection to negotiate
the version of the Protocol to use. This Operation shall be named the
Protocol Version Operation. All Connection Protocol Operations with
this name shall have the same semantics, as defined in this section.

Conceptually, this operation is:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the Protocol used for
    communication over the connection.  The requestor offers the
    version of the Protocol it supports.  The respondent replies with
    the version that will be used - either the one offered if
    supported, or its own (lower) version otherwise.

The request value of each Protocol Version Operation shall be 0x01,
and the response value for this Operation shall be 0x81.

For example, the corresponding Operation within the Greybus
:ref:`control-protocol` is named the Greybus Control Protocol Version
Operation. Its request and response values are respectively 0x01 and
0x81.

For this operation, the request specifies the greatest version of the
Protocol supported by the requestor.  The response contains the
version that shall be used for further communication -- either the one
offered if supported, or a lower version otherwise.

The following sections define the contents and semantics of this
Operation's Request and Response messages.

Common Greybus Protocol Version Request
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Table :num:`table-common-greybus-protocol-version-request` defines the
request payload for each Protocol's Protocol Version Operation. The
request supplies the greatest major and minor version of the
Connection Protocol supported by the sender.

The Common Greybus Protocol Version Request shall be sent only by the
AP for all Protocols except the SVC Protocol. In the case of the SVC
protocol, the request shall be sent only by the SVC.

.. figtable::
    :nofig:
    :label: table-common-greybus-protocol-version-request
    :caption: Common Greybus Protocol Version Request
    :spec: l l c c l

    =======  ==============  ======  ========  ==============================
    Offset   Field           Size    Value     Description
    =======  ==============  ======  ========  ==============================
    0        version_major   1       Number    Offered Protocol major version
    1        version_minor   1       Number    Offered Protocol minor version
    =======  ==============  ======  ========  ==============================

..

The values of the version_major and version_minor fields shall be
specified on a per-protocol basis; the subsequent sections of this
document which define individual Connection Protocols specify the
values of these fields for this Operation according to the particular
Protocol defined in each section.

Common Greybus Protocol Version Response
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Table :num:`table-common-greybus-protocol-version-response` defines
the response payload for each Protocol's Protocol Version
Operation. The response supplies the version of the protocol that
shall be used for any subsequent communication via the Connection.

.. figtable::
   :nofig:
   :label: table-common-greybus-protocol-version-response
   :caption: Common Greybus Protocol Version Request
   :spec: l l c c l

   =======  ==============  ======  ========  ==============================
   Offset   Field           Size    Value     Description
   =======  ==============  ======  ========  ==============================
   0        version_major   1       Number    Offered Protocol major version
   1        version_minor   1       Number    Offered Protocol minor version
   =======  ==============  ======  ========  ==============================

..

The values of the version_major and version_minor fields shall be
specified on a per-protocol basis; the subsequent sections of this
document which define individual Connection Protocols specify the
values of these fields for this Operation according to the particular
Protocol defined in each section.

.. _greybus-protocol-cport-shutdown-operation:

Common Greybus Protocol CPort Shutdown Operation
------------------------------------------------

With some exceptions, every :term:`Connection Protocol` implements a
"CPort Shutdown" :term:`Operation`. This Operation is used as part of
a sequence that closes a :term:`Greybus Connection`, as described in
:ref:`lifecycles_connection_management`.

Common Greybus Protocol CPort Shutdown Request
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Table :num:`table-common-greybus-protocol-cport-shutdown-request`
defines the Request payload for a Protocol's CPort Shutdown
Operation. The value of the phase field in the Request
payload shall equal one.

This Request shall only be sent by the AP. The AP should not send this
Request except as described in
:ref:`lifecycles_connection_management`. The results of sending this
Request under other circumstances are undefined.

.. figtable::
   :nofig:
   :label: table-common-greybus-protocol-cport-shutdown-request
   :caption: Common Greybus Protocol CPort Shutdown Request
   :spec: l l c c l

   =======  ==============  ======  ========  ==============================
   Offset   Field           Size    Value     Description
   =======  ==============  ======  ========  ==============================
   0        phase           1       1         Current phase in the closure sequence
   =======  ==============  ======  ========  ==============================

Common Greybus Protocol CPort Shutdown Response
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A Protocol's CPort Shutdown Response contains no payload.

The status byte in the Response's :term:`Message Header` shall equal
GB_OP_SUCCESS.

.. _connection-tx-restrictions:

Connection Transmission Restrictions
------------------------------------

Greybus Connections use |unipro| CPorts to exchange
application-specific payload data and, when the |unipro| End-to-End
Flow Control (E2EFC) feature is enabled, Flow Control Tokens.

Within a Greybus System, this exchange of data and Flow Control Tokens
is subject to certain restrictions and recommendations defined in this
section.

Specifically, when an Interface "**may transmit Segments on a
CPort**", the following requirements and recommendations hold:

- Interfaces shall transmit Segments on CPorts only when permitted or
  required to do so by [MIPI01]_, including Segments carrying Flow
  Control Tokens, regardless of whether the Segments carry payload
  data.

- Interfaces shall transmit Segments on CPorts involved in Greybus
  Connections only when permitted or required to do so by the Greybus
  Connection Protocol implemented by their respective CPort Users.

- If the |unipro| E2EFC feature is enabled on a connected CPort,
  Interfaces should ensure that Segments carrying Flow Control Tokens
  are transmitted by that CPort as buffer space becomes available to
  its CPort User.

Additionally, when an Interface "**shall halt Segment transmission on
a CPort**", the Interface shall ensure that the CPort's User shall
subsequently neither:

- request the transfer of a Message Fragment to its peer CPort User, nor
- signal its ability to consume more data to its local CPort.

The CPort User may terminate a currently ongoing |unipro| Message
transmission or complete ongoing flow-control related transactions
with its local CPort as a result of the Interface ensuring these
conditions hold.
