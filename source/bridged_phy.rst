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

We support bulk, control, and interrupt transfers, but not
isochronous at this point in time.

Details TBD.

GPIO Protocol
-------------

A connection using the GPIO protocol on a |unipro| network is used to
manage a simple GPIO controller. Such a GPIO controller implements
from one to 256 GPIO lines. Each of the operations defined below
specifies the line to which the operation applies.

Conceptually, the GPIO protocol operations are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the protocol used for
    communication over the connection.  The sender offers the
    version of the protocol it supports.  The receiver replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

.. c:function:: int line_count(u8 *count);

    Returns one less than the number of lines managed by the Greybus
    GPIO controller. This means the minimum number of lines is 1 and
    the maximum is 256.

.. c:function:: int activate(u8 which);

    Notifies the GPIO controller that one of its lines has been
    assigned for use.

.. c:function:: int deactivate(u8 which);

    Notifies the GPIO controller that a previously-activated line has
    been unassigned and can be deactivated.

.. c:function:: int get_direction(u8 which, u8 *direction);

    Requests the GPIO controller return a line's configured direction
    (0 for output, 1 for input).

.. c:function:: int direction_input(u8 which);

    Requests the GPIO controller configure a line for input.

.. c:function:: int direction_output(u8 which, u8 value);

    Requests the GPIO controller configure a line for output, and sets
    its initial output value (0 for low, 1 for high).

.. c:function:: int get_value(u8 which, u8 *value);

    Requests the GPIO controller return the current value sensed on a
    line (0 for low, 1 for high).

.. c:function:: int set_value(u8 which, u8 value);

    Requests the GPIO controller set the value (0 for low, 1 for high)
    for a line configured for output.

.. c:function:: int set_debounce(u8 which, u16 usec);

    Requests the GPIO controller set the debounce period (in
    microseconds).

.. c:function:: int irq_type(u8 which, u8 type);

    Requests the GPIO controller set the IRQ trigger type (none,
    falling/rising edge, or low/high level).

.. c:function:: int irq_mask(u8 which);

    Requests the GPIO controller mask the specified gpio irq line.

.. c:function:: int irq_unmask(u8 which);

    Requests the GPIO controller unmask the specified gpio irq line.

.. c:function:: int irq_ack(u8 which);

    Requests the GPIO controller ack the specified gpio irq line.

.. c:function:: int irq_event(u8 which);

    GPIO controller request to recipient signaling an event on the specified
    gpio irq line.

Greybus GPIO Protocol Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All operations sent to a GPIO controller are contained within a
Greybus GPIO request message. Every operation request results in a
matching response from the GPIO controller, also taking the form of a
GPIO controller message.  The request and response messages for each
GPIO operation are defined below.

Table :num:`table-gpio-operation-type` defines the Greybus GPIO
protocol operation types and their values. Both the request type and
response type values are shown.

.. figtable::
    :nofig:
    :label: table-gpio-operation-type
    :caption: GPIO Operation Types
    :spec: l l l

    ===========================  =============  ==============
    GPIO Operation Type          Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Line Count                   0x02           0x82
    Activate                     0x03           0x83
    Deactivate                   0x04           0x84
    Get Direction                0x05           0x85
    Direction Input              0x06           0x86
    Direction Output             0x07           0x87
    Get                          0x08           0x88
    Set                          0x09           0x89
    Set Debounce                 0x0a           0x8a
    IRQ Type                     0x0b           0x8b
    IRQ Mask                     0x0c           0x8c
    IRQ Unmask                   0x0d           0x8d
    IRQ Ack                      0x0e           0x8e
    IRQ Event                    0x0f           0x8f
    (all other values reserved)  0x10..0x7f     0x90..0xff
    ===========================  =============  ==============

Greybus GPIO Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO protocol version operation allows the protocol
handling software on both ends of a connection to negotiate the
version of the GPIO protocol to use.

Greybus GPIO Protocol Version Request
"""""""""""""""""""""""""""""""""""""

The Greybus GPIO protocol version request message has no payload.

Greybus GPIO Protocol Version Response
""""""""""""""""""""""""""""""""""""""

The Greybus GPIO protocol version response payload contains two
one-byte values, as defined in table
:num:`table-gpio-protocol-version-response`.
A Greybus GPIO controller adhering to the protocol specified herein
shall report major version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-gpio-protocol-version-response
    :caption: GPIO Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      GPIO protocol major version
    1        version_minor   1       |gb-minor|      GPIO protocol minor version
    =======  ==============  ======  ==========      ===========================

Greybus GPIO Line Count Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO line count operation allows the requestor to
determine how many GPIO lines are implemented by the GPIO controller.

Greybus GPIO Line Count Request
"""""""""""""""""""""""""""""""

The Greybus GPIO line count request message has no payload.

Greybus GPIO Line Count Response
""""""""""""""""""""""""""""""""

Table :num:`table-gpio-line-count-response` describes the Greybus GPIO
line count response. The response contains a one-byte value defining
the number of lines managed by the controller, minus one. That is, a
count value of zero represents a single GPIO line, while a (maximal)
count value of 255 represents 256 lines. GPIOs shall be numbered
sequentially starting at zero.

.. figtable::
    :nofig:
    :label: table-gpio-line-count-response
    :caption: GPIO Protocol Line Count Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        count           1       Number          Number of GPIO lines minus 1
    =======  ==============  ======  ==========      ===========================

Greybus GPIO Activate Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO activate operation notifies the GPIO controller that
one of its GPIO lines has been allocated for use. This provides a
chance to do initial setup for the line, such as enabling power and
clock signals.

Greybus GPIO Activate Request
"""""""""""""""""""""""""""""

Table :num:`table-gpio-activate-request` defines the Greybus GPIO
activate request. The request supplies only the number of the line to
be activated.

.. figtable::
    :nofig:
    :label: table-gpio-activate-request
    :caption: GPIO Protocol Activate Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative GPIO line number
    =======  ==============  ======  ==========      ===========================

Greybus GPIO Activate Response
""""""""""""""""""""""""""""""

The Greybus GPIO activate response message has no payload.

Greybus GPIO Deactivate Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO deactivate operation notifies the GPIO controller
that a previously-activated line is no longer in use and can be
deactivated.

Greybus GPIO Deactivate Request
"""""""""""""""""""""""""""""""

Table :num:`table-gpio-deactivate-request` defines the Greybus GPIO
deactivate request. The request supplies only the number of the line
to be deactivated.

.. figtable::
    :nofig:
    :label: table-gpio-deactivate-request
    :caption: GPIO Protocol Deactivate Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative GPIO line number
    =======  ==============  ======  ==========      ===========================

Greybus Deactivate Response
"""""""""""""""""""""""""""

The Greybus GPIO deactivate response message has no payload.

Greybus GPIO Get Direction Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO get direction operation requests the GPIO controller
respond with the direction of transfer (in or out) for which a line is
configured.

Greybus GPIO Get Direction Request
""""""""""""""""""""""""""""""""""

Table :num:`table-gpio-get-direction-request` defines the Greybus GPIO
get direction request. The request supplies only the target line number.

.. figtable::
    :nofig:
    :label: table-gpio-get-direction-request
    :caption: GPIO Protocol Get Direction Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative GPIO line number
    =======  ==============  ======  ==========      ===========================

Greybus GPIO Get Direction Response
"""""""""""""""""""""""""""""""""""

Table :num:`table-gpio-get-direction-response` defines the Greybus
GPIO get direction response. The response contains one byte
indicating whether the line in question is configured for input or
output.

.. figtable::
    :nofig:
    :label: table-gpio-get-direction-response
    :caption: GPIO Protocol Get Direction Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        direction       1       0 or 1          Direction
    =======  ==============  ======  ==========      ===========================

*direction* is 0 for output, and 1 for input.

Greybus GPIO Direction Input Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO direction input operation requests the GPIO
controller to configure a line to be used for input.

Greybus GPIO Direction Input Request
""""""""""""""""""""""""""""""""""""

Table :num:`table-gpio-direction-input-request` defines the Greybus
GPIO direction input request. The request supplies only the number of
the line.

.. figtable::
    :nofig:
    :label: table-gpio-direction-input-request
    :caption: GPIO Protocol Direction Input Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative GPIO line number
    =======  ==============  ======  ==========      ===========================

Greybus GPIO Direction Input Response
"""""""""""""""""""""""""""""""""""""

The Greybus GPIO direction input response message has no payload.

Greybus GPIO Direction Output Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO direction output operation requests the GPIO
controller to configure a line to be used for output, and specifies
its initial value.

Greybus GPIO Direction Output Request
"""""""""""""""""""""""""""""""""""""

Table :num:`table-gpio-direction-output-request` defines the Greybus
GPIO direction output request. The request supplies the number of the
line and its initial value.

.. figtable::
    :nofig:
    :label: table-gpio-direction-output-request
    :caption: GPIO Protocol Direction Output Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative GPIO line number
    1        value           1       0 or 1          Initial value
    =======  ==============  ======  ==========      ===========================

For the *value* field, 0 is low, and 1 is high.

Greybus GPIO Direction Output Response
""""""""""""""""""""""""""""""""""""""

The Greybus GPIO direction output response message has no payload.

Greybus GPIO Get Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO get operation requests the GPIO controller respond
with the current value (high or low) on a line.

Greybus GPIO Get Request
""""""""""""""""""""""""

Table :num:`table-gpio-get-request` defines the Greybus GPIO get
request. The request supplies only the target line number.

.. figtable::
    :nofig:
    :label: table-gpio-get-request
    :caption: GPIO Protocol Get Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative GPIO line number
    =======  ==============  ======  ==========      ===========================

Greybus GPIO Get Response
"""""""""""""""""""""""""

Table :num:`table-gpio-get-response` defines the Greybus GPIO get
response. The response contains one byte indicating the value on the
line in question.

.. figtable::
    :nofig:
    :label: table-gpio-get-response
    :caption: GPIO Protocol Get Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        value           1       0 or 1          Value
    =======  ==============  ======  ==========      ===========================

*value* is 0 for low, and 1 for high.

Greybus GPIO Set Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO set operation requests the GPIO controller to set a
line configured to be used for output to have either a low or high
value.

Greybus GPIO Set Request
""""""""""""""""""""""""

Table :num:`table-gpio-set-request` defines the Greybus GPIO set
request. The request supplies the number of the line and the value to
be set.

.. figtable::
    :nofig:
    :label: table-gpio-set-request
    :caption: GPIO Protocol Set Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative GPIO line number
    1        value           1       0 or 1          Initial value
    =======  ==============  ======  ==========      ===========================

.. todo::
    Possibly make this a mask to allow multiple values to be set at once.

For the *value* field, 0 is low, and 1 is high.

Greybus GPIO Set Response
"""""""""""""""""""""""""

The Greybus GPIO set response message has no payload.

Greybus GPIO Set Debounce Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO set debounce operation requests the GPIO controller
to set the debounce delay configured to be used for a line.

Greybus GPIO Set Debounce Request
"""""""""""""""""""""""""""""""""

Table :num:`table-gpio-set-debounce-request` defines the Greybus GPIO
set debounce request. The request supplies the number of the line and
the time period (in microseconds) to be used for the line.  If the
period specified is 0, debounce is disabled.

.. figtable::
    :nofig:
    :label: table-gpio-set-debounce-request
    :caption: GPIO Protocol Set Debounce Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative GPIO line number
    1        usec            2       Number          Debounce period (microseconds)
    =======  ==============  ======  ==========      ===========================

Greybus GPIO Set Debounce Response
""""""""""""""""""""""""""""""""""

The Greybus GPIO set debounce response message has no payload.

Greybus GPIO IRQ Type Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO IRQ type operation requests the GPIO controller
to set the interrupt trigger type to be used for a line.

Greybus GPIO IRQ Type Request
"""""""""""""""""""""""""""""

Table :num:`table-gpio-irq-type-request` defines the Greybus GPIO IRQ
type request.  This request supplies the number of the line and the type
to be used for the line.

.. figtable::
    :nofig:
    :label: table-gpio-irq-type-request
    :caption: GPIO IRQ Type Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative GPIO line number
    1        type            4       Number          :ref:`gpio-irq-type-bits`
    =======  ==============  ======  ==========      ===========================

.. _gpio-irq-type-bits:

Greybus GPIO IRQ Type Bits
""""""""""""""""""""""""""

Table :num:`table-gpio-irq-type-bits` describes the defined interrupt
trigger type bit values defined for Greybus GPIO IRQ chips. These values
are taken directly from the <linux/interrupt.h> header file. Only a
single trigger type is valid, a mask of two or more values results
in a *GB_OP_INVALID* response.

.. figtable::
    :nofig:
    :label: table-gpio-irq-type-bits
    :caption: GPIO IRQ Type Bits
    :spec: l l l

    ===============================  ===================================================  ========================
    Linux Symbol                     Brief Description                                    Value
    ===============================  ===================================================  ========================
    IRQF_TRIGGER_NONE                No trigger specified, uses default/previous setting  0x00000000
    IRQF_TRIGGER_RISING              Rising edge triggered                                0x00000001
    IRQF_TRIGGER_FALLING             Falling edge triggered                               0x00000002
    IRQF_TRIGGER_HIGH                Level triggered high                                 0x00000004
    IRQF_TRIGGER_LOW                 Level triggered low                                  0x00000008
    |_|                              (All other values reserved)                          0x00000010..0x80000000
    ===============================  ===================================================  ========================

Greybus GPIO IRQ Type Response
""""""""""""""""""""""""""""""

The Greybus GPIO IRQ type response message has no payload.

Greybus GPIO IRQ Mask Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO IRQ mask operation requests the GPIO controller to
mask a GPIO IRQ line.

Greybus GPIO IRQ Mask Request
""""""""""""""""""""""""""""""

Table :num:`table-gpio-irq-mask-request` defines the Greybus GPIO IRQ
mask request.  This request supplies the number of the line to be
masked.

.. figtable::
    :nofig:
    :label: table-gpio-irq-mask-request
    :caption: GPIO IRQ Mask Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative GPIO line number
    =======  ==============  ======  ==========      ===========================

Greybus GPIO IRQ Mask Response
""""""""""""""""""""""""""""""

The Greybus GPIO IRQ mask response message has no payload.

Greybus GPIO IRQ Unmask Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO IRQ unmask operation requests the GPIO controller to
unmask a GPIO IRQ line.

Greybus GPIO IRQ Unmask Request
"""""""""""""""""""""""""""""""

Table :num:`table-gpio-irq-unmask-request` defines the Greybus GPIO IRQ
unmask request.  This request supplies the number of the line to be
unmasked.

.. figtable::
    :nofig:
    :label: table-gpio-irq-unmask-request
    :caption: GPIO IRQ Mask Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative GPIO line number
    =======  ==============  ======  ==========      ===========================

Greybus GPIO IRQ Unmask Response
""""""""""""""""""""""""""""""""

The Greybus GPIO IRQ unmask response message has no payload.

Greybus GPIO IRQ Ack Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO IRQ ack operation requests the GPIO controller to ack
a GPIO IRQ line.

Greybus GPIO IRQ Ack Request
""""""""""""""""""""""""""""

Table :num:`table-gpio-irq-ack-request` defines the Greybus GPIO IRQ Ack
request.  This request supplies the number of the line to be acked.

.. figtable::
    :nofig:
    :label: table-gpio-irq-ack-request
    :caption: GPIO IRQ Mask Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative GPIO line number
    =======  ==============  ======  ==========      ===========================

Greybus GPIO IRQ Ack Response
"""""""""""""""""""""""""""""

The Greybus GPIO IRQ Ack response message has no payload.

Greybus GPIO IRQ Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO IRQ event operation signals to the recipient that a
GPIO IRQ event has occurred on the GPIO Controller.

Greybus GPIO IRQ Event Request
""""""""""""""""""""""""""""""

Table :num:`table-gpio-irq-event-request` defines the Greybus GPIO IRQ
Event request.  This request supplies the number of the line signaling
an event.

.. figtable::
    :nofig:
    :label: table-gpio-irq-event-request
    :caption: GPIO IRQ Event Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative GPIO line number
    =======  ==============  ======  ==========      ===========================

Greybus GPIO IRQ Event Response
"""""""""""""""""""""""""""""""

The Greybus GPIO IRQ event response message has no payload.

SPI Protocol
------------

This section defines the operations used on a connection implementing
the Greybus SPI protocol. This protocol allows for management of a SPI
device. The protocol consists of the operations defined in this
section.

Conceptually, the operations in the Greybus SPI protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the protocol used for
    communication over the connection.  The sender offers the
    version of the protocol it supports.  The receiver replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

.. c:function:: int get_mode(u16 *mode);

    Returns a bit mask indicating the modes supported by the SPI master.

.. c:function:: int get_flags(u16 *flags);

    Returns a bit mask indicating the constraints of the SPI master.

.. c:function:: int get_bits_per_word(u32 *bpw);

    Returns the number of bits per word supported by the SPI master.

.. c:function:: int get_chipselect_num(u16 *num);

    Returns the number of chip select pins supported by the SPI master.

.. c:function:: int transfer(u8 chip_select, u8 mode, u8 count, struct gb_spi_transfer *transfers);

    Performs a SPI transaction as one or more SPI transfers, defined in the
    supplied array.

A transfer is made up of an array of gb_spi_transfer descriptors, each of which
specifies SPI master configurations during transfers. For write requests, the
data is sent following the array of messages; for read requests, the data is
returned in a response message from the SPI master.

Greybus SPI Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-spi-operation-type` defines the Greybus SPI
operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-spi-operation-type
    :caption: SPI Protocol Operation Types
    :spec: l l l

    ===========================  =============  ==============
    SPI Operation Type           Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Mode                         0x02           0x82
    Flags                        0x03           0x83
    Bits per word mask           0x04           0x84
    Number of Chip select pins   0x05           0x85
    Transfer                     0x06           0x86
    (all other values reserved)  0x07..0x7f     0x87..0xff
    ===========================  =============  ==============

Greybus SPI Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SPI protocol version operation allows the protocol
handling software on both ends of a connection to negotiate the
version of the SPI protocol to use.

Greybus SPI Protocol Version Request
""""""""""""""""""""""""""""""""""""

The Greybus SPI protocol version request message has no payload.

Greybus SPI Protocol Version Response
"""""""""""""""""""""""""""""""""""""

The Greybus SPI protocol version response payload contains two
one-byte values, as defined in table
:num:`table-spi-protocol-version-response`.
A Greybus SPI controller adhering to the protocol specified herein
shall report major version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-spi-protocol-version-response
    :caption: SPI Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      SPI protocol major version
    1        version_minor   1       |gb-minor|      SPI protocol minor version
    =======  ==============  ======  ==========      ===========================

Greybus SPI Protocol Mode Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SPI mode operation allows the requestor to determine the
details of the modes supported by the SPI master.

Greybus SPI Protocol Mode Request
"""""""""""""""""""""""""""""""""

The Greybus SPI mode request message has no payload.

Greybus SPI Protocol Mode Response
""""""""""""""""""""""""""""""""""

Table :num:`table-spi-mode-response` defines the Greybus SPI mode
response. The response contains a two-byte value whose bits
represent support or presence of certain modes in the SPI master.

.. figtable::
    :nofig:
    :label: table-spi-mode-response
    :caption: SPI Protocol Mode Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        mode            2       Bit Mask        :ref:`spi-mode-bits`
    =======  ==============  ======  ==========      ===========================

.. _spi-mode-bits:

Greybus SPI Protocol Mode Bit Masks
"""""""""""""""""""""""""""""""""""

Table :num:`table-spi-mode` defines the mode bit masks for Greybus SPI
masters.

.. figtable::
    :nofig:
    :label: table-spi-mode
    :caption: SPI Protocol Mode Bit Masks
    :spec: l l l

    ===============================  ======================================================  ========================
    Symbol                           Brief Description                                       Mask Value
    ===============================  ======================================================  ========================
    GB_SPI_MODE_CPHA                 Clock phase (0: sample on first clock, 1: on second)    0x0001
    GB_SPI_MODE_CPOL                 Clock polarity (0: clock low on idle, 1: high on idle)  0x0002
    GB_SPI_MODE_CS_HIGH              Chip select active high                                 0x0004
    GB_SPI_MODE_LSB_FIRST            Per-word bits-on-wire                                   0x0008
    GB_SPI_MODE_3WIRE                SI/SO signals shared                                    0x0010
    GB_SPI_MODE_LOOP                 Loopback mode                                           0x0020
    GB_SPI_MODE_NO_CS                One dev/bus, no chip select                             0x0040
    GB_SPI_MODE_READY                Slave pulls low to pause                                0x0080
    |_|                              (All other mask values reserved)                        0x0100..0x8000
    ===============================  ======================================================  ========================

Greybus SPI Protocol Flags Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SPI flags operation allows the requestor to determine the
constraints, if any, of the SPI master.

Greybus SPI Protocol Flags Request
""""""""""""""""""""""""""""""""""

The Greybus SPI flags request message has no payload.

Greybus SPI Protocol Flags Response
"""""""""""""""""""""""""""""""""""

Table :num:`table-spi-flags-response` defines the Greybus SPI flags
response. The response contains a two-byte value whose bits
represent constraints of the SPI master, if any.

.. figtable::
    :nofig:
    :label: table-spi-flags-response
    :caption: SPI Protocol Flags Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        flags           2       Number          :ref:`spi-flags-bits`
    =======  ==============  ======  ==========      ===========================

.. _spi-flags-bits:

Greybus SPI Protocol Flags Bit Masks
""""""""""""""""""""""""""""""""""""

Table :num:`table-spi-flag` describes the defined flags bit masks
defined for Greybus SPI masters.

.. figtable::
    :nofig:
    :label: table-spi-flag
    :caption: SPI Protocol Flags
    :spec: l l l

    ===============================  ===================================================  ========================
    Symbol                           Brief Description                                    Mask Value
    ===============================  ===================================================  ========================
    GB_SPI_FLAG_HALF_DUPLEX          Can't do full duplex                                 0x0001
    GB_SPI_FLAG_NO_RX                Can't do buffer read                                 0x0002
    GB_SPI_FLAG_NO_TX                Can't do buffer write                                0x0004
    |_|                              (All other flag values reserved)                     0x0008..0x8000
    ===============================  ===================================================  ========================

Greybus SPI Protocol Bits Per Word Mask Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SPI bits per word mask operation allows the requestor to
determine the mask indicating which values of bits_per_word are
supported by the SPI master. If set, transfer with unsupported
bits_per_word should be rejected. If not set, this value is simply
ignored, and it's up to the individual driver to perform any validation.

Transfers should be rejected if following expression evaluates to zero:

        master->bits_per_word_mask & (1 << (tx_desc->bits_per_word - 1))

Greybus SPI Protocol Bits Per Word Mask Request
"""""""""""""""""""""""""""""""""""""""""""""""

The Greybus SPI bits per word mask request message has no payload.

Greybus SPI Protocol Bits Per Word Mask Response
""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-spi-bits-per-word-response` defines the Greybus SPI
bits per word mask response. The response contains a four-byte value
whose bits represent the bits per word mask of the SPI master.

.. figtable::
    :nofig:
    :label: table-spi-bits-per-word-response
    :caption: SPI Protocol Bits Per Word Mask Response
    :spec: l l c c l

    =======  ==================   ======  ==========      ===========================
    Offset   Field                Size    Value           Description
    =======  ==================   ======  ==========      ===========================
    0        bits per word mask   4       Number          Bits per word mask of the SPI master
    =======  ==================   ======  ==========      ===========================

Greybus SPI Protocol Number of Chip Selects Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SPI number of chip selects operation allows the requestor
to determine the maximum number of chip select pins supported by SPI
master.

Greybus SPI Protocol Number of Chip Selects Request
"""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus SPI number of chip selects request message has no payload.

Greybus SPI Protocol Number of Chip Selects Response
""""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-spi-number-of-chip-selects-response` defines the
Greybus SPI number of chip selects response. The response contains
the maximum number of chip select pins supported by the SPI master.

.. figtable::
    :nofig:
    :label: table-spi-number-of-chip-selects-response
    :caption: SPI Protocol Number of Chip Selects Response
    :spec: l l c c l

    =======  ======================   ======  ==========      ===========================
    Offset   Field                    Size    Value           Description
    =======  ======================   ======  ==========      ===========================
    0        number of chip selects   2       Number          Maximum number of chip select pins
    =======  ======================   ======  ==========      ===========================

Greybus SPI Transfer Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SPI transfer operation requests that the SPI master
perform a SPI transaction. The operation consists of a set of one or
more gb_spi_transfer descriptors, which define data transfers to be
performed by the SPI master. The transfer operation request includes
data for each :ref:`gb_spi_transfer <gb_spi_transfer>` descriptor
involving a write operation.  The data shall be sent immediately
following the gb_spi_transfer descriptors (with no intervening pad
bytes).  The transfer operation response includes data for each
gb_spi_transfer descriptor involving a read operation, with all read
data transferred contiguously.

Greybus SPI Transfer Request
""""""""""""""""""""""""""""

The Greybus SPI transfer request contains the slave's chip select pin,
its mode, a count of message descriptors, an array of message descriptors,
and a block of zero or more bytes of data to be written.

.. _gb_spi_transfer:

**Greybus SPI gb_spi_transfer descriptor**

Table :num:`table-spi-transfer-descriptor` defines the Greybus SPI
gb_spi_transfer descriptor. This describes the configuration of a segment
of a SPI transaction.

.. figtable::
    :nofig:
    :label: table-spi-transfer-descriptor
    :caption: SPI Protocol gb_spi_transfer descriptor
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        speed_hz        4       Number          Transfer speed in Hz
    4        len             4       Number          Size of data to transfer
    8        delay_usecs     2       Number          Wait period after completion of transfer
    10       cs_change       1       Number          Toggle chip select pin after this transfer completes
    11       bits_per_word   1       Number          Select bits per word for this trnasfer
    =======  ==============  ======  ==========      ===========================

Table :num:`table-spi-transfer-request` defines the Greybus SPI
transfer request.

.. figtable::
    :nofig:
    :label: table-spi-transfer-request
    :caption: SPI Protocol Transfer Request
    :spec: l l c c l

    ==========     ==============  ======    ======================    ===========================
    Offset         Field           Size      Value                     Description
    ==========     ==============  ======    ======================    ===========================
    0              chip-select     1         Number                    chip-select pin for the slave device
    1              mode            1         Number                    :ref:`spi-mode-bits`
    2              count           2         Number                    Number of gb_spi_transfer descriptors
    4              transfers[0]    12        struct gb_spi_transfer    First SPI gb_spi_transfer descriptor in the transfer
    ...            ...             12        struct gb_spi_transfer    ...
    4+12*(N)       op[N]           12        struct gb_spi_transfer    Nth SPI gb_spi_transfer descriptor
    4+12*(N+1)     data            ...       Data                      Data for all the write transfers
    ==========     ==============  ======    ======================    ===========================

Any data to be written follows the last gb_spi_transfer descriptor. Data for
the first write gb_spi_transfer descriptor in the array immediately follows
the last gb_spi_transfer descriptor in the array, and no padding shall be
inserted between data sent for distinct SPI gb_spi_transfer descriptors.

Greybus SPI Transfer Response
"""""""""""""""""""""""""""""

Table :num:`table-spi-transfer-response` defines the Greybus SPI
transfer response. The response contains the data read as a result
of the request.

.. figtable::
    :nofig:
    :label: table-spi-transfer-response
    :caption: SPI Protocol Transfer Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ======================================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ======================================
    0        data                    Data            Data for first read gb_spi_transfer descriptor on the transfer
    ...      ...             ...     Data            ...
    ...      ...             ...     Data            Data for Nth read gb_spi_transfer descriptor on the transfer
    =======  ==============  ======  ==========      ======================================


UART Protocol
-------------

A connection using the UART protocol on a |unipro| network is used to
manage a simple UART controller.  This protocol is very close to the
CDC protocol for serial modems from the USB-IF specification, and
consists of the operations defined in this section.

The operations that can be performed on a Greybus UART controller are
conceptually:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the protocol used for
    communication over the connection.  The sender offers the
    version of the protocol it supports.  The receiver replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

.. c:function:: int send_data(u16 size, u8 *data);

    Requests that the UART device begin transmitting characters. One
    or more bytes to be transmitted shall be supplied by the sender.

.. c:function:: int receive_data(u16 *size, u8 *data);

    Receive data from the UART.  The indicated number of bytes has
    been received.

.. c:function:: int set_line_coding(u32 rate, u8 format, u8 parity, u8 data);

   Sets the line settings of the UART to the specified baud rate,
   format, parity, and data bits.

.. c:function:: int set_control_line_state(u8 state);

    Controls RTS and DTR line states of the UART.

.. c:function:: int send_break(u8 state);

    Requests that the UART generate a break condition on its transmit
    line.

.. c:function:: int serial_state(u16 *state);

    Receives the state of the UART's control lines and any line errors
    that might have occurred.

UART Protocol Operations
^^^^^^^^^^^^^^^^^^^^^^^^

This section defines the operations for a connection using the UART
protocol. The UART protocol allows a requestor to control a UART device
contained within a Greybus module.

Greybus UART Protocol Operations
""""""""""""""""""""""""""""""""

Table :num:`table-uart-operation-type` defines the Greybus
UART operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-uart-operation-type
    :caption: UART Operation Types
    :spec: l l l

    ===========================  =============  ==============
    UART Operation Type          Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Send Data                    0x02           0x82
    Receive Data                 0x03           0x83
    Set Line Coding              0x04           0x84
    Set Control Line State       0x05           0x85
    Send Break                   0x06           0x86
    Serial State                 0x07           0x87
    (all other values reserved)  0x08..0x7f     0x88..0xff
    ===========================  =============  ==============

Greybus UART Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus UART protocol version operation allows the protocol
handling software on both ends of a connection to negotiate the
version of the UART protocol to use.

Greybus UART Protocol Version Request
"""""""""""""""""""""""""""""""""""""

The Greybus UART protocol version request message has no payload.

Greybus UART Protocol Version Response
""""""""""""""""""""""""""""""""""""""

The Greybus UART protocol version response payload contains two
one-byte values, as defined in table
:num:`table-uart-protocol-version-response`.
A Greybus UART controller adhering to the protocol specified herein
shall report major version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-uart-protocol-version-response
    :caption: UART Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      UART protocol major version
    1        version_minor   1       |gb-minor|      UART protocol minor version
    =======  ==============  ======  ==========      ===========================

Greybus UART Send Data Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus UART Send Data operation requests that the UART
device begin transmission of characters.  One or more characters to be
transmitted may optionally be provided with this request.

Greybus UART Send Data Request
""""""""""""""""""""""""""""""

Table :num:`table-uart-send-data-request` defines the Greybus UART
send data request. This requests that the UART device begin
transmitting.  The request optionally contains one or more characters
to to be transmitted.

.. figtable::
    :nofig:
    :label: table-uart-send-data-request
    :caption: UART Protocol Send Data Request
    :spec: l l c c l

    =======  ==============  ======  ===========     ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ===========     ===========================
    0        size            2       Number          Size in bytes of data to be transmitted
    2        data            size    Characters      0 or more bytes of data to be transmitted
    =======  ==============  ======  ===========     ===========================

Greybus UART Send Data Response
"""""""""""""""""""""""""""""""

The Greybus UART send data response message has no payload.

Greybus UART Receive Data Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Unlike most other Greybus UART operations, the Greybus UART event
operation is initiated by the device implementing the UART
protocol. It notifies its peer that a data has been received by the
UART.

Greybus UART Receive Data Request
"""""""""""""""""""""""""""""""""

Table :num:`table-uart-receive-data-request` defines the Greybus UART
receive data request. The request contains the size of the data to be
received, and the data bytes to be received.

.. figtable::
    :nofig:
    :label: table-uart-receive-data-request
    :caption: UART Protocol Receive Data Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        size            2       Number          Size in bytes of received data
    2        data            size    Characters      1 or more bytes of received data
    =======  ==============  ======  ==========      ===========================

Greybus UART Received Data Response
"""""""""""""""""""""""""""""""""""

The Greybus UART event response message has no payload.

Greybus UART Set Line Coding Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus UART set line coding operation allows for configuration of
the UART to a specific set of line coding values.

Greybus UART Set Line Coding State Request
""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-uart-set-line-coding-request` defines the Greybus
UART set line coding state request. The request contains the specific
line coding values to be set.

.. figtable::
    :nofig:
    :label: table-uart-set-line-coding-request
    :caption: UART Protocol Set Line Coding State Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        rate            4       Number          Baud Rate setting
    4        format          1       Number          :ref:`uart-stop-bit-format`
    5        parity          1       Number          :ref:`uart-parity-format`
    6        data_bits       1       Number          Number of data bits
    =======  ==============  ======  ==========      ===========================

.. _uart-stop-bit-format:

Greybus UART Stop Bit Format
""""""""""""""""""""""""""""

Table :num:`table-uart-stop-bit-format` defines the Greybus UART stop
bit formats.

.. figtable::
    :nofig:
    :label: table-uart-stop-bit-format
    :caption: UART Protocol Stop Bit Format
    :spec: l l

    ==============================  ====
    1 Stop Bit                      0x00
    1.5 Stop Bits                   0x01
    2 Stop Bits                     0x02
    (All other values reserved)     0x03..0xff
    ==============================  ====

.. _uart-parity-format:

Greybus UART Parity format
""""""""""""""""""""""""""

Table :num:`table-uart-parity-format` defines the Greybus UART parity
formats.

.. figtable::
    :nofig:
    :label: table-uart-parity-format
    :caption: UART Protocol Parity Format
    :spec: l l

    ==============================  ====
    No Parity                       0x00
    Odd Parity                      0x01
    Even Parity                     0x02
    Mark Parity                     0x03
    Space Parity                    0x04
    (All other values reserved)     0x05..0xff
    ==============================  ====

Greybus UART Set Line Coding State Response
"""""""""""""""""""""""""""""""""""""""""""

The Greybus UART set line coding state response message has no payload.

Greybus UART Set Control Line State Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus UART set control line state operation requests that the
UART device set "outbound" UART status values.

Greybus UART Set Control Line State Request
"""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-uart-set-control-line-state-request` defines the
Greybus UART set control line state request. The request contains a
bit mask of modem status flags to set.

.. figtable::
    :nofig:
    :label: table-uart-set-control-line-state-request
    :caption: UART Protocol Set Control Line State Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        control         2       Bit mask        :ref:`uart-modem-status-flags`
    =======  ==============  ======  ==========      ===========================

.. _uart-modem-status-flags:

Greybus UART Modem Status Flags
"""""""""""""""""""""""""""""""

Table :num:`table-uart-modem-status-flags` defines the values supplied
as flag values for the Greybus UART set control line state
request. Any combination of these values may be supplied in a single
request.

.. figtable::
    :nofig:
    :label: table-uart-modem-status-flags
    :caption: UART Modem Status Flags
    :spec: l l l

    ============================    ==============  ===================
    Flag                            Value           Description
    ============================    ==============  ===================
    DTR                             0x0001          Data Terminal Ready
    RTS                             0x0002          Request To Send
    (all other values reserved)     0x0004..0x8000
    ============================    ==============  ===================

Greybus UART Set Control Line State Response
""""""""""""""""""""""""""""""""""""""""""""

The Greybus UART set control line state response message has no
payload.

Greybus UART Send Break Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus UART send break operation requests that the UART device
set the break condition on its transmit line to be either on or off.

Greybus UART Break Control Request
""""""""""""""""""""""""""""""""""

Table :num:`table-uart-break-control-request` defines the Greybus UART
break control request. The requestq supplies the duration of the break
condition that should be generated by the UART device transmit line.

.. figtable::
    :nofig:
    :label: table-uart-break-control-request
    :caption: UART Protocol Break Control Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        state           1       0 or 1          0 is off, 1 is on
    =======  ==============  ======  ==========      ===========================

Greybus UART Break Control Response
"""""""""""""""""""""""""""""""""""

The Greybus UART break control response message has no payload.

Greybus UART Serial State Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Unlike most other Greybus UART operations, the Greybus UART serial
state operation is initiated by the module implementing the UART
protocol. It notifies the peer that a control line status has changed,
or that there is an error with the UART.

Greybus UART Serial State Request
"""""""""""""""""""""""""""""""""

Table :num:`table-uart-serial-state-request` defines the Greybus UART
serial state request. The request contains the control value that the
UART is currently in.

.. figtable::
    :nofig:
    :label: table-uart-serial-state-request
    :caption: UART Protocol Serial State Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        control         2       Number          Control data state
    2        data            2       Number          :ref:`uart-control-flags`
    =======  ==============  ======  ==========      ===========================

.. _uart-control-flags:

Greybus UART Control Flags
""""""""""""""""""""""""""

Table :num:`table-uart-control-flags` defines the flag values used for
a Greybus UART serial state request.

.. figtable::
    :nofig:
    :label: table-uart-control-flags
    :caption: UART Control Flags
    :spec: l l l

    ============================    ==============  ===================
    Flag                            Value           Description
    ============================    ==============  ===================
    DCD                             0x0001          Carrier Detect line enabled
    DSR                             0x0002          DSR signal
    Break                           0x0004          Break condition detected
    RI                              0x0008          Ring Signal detected
    Framing Error                   0x0010          Framing error detected
    Parity Error                    0x0020          Parity error detected
    Overrun                         0x0040          Received data lost due to overrun
    (all other values reserved)     0x0080..0x8000
    ============================    ==============  ===================

Greybus UART Serial State Response
""""""""""""""""""""""""""""""""""

The Greybus UART serial state response message has no payload.

PWM Protocol
------------

A connection using PWM protocol on a |unipro| network is used to manage
a simple PWM controller. Such a PWM controller implements one or more
(up to 256) PWM devices, and each of the operations below specifies
the line to which the operation applies. This protocol consists of the
operations defined in this section.

Conceptually, the PWM protocol operations are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the protocol used for
    communication over the connection.  The sender offers the
    version of the protocol it supports.  The receiver replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

.. c:function:: int pwm_count(u8 *count);

    Returns one less than the number of instances managed by the
    Greybus PWM controller. This means the minimum number of PWMs is 1
    and the maximum is 256.

.. c:function:: int activate(u8 which);

    Notifies the PWM controller that one of its instances has been
    assigned for use.

.. c:function:: int deactivate(u8 which);

    Notifies the PWM controller that a previously-activated instance
    has been unassigned and can be deactivated.

.. c:function:: int config(u8 which, u32 duty, u32 period);

    Requests the PWM controller configure an instance for a particular
    duty cycle and period (in units of nanoseconds).

.. c:function:: int set_polarity(u8 which, u8 polarity);

    Requests the PWM controller configure an instance as normally
    active or inverted.

.. c:function:: int enable(u8 which);

    Requests the PWM controller enable a PWM instance to begin
    toggling.

.. c:function:: int disable(u8 which);

    Requests the PWM controller disable a previously enabled PWM
    instance

Greybus PWM Protocol Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All operations sent to a PWM controller are contained within a Greybus
PWM request message. Every operation request results in a response
from the PWM controller, also taking the form of a PWM controller
message.  The request and response messages for each PWM operation are
defined below.

The following table describes the Greybus PWM protocol operation types
and their values. Both the request type and response type values are
shown.

.. figtable::
    :nofig:
    :label: table-gpio-operation-type
    :caption: GPIO Operation Types
    :spec: l l l

    ===========================  =============  ==============
    PWM Operation Type           Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    PWM count                    0x02           0x82
    Activate                     0x03           0x83
    Deactivate                   0x04           0x84
    Config                       0x05           0x85
    Set Polarity                 0x06           0x86
    Enable                       0x07           0x87
    Disable                      0x08           0x88
    (all other values reserved)  0x09..0x7f     0x89..0xff
    ===========================  =============  ==============

Greybus PWM Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM protocol version operation allows the protocol
handling software on both ends of a connection to negotiate the
version of the PWM protocol to use.

Greybus PWM Protocol Version Request
""""""""""""""""""""""""""""""""""""

The Greybus PWM protocol version request message has no payload.

Greybus PWM Protocol Version Response
"""""""""""""""""""""""""""""""""""""

The Greybus PWM protocol version response payload contains two
one-byte values, as defined in table
:num:`table-pwm-protocol-version-response`.
A Greybus PWM controller adhering to the protocol specified herein
shall report major version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-pwm-protocol-version-response
    :caption: PWM Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      PWM protocol major version
    1        version_minor   1       |gb-minor|      PWM protocol minor version
    =======  ==============  ======  ==========      ===========================

Greybus PWM Count Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM count operation allows the requestor to determine how
many PWM instances are implemented by the PWM controller.

Greybus PWM Count Request
"""""""""""""""""""""""""

The Greybus PWM count request message has no payload.

Greybus PWM Count Response
""""""""""""""""""""""""""

Table :num:`table-pwm-count-response` defines the Greybus PWM count
response. The response contains a one-byte value defining the number
of PWM instances managed by the controller, minus one. That is, a
count value of zero represents a single PWM instance, while a
(maximal) count value of 255 represents 256 instances. The lines are
numbered sequentially starting at zero.

.. figtable::
    :nofig:
    :label: table-pwm-count-response
    :caption: PWM Protocol Count Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        count           1       Number          Number of PWM instances minus 1
    =======  ==============  ======  ==========      ===========================

Greybus PWM Activate Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM activate operation notifies the PWM controller that
one of its PWM instances has been allocated for use. This provides a
chance to do initial setup for the PWM instance, such as enabling
power and clock signals.

Greybus PWM Activate Request
""""""""""""""""""""""""""""

Table :num:`table-pwm-activate-request` defines the Greybus PWM
activate request. The request supplies only the number of the instance
to be activated.

.. figtable::
    :nofig:
    :label: table-pwm-activate-request
    :caption: PWM Protocol Activate Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative PWM instance number
    =======  ==============  ======  ==========      ===========================

Greybus PWM Activate Response
"""""""""""""""""""""""""""""

The Greybus PWM activate response message has no payload.

Greybuf PWM Deactivate Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM instance deactivate operation notifies the PWM
controller that a previously-activated instance is no longer in use
and can be deactivated.

Greybus PWM Deactivate Request
""""""""""""""""""""""""""""""

Table :num:`table-pwm-deactivate-request` defines the Greybus PWM
deactivate request. The request supplies only the number of the
instance to be deactivated.

.. figtable::
    :nofig:
    :label: table-pwm-deactivate-request
    :caption: PWM Protocol Deactivate Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative PWM instance number
    =======  ==============  ======  ==========      ===========================

Greybus PWM Deactivate Response
"""""""""""""""""""""""""""""""

The Greybus PWM deactivate response message has no payload.

Greybus PWM Configure Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM configure operation requests the PWM controller
configure a PWM instance with the given duty cycle and period.

Greybus PWM Configure Request
"""""""""""""""""""""""""""""

Table :num:`table-pwm-configure-request` defines the Greybus PWM
configure request. The request supplies the target instance number,
duty cycle, and period of the cycle.

.. figtable::
    :nofig:
    :label: table-pwm-configure-request
    :caption: PWM Protocol Configure Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative PWM instance number
    1        duty            4       Number          Duty cycle (in nanoseconds)
    5        period          4       Number          Period (in nanoseconds)
    =======  ==============  ======  ==========      ===========================

Greybus PWM Configure Response
""""""""""""""""""""""""""""""

The Greybus PWM configure response message has no payload.

Greybus PWM Polarity Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM polarity operation requests the PWM controller
configure a PWM instance with the given polarity.

Greybus PWM Polarity Request
""""""""""""""""""""""""""""

Table :num:`table-pwm-polarity-request` defines the Greybus PWM
polarity request. The request supplies the target instance number and
polarity (normal or inverted). The polarity may not be configured when
a PWM instance is enabled.

.. figtable::
    :nofig:
    :label: table-pwm-polarity-request
    :caption: PWM Protocol Polarity Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative PWM instance number
    1        polarity        1       Number          0 for normal, 1 for inverted
    =======  ==============  ======  ==========      ===========================

Greybus PWM Polarity Response
"""""""""""""""""""""""""""""

The Greybus PWM polarity response message has no payload.

Greybus PWM Enable Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM enable operation enables a PWM instance to begin
toggling.

Greybus PWM Enable Request
""""""""""""""""""""""""""

Table :num:`table-pwm-enable-request` defines the Greybus PWM enable
request. The request supplies only the number of the instance to be
enabled.

.. figtable::
    :nofig:
    :label: table-pwm-enable-request
    :caption: PWM Protocol Enable Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative PWM instance number
    =======  ==============  ======  ==========      ===========================

Greybus PWM Enable Response
"""""""""""""""""""""""""""

The Greybus PWM enable response message has no payload.

Greybus PWM Disable Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM disable operation stops a PWM instance that has
previously been enabled.

Greybus PWM Disable Request
"""""""""""""""""""""""""""

Table :num:`table-pwm-disable-request` defines the Greybus PWM disable
request. The request supplies only the number of the instance to be
disabled.

.. figtable::
    :nofig:
    :label: table-pwm-disable-request
    :caption: PWM Protocol Disable Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative PWM instance number
    =======  ==============  ======  ==========      ===========================

Greybus PWM Disable Response
""""""""""""""""""""""""""""

The Greybus PWM disable response message has no payload.

I2S Protocols
-------------

..  'I2S' should be replaced by 'Audio Streaming' or similar
    because more than i2s is supported by what's defined here.

Audio data may be streamed using the I2S Protocols Specification
described herein.  The I2S Protocols Specification is designed to
support arbitrarily complex audio topologies with any number of
intermediate Modules.  A Module that supports the I2S Protocols
Specification shall be referred to as an *I2S Module* even when
the Module supports other Greybus Protocols.

.. note::

    Where possible, the I2S Protocols Specification tries to be consistent
    with the
    `USB Audio Specification Version 2.0
    <http://www.usb.org/developers/docs/devclass_docs/Audio2.0_final.zip>`_.
    The I2S Protocols Specification is designed to handle
    *Type I Simple Audio Data Format*
    data as defined in Section 2.3.1 of the
    *USB Device Class Definition for Audio Data Formats*
    document.  This does not preclude the use of other
    data formats.

An I2S Module shall contain one or more *I2S Bundles*.  Each I2S Bundle
shall contain one *I2S Management CPort*, and may contain zero or
more *I2S Transmitter CPorts* and zero or more *I2S Receiver CPorts*.
There shall be at least one I2S Transmitter or Receiver CPort in each
I2S Bundle.  An I2S Bundle may have no physical low-level I2S or
similar hardware associated with it.

I2S Management CPorts, I2S Transmitter CPorts, and I2S Receiver CPorts
have unique CPort Protocol values in the `protocol` field of the CPort
Descriptor in an interface Manifest.

An *I2S Transmitter Bundle* is an I2S Bundle containing at least one
I2S Transmitter CPort.  Similarly for an *I2S Receiver Bundle*.
The terms *Transmitter* and *Receiver* are from the perspective of the
|unipro| network.  So an I2S Transmitter Bundle is an I2S Bundle capable
of sending audio data into the |unipro| network, while an I2S
Receiver Bundle is capable of receiving a data from a local
low-level I2S interface.  An I2S Bundle may be both an I2S
Transmitter Bundle and an I2S Receiver Bundle.

As a special case, I2S Management CPorts in an AP Module that are used
to manage I2S Bundles may exist apart from an I2S Bundle.  This shall
not prevent the AP Module from having I2S Bundles.  For example, the
AP Module may have an I2S Bundle for sending ringtones to the Speaker
Module when an incoming voice call arrives.  In this case, the I2S
Management CPort in the AP Module's I2S Bundle is distinct from the
I2S Management CPort used by the AP Module to manage that I2S Bundle.
The AP Module shall treat any I2S Bundle it exposes to the |unipro|
network no differently than an I2S Bundle in any other I2S Module.

Separate Management and Data Protocols
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

There are two separate protocols contained within the I2S Protocols
Specification.  The first protocol is the
:ref:`i2s-management-protocol`, which is used to manage audio streams.
The second protocol is the :ref:`i2s-data-protocol` and is used by I2S
Modules to stream audio data to one another.  Because the send and
receive side of the data protocol play different roles, each has
a distinct protocol identifier.

The I2S Management Protocol is used over an *I2S Management Connection*
which connects two I2S Management CPorts.  At least one of the I2S
Management CPorts shall be in the AP Module.  The I2S Data Protocol
is used over an *I2S Data Connection* which connects an I2S Transmitter
CPort to an I2S Receiver CPort.

.. _i2s-audio-data-attributes:

Audio Data Attributes and Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For audio data to be streamed and delivered correctly, the I2S Bundles
at both ends of an I2S Data Connection shall be configured similarly.
Note that it is possible for I2S Data Connections in an overall audio
stream to have their associated I2S Bundles configured differently.
For example, an intermediate I2S Module that is a sampling rate
converter may have different sampling rates for its receiving and
transmitting I2S Data Connections.  Even so, the I2S Bundles at
either end of each I2S Data Connection shall be configured similarly.

It is the responsibility of the AP Module to ensure that both the
individual I2S Data Connections, and the overall set of I2S Data
Connections combined with the functions of internal I2S Modules
and non-\ |unipro| devices are configured correctly.

The I2S Protocols Specification defines the *transfer* of audio data,
not the production or consumption of audio data.
Therefore, the encoding method, compression technique, and audio data
representation are irrelevant with respect to the I2S Protocols
Specification.  However, there are attributes of the audio data
that are relevant and are described herein.

The *Configuration* of an I2S Bundle or Data Connection is the set
of values used by the I2S Bundle or Data Connection for these audio
data attributes.  The I2S Protocols Specification places constraints
on the Configuration.  These constraints are:

*   the Configuration (i.e., sample frequency, number of channels
    per sample, etc.) of an I2S Bundle may not change while there is
    an active I2S Transmitter or Receiver CPort in the I2S Bundle;
*   the number of audio data bits for a sample on an individual channel
    shall be an integer multiple of eight;
*   the number of audio data bits for each channel shall be equal;
*   as per the USB Audio Specification, the number of bytes of audio
    data shall be one, two, three, or four;
*   every :ref:`i2s-send-data-op` shall send an integer number of
    audio data samples.

Some audio data attributes commonly differ for reasons including
underlying hardware constraints and the audio application.
These attributes shall be configurable.  The configurable audio
data attributes are:

*   the sample frequency which is the number of audio sample taken
    per second;
*   the number of audio channels per sample;
*   the number of bytes in a sample of audio channel data;
*   the byte order of multi-byte audio channel data;
*   the spatial location of the audio channels.

The spatial location of the audio channels is defined by the
USB Audio Specification.  The number of channels per sample
in the Configuration shall equal the number of spatial locations
selected by the Configuration.

There are other configurable attributes that don't affect the audio
data within the |unipro| audio stream but do affect the low-level
interface between the I2S Bundle and a non-\ |unipro| audio device.
These are :ref:`i2s-low-level-attributes`.

It is necessary to include these attributes in the I2S Configuration
data because the AP Module requires this information in order to
configure the low-level interface of the non-\ |unipro| device.
Examples of non-\ |unipro| audio devices are analog-to-digital
converters (ADCs), digital-to-analog converters (DACs), combined
ADC/DACs called coders-decoders (codecs), and audio mixers.

In order to configure the I2S Bundles at each end of an I2S Data
Connection similarly, the AP Module requires the ability to query
the I2S Bundles to see which options for each attribute the
I2S Bundle supports.  To enable this, the I2S Management Protocol contains
the :ref:`i2s-get-supported-configurations-op` which returns an array
of structures that describe the configurations supported by the I2S
Bundle.  Each entry of the array is a :ref:`i2s-configuration-struct`.
The AP Module also requires the ability to set the attribute values
of the I2S Bundle.  The :ref:`i2s-set-configuration-op` is provided for
this purpose.

Some attributes in the :ref:`i2s-configuration-struct` returned by
the :ref:`i2s-get-supported-configurations-op` may have multiple options
set.  This indicates that more than one option for that attribute is
supported by the I2S Bundle; however, only one option shall be selected
in the :ref:`i2s-configuration-struct` passed in the
:ref:`i2s-set-configuration-op`.

Configuration of the I2S Bundle shall be performed while no CPorts
in the I2S Bundle are active.

.. _i2s-low-level-attributes:

I2S Low-level Attributes
^^^^^^^^^^^^^^^^^^^^^^^^

There are several I2S Low-level Attributes supported by the
I2S Protocols Specification.  Some of the I2S Low-level Attributes
vary depending on the *low-level Interface Protocol* so more
I2S Low-level Attributes may be added as support for additional
Low-level Interface Protocols is added.  The current I2S Low-level
Attributes are:

*   the Low-level Interface Protocol;
*   the I2S Bundle's role (master or slave) with respect to the Bit Clock (BCLK);
*   the I2S Bundle's role with respect to the Word Clock (WCLK);
*   the polarity of the WCLK;
*   the BCLK edge that the WCLK changes on;
*   the BCLK edge when transmit bits are presented;
*   the BCLK edge when receive bits are latched;
*   the number of BCLK cycles between when WCLK changes and when
    data for the next channel is presented.

The Low-level Interface Protocol specifies the protocol used by the
3- (or more) wire interface between the I2S Bundle and the non-\ |unipro|
device.  The currently supported Low-level Interface Protocols are:
Pulse Code Modulation (PCM), Inter-IC Sound (I2S), and Left-Right Stereo
(LR Stereo).  They are described in more detail below.

Sometimes Low-level Interface Protocols also specify the format of the
audio data (e.g., I2S).  For this discussion, the audio data format is
irrelevant and only the Low-level Interface Protocol is relevant.

The I2S Bundle's *role* with respect to the Bit and Word Clocks specifies
whether the I2S Bundle generates the respective clock signal or not.
When the I2S Bundle generates the clock signal, its role is *clock master*;
when it does not generate the clock signal, its role is *clock slave*.

The polarity of the WCLK may be reversed for some Low-level Interface
Protocols.  The effects of reversing the WCLK polarity varies by
Low-level Interface Protocol.  The WCLK is also referred to as the
Left-Right Clock (LRCLK) and Word Select (WS).

The remaining I2S Low-level Attributes specify which BCLK edge
various events are synchronized to.

Pulse Code Modulation (PCM) Low-level Interface Protocol
""""""""""""""""""""""""""""""""""""""""""""""""""""""""

There are many variations of the `Pulse Code Modulation (PCM)
<http://en.wikipedia.org/wiki/Pulse-code_modulation>`_
Low-level Interface Protocol.  Most variations are supported
by setting I2S Low-level Attributes appropriately.

..  The link above is useless.  The only other links I've found
    that have decent descriptions are in datasheets for parts
    and the description is buried in the middle.
    Best example I have is:
    http://kcwirefree.com/docs/guides/kcTechnicalAudio.pdf.
    Jump to Sections 10.3.2 and 10.3.3 (p. 12).  Other parts
    have variation of this.  There doesn't seem to be one
    standard.

The PCM Low-level Interface Protocol uses the WCLK signal for
transmitting *Frame SYNC* pulses.  A Frame SYNC pulse is transmitted
when the WCLK master reverses the WCLK polarity for one or more BCLK cycles.
The beginning of a Frame SYNC pulse signals the beginning of a new sample.
The audio data for all channels in the sample is transferred between
Frame SYNC pulses.  If there is no more audio data to transfer,
zero bits are transferred until the next Frame SYNC pulse (which
signals the start of the next sample).

Important points are:

*   one or more audio channels may be transferred;
*   the BCLK role may be master or slave;
*   the WCLK role may be master or slave;
*   the WCLK polarity may be normal or reversed (normal is when
    the WCLK is low except when a Frame SYNC pulse is being transmitted);
*   the WCLK may change on the rising or falling edge of the BCLK;
*   data bits being transmitted may be presented on the rising or
    falling edge of BCLK;
*   data bits being received may be latched on the rising or falling
    edge of BCLK;
*   the first bit of the new sample may start on the same BCLK
    edge as the WCLK signal (i.e., no offset) or one BCLK cycle
    later (i.e., offset by one).

Inter-IC Sound (I2S) Low-level Interface Protocol
"""""""""""""""""""""""""""""""""""""""""""""""""

The `Inter-IC Sound (I2S)
<https://web.archive.org/web/20060702004954/http://www.semiconductors.philips.com/acrobat_download/various/I2SBUS.pdf>`_
Low-level Interface Protocol specifies some I2S Low-level Attribute
values but leaves others open.  The WCLK signal specifies
whether the left or right channel's audio data is being
transferred.

Important points are:

*   there are two channels per sample;
*   the BCLK role may be master or slave;
*   the WCLK role may be master or slave;
*   the WCLK polarity may be normal or reversed (normal is when
    the left channel data is transferred when WCLK is low and the
    right channel data is transferred when WCLK is high);
*   the WCLK may change on the rising or falling edge of the BCLK;
*   data bits being transmitted may be presented on the rising or
    falling edge of BCLK;
*   data bits being received are latched on the rising edge of BCLK;
*   the first bit of the new sample starts one BCLK cycle after WCLK
    changes (i.e., offset by one).

LR Stereo Low-level Interface Protocol
""""""""""""""""""""""""""""""""""""""

The *LR Stereo* Low-level Interface Protocol refers to the
protocol used by
`Left-justified and Right-justified Stereo Formats
<http://www.cirrus.com/en/pubs/appNote/AN282REV1.pdf>`_.
The only difference between the two formats is whether
the audio data is left- or right-justified.  The justification
of the audio data is not relevant to the Low-level Interface Protocol
so the protocols for the two formats are combined into the
LR Stereo Low-level Interface Protocol.

..  I don't like having a hardware vendor's link here but
    I can't find a better one.

The LR Stereo Low-level Interface Protocol is similar to I2S except
the WCLK polarity is reversed and there is no offset between
when WCLK changes and when data for the next channel is presented.

Important points are:

*   there are two channels per sample;
*   the BCLK role may be master or slave;
*   the WCLK role may be master or slave;
*   the WCLK polarity may be normal or reversed (normal is when
    the left channel data is transferred when WCLK is high and the
    right channel data is transferred when WCLK is low);
*   the WCLK may change on the rising or falling edge of the BCLK;
*   data bits being transmitted may be presented on the rising or
    falling edge of BCLK;
*   data bits being received may be latched on the rising or falling
    edge of BCLK;
*   the first bit of the new sample starts on the same BCLK
    edge as the WCLK signal (i.e., no offset).

.. _i2s-audio-samples-per-message:

Audio Samples per Greybus Message
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Since audio samples tend to small but sent many times per second,
and small delays are not perceptible by the human ear, the I2S Protocols
Specification supports combining multiple audio samples into one Greybus
Message.  This is configured using the :ref:`i2s-set-samples-per-message-op`.
The I2S Transmitter and Receiver Bundles at each end of an
I2S Data Connection shall be set to the same samples per message value.
Once set, the I2S Transmitter Bundle shall send the specified number
of audio samples in each :ref:`i2s-send-data-op`.

Setting the samples per message is considered part of the audio stream
configuration and shall be performed while no CPorts are active
in the I2S Bundle.  Once set, the samples per message value shall
remain in effect indefinitely or until modified by another
:ref:`i2s-set-samples-per-message-op`.

When the samples per message is not set, a default value of one shall
be used.

.. _i2s-audio-video-synchronization:

Audio and Video Synchronization
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

One of the I2S Management Protocol's goals is to support synchronizing
audio output with video output.  To that end, the
:ref:`i2s-get-processing-delay-op` provides the AP Module with the amount
of time the I2S Bundle takes to *process* the audio data.  The *processing*
required depends on the I2S Bundle.  For example, an audio mixer's
processing may involve mixing the data from two separate audio streams
while a Speaker Module's processing may involve streaming audio data to
a DAC.  The delay value returned by the Operation should be accurate
to within 500 microseconds.

..  I expect this value to be zero in most cases.  Hopefully, there
    is something similar for video streams so the AP Module can
    determine if it needs to delay the audio stream so the video
    stream can "fill its pipeline".

The I2S Management Protocol contains the :ref:`i2s-set-start-delay-op`
which causes the I2S Transmitter Bundle to buffer its audio data for the
specified amount of time before streaming it.  This only delays when
audio streaming *starts*.  The delay time begins when the first
I2S Transmitter CPort in the I2S Transmitter Bundle is activated.
When the delay time elapses, the I2S Transmitter Bundle shall
begin streaming audio data to its active I2S Transmitter CPorts.
If no I2S Transmitter CPorts are active when the delay time elapses,
no audio data is streamed and any buffered audio data shall be discarded.
The I2S Transmitter Bundle shall delay with an accuracy of 500 microseconds.

It is possible for an I2S Transmitter Bundle to send the buffered data
faster than the audio samples can be output at the final destination.
When this happens, it effectively transfers the audio data buffering
downstream but does not change the audio output at the final destination.

..  Should E2EFC be enabled so audio data isn't discarded when a
    downstream Bundle doesn't have enough space to hold it all?

Setting the start delay is considered part of the audio stream configuration
and shall be performed while no CPorts are active in the I2S Bundle.
Once set, the start delay shall remain in effect indefinitely or until
modified by another :ref:`i2s-set-start-delay-op`.
When the start delay is not set, a default value of zero shall be used.

.. _i2s-audio-stream-activation-deactivation:

Audio Stream Activation and Deactivation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Once the I2S Bundles in a planned audio stream are configured
(i.e., configuration set, samples per message set,
start delay set), audio streaming is ready to begin.
The AP Module starts audio streaming by activating the
I2S Data Connections making up the planned audio stream.
To activate an I2S Data Connection, the AP Module uses
:ref:`i2s-activate-cport-op` to activate the I2S Transmitter
and Receiver CPorts at each end of the I2S Data Connection.

When the first I2S Transmitter CPort in an I2S Bundle is
activated, the start delay time begins and the I2S Bundle
starts buffering audio data.  When the start delay time
elapses, the I2S Bundle begins streaming the audio data
to all active I2S Transmitter CPorts in the I2S Bundle.

I2S Transmitters CPorts may be added or removed while the
I2S Bundle is actively streaming.  When an I2S Transmitter
CPort is activated, its active downstream I2S Data Connections
shall begin receiving audio data and become part of the overall
audio stream.  When an I2S Transmitter CPort is deactivated, its
active downstream I2S Data Connections shall stop receiving audio
data and shall no longer be part of the overall audio stream.
When the last I2S Transmitter CPort in an I2S Bundle is deactivated,
the I2S Bundle may free the resources allocated for the stream
and discard any buffered audio data.

When an I2S Receiver CPort in an I2S Bundle is activated,
it shall wait for audio data to arrive.  When audio data
arrives, it shall pass the data onto the device or function
on whose behalf it is receiving data.

I2S Receiver Bundles may be overrun by incoming audio data.
When an overrun occurs, the I2S Receiver Bundle shall discard
the incoming data.  The I2S Receiver Bundle may buffer
audio data so audio data is not discarded as often.  Whether
audio data is buffered and how much audio data to buffer
is left to the I2S Receiver Bundle designer.  When the I2S
Receiver Bundle is overrun while buffering audio data, it
may discard buffered audio data, the incoming audio data,
or a combination of both.  Regardless of how overruns are
handled, audio data shall remain in order.

.. _i2s-streaming-audio-data:

Streaming Audio Data
^^^^^^^^^^^^^^^^^^^^

An I2S Transmitter Bundle streams audio data to an
I2S Receiver Bundle over an I2S Data Connection using
:ref:`i2s-send-data-op`\s.  Each I2S Send Data Request
contains at least one complete audio sample.
A complete audio sample contains one sample of
audio data for every audio channel being streamed.

Every audio sample sent over an I2S Data Connection
is numbered beginning at zero.  Since different I2S Transmitter
CPorts within the I2S Transmitter Bundle may be
activated at different times, the same audio sample
may be numbered differently in each I2S Data Connection.
However, within an I2S Data Connection the audio sample
number shall begin at zero and increment by one for each
audio sample.

To enable an I2S Receiver Bundle to recognize that one
or more I2S Send Data Requests are missing, each
I2S Send Data Request contains a `sample_number` field.
The `sample_number` field contains the sample number of
the first audio sample contained in the I2S Send Data Request.
The I2S Transmitter Bundle shall increase the value placed
in the `sample_number` field of consecutive I2S Send Data
Requests by the number of audio samples contained in each request.
See :ref:`i2s-send-data-op` for further details on the
I2S Send Data Requests.

When an I2S Receiver Bundle receives an I2S Send Data
Request whose `sample_number` field value does not match
the expected sample number, it can determine the action
to take by comparing the sample number it expected to
the sample number it received.

If the sample number the I2S Receiver Bundle expected is
less than the sample number in the received request,
then at least one I2S Send Data Request is missing.
In this situation, the I2S Receiver Bundle shall fabricate
audio data and substitute the fabricated data for the missing
data.  The number of audio samples to fabricate is calculated
by subtracting the audio sample number in the received
request by the one expected.
How the missing audio data is fabricated is left to
the I2S Module designer.

For example, if the samples per message has been set to four
and the I2S Receiver Bundle has received I2S Send Data Requests
whose `sample_number` values are zero, four, and twelve,
then the I2S Receiver Bundle shall fabricate audio data
for audio samples eight, nine, ten, and eleven.

If the sample number the I2S Receiver Bundle expected is
greater than or equal to the sample number in the received
request, then either the I2S Send Request is a duplicate or
the I2S Send Request arrived late and the I2S Receiver
Bundle has fabricated audio data in its place.  In either
case, the I2S Receiver Bundle shall discard the contents
of the I2S Send Data Request.

It is possible for the I2S Receiver Bundle to be overrun
with incoming I2S Send Data Requests or to underrun by
not having audio data available when required.
The handling of these conditions is left to the I2S Module
designer.

.. _i2s-errors-and-event-reporting:

Errors and Event Reporting
^^^^^^^^^^^^^^^^^^^^^^^^^^

Audio data streaming events detected by the I2S Bundle
are reported to the AP Module using :ref:`i2s-report-event-op`\s.
Events include Greybus I2S Protocol errors, audio data underrun,
and audio data overrun.  The I2S Bundle shall report events when
one or more I2S Transmitter or Receiver CPorts are active;
otherwise, it shall not report events.

The *halted* event indicates that the I2S Bundle is unable to
continue streaming.  This event shall be preceded by another
event indicating why the I2S Bundle halted.  Once an I2S Bundle
reports the halted event, the AP shall deactivate all active I2S
Transmitter and Receiver CPorts.

In order to prevent flooding the AP Module with events,
an I2S Bundle shall only report an event once per occurrence
and shall report no event within 10 milliseconds of a previous
event (except for the halted event which may follow immediately
after another event).

..  This needs more thought.

Example Audio Scenario (Informative)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Audio configurations may be complex and require several I2S
Data Connections to perform the desired task.
Figure 10.1 illustrates one example.  In the figure, the AP Module
generates a ringtone indicating that their is an incoming call.
The local party answers the call and begins recording.
When necessary, the AP Module generates alert tones indicating to
the local party that an event has occurred (e.g., an SMS text message
arrived).  Several I2S Modules and I2S Audio Connections are
required to carry out these tasks.

.. _fig-i2s_example:

.. figure:: _static/i2s_example.*
    :alt: Example Audio Scenario
    :name: example audio scenario
    :figwidth: 6in
    :align: center

    Example Audio Scenario (I2S Data Connections shown)

To set up an audio stream between two I2S Bundles, the AP Module
performs the following steps using the :ref:`control-protocol` and
the :ref:`i2s-management-protocol`.

*   Create a |unipro| Connection between the AP Module
    and each I2S Bundle.  These Connections are the
    I2S Management Connections.
*   Create a |unipro| Connection between the I2S Transmitter CPort
    in the I2S Transmitter Bundle and the I2S Receiver CPort in the
    I2S Receiver Bundle.  This Connection is the I2S Data Connection.
*   Query the I2S Bundles and retrieve the supported configurations
    for each.
*   Determine a configuration suitable to both I2S Bundles
    and any intermediate functions or non-\ |unipro| devices
    involved in the streaming.
*   Set the I2S Bundles, intermediate functions, and non-\ |unipro| devices
    to the chosen configuration.
*   If desired, set the number of audio samples per Greybus Message
    in the I2S Transmitter Bundle.  Otherwise one sample per Greybus
    Message shall be sent.
*   If required, determine the start up delay required to synchronize the
    audio data with the video data.
*   If required, set the start delay for the I2S Transmitter Bundle.
    Otherwise a start delay of zero shall be used.
*   If present, configure and start the intermediate functions and
    non-\ |unipro| devices.
*   Activate the I2S Receiver CPort in the I2S Receiver Bundle.
*   Activate the I2S Transmitter CPort in the I2S Transmitter Bundle.

The I2S Transmitter Bundle may now stream audio data to the
I2S Receiver Bundle using :ref:`i2s-send-data-op`\s.

To tear down an audio stream between two I2S Bundles, the AP Module
performs the following steps using the :ref:`control-protocol` and
the :ref:`i2s-management-protocol`:

*   Deactivate the I2S Transmitter CPort in the I2S Transmitter Bundle.
    This stops the I2S Transmitter Bundle from streaming audio data
    over the associated I2S Data Connection.
*   Deactivate the I2S Receiver CPort in the I2S Receiver Bundle.
*   Destroy the |unipro| Connection between the two I2S Bundles
    used for the I2S Data Connection.
*   Destroy the two |unipro| Connections between the AP Module
    and I2S Bundles used for the I2S Management Connections.

When multiple I2S Data Connections are used in an audio stream,
the AP Module shall ensure that the selected configuration satisfies
the constraints of all the I2S Bundles, intermediate modules,
and non-\ |unipro| devices involved.

.. _i2s-management-protocol:

I2S Management Protocol
^^^^^^^^^^^^^^^^^^^^^^^

I2S Management Protocol Operations are communicated over I2S Management
Connections.  I2S Management Connections connect the AP Module to
I2S Bundles.  There shall be an I2S Management Connection between
the AP Module and each I2S Bundle participating in the audio stream.

In the following descriptions, Operations apply to the I2S Bundle
associated with the I2S Management Connection that the Operation is
sent on.  Similarly, arguments to parameters such as `cport` shall
be CPorts contained within the I2S Bundle associated with the
I2S Management Connection that the Operation is sent on.

Conceptually, the I2S Management Protocol Operations are:

.. c:function:: int get_supported_configurations(u8 *configurations, struct gb_i2s_configuration *configurations);

    Requests the I2S Bundle return an array of :ref:`i2s-configuration-struct`
    describing the configurations it supports.

.. c:function:: int set_configuration(struct gb_i2s_configuration *configuration);

    Requests the I2S Bundle set its configuration values to
    those specified by the supplied configuration.

.. c:function:: int set_samples_per_message(u16 samples_per_message);

    Requests the I2S Bundle send the specified number of audio
    samples in each :ref:`i2s-send-data-op`.

    The default samples per message value shall be 0.

.. c:function:: int get_processing_delay(u32 *microseconds);

    Returns the number of microseconds the I2S Bundle requires
    to process an audio sample before it is forwarded.

..  The USB Audio spec expresses this delay in audio microframes
    instead of microseconds (Section 3.12 of USB Dev Class Def.
    for Audio Devices v2.0).  The issue I have with this is the
    number of microframes varies depending on the sampling rate
    (if I understand what they're doing correctly).  It seems
    simpler to just use microseconds but maybe it should change
    to match USB.

.. c:function:: int set_start_delay(u32 microseconds);

    Requests the I2S Transmitter Bundle buffer audio data
    for the specified amount of time before beginning to
    stream it.

    The default start delay value shall be 0.

.. c:function:: int activate_cport(u16 cport);

    Requests the I2S Bundle activate the specified CPort.

    When `cport` refers to an I2S Transmitter CPort,
    the I2S Bundle shall send audio data through that CPort.
    When `cport` refers to an I2S Receiver CPort,
    the I2S Bundle shall forward the audio data from the CPort
    to the device or function on whose behalf it is receiving
    the audio data.

.. c:function:: int deactivate_cport(u16 cport);

    Requests the I2S Bundle deactivate the specified CPort.
    When this operation completes, the I2S Bundle shall no
    longer send or receive audio data on the specified CPort.

..  I keep debating whether to have start & stop ops but they
    wouldn't be any different than the activate/deactivate ops
    already defined.  Adding them would just create more work
    for AP.

.. c:function:: int report_event(u32 event);

    Reports an I2S Audio Event. The events are described in
    :ref:`i2s-audio-events`.

.. _i2s-configuration-struct:

Greybus I2S Configuration Structure
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-i2s-configuration` defines the Greybus I2S
Configuration Structure. The structureq describes configurations
supported by I2S Bundles.  It is used by
:ref:`i2s-get-supported-configurations-op`\s and
:ref:`i2s-set-configuration-op`\s.  See
:ref:`i2s-audio-data-attributes` for further details.

.. figtable::
    :nofig:
    :label: table-i2s-configuration
    :caption: I2S Protocol Configuration Structure
    :spec: l l c c l

    =======  ====================  =====  =========  ==============================
    Offset   Field                 Size   Value      Description
    =======  ====================  =====  =========  ==============================
    0        sample_frequency      4      Number     Number of samples per
                                                     second
    4        num_channels          1      Number     Number of channels per
                                                     sample
    5        bytes_per_channel     1      Number     Number of audio bytes per
                                                     channel
    6        byte_order            1      Bit Mask   :ref:`i2s-byte-order-bits`
    7        pad                   1                 Padding
    8        spatial_locations     4      Bit Mask   :ref:`i2s-spatial-location-bits`
    12       ll_protocol           4      Bit Mask   :ref:`i2s-protocol-bits`
    16       ll_bclk_role          1      Bit Mask   :ref:`i2s-role-bits`
    17       ll_wclk_role          1      Bit Mask   :ref:`i2s-role-bits`
    18       ll_wclk_polarity      1      Bit Mask   :ref:`i2s-polarity-bits`
    19       ll_wclk_change_edge   1      Bit Mask   :ref:`i2s-clock-edge-bits`
    20       ll_data_tx_edge       1      Bit Mask   :ref:`i2s-clock-edge-bits`
    21       ll_data_rx_edge       1      Bit Mask   :ref:`i2s-clock-edge-bits`
    22       ll_data_offset        1      Number     BCLK-WCLK offset
    23       ll_pad                1                 Padding
    =======  ====================  =====  =========  ==============================

The `ll_wclk_change_edge`, `ll_data_tx_edge`, and `ll_data_rx_edge` fields
specify which BCLK edge the respective signal may change on.
The `ll_data_offset` field specifies how may BCLK cycles there are between
WCLK changing and the first data bit of the next channel being presented
or latched.  This is referred to as the `offset`.

.. _i2s-byte-order-bits:

Greybus I2S Byte-Order Bit Masks
""""""""""""""""""""""""""""""""

Table :num:`table-i2s-byte-order-bit-mask` defines the bit masks which
specify the set of supported I2S byte orders.  These includes a *Not
Applicable (NA)* value used for single-byte audio data.

.. figtable::
    :nofig:
    :label: table-i2s-byte-order-bit-mask
    :caption: I2S Protocol Byte Order Bit Masks
    :spec: l l l

    ===============================  =============================  ===============
    Symbol                           Brief Description              Mask Value
    ===============================  =============================  ===============
    GB_I2S_BYTE_ORDER_NA             Not applicable                 0x01
    GB_I2S_BYTE_ORDER_BE             Big endian                     0x02
    GB_I2S_BYTE_ORDER_LE             Little endian                  0x04
    ===============================  =============================  ===============

.. _i2s-spatial-location-bits:

Greybus I2S Spatial Location Bit Masks
""""""""""""""""""""""""""""""""""""""

Table :num:`table-i2s-spatial-location-bit-mask` defines the bit masks
which specify the set of supported I2S Spatial Locations.  These
values are defined in Section 4.1 of the *USB Device Class Definition
for Audio Devices* document which is part of the `USB Audio
Specification Version 2.0
<http://www.usb.org/developers/docs/devclass_docs/Audio2.0_final.zip>`_.

.. figtable::
    :nofig:
    :label: table-i2s-spatial-location-bit-mask
    :caption: I2S Protocol Spatial Location Bit Masks
    :spec: l l l

    ===============================  ===========================    ===============
    Symbol                           Brief Description              Mask Value
    ===============================  ===========================    ===============
    GB_I2S_SPATIAL_LOCATION_FL       Front Left                     0x00000001
    GB_I2S_SPATIAL_LOCATION_FR       Front Right                    0x00000002
    GB_I2S_SPATIAL_LOCATION_FC       Front Center                   0x00000004
    GB_I2S_SPATIAL_LOCATION_LFE      Low Frequency Effects          0x00000008
    GB_I2S_SPATIAL_LOCATION_BL       Back Left                      0x00000010
    GB_I2S_SPATIAL_LOCATION_BR       Back Right                     0x00000020
    GB_I2S_SPATIAL_LOCATION_FLC      Front Left of Center           0x00000040
    GB_I2S_SPATIAL_LOCATION_FRC      Front Right of Center          0x00000080
    GB_I2S_SPATIAL_LOCATION_BC       Back Center                    0x00000100
    GB_I2S_SPATIAL_LOCATION_SL       Side Left                      0x00000200
    GB_I2S_SPATIAL_LOCATION_SR       Side Right                     0x00000400
    GB_I2S_SPATIAL_LOCATION_TC       Top Center                     0x00000800
    GB_I2S_SPATIAL_LOCATION_TFL      Top Front Left                 0x00001000
    GB_I2S_SPATIAL_LOCATION_TFC      Top Front Center               0x00002000
    GB_I2S_SPATIAL_LOCATION_TFR      Top Front Right                0x00004000
    GB_I2S_SPATIAL_LOCATION_TBL      Top Back Left                  0x00008000
    GB_I2S_SPATIAL_LOCATION_TBC      Top Back Center                0x00010000
    GB_I2S_SPATIAL_LOCATION_TBR      Top Back Right                 0x00020000
    GB_I2S_SPATIAL_LOCATION_TFLC     Top Front Left of Center       0x00040000
    GB_I2S_SPATIAL_LOCATION_TFRC     Top Front Right of Center      0x00080000
    GB_I2S_SPATIAL_LOCATION_LLFE     Left Low Frequency Effects     0x00100000
    GB_I2S_SPATIAL_LOCATION_RLFE     Right Low Frequency Effects    0x00200000
    GB_I2S_SPATIAL_LOCATION_TSL      Top Side Left                  0x00400000
    GB_I2S_SPATIAL_LOCATION_TSR      Top Side Right                 0x00800000
    GB_I2S_SPATIAL_LOCATION_BC       Bottom Center                  0x01000000
    GB_I2S_SPATIAL_LOCATION_BLC      Back Left of Center            0x02000000
    GB_I2S_SPATIAL_LOCATION_BRC      Back Right of Center           0x04000000
    GB_I2S_SPATIAL_LOCATION_RD       Raw Data                       0x80000000
    ===============================  ===========================    ===============

.. _i2s-protocol-bits:

Greybus I2S Protocol Bit Masks
""""""""""""""""""""""""""""""

This table defines the bit masks which specify the set of supported
I2S Low-level Protocols.
See :ref:`i2s-low-level-attributes` for further details.

.. figtable::
    :nofig:
    :label: table-i2s-spatial-location-bit-mask
    :caption: I2S Protocol Spatial Location Bit Masks
    :spec: l l l

    ===============================  ===========================    ===============
    Symbol                           Brief Description              Mask Value
    ===============================  ===========================    ===============
    GB_I2S_PROTOCOL_PCM              Pulse Code Modulation (PCM)    0x00000001
    GB_I2S_PROTOCOL_I2S              Inter-IC Sound (I2S)           0x00000002
    GB_I2S_PROTOCOL_LR_STEREO        LR Stereo                      0x00000004
    ===============================  ===========================    ===============

.. _i2s-role-bits:

Greybus I2S Role Bit Masks
""""""""""""""""""""""""""

Table :num:`table-i2s-role-bit-mask` defines the bit masks which
specify the set of supported I2S clock roles.  See
:ref:`i2s-low-level-attributes` for further details.

.. figtable::
    :nofig:
    :label: table-i2s-role-bit-mask
    :caption: I2S Protocol Role Bit Masks
    :spec: l l l

    ===============================  =============================  ===============
    Symbol                           Brief Description              Mask Value
    ===============================  =============================  ===============
    GB_I2S_ROLE_MASTER               Low-level clock generator      0x01
    GB_I2S_ROLE_SLAVE                Not low-level clock generator  0x02
    ===============================  =============================  ===============

.. _i2s-polarity-bits:

Greybus I2S Polarity Bit Masks
""""""""""""""""""""""""""""""

Table :num:`table-i2s-polarity-bit-mask` defines the bit masks which
specify the set of supported I2S clock polarities.  See
:ref:`i2s-low-level-attributes` for further details.

.. figtable::
    :nofig:
    :label: table-i2s-polarity-bit-mask
    :caption: I2S Protocol Polarity Bit Masks
    :spec: l l l

    ===============================  ========================       ===============
    Symbol                           Brief Description              Mask Value
    ===============================  ========================       ===============
    GB_I2S_POLARITY_NORMAL           Clock polarity normal          0x01
    GB_I2S_POLARITY_REVERSED         Clock polarity reversed        0x02
    ===============================  ========================       ===============

.. _i2s-clock-edge-bits:

Greybus I2S Clock Edge Bit Masks
""""""""""""""""""""""""""""""""

Table :num:`table-i2s-edge-bit-mask` defines the bit masks which
specify the set of supported I2S clock edges.  See
:ref:`i2s-low-level-attributes` for further details.

.. figtable::
    :nofig:
    :label: table-i2s-edge-bit-mask
    :caption: I2S Protocol Edge Bit Masks
    :spec: l l l

    ===============================  ========================       ===============
    Symbol                           Brief Description              Mask Value
    ===============================  ========================       ===============
    GB_I2S_EDGE_RISING               Synchronized to rising         0x01
                                     or leading clock edge
    GB_I2S_EDGE_FALLING              Synchronized to falling        0x02
                                     or trailing clock edge
    ===============================  ========================       ===============

Greybus I2S Management Protocol Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-i2s-operation-type` defines the Greybus I2S
Management Protocol Operation types and their values.  A message type
consists of an Operation Type combined with a flag (0x80) indicating
whether the operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-i2s-operation-type
    :caption: I2S Operation Types
    :spec: l l l

    ===========================================  =============  ==============
    I2S Management Operation Type                Request Value  Response Value
    ===========================================  =============  ==============
    Invalid                                      0x00           0x80
    :ref:`i2s-get-supported-configurations-op`   0x01           0x81
    :ref:`i2s-set-configuration-op`              0x02           0x82
    :ref:`i2s-set-samples-per-message-op`        0x03           0x83
    :ref:`i2s-get-processing-delay-op`           0x04           0x84
    :ref:`i2s-set-start-delay-op`                0x05           0x85
    :ref:`i2s-activate-cport-op`                 0x06           0x86
    :ref:`i2s-deactivate-cport-op`               0x07           0x87
    :ref:`i2s-report-event-op`                   0x08           0x88
    (all other values reserved)                  0x09..0x7f     0x89..0xff
    ===========================================  =============  ==============

.. _i2s-get-supported-configurations-op:

Greybus I2S Get Supported Configurations Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2S Get Supported Configurations Operation requests
the I2S Bundle return an array of :ref:`i2s-configuration-struct`\s
which describe the configurations supported by the I2S Bundle.
See :ref:`i2s-audio-data-attributes` for further details.

Greybus I2S Get Supported Configurations Request
""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus I2S get supported configurations request message has no payload.

Greybus I2S Get Supported Configurations Response
"""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-i2s-get-supported-configurations-response` defines
the I2S Get Supported Configurations Response. The response contains
a configurations count, and an array of :ref:`i2s-configuration-struct`\s.

.. figtable::
    :nofig:
    :label: table-i2s-get-supported-configurations-response
    :caption: I2S Protocol Get Supported Configurations Response
    :spec: l l c c l

    ===========  ==============  ======  ===============================  =======================================
    Offset       Field           Size    Value                            Description
    ===========  ==============  ======  ===============================  =======================================
    0            config_count    1       Number, N                        Entries in `config` array
    1            pad             2                                        Padding
    3            config[1]       24      :ref:`i2s-configuration-struct`  First entry in `config` array
    ...          ...             24      :ref:`i2s-configuration-struct`  ...
    3+24*(N-1)   config[N]       24      :ref:`i2s-configuration-struct`  Last entry in `config` array
    ===========  ==============  ======  ===============================  =======================================

..  I can't make this table look right.

.. _i2s-set-configuration-op:

Greybus I2S Set Configuration Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2S Set Configuration Operation requests the I2S Bundle
set its configuration to the specified values.

Greybus I2S Set Configuration Request
"""""""""""""""""""""""""""""""""""""

Table :num:`table-i2s-set-configuration-request` defines the Greybus
I2S Set Configuration Request. The Request supplies the configuration
values that the I2S Bundle shall use.  There shall be only one option
selected in the bit mask fields.

.. figtable::
    :nofig:
    :label: table-i2s-set-configuration-request
    :caption: I2S Protocol Set Configuration Request
    :spec: l l c c l

    =======  ==============  ======  ===============================  ================================
    Offset   Field           Size    Value                            Description
    =======  ==============  ======  ===============================  ================================
    0        config          24      :ref:`i2s-configuration-struct`  Bundle's configuration values
    =======  ==============  ======  ===============================  ================================

Greybus I2S Set Configuration Response
""""""""""""""""""""""""""""""""""""""

The Greybus I2S Set Configuration response message contains no payload.

.. _i2s-set-samples-per-message-op:

Greybus I2S Set Samples per Message Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2S Set Samples per Message Operation requests the
I2S Transmitter Bundle include the specified number of audio samples
in each :ref:`i2s-send-data-op`.  See :ref:`i2s-audio-samples-per-message`
for further details.

The default number of samples per message is one.

Greybus I2S Set Samples per Message Request
"""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-i2s-set-samples-per-message-request` defines the
Greybus I2S Set Samples per Message Request. The Request supplies the
number of audio samples that the transmitter shall include in each
:ref:`i2s-send-data-op`.

.. figtable::
    :nofig:
    :label: table-i2s-set-samples-per-message-request
    :caption: I2S Protocol Set Samples per Message Request
    :spec: l l c c l

    =======  ===================  ======  ==========      =========================
    Offset   Field                Size    Value           Description
    =======  ===================  ======  ==========      =========================
    0        samples_per_message  2       Number          Samples per message
    =======  ===================  ======  ==========      =========================

Greybus I2S Set Samples per Message Response
""""""""""""""""""""""""""""""""""""""""""""

The Greybus I2S Set Samples per Message response message has no payload.

.. _i2s-get-processing-delay-op:

Greybus I2S Get Processing Delay Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2S Get Processing Delay Operation requests the
I2S Bundle indicate how much time it requires to process
each audio data sample.
See :ref:`i2s-audio-video-synchronization` for further details.

The delay value returned should be accurate to within 500 microseconds.

Greybus I2S Get Processing Delay Request
""""""""""""""""""""""""""""""""""""""""

The Greybus I2S get processing delay request message has no payload.

Greybus I2S Get Processing Delay Response
"""""""""""""""""""""""""""""""""""""""""

Table :num:`table-i2s-get-processing-delay-response` defines the
Greybus I2S Get Processing Delay Response. The Response contains a
4-byte value indicating the controller's processing delay in
microseconds.

.. figtable::
    :nofig:
    :label: table-i2s-get-processing-delay-response
    :caption: I2S Protocol Get Processing Delay Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        microseconds    4       Number          Processing delay
    =======  ==============  ======  ==========      ===========================

.. _i2s-set-start-delay-op:

Greybus I2S Set Start Delay Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2S Set Start Delay Operation requests the I2S
Transmitter Bundle delay the specified amount of time before
it starts streaming audio data.  Delay values are in microseconds.
See :ref:`i2s-audio-video-synchronization` for further details.

The I2S Transmitter Bundle shall delay with an accuracy of 500 microseconds.

The default start delay value is zero.

Greybus I2S Set Start Delay Request
"""""""""""""""""""""""""""""""""""

Table :num:`table-i2s-set-start-delay-request` defines the Greybus I2S
Set Start Delay Request. The Request supplies the amount of time that
the I2S Transmitter Bundle shall delay before it starts streaming
audio data.

.. figtable::
    :nofig:
    :label: table-i2s-set-start-delay-request
    :caption: I2S Protocol Set Start Delay Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        microseconds    4       Number          Delay before starting
    =======  ==============  ======  ==========      ===========================

Greybus I2S Set Start Delay Response
""""""""""""""""""""""""""""""""""""

The Greybus I2S Set Start Delay response message has no payload.

.. _i2s-activate-cport-op:

Greybus I2S Activate CPort Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2S Activate CPort Operation requests the
I2S Bundle activate the specified CPort.
See :ref:`i2s-audio-stream-activation-deactivation` for further details.

Greybus I2S Activate CPort Request
""""""""""""""""""""""""""""""""""

Table :num:`table-i2s-activate-cport-request` defines the Greybus I2S
Activate CPort Request. The Request supplies the CPort that shall be
activated.

.. figtable::
    :nofig:
    :label: table-i2s-activate-cport-request
    :caption: I2S Protocol Activate CPort Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        cport           2       Number          I2S Transmitter or Receiver
                                                     CPort
    =======  ==============  ======  ==========      ===========================

Greybus I2S Activate CPort Response
"""""""""""""""""""""""""""""""""""

The Greybus I2S Activate CPort response message has no payload.

.. _i2s-deactivate-cport-op:

Greybus I2S Deactivate CPort Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2S Deactivate CPort Operation requests the
I2S Bundle deactivate the specified CPort.
See :ref:`i2s-audio-stream-activation-deactivation` for further details.

Greybus I2S Deactivate CPort Request
""""""""""""""""""""""""""""""""""""

Table :num:`table-i2s-deactivate-cport-request` defines the Greybus
I2S Deactivate CPort Request. The Request supplies the CPort that
shall be deactivated.

.. figtable::
    :nofig:
    :label: table-i2s-deactivate-cport-request
    :caption: I2S Protocol Deactivate CPort Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        cport           2       Number          I2S Transmitter or Receiver
                                                     CPort
    =======  ==============  ======  ==========      ===========================

Greybus I2S Deactivate CPort Response
"""""""""""""""""""""""""""""""""""""

The Greybus I2S Deactivate CPort response message has no payload.

.. _i2s-report-event-op:

Greybus I2S Report Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2S Report Event Operation notifies the
AP Module of audio streaming events.
See :ref:`i2s-errors-and-event-reporting` for further details.

Greybus I2S Report Event Request
""""""""""""""""""""""""""""""""

Table :num:`table-i2s-report-event-request` defines the Greybus I2S
Report Event Request. The Requestq supplies the one-byte event that
has occurred on the sending controller.

.. figtable::
    :nofig:
    :label: table-i2s-report-event-request
    :caption: I2S Protocol Report Event Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        event           1       Number          :ref:`i2s-audio-events`
    =======  ==============  ======  ==========      ===========================

.. _i2s-audio-events:

Greybus I2S Events
""""""""""""""""""

Table :num:`table-i2s-event` defines the Greybus I2S audio streaming
events and their values.

.. figtable::
    :nofig:
    :label: table-i2s-event
    :caption: I2S Protocol Events
    :spec: l l l

    ===============================  ========================       ===============
    Symbol                           Brief Description              Value
    ===============================  ========================       ===============
    GB_I2S_EVENT_UNSPECIFIED         Catch-all for events           0x01
                                     not in this table
    GB_I2S_EVENT_HALT                Streaming has halted           0x02
    GB_I2S_EVENT_INTERNAL_ERROR      Internal error that            0x03
                                     should never happen
    GB_I2S_EVENT_PROTOCOL_ERROR      Incorrect Operation            0x04
                                     order, etc.
    GB_I2S_EVENT_FAILURE             Operation failed               0x05
    GB_I2S_EVENT_OUT_OF_SEQUENCE     Sample sequence number         0x06
                                     incorrect
    GB_I2S_EVENT_UNDERRUN            No data to send                0x07
    GB_I2S_EVENT_OVERRUN             Being flooded by data          0x08
    GB_I2S_EVENT_CLOCKING            Low-level clocking issue       0x09
    GB_I2S_EVENT_DATA_LEN            Invalid message data           0x0a
                                     length
    ===============================  ========================       ===============

Greybus I2S Report Event Response
"""""""""""""""""""""""""""""""""

The Greybus I2S Report Event response message has no payload.

.. _i2s-data-protocol:

I2S Data Protocol
^^^^^^^^^^^^^^^^^

I2S Data Protocol Operations are communicated over I2S Data Connections.
I2S Data Connections connect I2S Transmitter CPorts to I2S Receiver CPorts.
An I2S Bundle shall have at least one I2S Transmitter or I2S Receiver CPort.
Some I2S Transmitter and I2S Receiver CPorts may be unused depending on
the current audio stream configuration.

In the following descriptions, Operations apply to the I2S Bundle
associated with the I2S Management Connection that the Operation is
sent on.

Conceptually, the I2S Data Protocol Operations are:

.. c:function:: int send_data(u32 sample_number, u32 size, u8 *data);

    Sends an integer number of audio samples from an
    I2S Transmitter CPort to an I2S Receiver CPort over
    an I2S Data Connection.  The I2S Bundles involved
    shall be configured before using this Operation.

Greybus I2S Data Protocol Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-i2s-data-operation-type` defines the Greybus I2S
Data Protocol Operation types and their values.  A message type
consists of an Operation Type combined with a flag (0x80) indicating
whether the operation is a request or a response.  All operations have
responses except for Send Data Request.

.. figtable::
    :nofig:
    :label: table-i2s-data-operation-type
    :caption: I2S Data Operation Types
    :spec: l l l

    =============================  =============  ==============
    I2S Data Operation Type        Request Value  Response Value
    =============================  =============  ==============
    Invalid                        0x00           0x80
    :ref:`i2s-send-data-op`        0x01           0x81
    (all other values reserved)    0x02..0x7f     0x82..0xff
    =============================  =============  ==============

.. _i2s-send-data-op:

Greybus I2S Send Data Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2S Send Data Operation sends data from an I2S
Transmitter to an I2S Receiver over an I2S Data Connection.
No response message shall be sent.
See :ref:`i2s-streaming-audio-data` for further details.

Greybus I2S Send Data Request
"""""""""""""""""""""""""""""

Table :num:`table-i2s-send-data-request` Greybus I2S Send Data Request
sends one or more complete audio samples.

.. figtable::
    :nofig:
    :label: table-i2s-send-data-request
    :caption: I2S Protocol Send Data Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        sample_number   4       Number          Sample number of first
                                                     sample in message
    4        size            4       Number          Bytes in data field
    8        data            ...     Data            Audio data
    =======  ==============  ======  ==========      ===========================

Greybus I2S Send Data Response
""""""""""""""""""""""""""""""

There shall be no response message for the Greybus I2S send data request.

I2C Protocol
------------

This section defines the operations used on a connection implementing
the Greybus I2C protocol. This protocol allows for management of an I2C
device present on a module. The protocol consists of five basic
operations, whose request and response message formats are defined
here.

Conceptually, the five operations in the Greybus I2C protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the protocol used for
    communication over the connection.  The sender offers the
    version of the protocol it supports.  The receiver replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

.. c:function:: int get_functionality(u32 *functionality);

    Returns a bitmask indicating the features supported by the I2C
    adapter.

.. c:function:: int set_timeout(u16 timeout_ms);

   Sets the timeout (in milliseconds) the I2C adapter should allow
   before giving up on an addressed client.

.. c:function:: int set_retries(u8 retries);

   Sets the number of times an adapter should retry an I2C op before
   giving up.

.. c:function:: int transfer(u8 op_count, struct i2c_op *ops);

   Performs an I2C transaction made up of one or more "steps" defined
   in the supplied I2C op array.

A transfer is made up of an array of "I2C ops", each of which
specifies an I2C slave address, flags controlling message behavior,
and a length of data to be transferred. For write requests, the data
is sent following the array of messages; for read requests, the data
is returned in a response message from the I2C adapter.

Greybus I2C Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-i2c-operation-type` defines the Greybus I2C
operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-i2c-operation-type
    :caption: I2C Operation Types
    :spec: l l l

    ===========================  =============  ==============
    I2C Operation Type           Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Functionality                0x02           0x82
    Timeout                      0x03           0x83
    Retries                      0x04           0x84
    Transfer                     0x05           0x85
    (all other values reserved)  0x06..0x7f     0x86..0xff
    ===========================  =============  ==============

Greybus I2C Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2C protocol version operation allows the protocol
handling software on both ends of a connection to negotiate the
version of the I2C protocol to use.

Greybus I2C Protocol Version Request
""""""""""""""""""""""""""""""""""""

The Greybus I2C protocol version request message has no payload.

Greybus I2C Protocol Version Response
"""""""""""""""""""""""""""""""""""""

The Greybus I2C protocol version response payload contains two
one-byte values, as defined in table
:num:`table-i2c-protocol-version-response`.
A Greybus I2C controller adhering to the protocol specified herein
shall report major version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-i2c-protocol-version-response
    :caption: I2C Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      I2C protocol major version
    1        version_minor   1       |gb-minor|      I2C protocol minor version
    =======  ==============  ======  ==========      ===========================

Greybus I2C Functionality Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2C functionality operation allows the requestor to
determine the details of the functionality provided by the I2C
adapter.

Greybus I2C Functionality Request
"""""""""""""""""""""""""""""""""

The Greybus I2C functionality request message has no payload.

Greybus I2C Functionality Response
""""""""""""""""""""""""""""""""""

Table :num:`table-i2c-functionality-response` defines the Greybus I2C
functionality response. The response contains a four-byte value
whose bits represent support or presence of certain functionality in
the I2C adapter.

.. figtable::
    :nofig:
    :label: table-i2c-functionality-response
    :caption: I2C Protocol Functionality Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        functionality   4       Number          :ref:`i2c-functionality-bits`
    =======  ==============  ======  ==========      ===========================

.. _i2c-functionality-bits:

Greybus I2C Functionality Bit Masks
"""""""""""""""""""""""""""""""""""

Table :num:`table-i2c-functionality-bit-mask` defines the
functionality bit masks for Greybus I2C adapters. These include a set
of bits describing SMBus capabilities.  These values are taken
directly from the <linux/i2c.h> header file.

.. figtable::
    :nofig:
    :label: table-i2c-functionality-bit-mask
    :caption: I2C Functionality Bit Masks
    :spec: l l l

    ===============================  ===================================================  ========================
    Linux Symbol                     Brief Description                                    Mask Value
    ===============================  ===================================================  ========================
    I2C_FUNC_I2C                     Basic I2C protocol (not SMBus) support               0x00000001
    I2C_FUNC_10BIT_ADDR              10-bit addressing is supported                       0x00000002
    |_|                              (Reserved)                                           0x00000004
    I2C_FUNC_SMBUS_PEC               SMBus CRC-8 byte added to transfers (PEC)            0x00000008
    I2C_FUNC_NOSTART                 Repeated start sequence can be skipped               0x00000010
    |_|                              (Reserved range)                                     0x00000020..0x00004000
    I2C_FUNC_SMBUS_BLOCK_PROC_CALL   SMBus block write-block read process call supported  0x00008000
    I2C_FUNC_SMBUS_QUICK             SMBus write_quick command supported                  0x00010000
    I2C_FUNC_SMBUS_READ_BYTE         SMBus read_byte command supported                    0x00020000
    I2C_FUNC_SMBUS_WRITE_BYTE        SMBus write_byte command supported                   0x00040000
    I2C_FUNC_SMBUS_READ_BYTE_DATA    SMBus read_byte_data command supported               0x00080000
    I2C_FUNC_SMBUS_WRITE_BYTE_DATA   SMBus write_byte_data command supported              0x00100000
    I2C_FUNC_SMBUS_READ_WORD_DATA    SMBus read_word_data command supported               0x00200000
    I2C_FUNC_SMBUS_WRITE_WORD_DATA   SMBus write_word_data command supported              0x00400000
    I2C_FUNC_SMBUS_PROC_CALL         SMBus process_call command supported                 0x00800000
    I2C_FUNC_SMBUS_READ_BLOCK_DATA   SMBus read_block_data command supported              0x01000000
    I2C_FUNC_SMBUS_WRITE_BLOCK_DATA  SMBus write_block_data command supported             0x02000000
    I2C_FUNC_SMBUS_READ_I2C_BLOCK    SMBus read_i2c_block_data command supported          0x04000000
    I2C_FUNC_SMBUS_WRITE_I2C_BLOCK   SMBus write_i2c_block_data command supported         0x08000000
    |_|                              (All other values reserved)                          0x10000000..0x80000000
    ===============================  ===================================================  ========================

Greybus I2C Set Timeout Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2C set timeout operation allows the requestor to set the
timeout value to be used by the I2C adapter for non-responsive slave
devices.

Greybus I2C Set Timeout Request
"""""""""""""""""""""""""""""""

Table :num:`table-i2c-set-timeout-request` defines the Greybus I2C set
timeout request. The request contains a 16-bit value representing the
timeout to be used by an I2C adapter, expressed in milliseconds. If
the value supplied is zero, an I2C adapter-defined value shall be
used.

.. figtable::
    :nofig:
    :label: table-i2c-set-timeout-request
    :caption: I2C Protocol Set Timeout Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        msec            2       Number          Timeout period in milliseconds
    =======  ==============  ======  ==========      ===========================

Greybus I2C Set Timeout Response
""""""""""""""""""""""""""""""""

The Greybus I2C set timeout response message has no payload.

Greybus I2C Set Retries Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2C set retries operation allows the requestor to set the
number of times the I2C adapter retries I2C messages.

Greybus I2C Set Retries Request
"""""""""""""""""""""""""""""""

Table :num:`table-i2c-set-retries-request` defines theq Greybus I2C
set timeout request. The request contains an eight-bit value
representing the number of retries to be used by an I2C adapter.

.. figtable::
    :nofig:
    :label: table-i2c-set-retries-request
    :caption: I2C Protocol Set Retries Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        count           1       Number          Retry count
    =======  ==============  ======  ==========      ===========================

Greybus I2C Set Retries Response
""""""""""""""""""""""""""""""""

The Greybus I2C set retries response message has no payload.

Greybus I2C Transfer Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2C transfer operation requests that the I2C adapter
perform an I2C transaction. The operation consists of a set of one or
more "I2C ops" to be performed by the I2C adapter. The transfer
operation request includes data for each I2C op involving a write
operation.  The data is concatenated (without padding) and is
sent immediately after the set of I2C op descriptors. The
transfer operation response includes data for each I2C op
involving a read operation, with all read data transferred
contiguously.

Greybus I2C Transfer Request
""""""""""""""""""""""""""""

The Greybus I2C transfer request contains a message count, an array of
message descriptors, and a block of zero or more bytes of data to be
written.

**Greybus I2C Op**

Table :num:`table-i2c-op` defines the Greybus I2C op. An I2C op
describes a segment of an I2C transaction.

.. figtable::
    :nofig:
    :label: table-i2c-op
    :caption: I2C Op
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        addr            2       Number          Slave address
    2        flags           2       Number          :ref:`i2c-op-flag-bits`
    4        size            2       Number          Size of data to transfer
    =======  ==============  ======  ==========      ===========================

.. _i2c-op-flag-bits:

Greybus I2C Op Flag Bit Masks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Table :num:`table-i2c-op-flag` defines the defined flag bit masks
defined for Greybus I2C ops. They are taken directly from the
<linux/i2c.h> header file.

.. figtable::
    :nofig:
    :label: table-i2c-op-flag
    :caption: I2C Protocol Op Flag Bit Masks
    :spec: l l l

    ==============  =========================================       ===============
    Linux Symbol    Brief Description                               Mask Value
    ==============  =========================================       ===============
    I2C_M_RD        Data is to be read (from slave to master)       0x0001
    |_|             (Reserved range)                                0x0002..0x0008
    I2C_M_TEN       10-bit addressing is supported                  0x0010
    |_|             (Reserved range)                                0x0020..0x0200
    I2C_M_RECV_LEN  First byte received contains length             0x0400
    |_|             (Reserved range)                                0x0800..0x2000
    I2C_M_NOSTART   Skip repeated start sequence                    0x4000
    |_|             (Reserved)                                      0x8000
    ==============  =========================================       ===============

Table :num:`table-i2c-transfer-request` defines the Greybus I2C
transfer request.

.. figtable::
    :nofig:
    :label: table-i2c-transfer-request
    :caption: I2C Protocol Transfer Request
    :spec: l l c c l

    ===========  ==============  =======  ==============   ===================================
    Offset       Field           Size     Value            Description
    ===========  ==============  =======  ==============   ===================================
    0            op_count        2        Number           Number of I2C ops in transfer
    2            op[1]           6        struct i2c_op    Descriptor for first I2C op in the transfer
    ...          ...             6        struct i2c_op    ...
    2+6*(N-1)    op[N]           6        struct i2c_op    Descriptor for Nth I2C op
    2+6*N        data            6        Data             Data for first write op in the transfer
    ...          ...             ...      Data             Data for last write op on the transfer
    ===========  ==============  =======  ==============   ===================================

Any data to be written follows the last op descriptor.  Data for
the first write op in the array immediately follows the last op in
the array, and no padding shall be inserted between data sent for
distinct I2C ops.

Greybus I2C Transfer Response
"""""""""""""""""""""""""""""

Table :num:`table-i2c-transfer-response` defines the Greybus I2C
transfer response. The response contains the data read as a result
of messages.

.. figtable::
    :nofig:
    :label: table-i2c-transfer-response
    :caption: I2C Protocol Transfer Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ======================================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ======================================
    0        data                    Data            Data for first read op on the transfer
    ...      ...             ...     Data            ...
    ...      ...             ...     Data            Data for last read op on the transfer
    =======  ==============  ======  ==========      ======================================

SDIO Protocol
-------------

TBD

