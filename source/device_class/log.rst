Log Protocol
------------

This section defines the Operations used on a Connection implementing the
Greybus Log Protocol. This Protocol allows an Interface to send human-readable
debug log messages to the AP. These messages are typically meant to be displayed
by the AP's system logger (e.g. ``dmesg``).

The Operations in the Greybus log Protocol are:

.. c:function:: int ping(void);

    See :ref:`greybus-protocol-ping-operation`.

.. c:function:: int send_log(u16 len, char *log);

    Log message from an Interface to the AP asynchronously

Greybus Log Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-log-operation-type` describes the Greybus Log Operation types
and their values. A message type consists of an Operation type combined with a
flag (0x80) indicating whether the Operation is a Request or a Response.

.. figtable::
    :nofig:
    :label: table-log-operation-type
    :caption: Log Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Log Operation Type           Request Value  Response Value
    ===========================  =============  ==============
    Ping                         0x00           0x80
    Reserved                     0x01           0x81
    Send Log                     0x02           0x82
    (all other values reserved)  0x03..0x7e     0x83..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

Greybus Log Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Log Ping Operation is the :ref:`greybus-protocol-ping-operation` for
the Log Protocol.  It consists of a Request containing no payload, and a
Response with no payload that indicates a successful result.

Greybus Log Send Log Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Log Send Log Operation sends a log message from the Interface to the
AP in an asynchronous way. A log message is described by a null-terminated
sequence of UTF-8 characters and its associated length.

Greybus Log Send Log Request
""""""""""""""""""""""""""""

Table :num:`table-log-send-log-request` defines the Greybus Log Send Log
Request. The Request supplies the size of the log message that is sent by the
Interface and the log message itself.

.. figtable::
    :nofig:
    :label: table-log-send-log-request
    :caption: Log Protocol Send Log Request
    :spec: l l c c l

    =======  ==============  ======  ==========  ===========================
    Offset   Field           Size    Value       Description
    =======  ==============  ======  ==========  ===========================
    0        length          2       Number      Length in bytes of the log message
    2        log             X       UTF-8       Content of the log message
    =======  ==============  ======  ==========  ===========================

..

Greybus Log Send Log Response
"""""""""""""""""""""""""""""

The Greybus Log Send Log Response message has no payload.

