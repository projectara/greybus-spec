Vibrator Protocol
-----------------

This section defines the operations used on a connection implementing
the Greybus vibrator Protocol.  This Protocol allows an AP Module to manage
a vibrator device present on a Module.  The Protocol is very simple,
and maps almost directly to the Android HAL vibrator interface.

The operations in the Greybus vibrator Protocol are:

.. c:function:: int cport_shutdown(u8 phase);

    See :ref:`greybus-protocol-cport-shutdown-operation`.

.. c:function:: int vibrator_on(u16 timeout_ms);

   Turns on the vibrator for the number of specified milliseconds.

.. c:function:: int vibrator_off(void);

    Turns off the vibrator immediately.

Greybus Vibrator Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-vibrator-operation-type` describes the Greybus
vibrator operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-vibrator-operation-type
    :caption: Vibrator Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Vibrator Operation Type      Request Value  Response Value
    ===========================  =============  ==============
    CPort Shutdown               0x00           0x80
    Reserved                     0x01           0x81
    Vibrator On                  0x02           0x82
    Vibrator Off                 0x03           0x83
    (all other values reserved)  0x04..0x7e     0x84..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

.. _vibrator-cport-shutdown:

Greybus Vibrator CPort Shutdown Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Vibrator CPort Shutdown Operation is the
:ref:`greybus-protocol-cport-shutdown-operation` for the Vibrator
Protocol.

Greybus Vibrator On Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus vibrator on operation allows the AP Module to request the
vibrator be enabled for the specified number of milliseconds.

Greybus Vibrator On Request
"""""""""""""""""""""""""""

Table :num:`table-vibrator-on-request` defines the Greybus Vibrator
On request.  The request supplies the amount of time that the
vibrator should now be enabled for.

.. figtable::
    :nofig:
    :label: table-vibrator-on-request
    :caption: Vibrator Protocol On Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        timeout_ms      2       Number          timeout in milliseconds
    =======  ==============  ======  ==========      ===========================

..

Greybus Vibrator On Response
""""""""""""""""""""""""""""

The Greybus vibrator on response message has no payload.

Greybus Vibrator Off Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Vibrator off operation allows the AP Module to request the
vibrator be turned off as soon as possible.

Greybus Vibrator Off Request
""""""""""""""""""""""""""""

The Greybus vibrator off request message has no payload.

Greybus Vibrator Off Response
"""""""""""""""""""""""""""""

The Greybus vibrator off response message has no payload.

