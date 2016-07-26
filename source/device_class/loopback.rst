Loopback Protocol
-----------------

This section defines the operations used on a connection implementing
the Greybus loopback Protocol.  This Protocol is used for testing a
Greybus device and the connection to the device, by sending and
receiving data in a "loop".

The operations in the Greybus loopback Protocol are:

.. c:function:: int cport_shutdown(u8 phase);

    See :ref:`greybus-protocol-cport-shutdown-operation`.

.. c:function:: int ping(void);

   Sends a "ping" message to the device, from the host, that needs to be
   acknowledged by the device.  By measuring how long this message takes
   to succeed, an idea of the speed of the connection can be made.

.. c:function:: int transfer(u32 len, char *send, char *receive);

   Sends a stream of bytes to the device and receives them back from the
   device.

.. c:function:: int sink(u32 len, char *send);

   Sends a stream of bytes to the device that needs to be acknowledged by the
   device. No data are sent back from the device.

Greybus Loopback Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-loopback-operation-type` describes the Greybus
loopback operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-loopback-operation-type
    :caption: Loopback Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Loopback Operation Type      Request Value  Response Value
    ===========================  =============  ==============
    CPort Shutdown               0x00           0x80
    Reserved                     0x01           0x81
    Ping                         0x02           0x82
    Transfer                     0x03           0x83
    Sink                         0x04           0x84
    (all other values reserved)  0x05..0x7e     0x85..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

.. _loopback-cport-shutdown:

Greybus Loopback CPort Shutdown Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Loopback CPort Shutdown Operation is the
:ref:`greybus-protocol-cport-shutdown-operation` for the Loopback
Protocol.

Greybus Loopback Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus ping operation is a simple message that has no response.  It
is used to time how long a single message takes to be sent and
acknowledged from the receiver.

Greybus Loopback Ping Request
"""""""""""""""""""""""""""""

The Greybus ping request message has no payload.

Greybus Loopback Ping Response
""""""""""""""""""""""""""""""

The Greybus ping response message has no payload.

Greybus Loopback Transfer Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Loopback transfer operation sends data and then the same
data is returned.  This is used to determine the time required to
transfer different size messages. To facilitate analysis, the messages
used for both the Loopback Transfer Operation request and response
message have identical formats.


Greybus Loopback Transfer Request
"""""""""""""""""""""""""""""""""

Table :num:`table-loopback-request` defines the Greybus Loopback
Transfer request.  The request supplies size of the data that is sent to
the device, and the data itself.

.. figtable::
    :nofig:
    :label: table-loopback-request
    :caption: Loopback Protocol Transfer Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        len             4       Number          length in bytes of the data field
    4        reserved0       4       Number          Not used - same size as response
    8        reserved1       4       Number          Not used - same size as response
    12       data            X       Data            array of data bytes
    =======  ==============  ======  ==========      ===========================

..

Greybus Loopback Transfer Response
""""""""""""""""""""""""""""""""""

Table :num:`table-loopback-response` defines the Greybus Loopback
Transfer response.  The response contains the same data that was sent in
the request.

.. figtable::
    :nofig:
    :label: table-loopback-response
    :caption: Loopback Protocol Transfer Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        len             4       Number          length in bytes of the data field
    4        reserved0       4       Number          reserved for use by the implementation
    8        reserved1       4       Number          reserved for use by the implementation
    12       data            X       Data            array of data bytes
    =======  ==============  ======  ==========      ===========================

..

Greybus Loopback Sink Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Loopback sink operation sends data to the device.
No data is returned back.

Greybus Loopback Sink Request
"""""""""""""""""""""""""""""

The Greybus sink request message is identical to the Greybus transfer request
message.

Greybus Loopback Sink Response
""""""""""""""""""""""""""""""

The Greybus sink response message has no payload.

