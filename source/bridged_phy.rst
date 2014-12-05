.. include:: defines.rst

.. _bridged-phy-protocols:

Bridged PHY Connection Protocols
================================

This section defines a group of protocols whose purpose is to support
communication with modules on the Greybus network which do not comply
with an existing device class protocol, and which include integrated
circuits using alternative physical interfaces to |unipro|. Modules
which implement any of the protocols defined in this section are said
to be *non-device class conformant*.

USB Protocol
------------

We will support bulk, control, and interrupt transfers, but not
isochronous at this point in time.

Details TBD.

GPIO Protocol
-------------

A connection using GPIO protocol on a |unipro| network is used to manage
a simple GPIO controller. Such a GPIO controller implements one or
more (up to 256) GPIO lines, and each of the operations below
specifies the line to which the operation applies. This protocol
consists of the operations defined in this section.

Conceptually, the GPIO protocol operations are:

::

    int get_version(u8 *major, u8 *minor);

..

    Returns the major and minor Greybus GPIO protocol version number
    supported by the GPIO controller. GPIO controllers adhering to the
    protocol specified herein shall report major version 0, minor
    version 1.

::

    int line_count(u8 *count);

..

    Returns one less than the number of lines managed by the Greybus
    GPIO controller. This means the minimum number of lines is 1 and
    the maximum is 256.

::

    int activate(u8 which);

..

    Notifies the GPIO controller that one of its lines has been
    assigned for use.

::

    int deactivate(u8 which);

..

    Notifies the GPIO controller that a previously-activated line has
    been unassigned and can be deactivated.

::

    int get_direction(u8 which, u8 *direction);

..

    Requests the GPIO controller return a line’s configured direction
    (0 for output, 1 for input).

::

    int direction_input(u8 which);

..

    Requests the GPIO controller configure a line for input.

::

    int direction_output(u8 which, u8 value);

..

    Requests the GPIO controller configure a line for output, and sets
    its initial output value (0 for low, 1 for high).

::

    int get_value(u8 which, u8 *value);

..

    Requests the GPIO controller return the current value sensed on a
    line (0 for low, 1 for high).

::

    int set_value(u8 which, u8 value);

..

    Requests the GPIO controller set the value (0 for low, 1 for high)
    for a line configured for output.

::

    int set_debounce(u8 which, u16 usec);

..

    Requests the GPIO controller set the debounce period (in
    microseconds).

Greybus GPIO Protocol Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All operations sent to a GPIO controller are contained within a
Greybus GPIO request message. Every operation request will result in a
matching response [#bp]_ [#bq]_ [#br]_ [#bs]_ from the GPIO
controller, also taking the form of a GPIO controller message.  The
request and response messages for each GPIO operation are defined
below.

The following table describes the Greybus GPIO protocol operation
types and their values. Both the request type and response type values
are shown.

.. list-table::
   :header-rows: 1

   * - GPIO Operation
     - Request Value
     - Response Value
   * - Invalid
     - 0x00
     - 0x80
   * - Protocol version
     - 0x01
     - 0x81
   * - Line count
     - 0x02
     - 0x82
   * - Activate
     - 0x03
     - 0x83
   * - Deactivate
     - 0x04
     - 0x84
   * - Get direction
     - 0x05
     - 0x85
   * - Direction input
     - 0x06
     - 0x86
   * - Direction output
     - 0x07
     - 0x87
   * - Get
     - 0x08
     - 0x88
   * - Set
     - 0x09
     - 0x89
   * - Set debounce
     - 0x0a
     - 0x8a
   * - (All other values reserved)
     - 0x0b..0x7f
     - 0x8b..0xff

Greybus GPIO Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO version operation allows the AP to determine the
version of this protocol to which the GPIO controller complies.

Greybus GPIO Protocol Version Request
"""""""""""""""""""""""""""""""""""""

The Greybus GPIO protocol version request contains no data beyond the
Greybus GPIO message header.

Greybus GPIO Protocol Version Response
""""""""""""""""""""""""""""""""""""""

The Greybus GPIO protocol version response contains a status byte,
followed by two 1-byte values. If the value of the status byte is
non-zero, any other bytes in the response shall be ignored. A Greybus
GPIO controller adhering to the protocol specified herein shall report
major version 0, minor version 1.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure
   * - 1
     - version_major
     - 1
     - |gb-major|
     - Greybus GPIO protocol major version
   * - 2
     - version_minor
     - 1
     - |gb-minor|
     - Greybus GPIO protocol minor version

Greybus GPIO Line Count Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO line count operation allows the AP to determine how
many GPIO lines are implemented by the GPIO controller.

Greybus GPIO Line Count Request
"""""""""""""""""""""""""""""""

The Greybus GPIO line count request contains no data beyond the
Greybus GPIO message header.

Greybus GPIO Line Count Response
""""""""""""""""""""""""""""""""

The Greybus GPIO line count response contains a status byte, followed
by a 1-byte value defining the number of lines managed by the
controller, minus 1. That is, a count value of 0 represents a single
GPIO line, while a (maximal) count value of 255 represents 256
lines. The lines are numbered sequentially starting with 0 (i.e., no
gaps in the numbering).

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure
   * - 1
     - count
     - 1
     -
     - Number of GPIO lines minus 1

Greybus GPIO Activate Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO activate operation notifies the GPIO controller that
one of its GPIO lines has been allocated for use. This provides a
chance to do initial setup for the line, such as enabling power and
clock signals.

Greybus GPIO Activate Request
"""""""""""""""""""""""""""""

The Greybus GPIO activate request supplies only the number of the line
to be activated.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - which
     - 1
     -
     - Controller-relative GPIO line number

Greybus GPIO Activate Response
""""""""""""""""""""""""""""""

The Greybus GPIO activate response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus GPIO Deactivate Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO deactivate operation notifies the GPIO controller
that a previously-activated line is no longer in use and can be
deactivated.

Greybus GPIO Deactivate Request
"""""""""""""""""""""""""""""""

The Greybus GPIO deactivate request supplies only the number of the
line to be deactivated.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - which
     - 1
     -
     - Controller-relative GPIO line number

Greybus Deactivate Response
"""""""""""""""""""""""""""

The Greybus GPIO deactivate response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus GPIO Get Direction Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO get direction operation requests the GPIO controller
respond with the direction of transfer (in or out) for which a line is
configured.

Greybus GPIO Get Direction Request
""""""""""""""""""""""""""""""""""

The Greybus GPIO get direction request supplies only the target line number.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - which
     - 1
     -
     - Controller-relative GPIO line number

Greybus Get Direction Response
""""""""""""""""""""""""""""""

The Greybus GPIO get direction response contains the status byte and
one byte indicating whether the line in question is configured for
input or output. If the value of the status byte is non-zero, the
direction byte shall be ignored.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure
   * - 1
     - direction
     - 1
     - 0 or 1
     - Direction (0 = output, 1 = input)

Greybus GPIO Direction Input Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO direction input operation requests the GPIO
controller to configure a line to be used for input.

Greybus GPIO Direction Input Request
""""""""""""""""""""""""""""""""""""

The Greybus GPIO direction input request supplies only the number of
the line.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - which
     - 1
     -
     - Controller-relative GPIO line number

Greybus Direction Input Response
""""""""""""""""""""""""""""""""

The Greybus GPIO direction input response contains only the status
byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus GPIO Direction Output Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO direction output operation requests the GPIO
controller to configure a line to be used for output, and specifies
its initial value.

Greybus GPIO Direction Output Request
"""""""""""""""""""""""""""""""""""""

The Greybus GPIO direction output request supplies the number of the
line and its initial value.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - which
     - 1
     -
     - Controller-relative GPIO line number
   * - 1
     - value
     - 1
     - 0 or 1
     - Initial value (0 = low, 1 = high)

Greybus Direction Output Response
"""""""""""""""""""""""""""""""""

The Greybus GPIO direction output response contains only the status
byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus GPIO Get Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO get operation requests the GPIO controller respond
with the current value (high or low) on a line.

Greybus GPIO Get Request
""""""""""""""""""""""""

The Greybus GPIO get request supplies only the target line number.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - which
     - 1
     -
     - Controller-relative GPIO line number

Greybus Get Response
""""""""""""""""""""

The Greybus GPIO get response contains the status byte, plus one byte
indicating the value on the line in question.  If the value of the
status byte is non-zero, the value byte shall be ignored.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure
   * - 1
     - value
     - 1
     - 0 or 1
     - Value (0 = low, 1 = high)

Greybus GPIO Set Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO set operation requests the GPIO controller to set a
line configured to be used for output to have either a low or high
value.

Greybus GPIO Set Request
""""""""""""""""""""""""

The Greybus GPIO set request [#bt]_ [#bu]_ supplies the number of the
line and the value to be set.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - which
     - 1
     -
     - Controller-relative GPIO line number
   * - 1
     - value
     - 1
     - 0 or 1
     - Value (0 = low, 1 = high)

Greybus Set Response
""""""""""""""""""""

The Greybus GPIO set response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus GPIO Set Debounce Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO set debounce operation requests the GPIO controller
to set the debounce delay configured to be used for a line.

Greybus GPIO Set Debounce Request
"""""""""""""""""""""""""""""""""

The Greybus GPIO set debounce request supplies the number of the line
and the time period (in microseconds) to be used for the line.  If the
period specified is 0, debounce is disabled.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - which
     - 1
     -
     - Controller-relative GPIO line number
   * - 1
     - usec
     - 2
     -
     - Debounce period (microseconds)

Greybus Set Debounce Response
"""""""""""""""""""""""""""""

The Greybus GPIO set debounce response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

SPI Protocol
------------

TBD.

UART Protocol
-------------

A connection using the UART protocol on a |unipro| network is used to
manage a simple UART controller.  This protocol is very close to the
CDC protocol for serial modems from the USB-IF specification, and
consists of the operations defined in this section.

The operations that can be performed on a Greybus UART controller are:

::

    int get_version(u8 *major, u8 *minor);

..

    Returns the major and minor Greybus UART protocol version number
    supported by the UART device.

::

    int send_data(u16 size, u8 *data);

..

    Requests that the UART device begin transmitting characters. One
    or more bytes to be transmitted will be supplied.

::

    int receive_data(u16 size, u8 *data);

..

    Receive data from the UART.  One or more bytes will be supplied.

::

    int set_line_coding(u32 rate, u8 format, u8 parity, u8 data);

..

   Sets the line settings of the UART to the specified baud rate,
   format, parity, and data bits.

::

    int set_control_line_state(u8 state);

..

    Controls RTS and DTR line states of the UART.

::

    int send_break(u8 state);

..

    Requests that the UART generate a break condition on its transmit
    line.

::

    int serial_state(u16 *state);

..

    Receives the state of the UART’s control lines and any line errors
    that might have occurred.

UART Protocol Operations
^^^^^^^^^^^^^^^^^^^^^^^^

This section defines the operations for a connection using the UART
protocol.  UART protocol allows an AP to control a UART device
contained within a Greybus module.

Greybus UART Message Types
""""""""""""""""""""""""""

This table describes the known Greybus UART operation types and their
values. A message type consists of an operation type combined with a
flag (0x80) indicating whether the operation is a request or a
response.  There are 127 valid operation type values.

.. list-table::
   :header-rows: 1

   * - Descriptor Type
     - Request Value
     - Response Value
   * - Invalid
     - 0x00
     - 0x80
   * - Protocol version
     - 0x01
     - 0x81
   * - Send Data
     - 0x02
     - 0x82
   * - Receive Data
     - 0x03
     - 0x83
   * - Set Line Coding
     - 0x04
     - 0x84
   * - Set Control Line State
     - 0x05
     - 0x85
   * - Send Break
     - 0x06
     - 0x86
   * - Serial State
     - 0x07
     - 0x87
   * - (All other values reserved)
     - 0x08..0x7f
     - 0x08..0xff

Greybus UART Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus UART protocol version operation allows the AP to determine
the version of this protocol to which the UART device complies.

Greybus UART Protocol Version Request
"""""""""""""""""""""""""""""""""""""

The Greybus UART protocol version request contains no data beyond the
Greybus UART message header.

Greybus UART Protocol Version Response
""""""""""""""""""""""""""""""""""""""

The Greybus UART protocol version response contains a status byte,
followed by two 1-byte values. If the value of the status byte is
non-zero, any other bytes in the response shall be ignored. A Greybus
UART device adhering to the protocol specified herein shall report
major version |gb-major|, minor version |gb-minor|.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure
   * - 1
     - version_major
     - 1
     - |gb-major|
     - Greybus UART protocol major version
   * - 2
     - version_minor
     - 1
     - |gb-minor|
     - Greybus UART protocol minor version

Greybus UART Send Data Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus UART start transmission operation allows the AP to request
the UART device begin transmission of characters.  One or more
characters to be transmitted may optionally be provided with this
request.

Greybus UART Send Data Request
""""""""""""""""""""""""""""""

The Greybus UART start transmission request shall request the UART
device begin transmitting.  The request optionally contains one or
more characters to to be transmitted.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - size
     - 2
     -
     - Size (bytes) of data to be transmitted
   * - 2
     - data
     -
     -
     - 0 or more bytes of data to be transmitted

Greybus UART Send Data Response
"""""""""""""""""""""""""""""""

The Greybus UART start transmission response contains only the status
byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus UART Receive Data Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Unlike most other Greybus UART operations, the Greybus UART event
operation is initiated by the UART device and received by the AP. It
notifies the AP that a data has been received by the UART.

Greybus UART Receive Data Request
"""""""""""""""""""""""""""""""""

The Greybus UART receive data request contains the size of the data to
be received, and the data bytes to be received.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - size
     - 2
     -
     - Size (bytes) of received data
   * - 2
     - data
     -
     -
     - 1 or more bytes of received data

Greybus UART Received Data Response
"""""""""""""""""""""""""""""""""""

The Greybus UART event response is sent by the AP to the UART device,
and contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus UART Set Line Coding Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus UART set line coding operation allows the AP to request
the UART to be set up to a specific set of line coding values.

Greybus UART Set Line Coding State Request
""""""""""""""""""""""""""""""""""""""""""

The Greybus UART set line coding state request contains the specific
line coding values to be set.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - rate
     - 4
     -
     - Baud Rate setting
   * - 4
     - format
     - 1
     -
     - Stop bit format setting
   * - 5
     - parity
     - 1
     -
     - Parity setting
   * - 6
     - data
     - 1
     -
     - Data bits setting

**Stop bit format setting**

.. list-table::
   :header-rows: 1

   * - 1 Stop Bit
     - 0x00
   * - 1.5 Stop Bits
     - 0x01
   * - 2 Stop Bits
     - 0x02
   * - (All other values reserved)
     - 0x03..0xff

**Parity setting**

.. list-table::
   :header-rows: 1

   * - No Parity
     - 0x00
   * - Odd Parity
     - 0x01
   * - Even Parity
     - 0x02
   * - Mark Parity
     - 0x03
   * - Space Parity
     - 0x04
   * - (All other values reserved)
     - 0x05..0xff

Greybus UART Set Line Coding State Response
"""""""""""""""""""""""""""""""""""""""""""

The Greybus UART set line coding state response contains only a status
byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus UART Set Control Line State Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus UART set control line state allows the AP to request the
UART device set “outbound” UART status values.

Greybus UART Set Control Line State Request
"""""""""""""""""""""""""""""""""""""""""""

The Greybus UART set modem status request contains no data beyond the
Greybus UART message header.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - control
     - 2
     -
     - Modem status flag values (see below)

This table describes the values supplied as flag values for the
Greybus UART set modem request. Any combination of these values may be
supplied in a single request.

.. list-table::
   :header-rows: 1

   * - Flag
     - Value
     - Meaning
   * - DTR
     - 0x0001
     - Data terminal ready
   * - RTS
     - 0x0002
     - Request to send
   * - (All other values reserved)
     - 0x0004..0x8000
     -

Greybus UART Set Control Line State Response
""""""""""""""""""""""""""""""""""""""""""""

The Greybus UART set control line state response contains only a
status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus UART Send Break Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus UART send break operation allows the AP to request the
UART device set the break condition on its transmit line to be either
on or off.

Greybus UART Break Control Request
""""""""""""""""""""""""""""""""""

The Greybus UART break control request supplies the duration of the
break condition that should be generated by the UART device transmit
line.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - state
     - 1
     - 0 or 1
     - 0 is off, 1 is on

Greybus UART Break Control Response
"""""""""""""""""""""""""""""""""""

The Greybus UART break control response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus UART Serial State Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Unlike most other Greybus UART operations, the Greybus UART serial
state operation is initiated by the UART device and received by the
AP. It notifies the AP that a control line status has changed, or that
there is an error with the UART.

Greybus UART Serial State Request
"""""""""""""""""""""""""""""""""

The Greybus UART serial state request contains the control value that
the UART is currently in.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - control
     - 2
     -
     - Control data state
   * - 2
     - data
     -
     -
     - 1 or more bytes of received data

**Greybus UART Control Flags**

The following table defines the flag values used for a Greybus UART
Serial State request.

.. list-table::
   :header-rows: 1

   * - Flag
     - Value
     - Meaning
   * - DCD
     - 0x0001
     - Carrier Detect line enabled
   * - DSR
     - 0x0002
     - DSR signal
   * - Break
     - 0x0004
     - Break condition detected on input
   * - RI
     - 0x0008
     - Ring Signal detection
   * - Framing error
     - 0x0010
     - Framing error detected on input
   * - Parity error
     - 0x0020
     - Parity error detected on input
   * - Overrun
     - 0x0040
     - Received data lost due to overrun
   * - (All other values reserved)
     - 0x0080..0x8000
     -

Greybus UART Serial State Response
""""""""""""""""""""""""""""""""""

The Greybus UART serial state response is sent by the AP to the UART
device, and contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

PWM Protocol
------------

A connection using PWM protocol on a |unipro| network is used to manage
a simple PWM controller. Such a PWM controller implements one or more
(up to 256) PWM devices, and each of the operations below specifies
the line to which the operation applies. This protocol consists of the
operations defined in this section.

Conceptually, the PWM protocol operations are:

::

    int get_version(u8 *major, u8 *minor);

..

    Returns the major and minor Greybus PWM protocol version number
    supported by the PWM controller. PWM controllers adhering to the
    protocol specified herein shall report major version 0, minor
    version 1.

::

    int pwm_count(u8 *count);

..

    Returns one less than the number of instances managed by the
    Greybus PWM controller. This means the minimum number of PWMs is 1
    and the maximum is 256.

::

    int activate(u8 which);

..

    Notifies the PWM controller that one of its instances has been
    assigned for use.

::

    int deactivate(u8 which);

..

    Notifies the PWM controller that a previously-activated instance
    has been unassigned and can be deactivated.

::

    int config(u8 which, u32 duty, u32 period);

..

    Requests the PWM controller configure an instance for a particular
    duty cycle and period (in units of nanoseconds).

::

    int set_polarity(u8 which, u8 polarity);

..

    Requests the PWM controller configure an instance as normally
    active or inversed.

::

    int enable(u8 which);

..

    Requests the PWM controller enable a PWM instance to begin
    toggling.

::

    int disable(u8 which);

..

    Requests the PWM controller disable a previously enabled PWM
    instance

Greybus PWM Protocol Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All operations sent to a PWM controller are contained within a Greybus
PWM request message. Every operation request will result in a response
from the PWM controller, also taking the form of a PWM controller
message.  The request and response messages for each PWM operation are
defined below.

The following table describes the Greybus PWM protocol operation types
and their values. Both the request type and response type values are
shown.

.. list-table::
   :header-rows: 1

   * - PWM Operation
     - Request Value
     - Response Value
   * - Invalid
     - 0x00
     - 0x80
   * - Protocol version
     - 0x01
     - 0x81
   * - PWM count
     - 0x02
     - 0x82
   * - Activate
     - 0x03
     - 0x83
   * - Deactivate
     - 0x04
     - 0x84
   * - Config
     - 0x05
     - 0x85
   * - Set Polarity
     - 0x06
     - 0x86
   * - Enable
     - 0x07
     - 0x87
   * - Disable
     - 0x08
     - 0x88
   * - (All other values reserved)
     - 0x09..0x7f
     - 0x89..0xff

Greybus PWM Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM version operation allows the AP to determine the
version of this protocol to which the PWM controller complies.

Greybus PWM Protocol Version Request
""""""""""""""""""""""""""""""""""""

The Greybus PWM protocol version request contains no data beyond the
Greybus PWM message header.

Greybus PWM Protocol Version Response
"""""""""""""""""""""""""""""""""""""

The Greybus PWM protocol version response contains a status byte,
followed by two 1-byte values. If the value of the status byte is
non-zero, any other bytes in the response shall be ignored. A Greybus
PWM controller adhering to the protocol specified herein shall report
major version 0, minor version 1.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure
   * - 1
     - version_major
     - 1
     - |gb-major|
     - Greybus PWM protocol major version
   * - 2
     - version_minor
     - 1
     - |gb-minor|
     - Greybus PWM protocol minor version

Greybus PWM Count Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM count operation allows the AP to determine how many
PWM instances are implemented by the PWM controller.

Greybus PWM Count Request
"""""""""""""""""""""""""

The Greybus PWM count request contains no data beyond the Greybus PWM
message header.

Greybus PWM Count Response
""""""""""""""""""""""""""

The Greybus PWM count response contains a status byte, followed by a
1-byte value defining the number of PWM instances managed by the
controller, minus 1. That is, a count value of 0 represents a single
PWM instance, while a (maximal) count value of 255 represents 256
instances. The lines are numbered sequentially starting with 0 (i.e.,
no gaps in the numbering).

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure
   * - 1
     - count
     - 1
     -
     - Number of PWM instances minus 1

Greybus PWM Activate Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM activate operation notifies the PWM controller that
one of its PWM instances has been allocated for use. This provides a
chance to do initial setup for the PWM instance, such as enabling
power and clock signals.

Greybus PWM Activate Request
""""""""""""""""""""""""""""

The Greybus PWM activate request supplies only the number of the
instance to be activated.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - which
     - 1
     -
     - Controller-relative PWM instance number

Greybus PWM Activate Response
"""""""""""""""""""""""""""""

The Greybus PWM activate response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybuf PWM Deactivate Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM instance deactivate operation notifies the PWM
controller that a previously-activated instance is no longer in use
and can be deactivated.

Greybus PWM Deactivate Request
""""""""""""""""""""""""""""""

The Greybus PWM deactivate request supplies only the number of the
instance to be deactivated.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - which
     - 1
     -
     - Controller-relative PWM instance number

Greybus PWM Deactivate Response
"""""""""""""""""""""""""""""""

The Greybus PWM deactivate response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus PWM Config Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM config operation requests the PWM controller configure
a PWM instance with the given duty cycle and period.

Greybus PWM Config Request
""""""""""""""""""""""""""

The Greybus PWM Config request supplies the target instance number,
duty cycle, and period of the cycle.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - which
     - 1
     -
     - Controller-relative PWM instance number
   * - 1
     - duty
     - 4
     -
     - Duty cycle (in nanoseconds)
   * - 5
     - period
     - 4
     -
     - Period (in nanoseconds)

Greybus PWM Config Response
"""""""""""""""""""""""""""

The Greybus PWM Config response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus PWM Polarity Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM polarity operation requests the PWM controller
configure a PWM instance with the given polarity.

Greybus PWM Polarity Request
""""""""""""""""""""""""""""

The Greybus PWM Polarity request supplies the target instance number
and polarity (normal or inversed). The polarity may not be configured
when a PWM instance is enabled and will respond with a busy failure.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - which
     - 1
     -
     - Controller-relative PWM instance number
   * - 1
     - polarity
     - 1
     -
     - 0 for normal, 1 for inversed

Greybus PWM Polarity Response
"""""""""""""""""""""""""""""

The Greybus PWM Config response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus PWM Enable Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM enable operation enables a PWM instance to begin
toggling.

Greybus PWM Enable Request
""""""""""""""""""""""""""

The Greybus PWM enable request supplies only the number of the
instance to be enabled.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - which
     - 1
     -
     - Controller-relative PWM instance number

Greybus PWM Enable Response
"""""""""""""""""""""""""""

The Greybus PWM enable response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus PWM Disable Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM disable operation stops a PWM instance that has
previously been enabled.

Greybus PWM Disable Request
"""""""""""""""""""""""""""

The Greybus PWM disable request supplies only the number of the
instance to be disabled.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - which
     - 1
     -
     - Controller-relative PWM instance number

Greybus PWM Disable Response
""""""""""""""""""""""""""""

The Greybus PWM disable response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

I2S Protocol
____________

TBD.

I2C Protocol
------------

This section defines the operations used on a connection implementing
the Greybus I2C protocol. This protocol allows an AP to manage an I2C
device present on a module. The protocol consists of five basic
operations, whose request and response message formats are defined
here.

Conceptually, the five operations in the Greybus I2C protocol are:

::

    int get_version(u8 *major, u8 *minor);

..

    Returns the major and minor Greybus i2c protocol version number
    supported by the i2c adapter.

::

    int get_functionality(u32 *functionality);

..

    Returns a bitmask indicating the features supported by the i2c
    adapter.

::

    int set_timeout(u16 timeout_ms);

..

   Sets the timeout (in milliseconds) the i2c adapter should allow
   before giving up on an addressed client.

::

    int set_retries(u8 retries);

..

   Sets the number of times an adapter should retry an i2c op before
   giving up.

::

    int transfer(u8 op_count, struct i2c_op *ops);

..

   Performs an i2c transaction made up of one or more “steps” defined
   in the supplied i2c op array.

A transfer is made up of an array of “I2C ops”, each of which
specifies an I2C slave address, flags controlling message behavior,
and a length of data to be transferred. For write requests, the data
is sent following the array of messages; for read requests, the data
is returned in a response message from the I2C adapter.

Greybus I2C Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^

This table describes the Greybus I2C operation types and their
values. A message type consists of an operation type combined with a
flag (0x80) indicating whether the operation is a request or a
response.

.. list-table::
   :header-rows: 1

   * - Descriptor Type
     - Request Value
     - Response Value
   * - Invalid
     - 0x00
     - 0x80
   * - Protocol version
     - 0x01
     - 0x81
   * - Functionality
     - 0x02
     - 0x82
   * - Timeout
     - 0x03
     - 0x83
   * - Retries
     - 0x04
     - 0x84
   * - Transfer
     - 0x05
     - 0x85
   * - (All other values reserved)
     - 0x06..0x7f
     - 0x86..0xff

Greybus I2C Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2C protocol version operation allows the AP to determine
the version of this protocol to which the I2C adapter complies.

Greybus I2C Protocol Version Request
""""""""""""""""""""""""""""""""""""

The Greybus I2C protocol version request contains no data beyond the
Greybus I2C message header.

Greybus I2C Protocol Version Response
"""""""""""""""""""""""""""""""""""""

The Greybus I2C protcol version response contains a status byte,
followed by two 1-byte values. If the value of the status byte is
non-zero, any other bytes in the response shall be ignored. A Greybus
I2C adapter adhering to the protocol specified herein shall report
major version 0, minor version 1.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure
   * - 1
     - version_major
     - 1
     - |gb-major|
     - Greybus I2C protocol major version
   * - 2
     - version_minor
     - 1
     - |gb-minor|
     - Greybus I2C protocol minor version

Greybus I2C Functionality Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2C functionality operation allows the AP to determine the
details of the functionality provided by the I2C adapter.

Greybus I2C Functionality Request
"""""""""""""""""""""""""""""""""

The Greybus I2C functionality request contains no data beyond the I2C
message header.

Greybus I2C Functionality Response
""""""""""""""""""""""""""""""""""

The Greybus I2C functionality response contains the status byte and a
4-byte value whose bits represent support or presence of certain
functionality in the I2C adapter.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure
   * - 1
     - functionality
     - 4
     -
     - Greybus I2C functionality mask (see below)

**Greybus I2C Functionality Bits**

This table describes the defined functionality bit values defined for
Greybus I2C adapters. These include a set of bits describing SMBus
capabilities.  These values are taken directly from the <linux/i2c.h>
header file.

.. list-table::
   :header-rows: 1

   * - Linux Symbol
     - Brief Description
     - Mask Value
   * - I2C_FUNC_I2C
     - Basic I2C protocol (not SMBus) support
     - 0x00000001
   * - I2C_FUNC_10BIT_ADDR
     - 10-bit addressing is supported
     - 0x00000002
   * -
     - (Reserved)
     - 0x00000004
   * - I2C_FUNC_SMBUS_PEC
     - SMBus CRC-8 byte added to transfers (PEC)
     - 0x00000008
   * - I2C_FUNC_NOSTART
     - Repeated start sequence can be skipped
     - 0x00000010
   * -
     - (Reserved range)
     - 0x00000020..0x00004000
   * - I2C_FUNC_SMBUS_BLOCK_PROC_CALL
     - SMBus block write-block read process call supported
     - 0x00008000
   * - I2C_FUNC_SMBUS_QUICK
     - SMBus write_quick command supported
     - 0x00010000
   * - I2C_FUNC_SMBUS_READ_BYTE
     - SMBus read_byte command supported
     - 0x00020000
   * - I2C_FUNC_SMBUS_WRITE_BYTE
     - SMBus write_byte command supported
     - 0x00040000
   * - I2C_FUNC_SMBUS_READ_BYTE_DATA
     - SMBus read_byte_data command supported
     - 0x00080000
   * - I2C_FUNC_SMBUS_WRITE_BYTE_DATA
     - SMBus write_byte_data command supported
     - 0x00100000
   * - I2C_FUNC_SMBUS_READ_WORD_DATA
     - SMBus read_word_data command supported
     - 0x00200000
   * - I2C_FUNC_SMBUS_WRITE_WORD_DATA
     - SMBus write_word_data command supported
     - 0x00400000
   * - I2C_FUNC_SMBUS_PROC_CALL
     - SMBus process_call command supported
     - 0x00800000
   * - I2C_FUNC_SMBUS_READ_BLOCK_DATA
     - SMBus read_block_data command supported
     - 0x01000000
   * - I2C_FUNC_SMBUS_WRITE_BLOCK_DATA
     - SMBus write_block_data command supported
     - 0x02000000
   * - I2C_FUNC_SMBUS_READ_I2C_BLOCK
     - SMBus read_i2c_block_data command supported
     - 0x04000000
   * - I2C_FUNC_SMBUS_WRITE_I2C_BLOCK
     - SMBus write_i2c_block_data command supported
     - 0x08000000
   * -
     - (All other values reserved)
     - 0x10000000..0x80000000

Greybus I2C Set Timeout Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2C set timeout operation allows the AP to set the timeout
value to be used by the I2C adapter for non-responsive slave devices.

Greybus I2C Set Timeout Request
"""""""""""""""""""""""""""""""

The Greybus I2C set timeout request contains a 16-bit value
representing the timeout to be used by an I2C adapter, expressed in
milliseconds. If the value supplied is 0, an I2C adapter-defined shall
be used.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - msec
     - 2
     -
     - Timeout period (milliseconds)

Greybus I2C Set Timeout Response
""""""""""""""""""""""""""""""""

The Greybus I2C set timeout response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus I2C Set Retries Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2C set retries operation allows the AP to set the number
of times the I2C adapter retries I2C messages.

Greybus I2C Set Retries Request
"""""""""""""""""""""""""""""""

The Greybus I2C set timeout request contains an 8-bit value
representing the number of retries to be used by an I2C adapter.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - count
     - 1
     -
     - Retry count

Greybus I2C Set Retries Response
""""""""""""""""""""""""""""""""

The Greybus I2C set retries response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure

Greybus I2C Transfer Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2C transfer operation allows the AP to request the I2C
adapter perform an I2C transaction. The operation consists of a set of
one or more “i2c ops” to be performed by the I2C adapter. The transfer
operation request will include data for each I2C op involving a write
operation.  The data will be concatenated (without padding) and will
be be sent immediately after the set of I2C op descriptors. The
transfer operation response will include data for each I2C op
involving a read operation, with all read data transferred
contiguously.

Greybus I2C Transfer Request
""""""""""""""""""""""""""""

The Greybus I2C transfer request contains a message count, an array of
message descriptors, and a block of 0 or more bytes of data to be
written.

**Greybus I2C Op**

A Greybus I2C op describes a segment of an I2C transaction.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - addr
     - 2
     -
     - Slave address
   * - 2
     - flags
     - 2
     -
     - i2c op flags
   * - 2
     - size
     - 2
     -
     - Size of data to transfer

**Greybus I2C Op Flag Bits**

This table describes the defined flag bit values defined for Greybus
I2C ops. They are taken directly from the <linux/i2c.h> header file.

.. list-table::
   :header-rows: 1

   * - Linux Symbol
     - Brief Description
     - Mask Value
   * - I2C_M_RD
     - Data is to be read (from slave to master)
     - 0x0001
   * -
     - (Reserved range)
     - 0x0002..0x0008
   * - I2C_M_TEN
     - 10-bit addressing is supported
     - 0x0010
   * -
     - (Reserved range)
     - 0x0020..0x0200
   * - I2C_M_RECV_LEN
     - First byte received contains length
     - 0x0400
   * -
     - (Reserved range)
     - 0x0800..0x2000
   * - I2C_M_NOSTART
     - Skip repeated start sequence
     - 0x4000
   * -
     - (Reserved)
     - 0x8000

Here is the structure of a Greybus I2C transfer request.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - op_count
     - 2
     - N
     - Number of I2C ops in transfer
   * - 2
     - op[1]
     - 6
     -
     - Descriptor for first I2C op in the transfer
   * -
     - ...
     -
     -
     - ...
   * - 2+6*(N-1)
     - op[N]
     - 6
     -
     - Descriptor for Nth I2C op (and so on)
   * - 2+6*N
     - (data)
     -
     -
     - Data for first write op in the transfer
   * -
     - ...
     -
     -
     - ...
   * -
     - ...
     -
     -
     - Data for last write op in the transfer

Any data to be written will follow the last op descriptor.  Data for
the first write op in the array will immediately follow the last op in
the array, and no padding shall be inserted between data sent for
distinct I2C ops.

Greybus I2C Transfer Response
"""""""""""""""""""""""""""""

The Greybus I2C transfer response contains a status byte followed by
the data read as a result of messages.  If the value of the status
byte is non-zero, the data that follows (if any) shall be ignored.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     -
     - Success, or reason for failure
   * - 1
     - (data)
     -
     -
     - Data for first read op in the transfer
   * -
     - ...
     -
     -
     - ...
   * -
     - ...
     -
     -
     - Data for last read op in the transfer

SDIO Protocol
-------------

TBD


.. Footnotes
.. =========

.. rubric:: Footnotes


.. [#bp] If the AP send out a request, it will automatically receive a
         response through CPort Rx path, right? So, the AP need to
         decode the response message to see what the message is .

.. [#bq] Yes.  The response can be as simple as acknowledging that the
         request was received, but a few request types may supply
         additional information.

.. [#br] If the response is just acknowledging that the request was
         received, it my be useless for AP to get this
         information. But, AP does not know whether it's a simple
         acknowledge or not. So, there will always an interrupt to
         notify the AP that a response messages received. Then AP will
         be busy to serve the interrupt.

.. [#bs] We have discussed having an option for sending requests
         without a response for cases where the sender really doesn't
         care.  I am only now updating the document to reflect some
         other changes; I believe the no-response option will be added
         before this is finalized.

.. [#bt] Each request can only set one line? Why cannt it set multiple
         lines with each request?

.. [#bu] Good question.  I suppose we could encode a mask of the GPIOs
         to be affected rather than just indicating a single one.


