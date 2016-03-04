.. _bridged-phy-protocols:

Bridged PHY Connection Protocols
================================

This section defines a group of Protocols whose purpose is to support
communication with Modules on the Greybus network which do not comply
with an existing device class Protocol, and which include integrated
circuits using alternative physical interfaces to |unipro|. Modules
which implement any of the Protocols defined in this section are said
to be *non-device class conformant*.

USB Protocol
------------

We support bulk, control, and interrupt transfers, but not
isochronous at this point in time.

Details TBD.

GPIO Protocol
-------------

A connection using the GPIO Protocol on a |unipro| network is used to
manage a simple GPIO controller. Such a GPIO controller implements
from one to 256 GPIO lines. Each of the operations defined below
specifies the line to which the operation applies.

Conceptually, the GPIO Protocol operations are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Refer to :ref:`greybus-protocol-version-operation`.

.. c:function:: int line_count(u8 *count);

    Returns one less than the number of lines managed by the Greybus
    GPIO controller. This means the minimum number of lines is 1 and
    the maximum is 256.

.. c:function:: int activate(u8 which);

    Notifies the GPIO controller that one of its lines has been
    assigned for use.

.. c:function:: int deactivate(u8 which);

    Notifies the GPIO controller that a previously activated line has
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

.. c:function:: void irq_event(u8 which);

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
Protocol operation types and their values. Both the request type and
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
    IRQ Event                    0x0e           N/A
    (all other values reserved)  0x0f..0x7f     0x1f..0xff
    ===========================  =============  ==============

..

Greybus GPIO Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO Protocol Version Operation is the
:ref:`greybus-protocol-version-operation` for the GPIO Protocol.

Greybus implementations adhering to the Protocol specified herein
shall specify the value |gb-major| for the version_major and
|gb-minor| for the version_minor fields found in this Operation's
request and response messages.


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

..

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

..

Greybus GPIO Activate Response
""""""""""""""""""""""""""""""

The Greybus GPIO activate response message has no payload.

Greybus GPIO Deactivate Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO deactivate operation notifies the GPIO controller
that a previously activated line is no longer in use and can be
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

..

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

..

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
    0        direction       1       Number          Direction (0 for output, 1 for input)
    =======  ==============  ======  ==========      ===========================

..

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

..

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
    1        value           1       Number          Initial value (0 is low, 1 is high)
    =======  ==============  ======  ==========      ===========================

..

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

..

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
    0        value           1       Number          Value (0 is low, 1 is high)
    =======  ==============  ======  ==========      ===========================

..

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
    1        value           1       Number          Initial value (0 is low, 1 is high)
    =======  ==============  ======  ==========      ===========================

.. todo::
    Possibly make this a mask to allow multiple values to be set at once.

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

..

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
    1        type            1       Number          :ref:`gpio-irq-type-bits`
    =======  ==============  ======  ==========      ===========================

..

.. _gpio-irq-type-bits:

Greybus GPIO IRQ Type Bits
""""""""""""""""""""""""""

Table :num:`table-gpio-irq-type-bits` describes the defined interrupt
trigger type bit values defined for Greybus GPIO IRQ chips. Only the listed
trigger type values are valid.

.. figtable::
    :nofig:
    :label: table-gpio-irq-type-bits
    :caption: GPIO IRQ Type Bits
    :spec: l l l

    =====================  ===================================================  ==========
    Symbol                 Brief Description                                    Value
    =====================  ===================================================  ==========
    IRQ_TYPE_NONE          No trigger specified, uses default/previous setting  0x00
    IRQ_TYPE_EDGE_RISING   Rising edge triggered                                0x01
    IRQ_TYPE_EDGE_FALLING  Falling edge triggered                               0x02
    IRQ_TYPE_EDGE_BOTH     Rising and falling edge triggered                    0x03
    IRQ_TYPE_LEVEL_HIGH    Level triggered high                                 0x04
    IRQ_TYPE_LEVEL_LOW     Level triggered low                                  0x08
    |_|                    (All other values reserved)                          0x10..0xff
    =====================  ===================================================  ==========

..

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

..

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
    :caption: GPIO IRQ Unmask Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        which           1       Number          Controller-relative GPIO line number
    =======  ==============  ======  ==========      ===========================

..

Greybus GPIO IRQ Unmask Response
""""""""""""""""""""""""""""""""

The Greybus GPIO IRQ unmask response message has no payload.

Greybus GPIO IRQ Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus GPIO IRQ event operation signals to the recipient that a
GPIO IRQ event has occurred on the GPIO Controller.

The GPIO controller is responsible for masking the interrupt before sending the
event.

Note that the GPIO IRQ event operation is unidirectional and has no response.

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

..


SPI Protocol
------------

This section defines the operations used on a connection implementing
the Greybus SPI Protocol. This Protocol allows for management of a SPI
device. The Protocol consists of the operations defined in this
section.

Conceptually, the operations in the Greybus SPI Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Refer to :ref:`greybus-protocol-version-operation`.

.. c:function:: int master_config(u16 *mode, u16 *flags, u32 *bpw_mask, u16 *num_chipselect, u32 *min_speed_hz, u32 *max_speed_hz);

    Returns a set of configuration parameters related to SPI master.

.. c:function:: int device_config(u16 cs, u16 *mode, u8 *bpw, u32 *max_speed_hz, u8 *device_type, u8 *name[32]);

    Returns a set of configuration parameters related to SPI device in a chipselect.

.. c:function:: int transfer(u8 chip_select, u8 mode, u8 count, struct gb_spi_transfer *transfers);

    Performs a SPI transaction as one or more SPI transfers, defined in the
    supplied array.

A transfer is made up of an array of :ref:`gb_spi_transfer <gb_spi_transfer>`
descriptors, each of which specifies SPI master configurations during transfers.
For write requests, the data is sent following the array of messages; for read
requests, the data is returned in a response message from the SPI master.

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
    Master Config                0x02           0x82
    Device Config                0x03           0x83
    Transfer                     0x04           0x84
    (all other values reserved)  0x05..0x7f     0x85..0xff
    ===========================  =============  ==============

..

Greybus SPI Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SPI Protocol Version Operation is the
:ref:`greybus-protocol-version-operation` for the SPI Protocol.

Greybus implementations adhering to the Protocol specified herein
shall specify the value |gb-major| for the version_major and
|gb-minor| for the version_minor fields found in this Operation's
request and response messages.


Greybus SPI Protocol Master Config Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SPI Master Config operation allows the requestor to determine the
details of the configuration parameters by the SPI master. This operation can be
executed at any time, however it shall be executed after the negotiation of the
protocol version. All other operations should be discarded until the successful
execution of this one.

Greybus SPI Protocol Master Config Request
""""""""""""""""""""""""""""""""""""""""""

The Greybus SPI Master Config request message has no payload.

Greybus SPI Protocol Master Config Response
"""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-spi-master-config-response` defines the Greybus SPI Master
Config response. The response contains a set of values representing the support,
limits and default values of certain configurations.

.. figtable::
    :nofig:
    :label: table-spi-master-config-response
    :caption: SPI Protocol Master Config Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        bpw_mask        4       Bit Mask        :ref:'spi-bpw-mask`
    4        min_speed_hz    4       Number          Lower limit for transfer speed
    8        max_speed_hz    4       Number          Higher limit for transfer speed
    10       mode            2       Bit Mask        :ref:`spi-mode-bits`
    12       flags           2       Bit Mask        :ref:`spi-flags-bits`
    14       num_chipselect  1       Number          Maximum chipselect supported by Master
    =======  ==============  ======  ==========      ===========================

..

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

..

.. _spi-bpw-mask:

Greybus SPI Protocol Bits Per Word Mask
"""""""""""""""""""""""""""""""""""""""
The Greybus SPI bits per word mask allows the requestor to determine the mask
indicating which values of bits_per_word are supported by the SPI master. If
set, transfer with unsupported bits_per_word should be rejected. If not set,
this value is simply ignored, and it's up to the individual driver to perform
any validation.

Transfers should be rejected if following expression evaluates to zero:

        master->bits_per_word_mask & (1 << (tx_desc->bits_per_word - 1))

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

..

Greybus SPI Protocol Device Config Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SPI Device Config operation allows the requestor to determine the
details of the configuration parameters of a access-enable device. This
operation can be executed at any time, however it shall be executed after the
the Master Config Operation for each chipselect till the number given by the
num_chipselect in the Master Config Response. All transfer operations for the
device should be discarded until the successful execution of this operation.

Greybus SPI Protocol Device Config Request
""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-spi-device-config-request` describes the Greybus SPI Device
Config request. The request supplies the chip_select which is a unique
identifier between 0 and num_chipselect.

.. figtable::
    :nofig:
    :label: table-spi-device-config-request
    :caption: SPI Device Config Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        chip_select     1       Number          Chip Select Number
    =======  ==============  ======  ==========      ===========================

..

.. _spi-dev-config-response:

Greybus SPI Protocol Device Config Response
"""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-spi-device-config-response` defines the Greybus SPI Device
Config response. The response contains a set of values representing the
limits and default values of certain configurations of a device.

.. figtable::
    :nofig:
    :label: table-spi-device-config-response
    :caption: SPI Protocol Device Config Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        mode            2       Bit Mask        :ref:`spi-mode-bits`
    2        bpw             1       Number          bits per word supported by device
    3        max_speed_hz    4       Number          Higher limit for transfer speed
    7        device_type     1       Number          :ref:`spi-device-type`
    8        name            32      UTF-8           Name and/or Device driver alias
    =======  ==============  ======  ==========      ===========================

..

.. _spi-device-type:

Greybus SPI Protocol Device Type
""""""""""""""""""""""""""""""""

Table :num:`table-spi-device-type` defines the types of device associated with
asked chip-select for Greybus SPI devices. The name field in :ref:`spi-dev-config-response`
shall be ignore if the Device Type is not equal to GB_SPI_SPI_MODALIAS.

.. figtable::
    :nofig:
    :label: table-spi-device-type
    :caption: SPI Protocol Device Type Values
    :spec: l l l

    ===============================  ======================================================  ========================
    Symbol                           Brief Description                                       Value
    ===============================  ======================================================  ========================
    GB_SPI_SPI_DEV                   SPI device is a generic bit bang SPI device             0x00
    GB_SPI_SPI_NOR                   SPI device is a SPI NOR device that supports JEDEC id   0x01
    GB_SPI_SPI_MODALIAS              SPI device driver can be represented by the name field  0x02
    |_|                              (All other values reserved)                             0x03..0xFF
    ===============================  ======================================================  ========================

..

Greybus SPI Transfer Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SPI transfer operation requests that the SPI master perform a SPI
transaction. The operation consists of a set of one or more
:ref:`gb_spi_transfer <gb_spi_transfer>` descriptors, which define data
transfers to be performed by the SPI master. The transfer operation request
includes data for each :ref:`gb_spi_transfer <gb_spi_transfer>` descriptor
involving a write operation.  The data shall be sent immediately following the
:ref:`gb_spi_transfer <gb_spi_transfer>` descriptors (with no intervening pad
bytes).  The transfer operation response includes data for each
:ref:`gb_spi_transfer <gb_spi_transfer>` descriptor involving a read operation,
with all read data transferred contiguously.

Greybus SPI Transfer Request
""""""""""""""""""""""""""""

The Greybus SPI transfer request contains the slave's chip select pin,
its mode, a count of message descriptors, an array of message descriptors,
and a block of zero or more bytes of data to be written.

.. _gb_spi_transfer:

Table :num:`table-spi-transfer-descriptor` defines the **Greybus SPI
gb_spi_transfer descriptor**. This describes the configuration of a segment
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
    11       bits_per_word   1       Number          Select bits per word for this transfer
    12       rdwr            1       Bit Mask        Bit Mask indicating Read (0x01) and/or Write (0x02) transfer type
    =======  ==============  ======  ==========      ===========================

Table :num:`table-spi-transfer-request` defines the Greybus SPI
transfer request.

.. figtable::
    :nofig:
    :label: table-spi-transfer-request
    :caption: SPI Protocol Transfer Request
    :spec: l l c c l

    ==========     ==============  ======    ===============    ===========================
    Offset         Field           Size      Value              Description
    ==========     ==============  ======    ===============    ===========================
    0              chip-select     1         Number             chip-select pin for the slave device
    1              mode            1         Number             :ref:`spi-mode-bits`
    2              count           2         Number             Number of :ref:`gb_spi_transfer <gb_spi_transfer>` descriptors
    4              op[1]           13        Structure          First SPI :ref:`gb_spi_transfer <gb_spi_transfer>` descriptor in the transfer
    ...            ...             13        Structure          ...
    4+13*(N-1)     op[N]           13        Structure          Last SPI :ref:`gb_spi_transfer <gb_spi_transfer>` descriptor
    4+13*N         data            ...       Data               Data for all the write transfers
    ==========     ==============  ======    ===============    ===========================

Any data to be written follows the last :ref:`gb_spi_transfer <gb_spi_transfer>`
descriptor. Data for the first write :ref:`gb_spi_transfer <gb_spi_transfer>`
descriptor in the array immediately follows the last :ref:`gb_spi_transfer
<gb_spi_transfer>` descriptor in the array, and no padding shall be inserted
between data sent for distinct SPI :ref:`gb_spi_transfer <gb_spi_transfer>`
descriptors.

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
    0        data                    Data            Data for first read :ref:`gb_spi_transfer <gb_spi_transfer>` descriptor on the transfer
    ...      ...             ...     Data            ...
    ...      ...             ...     Data            Data for Last read :ref:`gb_spi_transfer <gb_spi_transfer>` descriptor on the transfer
    =======  ==============  ======  ==========      ======================================

..

UART Protocol
-------------

A connection using the UART Protocol on a |unipro| network is used to
manage a simple UART controller.  This Protocol is very close to the
CDC protocol for serial modems from the USB-IF specification, and
consists of the operations defined in this section.

The operations that can be performed on a Greybus UART controller are
conceptually:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Refer to :ref:`greybus-protocol-version-operation`.

.. c:function:: int send_data(u16 size, u8 *data);

    Requests that the UART device begins transmitting characters. One
    or more bytes to be transmitted shall be supplied by the sender.

.. c:function:: int receive_data(u16 size, u8 flags, u8 *data);

    Receive data from the UART and any line errors that might have
    occurred.

.. c:function:: int set_line_coding(u32 rate, u8 format, u8 parity, u8 data);

   Sets the line settings of the UART to the specified baud rate,
   format, parity, and data bits.

.. c:function:: int set_control_line_state(u8 state);

    Controls RTS and DTR line states of the UART.

.. c:function:: int send_break(u8 state);

    Requests that the UART generate a break condition on its transmit
    line.

.. c:function:: int serial_state(u8 state);

    Receives the state of the UART's control lines.

UART Protocol Operations
^^^^^^^^^^^^^^^^^^^^^^^^

This section defines the operations for a connection using the UART
Protocol. The UART Protocol allows a requestor to control a UART device
contained within a Greybus Module.

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

..

Greybus UART Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus UART Protocol Version Operation is the
:ref:`greybus-protocol-version-operation` for the UART Protocol.

Greybus implementations adhering to the Protocol specified herein
shall specify the value |gb-major| for the version_major and
|gb-minor| for the version_minor fields found in this Operation's
request and response messages.


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
to be transmitted.

.. figtable::
    :nofig:
    :label: table-uart-send-data-request
    :caption: UART Protocol Send Data Request
    :spec: l l c c l

    =======  ==============  ======  ===========     ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ===========     ===========================
    0        size            2       Number          Size in bytes of data to be transmitted
    2        data            *size*  Data            1 or more bytes of data to be transmitted
    =======  ==============  ======  ===========     ===========================

..

Greybus UART Send Data Response
"""""""""""""""""""""""""""""""

The Greybus UART send data response message has no payload.

Greybus UART Receive Data Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Unlike most other Greybus UART operations, the Greybus UART event
operation is initiated by the device implementing the UART
Protocol. It notifies its peer that a data has been received by the
UART.

Note that the UART Receive Data Operation is unidirectional and has no response.

Greybus UART Receive Data Request
"""""""""""""""""""""""""""""""""

Table :num:`table-uart-receive-data-request` defines the Greybus UART
receive data request. The request contains the size of the data to be
received, associated line-status flags, and the data bytes to be received.
Every receive-data-request message must have a size field >= 1, with
firmware inserting a NUL byte as necessary when reporting a break event.
Note that overrun is special in that it is not associated with any
particular character.

.. figtable::
    :nofig:
    :label: table-uart-receive-data-request
    :caption: UART Protocol Receive Data Request
    :spec: l l c c l

    =======  ==============  =======  ==========      ===========================
    Offset   Field           Size     Value           Description
    =======  ==============  =======  ==========      ===========================
    0        size            2        Number          Size in bytes of received data
    2        flags           1        Bit mask        :ref:`uart-receive-data-status-flags`
    3        data            *size*   Data            1 or more bytes of received data
    =======  ==============  =======  ==========      ===========================

..

.. _uart-receive-data-status-flags:

Greybus UART Receive Data Status Flags
""""""""""""""""""""""""""""""""""""""

Table :num:`table-uart-receive-data-request` defines the values supplied
as flag values for the Greybus UART receive data request.
Any combination of these values may be supplied in a single request.

.. figtable::
    :nofig:
    :label: table-uart-receive-data-status-flags
    :caption: UART Modem Receive Data Status Flags
    :spec: l l l

    ============================    ==============  ===================
    Flag                            Value           Description
    ============================    ==============  ===================
    Framing Error                   0x01            Framing error detected
    Parity Error                    0x02            Parity error detected
    Overrun                         0x04            Received data lost due to overrun
    Break                           0x08            Break condition detected
    (all other values reserved)     0x10..0x80
    ============================    ==============  ===================

..

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

..

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

..

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

..

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
    0        control         1       Bit mask        :ref:`uart-modem-status-flags`
    =======  ==============  ======  ==========      ===========================

..

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
    DTR                             0x01            Data Terminal Ready
    RTS                             0x02            Request To Send
    (all other values reserved)     0x04..0x80
    ============================    ==============  ===================

..

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
    0        state           1       Number          0 is off, 1 is on
    =======  ==============  ======  ==========      ===========================

..

Greybus UART Break Control Response
"""""""""""""""""""""""""""""""""""

The Greybus UART break control response message has no payload.

Greybus UART Serial State Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Unlike most other Greybus UART operations, the Greybus UART serial
state operation is initiated by the Module implementing the UART
Protocol. It notifies the peer that a control line status has changed,
or that there is an error with the UART.

Note that the UART Serial State Operation is unidirectional and has no response.

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
    0        control         1       Bit mask        :ref:`uart-control-flags`
    =======  ==============  ======  ==========      ===========================

..

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
    DCD                             0x01            Carrier Detect line enabled
    DSR                             0x02            DSR signal
    RI                              0x04            Ring Signal detected
    (all other values reserved)     0x08..0x80
    ============================    ==============  ===================

..

PWM Protocol
------------

A connection using PWM Protocol on a |unipro| network is used to manage
a simple PWM controller. Such a PWM controller implements one or more
(up to 256) PWM devices, and each of the operations below specifies
the line to which the operation applies. This Protocol consists of the
operations defined in this section.

Conceptually, the PWM Protocol operations are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Refer to :ref:`greybus-protocol-version-operation`.

.. c:function:: int pwm_count(u8 *count);

    Returns one less than the number of instances managed by the
    Greybus PWM controller. This means the minimum number of PWMs is 1
    and the maximum is 256.

.. c:function:: int activate(u8 which);

    Notifies the PWM controller that one of its instances has been
    assigned for use.

.. c:function:: int deactivate(u8 which);

    Notifies the PWM controller that a previously activated instance
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

Table :num:`table-pwm-operation-type` describes the Greybus PWM Protocol
operation types and their values. Both the request type and response type values
are shown.

.. figtable::
    :nofig:
    :label: table-pwm-operation-type
    :caption: PWM Operation Types
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

..

Greybus PWM Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM Protocol Version Operation is the
:ref:`greybus-protocol-version-operation` for the PWM Protocol.

Greybus implementations adhering to the Protocol specified herein
shall specify the value |gb-major| for the version_major and
|gb-minor| for the version_minor fields found in this Operation's
request and response messages.

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

..

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

..

Greybus PWM Activate Response
"""""""""""""""""""""""""""""

The Greybus PWM activate response message has no payload.

Greybus PWM Deactivate Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus PWM instance deactivate operation notifies the PWM
controller that a previously activated instance is no longer in use
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

..

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

..

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

..

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

..

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

..

Greybus PWM Disable Response
""""""""""""""""""""""""""""

The Greybus PWM disable response message has no payload.

I2C Protocol
------------

This section defines the operations used on a connection implementing
the Greybus I2C Protocol. This Protocol allows for management of an I2C
device present on a Module. The Protocol consists of five basic
operations, whose request and response message formats are defined
here.

Conceptually, the five operations in the Greybus I2C Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Refer to :ref:`greybus-protocol-version-operation`.

.. c:function:: int get_functionality(u32 *functionality);

    Returns a bitmask indicating the features supported by the I2C
    adapter.

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
    Reserved                     0x03           0x83
    Reserved                     0x04           0x84
    Transfer                     0x05           0x85
    (all other values reserved)  0x06..0x7f     0x86..0xff
    ===========================  =============  ==============

..

Greybus I2C Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus I2C Protocol Version Operation is the
:ref:`greybus-protocol-version-operation` for the I2C Protocol.

Greybus implementations adhering to the Protocol specified herein
shall specify the value |gb-major| for the version_major and
|gb-minor| for the version_minor fields found in this Operation's
request and response messages.


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

..

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

..

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

Table :num:`table-i2c-op` defines the **Greybus I2C op**. An I2C op
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

..

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

..

Table :num:`table-i2c-transfer-request` defines the Greybus I2C
transfer request.

.. figtable::
    :nofig:
    :label: table-i2c-transfer-request
    :caption: I2C Protocol Transfer Request
    :spec: l l c c l

    ===========  ==============  =======  ==========   ===================================
    Offset       Field           Size     Value        Description
    ===========  ==============  =======  ==========   ===================================
    0            op_count        2        Number       Number of I2C ops in transfer
    2            op[1]           6        Structure    Descriptor for first I2C op in the transfer
    ...          ...             6        Structure    ...
    2+6*(N-1)    op[N]           6        Structure    Descriptor for last I2C op
    2+6*N        data            6        Data         Data for first write op in the transfer
    ...          ...             ...      Data         Data for last write op on the transfer
    ===========  ==============  =======  ==========   ===================================

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

..

SDIO Protocol
-------------

This section defines the operations used on a connection
implementing the Greybus SDIO Protocol. This Protocol allows for
management of a SDIO device present on a Module. The Protocol
consists of operations, whose request and response message
formats are defined here.

Conceptually, the operations in the Greybus SDIO Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Refer to :ref:`greybus-protocol-version-operation`.

.. c:function:: int get_capabilities(u32 *caps, u32 *ocr, u16 *max_blk_count, u16 *max_blk_size);

   Request the SDIO controller to return a set of capabilities
   available, supported voltage ranges and maximum block count/size
   per data command transfer.

.. c:function:: int set_ios(struct gb_sdio_ios *ios);

    Request the SDIO controller to setup various parameters
    related with the interface.

.. c:function:: int command(u8 cmd, u8 cmd_flags, u8 cmd_type, u32 arg, u32 *resp[4]);

    Send a control command as specified by the SD Association and
    return the correspondent response.

.. c:function:: int transfer(u8 data_flags, u16 *data_blocks, u16 *data_blksz, u8 *data);

    Performs a SDIO data transaction defined by the size to be
    send/received.

.. c:function:: int sdio_event(u8 event);

    The SDIO controller notifies the recipient of SD card related
    events.


Greybus SDIO Protocol Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All operations sent to a SDIO controller are contained within a
Greybus SDIO request message. Every operation request results in
a matching response from the SDIO controller, also taking the
form of a SDIO controller message.  The request and response
messages for each SDIO operation are defined below.

Table :num:`table-sdio-operation-type` defines the Greybus SDIO
Protocol operation types and their values. Both the request type
and response type values are shown.

.. figtable::
    :nofig:
    :label: table-sdio-operation-type
    :caption: SDIO Operation Types
    :spec: l l l

    ===========================  =============  ==============
    SDIO Operation Type          Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Get Capabilities             0x02           0x82
    Set Ios                      0x03           0x83
    Command                      0x04           0x84
    Transfer                     0x05           0x85
    Event                        0x06           N/A
    (all other values reserved)  0x07..0x7f     0x87..0xff
    ===========================  =============  ==============

..

Greybus SDIO Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SDIO Protocol Version Operation is the
:ref:`greybus-protocol-version-operation` for the SDIO Protocol.

Greybus implementations adhering to the Protocol specified herein
shall specify the value |gb-major| for the version_major and
|gb-minor| for the version_minor fields found in this Operation's
request and response messages.

Greybus SDIO Get Capabilities Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SDIO Get Capabilities operation allows the requester to
fetch capabilities that are supported by the Controller.

Greybus SDIO Get Capabilities Request
"""""""""""""""""""""""""""""""""""""

The Greybus SDIO Get Capabilities request message has no payload.

Greybus SDIO Get Capabilities Response
""""""""""""""""""""""""""""""""""""""

The Greybus SDIO Get Capabilities response message returns value whose
bits represent the support of certain capability from the SDIO
controller, as defined in table :num:`table-sdio-get-caps-response`.


.. figtable::
    :nofig:
    :label: table-sdio-get-caps-response
    :caption: SDIO Protocol Get Capabilities Response
    :spec: l l c c l

    =========    ==============  ======  ==========      ===========================
    Offset       Field           Size    Value           Description
    =========    ==============  ======  ==========      ===========================
    0            caps            4       Bit Mask        :ref:`sdio-caps-bits`
    4            ocr             4       Bit Mask        :ref:`sdio-voltage-range`
    8            f_min           4       Number          Minimum frequency supported by the controller
    12           f_max           4       Number          Maximum frequency supported by the controller
    16           max_blk_count   2       Number          Maximum Number of blocks per data command transfer
    18           max_blk_size    2       Number          Maximum size of each block to transfer
    =========    ==============  ======  ==========      ===========================

..

.. _sdio-caps-bits:

Greybus SDIO Get Capabilities Bit Masks
"""""""""""""""""""""""""""""""""""""""
Table :num:`table-sdio-get-caps` define the Capabilities bit masks for
Greybus SDIO.

.. figtable::
    :nofig:
    :label: table-sdio-get-caps
    :caption: SDIO Protocol Get Capabilities Bit Masks
    :spec: l l l

    ===============================  ======================================================  ========================
    Symbol                           Brief Description                                       Mask Value
    ===============================  ======================================================  ========================
    GB_SDIO_CAP_NONREMOVABLE         Device is unremovable from the slot                     0x00000001
    GB_SDIO_CAP_4_BIT_DATA           Host support 4 bit transfers                            0x00000002
    GB_SDIO_CAP_8_BIT_DATA           Host support 8 bit transfers                            0x00000004
    GB_SDIO_CAP_MMC_HS               Host support mmc high-speed timings                     0x00000008
    GB_SDIO_CAP_SD_HS                Host support SD high-speed timings                      0x00000010
    GB_SDIO_CAP_ERASE                Host allow erase and trim commands                      0x00000020
    GB_SDIO_CAP_1_2V_DDR             Host support DDR mode at 1.2V                           0x00000040
    GB_SDIO_CAP_1_8V_DDR             Host support DDR mode at 1.8V                           0x00000080
    GB_SDIO_CAP_POWER_OFF_CARD       Host can power off card                                 0x00000100
    GB_SDIO_CAP_UHS_SDR12            Host support UHS SDR12 mode                             0x00000200
    GB_SDIO_CAP_UHS_SDR25            Host support UHS SDR25 mode                             0x00000400
    GB_SDIO_CAP_UHS_SDR50            Host support UHS SDR50 mode                             0x00000800
    GB_SDIO_CAP_UHS_SDR104           Host support UHS SDR104 mode                            0x00001000
    GB_SDIO_CAP_UHS_DDR50            Host support UHS DDR50 mode                             0x00002000
    GB_SDIO_CAP_DRIVER_TYPE_A        Host support Driver Type A                              0x00004000
    GB_SDIO_CAP_DRIVER_TYPE_C        Host support Driver Type C                              0x00008000
    GB_SDIO_CAP_DRIVER_TYPE_D        Host support Driver Type D                              0x00010000
    GB_SDIO_CAP_HS200_1_2V           Host support HS200 mode at 1.2V                         0x00020000
    GB_SDIO_CAP_HS200_1_8V           Host support HS200 mode at 1.8V                         0x00040000
    GB_SDIO_CAP_HS400_1_2V           Host support HS400 mode at 1.2V                         0x00080000
    GB_SDIO_CAP_HS400_1_8V           Host support HS400 mode at 1.8V                         0x00100000
    |_|                              (All other mask values reserved)                        0x00200000..0x80000000
    ===============================  ======================================================  ========================

..

Greybus SDIO Set Ios Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SDIO Set Ios operation allows the requester to setup
parameters listed in to SDIO controller

Greybus SDIO Set Ios Request
""""""""""""""""""""""""""""

Table :num:`table-sdio-setios-request` defines the Greybus SDIO Set
Ios request. The request shall pass a descriptor which contains a set
of parameters for configuring the SDIO controller.

.. figtable::
    :nofig:
    :label: table-sdio-setios-request
    :caption: SDIO Protocol Set Ios Request
    :spec: l l c c l

    =======  ==============  ======  ===========     ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ===========     ===========================
    0        op              14      Structure       SDIO gb_sdio_ios descriptor
    =======  ==============  ======  ===========     ===========================

Table :num:`table-sdio-setios-descriptor` defines the Greybus SDIO
gb_sdio_ios. This describes the parameters to configure the SDIO
controller.

.. figtable::
    :nofig:
    :label: table-sdio-setios-descriptor
    :caption: SDIO Protocol Set Ios Descriptor
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        clock           4       Number          clock rate in Hz 
    4        vdd             4       Number          :ref:`sdio-voltage-range`
    8        bus_mode        1       Number          :ref:`sdio-bus-mode`
    9        power_mode      1       Number          :ref:`sdio-power-mode`
    10       bus_width       1       Number          :ref:`sdio-bus-width`
    11       timing          1       Number          :ref:`sdio-timing`
    12       signal_voltage  1       Number          :ref:`sdio-signal-voltage`
    13       drv_type        1       Number          :ref:`sdio-driver-type`
    =======  ==============  ======  ==========      ===========================

..

.. _sdio-voltage-range:

Greybus SDIO Protocol Voltage Range Bit Mask
""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-sdio-voltage-range` defines the voltage ranges bit
masks for the Greybus SDIO controllers.

.. figtable::
    :nofig:
    :label: table-sdio-voltage-range
    :caption: SDIO Protocol Voltage Range Bit Masks
    :spec: l l l

    ===============================  ======================================================  ========================
    Symbol                           Brief Description                                       Mask Value
    ===============================  ======================================================  ========================
    GB_SDIO_VDD_165_195              VDD voltage 1.65 - 1.95                                 0x00000001
    GB_SDIO_VDD_20_21                VDD voltage 2.0 ~ 2.1                                   0x00000002
    GB_SDIO_VDD_21_22                VDD voltage 2.1 ~ 2.2                                   0x00000004
    GB_SDIO_VDD_22_23                VDD voltage 2.2 ~ 2.3                                   0x00000008
    GB_SDIO_VDD_23_24                VDD voltage 2.3 ~ 2.4                                   0x00000010
    GB_SDIO_VDD_24_25                VDD voltage 2.4 ~ 2.5                                   0x00000020
    GB_SDIO_VDD_25_26                VDD voltage 2.5 ~ 2.6                                   0x00000040
    GB_SDIO_VDD_26_27                VDD voltage 2.6 ~ 2.7                                   0x00000080
    GB_SDIO_VDD_27_28                VDD voltage 2.7 ~ 2.8                                   0x00000100
    GB_SDIO_VDD_28_29                VDD voltage 2.8 ~ 2.9                                   0x00000200
    GB_SDIO_VDD_29_30                VDD voltage 2.9 ~ 3.0                                   0x00000400
    GB_SDIO_VDD_30_31                VDD voltage 3.0 ~ 3.1                                   0x00000800
    GB_SDIO_VDD_31_32                VDD voltage 3.1 ~ 3.2                                   0x00001000
    GB_SDIO_VDD_32_33                VDD voltage 3.2 ~ 3.3                                   0x00002000
    GB_SDIO_VDD_33_34                VDD voltage 3.3 ~ 3.4                                   0x00004000
    GB_SDIO_VDD_34_35                VDD voltage 3.4 ~ 3.5                                   0x00008000
    GB_SDIO_VDD_35_36                VDD voltage 3.5 ~ 3.6                                   0x00010000
    |_|                              (All other mask values reserved)                        0x00020000..0x80000000
    ===============================  ======================================================  ========================

..

.. _sdio-bus-mode:

Greybus SDIO Protocol Bus Mode
""""""""""""""""""""""""""""""

Table :num:`table-sdio-bus-mode` defines the Mode in which the Bus
should be set for operation.

.. figtable::
    :nofig:
    :label: table-sdio-bus-mode
    :caption: SDIO Protocol Bus Mode
    :spec: l l l

    ===============================  ======================================================  ========================
    Symbol                           Brief Description                                       Value
    ===============================  ======================================================  ========================
    GB_SDIO_BUSMODE_OPENDRAIN        SDIO open drain bus mode                                0x00
    GB_SDIO_BUSMODE_PUSHPULL         SDIO push-pull bus mode                                 0x01
    |_|                              (All other values reserved)                             0x02..0xff
    ===============================  ======================================================  ========================

..

.. _sdio-power-mode:

Greybus SDIO Protocol Power Mode
""""""""""""""""""""""""""""""""

Table :num:`table-sdio-power-mode` defines the power supply mode in
which the slot should be set.

.. figtable::
    :nofig:
    :label: table-sdio-power-mode
    :caption: SDIO Protocol Power Mode
    :spec: l l l

    ===============================  ======================================================  ========================
    Symbol                           Brief Description                                       Value
    ===============================  ======================================================  ========================
    GB_SDIO_POWER_OFF                SDIO power off                                          0x00
    GB_SDIO_POWER_UP                 SDIO power up                                           0x01
    GB_SDIO_POWER_ON                 SDIO power on                                           0x02
    GB_SDIO_POWER_UNDEFINED          SDIO power undefined                                    0x03
    |_|                              (All other values reserved)                             0x04..0xff
    ===============================  ======================================================  ========================

..

.. _sdio-bus-width:

Greybus SDIO Protocol Bus Width
"""""""""""""""""""""""""""""""

Table :num:`table-sdio-bus-width` defines the values in which the data
bus width can be set.

.. figtable::
    :nofig:
    :label: table-sdio-bus-width
    :caption: SDIO Protocol Bus Width
    :spec: l l l

    ===============================  ======================================================  ========================
    Symbol                           Brief Description                                       Value
    ===============================  ======================================================  ========================
    GB_SDIO_BUS_WIDTH_1              SDIO data bus width 1 bit mode                          0x00
    GB_SDIO_BUS_WIDTH_4              SDIO data bus width 4 bit mode                          0x02
    GB_SDIO_BUS_WIDTH_8              SDIO data bus width 8 bit mode                          0x03
    |_|                              (All other values reserved)                             0x04..0xff
    ===============================  ======================================================  ========================

..

.. _sdio-timing:

Greybus SDIO Protocol Timing
""""""""""""""""""""""""""""

Table :num:`table-sdio-timing` defines the timing specification values
for the bus.

.. figtable::
    :nofig:
    :label: table-sdio-timing
    :caption: SDIO Protocol Timing
    :spec: l l l

    ===============================  ======================================================  ========================
    Symbol                           Brief Description                                       Value
    ===============================  ======================================================  ========================
    GB_SDIO_TIMING_LEGACY            Default speed                                           0x00
    GB_SDIO_TIMING_MMC_HS            MMC High speed                                          0x01
    GB_SDIO_TIMING_SD_HS             SD High speed                                           0x02
    GB_SDIO_TIMING_UHS_SDR12         Ultra High Speed SDR12                                  0x03
    GB_SDIO_TIMING_UHS_SDR25         Ultra High Speed SDR25                                  0x04
    GB_SDIO_TIMING_UHS_SDR50         Ultra High Speed SDR50                                  0x05
    GB_SDIO_TIMING_UHS_SDR104        Ultra High Speed SDR104                                 0x06
    GB_SDIO_TIMING_UHS_DDR50         Ultra High Speed DDR50                                  0x07
    GB_SDIO_TIMING_MMC_DDR52         MMC DDR52                                               0x08
    GB_SDIO_TIMING_MMC_HS200         MMC HS200                                               0x09
    GB_SDIO_TIMING_MMC_HS400         MMC HS400                                               0x0A
    |_|                              (All other values reserved)                             0x0B..0xff
    ===============================  ======================================================  ========================

..

.. _sdio-signal-voltage:

Greybus SDIO Protocol Signal Voltage
""""""""""""""""""""""""""""""""""""

Table :num:`table-sdio-signal-voltage` defines the signal voltage
values allowed to be set for the bus.

.. figtable::
    :nofig:
    :label: table-sdio-signal-voltage
    :caption: SDIO Protocol Signal Voltage
    :spec: l l l

    ===============================  ======================================================  ========================
    Symbol                           Brief Description                                       Value
    ===============================  ======================================================  ========================
    GB_SDIO_SIGNAL_VOLTAGE_330       Signal Voltage = 3.30V                                  0x00
    GB_SDIO_SIGNAL_VOLTAGE_180       Signal Voltage = 1.80V                                  0x01
    GB_SDIO_SIGNAL_VOLTAGE_120       Signal Voltage = 1.20V                                  0x02
    |_|                              (All other values reserved)                             0x03..0xff
    ===============================  ======================================================  ========================

..

.. _sdio-driver-type:

Greybus SDIO Protocol Driver Type
"""""""""""""""""""""""""""""""""

Table :num:`table-sdio-driver-type` defines the driver strength types
in which the Controller shall be configured.

.. figtable::
    :nofig:
    :label: table-sdio-driver-type
    :caption: SDIO Protocol Driver Type
    :spec: l l l

    ===============================  ======================================================  ========================
    Symbol                           Brief Description                                       Value
    ===============================  ======================================================  ========================
    GB_SDIO_SET_DRIVER_TYPE_B        Driver Type B                                           0x00
    GB_SDIO_SET_DRIVER_TYPE_A        Driver Type A                                           0x01
    GB_SDIO_SET_DRIVER_TYPE_C        Driver Type C                                           0x02
    GB_SDIO_SET_DRIVER_TYPE_D        Driver Type D                                           0x03
    |_|                              (All other values reserved)                             0x04..0xff
    ===============================  ======================================================  ========================

..

Greybus SDIO Set Ios Response
"""""""""""""""""""""""""""""

The Greybus SDIO Set Ios response message has no payload.

Greybus SDIO Command Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SDIO Command operation allows the requester to send
control commands as specified by the SD Association to the SDIO
controller.


Greybus SDIO Command Request
""""""""""""""""""""""""""""

Table :num:`table-sdio-command-request` defines the Greybus SDIO
Command request.


.. figtable::
    :nofig:
    :label: table-sdio-command-request
    :caption: SDIO Protocol Command Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        cmd             1       Number          SDIO command operation code, as specified by SD Association
    1        cmd_flags       1       Bit Mask        :ref:`sdio-cmd-flags`
    2        cmd_type        1       Number          :ref:`sdio-cmd-type`
    3        arg             4       Number          SDIO command arguments, as specified by SD Association
    7        data_blocks     2       Number          If data is available, represents the number of total blocks to transfer, 0 otherwise
    9        data_blksz      2       Number          If data is available, represents the size of the blocks to transfer, 0 otherwise
    =======  ==============  ======  ==========      ===========================

..

.. _sdio-cmd-flags:

Greybus SDIO Protocol Command Flags
"""""""""""""""""""""""""""""""""""
Table :num:`table-sdio-cmd-flags` defines the flags that can be passed
to a command.

.. figtable::
    :nofig:
    :label: table-sdio-cmd-flags
    :caption: SDIO Protocol Command Flags
    :spec: l l l

    ===============================  ======================================================  ========================
    Symbol                           Brief Description                                       Mask Value
    ===============================  ======================================================  ========================
    GB_SDIO_RSP_NONE                 No Response is expected by the command                  0x00
    GB_SDIO_RSP_PRESENT              Response is expected by the command                     0x01
    GB_SDIO_RSP_136                  Long response is expected by the command                0x02
    GB_SDIO_RSP_CRC                  A valid CRC is expected by the command                  0x04
    GB_SDIO_RSP_BUSY                 Card may send a busy response                           0x08
    GB_SDIO_RSP_OPCODE               Response contains opcode                                0x10
    |_|                              (All other values reserved)                             0x20..0xff
    ===============================  ======================================================  ========================

..

.. _sdio-cmd-type:

Greybus SDIO Protocol Command Type
""""""""""""""""""""""""""""""""""
Table :num:`table-sdio-cmd-type` defines the command type passed to
the MMC/SD card.

.. figtable::
    :nofig:
    :label: table-sdio-cmd-type
    :caption: SDIO Protocol Command Type
    :spec: l l l

    ===============================  ======================================================  ========================
    Symbol                           Brief Description                                       Value
    ===============================  ======================================================  ========================
    GB_SDIO_CMD_AC                   Addressed Command                                       0x00
    GB_SDIO_CMD_ADTC                 Addressed Data Transfer Command                         0x01
    GB_SDIO_CMD_BC                   Broadcasted Command, no response                        0x02
    GB_SDIO_CMD_BCR                  Broadcasted Command with response                       0x03
    |_|                              (All other values reserved)                             0x04..0xff
    ===============================  ======================================================  ========================

..

Greybus SDIO Command Response
"""""""""""""""""""""""""""""

Table :num:`table-sdio-command-response` defines the Greybus SDIO
Command response.

.. figtable::
    :nofig:
    :label: table-sdio-command-response
    :caption: SDIO Protocol Command Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        resp            16      Number          SDIO command response, as specified by SD Association
    =======  ==============  ======  ==========      ===========================

..

Greybus SDIO Transfer Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SDIO Transfer operation allows the requester to send
or receive data blocks and shall be preceded by a Greybus Command
Request for data transfer command as specified by SD Association.

Greybus SDIO Transfer Request
"""""""""""""""""""""""""""""

Table :num:`table-sdio-transfer-request` defines the Greybus SDIO
Transfer request.

.. figtable::
    :nofig:
    :label: table-sdio-transfer-request
    :caption: SDIO Protocol Transfer Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        data_flags      1       Number          SDIO data flags
    1        data_blocks     2       Number          SDIO number of blocks of data to transfer
    3        data_blksz      2       Number          SDIO size of the blocks of data to transfer
    5        data            ...     Data            SDIO Data
    =======  ==============  ======  ==========      ===========================

..


.. figtable::
    :nofig:
    :label: table-sdio-data-flags
    :caption: SDIO Protocol Transfer Data Flags
    :spec: l l l

    ===============================  ======================================================  ========================
    Symbol                           Brief Description                                       Value
    ===============================  ======================================================  ========================
    GB_SDIO_DATA_WRITE               Data present in data_blocks request to be written       0x01
    GB_SDIO_DATA_READ                Data present in data_blocks response to be read         0x02
    GB_SDIO_DATA_STREAM              Data will be transfer until a cancel command is send    0x04
    |_|                              (All other values reserved)                             0x08..0x80
    ===============================  ======================================================  ========================

If data_flags field have the GB_SDIO_DATA_WRITE flag set, the size
field define the length in bytes of data to be transfer in
the data field. If data_flags field have the GB_SDIO_DATA_READ
set, the size field define the length of data
to be read and for that the data field is empty.

Greybus SDIO Transfer Response
""""""""""""""""""""""""""""""

Table :num:`table-sdio-transfer-response` defines the Greybus SDIO
Transfer response.

.. figtable::
    :nofig:
    :label: table-sdio-transfer-response
    :caption: SDIO Protocol Transfer Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        data_blocks     2       Number          SDIO number of blocks of data to transfer
    2        data_blksz      2       Number          SDIO size of the blocks of data to transfer
    4        data            ...     Data            SDIO Data
    =======  ==============  ======  ==========      ===========================

If Request data_flags field have the GB_SDIO_DATA_WRITE flag set, the
size field represent the size of data received in the Request in case
of success. If data_flags field have the GB_SDIO_DATA_READ set, the
size field defines the length of the data appended in the data field.

Greybus SDIO Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus SDIO Event operation signals to the recipient that
a change in the device setup have occurred in the SDIO controller.

This operation is unidirectional and does not have a correspondent
response.

Greybus SDIO Event Request
""""""""""""""""""""""""""

Table :num:`table-sdio-event-request` defines the Greybus SDIO Event
Request. The Request supplies the one-byte event that has occurred on
the sending controller.

.. figtable::
    :nofig:
    :label: table-sdio-event-request
    :caption: SDIO Protocol Detect Event Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        event           1       Bit Mask        :ref:`sdio-event-bits`
    =======  ==============  ======  ==========      ===========================

..

.. _sdio-event-bits:

Greybus SDIO Event Bit Masks
""""""""""""""""""""""""""""

Table :num:`table-sdio-event-bit-mask` defines the bit masks which
specify the set of events that a controller can trigger related to SD
card. If card have the GB_SDIO_CAP_NONREMOVABLE capability, the
card detection events shall be ignored.

.. figtable::
    :nofig:
    :label: table-sdio-event-bit-mask
    :caption: SDIO Protocol Event Bit Mask
    :spec: l l l

    ===============================  =============================  ===============
    Symbol                           Brief Description              Mask Value
    ===============================  =============================  ===============
    GB_SDIO_CARD_INSERTED            Card insertion detect          0x01
    GB_SDIO_CARD_REMOVED             Card removed detect            0x02
    GB_SDIO_WP                       Card Write Protect Switch      0x04
    |_|                              (All other values reserved)    0x08..0x80
    ===============================  =============================  ===============
