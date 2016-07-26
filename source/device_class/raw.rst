Raw Protocol
------------

This section defines the operations used on a connection implementing
the Greybus Raw Protocol.  This Protocol is used for streaming "raw"
data from userspace directly to or from the device.  The data contained
by the protocol is not interpreted by the kernel, but requires a
userspace program to handle it.  It can almost be considered a "vendor
specific" protocol in that the format of the data is unspecified, and
will vary by device.

The operations in the Greybus Raw Protocol are:

.. c:function:: int cport_shutdown(u8 phase);

    See :ref:`greybus-protocol-cport-shutdown-operation`.

.. c:function:: int send(u32 len, char *data);

   Sends a stream of data from the AP to the device.

Greybus Raw Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-raw-operation-type` describes the Greybus
Raw operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-raw-operation-type
    :caption: Raw Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Raw Operation Type           Request Value  Response Value
    ===========================  =============  ==============
    CPort Shutdown               0x00           0x80
    Reserved                     0x01           0x81
    Send                         0x02           0x82
    (all other values reserved)  0x04..0x7e     0x84..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

.. _raw-cport-shutdown:

Greybus Raw CPort Shutdown Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Raw CPort Shutdown Operation is the
:ref:`greybus-protocol-cport-shutdown-operation` for the Raw
Protocol.

Greybus Raw Send Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Raw send operation sends data from the requester to the
respondent.

Greybus Raw Send Request
""""""""""""""""""""""""

Table :num:`table-raw-send-request` defines the Greybus Raw Send
request.  The request supplies size of the data that is sent to the
device, and the data itself.

.. figtable::
    :nofig:
    :label: table-raw-send-request
    :caption: Raw Send Protocol Transfer Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        len             4       Number          length in bytes of the data field
    4        data            *len*   Data            data to be sent
    =======  ==============  ======  ==========      ===========================

..

Greybus Raw Send Response
"""""""""""""""""""""""""

The Greybus Raw send response message has no payload.

