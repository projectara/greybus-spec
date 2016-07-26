Lights Protocol
---------------

This section defines operations used on a connection implementing the Greybus
Lights Protocol. This Protocol allows an AP Module to control Lights devices
present on a Module. The Protocol consists of some basic operations that are
defined here.

The operations in the Greybus Lights Protocol are:

.. c:function:: int cport_shutdown(u8 phase);

    See :ref:`greybus-protocol-cport-shutdown-operation`.

.. c:function:: int get_lights(u8 *lights_count);

   Return the number of lights devices supported. lights_id used
   in the following operations are sequential increments from 0 to
   lights_count less one.

.. c:function:: int get_light_config(u8 light_id, u8 *channel_count, u8 *name[32]);

   Request the number of channels controlled by a light controller
   and its name, providing a valid identifier for that light.
   channel_id used in the following operations are sequential
   increments from 0 to channel_count less one.


.. c:function:: int get_channel_config(u8 light_id, u8 channel_id, struct gb_channel_config *config);

   Request a set of configuration parameters related to a channel in a
   light controller. The return structure elements shall map the fields
   of :ref:`lights-get-channel-config-response`.

.. c:function:: int get_channel_flash_config(u8 light_id, u8 channel_id, struct gb_channel_flash_config *flash_config);

   Request a set of flash configuration parameters related to a
   channel in a light controller. The return structure elements shall
   map the fields of :ref:`lights-get-channel-flash-config-response`

.. c:function:: int set_blink(u8 light_id, u8 channel_id, u16 time_on_ms, u16 time_off_ms);

   Set hardware blink if supported by the device, the time values are
   specified in milliseconds. Setting time values to 0 shall disable
   blink.

.. c:function:: int set_brightness(u8 light_id, u8 channel_id, u8 brightness);

   Set the level of brightness with the specified value.

.. c:function:: int set_color(u8 light_id, u8 channel_id, u32 color);

   Set color code with the specified value.

.. c:function:: int set_fade(u8 light_id, u8 channel_id, u32 fade_in, u32 fade_out);

   Set fade in and out level with the specified values.

.. c:function:: int set_flash_intensity(u8 light_id, u8 channel_id, u32 intensity_uA);

   Set flash current intensity in micro Amperes with the specified
   value.

.. c:function:: int set_flash_strobe(u8 light_id, u8 channel_id, u8 state);

   Set flash strobe state with the specified value, value 0 means
   strobe off other value means strobe on.

.. c:function:: int set_flash_timeout(u8 light_id, u8 channel_id, u32 timeout_us);

   Set flash timeout value in micro seconds with the specified value.

.. c:function:: int get_flash_fault(u8 light_id, u8 channel_id, *u32 fault);

   Get flash fault status from controller.

Greybus Lights Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-lights-operation-type` describes the Greybus Lights
operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-lights-operation-type
    :caption: Lights Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Lights Operation Type        Request Value  Response Value
    ===========================  =============  ==============
    CPort Shutdown               0x00           0x80
    Reserved                     0x01           0x81
    Get Lights                   0x02           0x82
    Get Light Config             0x03           0x83
    Get Channel Config           0x04           0x84
    Get Channel Flash Config     0x05           0x85
    Set Brightness               0x06           0x86
    Set Blink                    0x07           0x87
    Set Color                    0x08           0x88
    Set Fade                     0x09           0x89
    Event                        0x0a           N/A
    Set Flash Intensity          0x0b           0x8b
    Set Flash Strobe             0x0c           0x8c
    Set Flash Timeout            0x0d           0x8d
    Get Flash Fault              0x0e           0x8e
    (all other values reserved)  0x0f..0x7e     0x8f..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

.. _lights-cport-shutdown:

Greybus Lights CPort Shutdown Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights CPort Shutdown Operation is the
:ref:`greybus-protocol-cport-shutdown-operation` for the Lights
Protocol.

Greybus Lights Get Lights Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Get Lights operation allows the requester to
determine the actual number of Lights Controllers existing in the
Module. If this operation fail, no further operations related to
Greybus Lights shall occur.

Greybus Lights Get Lights Request
"""""""""""""""""""""""""""""""""

The Greybus Lights Get Lights request message has no payload.

Greybus Lights Get Lights Response
""""""""""""""""""""""""""""""""""

Table :num:`table-lights-get-lights-response` describes the Greybus
Lights Get Lights response. The response payload contains a one-byte
value defining the number of lights controllers in the Module.
If the value returned is 0 no further operations related to
Greybus Lights shall follow. Lights Controllers shall be numbered
sequentially starting at zero and ending in lights_count less one.

.. figtable::
    :nofig:
    :label: table-lights-get-lights-response
    :caption: Lights Get Lights Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        lights_count    1       Number          Number of Lights
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Get Light Config Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Get Light Config operation allows the requester to
collect a set of configuration parameters from a specific light
controller. If this operation fail, all Module lights controllers
configuration that already had occurred should be teared down and no
further operations related to Greybus Lights shall follow.

Greybus Lights Get Light Config Request
"""""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-get-light-config-request` describes the
Greybus Lights Get Light Config request. The request supplies only the
light_id which is a unique identifier between 0 and lights_count
less one.

.. figtable::
    :nofig:
    :label: table-lights-get-light-config-request
    :caption: Lights Get Light Config Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Get Light Config Response
""""""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-get-light-config-response` describes the
Greybus Lights Get Light Config response. The response payload
contains a one-byte value defining the number of existing channels in
the Controller and thirty two byte representing the name of the
Controller.

.. figtable::
    :nofig:
    :label: table-lights-get-light-config-response
    :caption: Lights Get Light Config Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        channel_count   1       Number          Number of Channels
    1        name            32      UTF-8           Light Controller name
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Get Channel Config Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Get Channel Config operation allows the requester
to collect a set of configuration parameters from a specific Channel
of a Light Controller. If this operation fail, all Module lights
Controllers configuration that already had occurred should be teared
down and no further operations related to Greybus Lights shall follow.

Greybus Lights Get Channel Config Request
"""""""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-get-channel-config-request` describes the
Greybus Lights Get Channel Config request. The request supplies the
light_id and channel_id which are unique identifiers between 0 and
lights_count or channel_count less one, respectively

.. figtable::
    :nofig:
    :label: table-lights-get-channel-config-request
    :caption: Lights Get Channel Config Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    =======  ==============  ======  ==========      ===========================

..

.. _lights-get-channel-config-response:

Greybus Lights Get Channel Config Response
""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-get-channel-config-response` describes the
Greybus Lights Get Channel Config response. The response payload
contains a set of parameters representing the configuration of the
channel.

.. figtable::
    :nofig:
    :label: table-lights-get-channel-config-response
    :caption: Lights Get Channel Config Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        max_brightness  1       Number          Maximum Supported Value for Brightness
    1        flags           4       Bit Mask        :ref:`lights-channel-flags`
    5        color           4       Number          Color code value
    9        color_name      32      UTF-8           Color name
    41       mode            4       Bit Mask        :ref:`lights-channel-mode`
    45       mode_name       32      UTF-8           Mode name
    =======  ==============  ======  ==========      ===========================

..

.. _lights-channel-flags:

Greybus Lights Channel Flags Bits
"""""""""""""""""""""""""""""""""

Table :num:`table-lights-channel-flag-bits` describes general flags
associated to a Channel. Only the listed values are valid.

.. figtable::
    :nofig:
    :label: table-lights-channel-flag-bits
    :caption: Lights Channel Flag Bits
    :spec: l l l

    ============================  ===================================================  ==========
    Symbol                        Brief Description                                    Mask Value
    ============================  ===================================================  ==========
    GB_LIGHT_CHANNEL_MULTICOLOR   Channel Support more than one color                  0x00000001
    GB_LIGHT_CHANNEL_FADER        Channel Support Hardware Fader                       0x00000002
    GB_LIGHT_CHANNEL_BLINK        Channel Support Hardware Blink                       0x00000004
    |_|                           (All other values reserved)                          0x00000008..0xffffffff
    ============================  ===================================================  ==========

..

.. _lights-channel-mode:

Greybus Lights Channel Mode Bits
""""""""""""""""""""""""""""""""

Table :num:`table-lights-channel-mode-bits` describes possible modes
associated to a Channel. Only the listed values are valid.

.. figtable::
    :nofig:
    :label: table-lights-channel-mode-bits
    :caption: Lights Channel Mode Bit Masks
    :spec: l l l

    ===============================  ===================================================  ========================
    Light Mode                       Brief Description                                    Mask Value
    ===============================  ===================================================  ========================
    GB_CHANNEL_MODE_NONE             Channel do not represent any specific mode           0x00000000
    GB_CHANNEL_MODE_BATTERY          Channel can represent the battery mode               0x00000001
    GB_CHANNEL_MODE_POWER            Channel can represent the power mode                 0x00000002
    GB_CHANNEL_MODE_WIRELESS         Channel can represent wifi activity mode             0x00000004
    GB_CHANNEL_MODE_BLUETOOTH        Channel can represent bluetooth activity mode        0x00000008
    GB_CHANNEL_MODE_KEYBOARD         Channel can represent light related to the keyboard  0x00000010
    GB_CHANNEL_MODE_BUTTONS          Channel can represent light related to buttons       0x00000020
    GB_CHANNEL_MODE_NOTIFICATION     Channel can represent general notification light     0x00000040
    GB_CHANNEL_MODE_ATTENTION        Channel can represent general attention light        0x00000080
    GB_CHANNEL_MODE_FLASH            Channel can be used as a flash light device          0x00000100
    GB_CHANNEL_MODE_TORCH            Channel can be used as a flash torch device          0x00000200
    GB_CHANNEL_MODE_INDICATOR        Channel can be used as a flash indicator device      0x00000400
    |_|                              (Reserved Range)                                     0x00000800..0x00080000
    GB_CHANNEL_MODE_VENDOR           Channel can be used as vendor specific mode          0x00100000..0x08000000
    |_|                              (Reserved Range)                                     0x10000000..0x80000000
    ===============================  ===================================================  ========================

..

Greybus Lights Get Channel Flash Config Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Get Channel Flash Config operation allows the
requester to collect a set of configuration parameters related to
flash type modes from a specific Channel of a Light Controller. If
this operation fail, all Module lights Controllers configuration that
already had occurred should be teared down and no further operations
related to Greybus Lights shall follow.

Greybus Lights Get Channel Flash Config Request
"""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-get-channel-flash-config-request` describes
the Greybus Lights Get Channel Config request. The request supplies
the light_id and channel_id which are unique identifiers between 0 and
lights_count or channel_count less one, respectively

.. figtable::
    :nofig:
    :label: table-lights-get-channel-flash-config-request
    :caption: Lights Get Channel Flash Config Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    =======  ==============  ======  ==========      ===========================

..

.. _lights-get-channel-flash-config-response:

Greybus Lights Get Channel Flash Config Response
""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-get-channel-flash-config-response` describes
the Greybus Lights Get Channel Flash Config response. The response
payload contains a set of flash type parameters representing the
configuration of the channel.

.. figtable::
    :nofig:
    :label: table-lights-get-channel-flash-config-response
    :caption: Lights Get Channel Flash Config Response
    :spec: l l c c l

    =======  =================  ======  ==========      ===========================
    Offset   Field              Size    Value           Description
    =======  =================  ======  ==========      ===========================
    0        intensity_min_uA   4       Number          Minimum Value for Current Intensity in microampere
    4        intensity_max_uA   4       Number          Maximum Value for Current Intensity in microampere
    8        intensity_step_uA  4       Number          Step Value for Current Intensity in microampere
    12       timeout_min_us     4       Number          Minimum Value for Strobe Flash timeout in microseconds
    16       timeout_max_us     4       Number          Maximum Value for Strobe Flash timeout in microseconds
    20       timeout_step_us    4       Number          Step Value for Strobe Flash timeout in microseconds
    =======  =================  ======  ==========      ===========================

..

Greybus Lights Set Brightness Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Set Brightness operation allows the requester to
set brightness level of a specific Channel to the specified value.

Greybus Lights Set Brightness Request
"""""""""""""""""""""""""""""""""""""
The Greybus Lights Set Brightness request payload contains three
1-byte values that represents light_id, channel_id and the level of
brightness to be set by the light device channel being controlled, in
which 0 represent the lower level (off) and 255 represent the highest
possible brightness level as defined in table
:num:`table-lights-set-brightness-request`.

.. figtable::
    :nofig:
    :label: table-lights-set-brightness-request
    :caption: Lights Set Brightness Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    2        brightness      1       Number          Channel brightness level to set
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Set Brightness Response
""""""""""""""""""""""""""""""""""""""

The Greybus Lights Set Brightness response message has no payload.

Greybus Lights Set Blink Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Set Blink operation allows the requester to enable
the blink mode of a specific Channel. Setting time_on and time_off to
0 or setting brightness  level to a fixed value shall disable blink.

Greybus Lights Set Blink Request
""""""""""""""""""""""""""""""""

The Greybus Lights Set Blink request payload contains a two 1-byte
values that represent the light_id and channel_id, more two 2-byte
values that represents the duration in milliseconds of the on and off
period during the blink to be set by the light device channel being
controlled, as defined in table :num:`table-lights-set-blink-request`.

.. figtable::
    :nofig:
    :label: table-lights-set-blink-request
    :caption: Lights Set Blink Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    2        time_on_ms      2       Number          Time on in milliseconds
    4        time_off_ms     2       Number          Time off in milliseconds
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Set Blink Response
"""""""""""""""""""""""""""""""""

The Greybus Lights Set Blink response message has no payload.

Greybus Lights Set Color Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Set Color operation allows the requester to set a
value for a color space of a specific Channel to the specified value.

Greybus Lights Set Color Request
""""""""""""""""""""""""""""""""

The Greybus Lights Set Color request payload contains two 1-byte
values that represents light_id, channel_id and one 4-byte value which
represents a color code in any color space for the light device
channel, as defined in table
:num:`table-lights-set-color-request`.

.. figtable::
    :nofig:
    :label: table-lights-set-color-request
    :caption: Lights Set Color Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    2        color           4       Number          Channel color code
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Set Color Response
"""""""""""""""""""""""""""""""""

The Greybus Lights Set Color response message has no payload.

Greybus Lights Set Fade Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Set Fade operation allows the requester to enable
and set the parameters for fade effect of a specific Channel.

Greybus Lights Set Fade Request
"""""""""""""""""""""""""""""""

The Greybus Lights Set Fade request payload contains a two 1-byte
values that represent the light_id and channel_id, more two 2-byte
values that represents a level of the fade in and out effect during
brightness transitions by the light device channel being controlled,
as defined in table
:num:`table-lights-set-fade-request`.

.. figtable::
    :nofig:
    :label: table-lights-set-fade-request
    :caption: Lights Set Fade Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    2        fade_in         2       Number          Fade in level
    4        fade_out        2       Number          Fade out level
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Set Fade Response
""""""""""""""""""""""""""""""""

The Greybus Lights Set Fade response message has no payload.

Greybus Lights Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Event operation signals to the recipient that a
change in the device setup have occurred.

This event shall be discarded by the recipient until a valid light
controller configuration is known.

This operation is unidirectional and does not have a correspondent
response.

Greybus Lights Event Request
""""""""""""""""""""""""""""

Table :num:`table-lights-event-request` defines the Greybus Lights
Event request. The request payload supplies two 1-byte fields that
represent the light_id and event bit mask.

.. figtable::
    :nofig:
    :label: table-lights-event-request
    :caption: Lights Event Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        event           1       Bit Mask        :ref:`lights-event-bits`
    =======  ==============  ======  ==========      ===========================

..

.. _lights-event-bits:

Greybus Lights Event Bit Masks
""""""""""""""""""""""""""""""

Table :num:`table-lights-event-bit-mask` defines the bit masks which
specify the set of events that occurred in the sending controller.

.. figtable::
    :nofig:
    :label: table-lights-event-bit-mask
    :caption: Lights Protocol Event Bit Mask
    :spec: l l l

    ===============================  =============================  ===============
    Symbol                           Brief Description              Mask Value
    ===============================  =============================  ===============
    GB_LIGHTS_LIGHT_CONFIG           Configuration Changed          0x01
    |_|                              (All other values reserved)    0x02..0x80
    ===============================  =============================  ===============

..

Greybus Lights Set Flash Intensity Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Set Flash Intensity operation allows the requester
to set current Intensity level in microamperes of a Channel to the
specified value.

Greybus Lights Set Flash Intensity Request
""""""""""""""""""""""""""""""""""""""""""

The Greybus Lights Set Flash Intensity request payload contains two
1-byte values that represent the light_id and channel_id, and 4-byte
value that represents the current intensity in microamperes. The value
shall be set between the minimum and maximum values got from flash
configuration operation.
:num:`table-lights-set-flash-intensity-request`.

.. figtable::
    :nofig:
    :label: table-lights-set-flash-intensity-request
    :caption: Lights Set Flash Intensity Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    2        intensity_uA    4       Number          Current Intensity in microamperes
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Set Flash Intensity Response
"""""""""""""""""""""""""""""""""""""""""""

The Greybus Lights Set Flash Intensity response message has no payload.

Greybus Lights Set Flash Strobe Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Set Flash Strobe operation allows the requester
to enable or disable the strobe associated with a Channel.

Greybus Lights Set Flash Strobe Request
"""""""""""""""""""""""""""""""""""""""

The Greybus Lights Set Flash Strobe request payload contains three
1-byte values that represents light_id, channel_id and the strobe
state to be set. If state is 0 means disable, 1 means enable. Any
other value shall be considered invalid.
:num:`table-lights-set-flash-strobe-request`.

.. figtable::
    :nofig:
    :label: table-lights-set-flash-strobe-request
    :caption: Lights Set Flash Strobe Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    2        state           1       Number          Strobe state to be set
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Set Flash Strobe Response
""""""""""""""""""""""""""""""""""""""""

The Greybus Lights Set Flash Strobe response message has no payload.

Greybus Lights Set Flash Timeout Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Set Flash Timeout operation allows the requester to
set flash timeout in microseconds of a Channel to the specified value.

Greybus Lights Set Flash Timeout Request
""""""""""""""""""""""""""""""""""""""""

The Greybus Lights Set Flash Timeout request payload contains two
1-byte values that represent the light_id and channel_id, and 4-byte
value that represents the flash timeout in microseconds. The value
shall be set between the minimum and maximum values got from flash
configuration operation.
:num:`table-lights-set-flash-timeout-request`.

.. figtable::
    :nofig:
    :label: table-lights-set-flash-timeout-request
    :caption: Lights Set Flash Timeout Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    2        timeout_us      4       Number          Timeout Value in microseconds
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Set Flash Timeout Response
"""""""""""""""""""""""""""""""""""""""""

The Greybus Lights Set Flash Timeout response message has no payload.

Greybus Lights Get Flash Fault Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Get Flash Fault operation allows the requester to
get a detailed information of the status and fault reasons of the
flash type controller.

Greybus Lights Get Flash Fault Request
""""""""""""""""""""""""""""""""""""""

The Greybus Lights Get Flash Fault request payload contains two
1-byte values that represent the light_id and channel_id.
:num:`table-lights-get-flash-fault-request`.

.. figtable::
    :nofig:
    :label: table-lights-get-flash-fault-request
    :caption: Lights Get Flash Fault Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Get Flash Fault Response
"""""""""""""""""""""""""""""""""""""""

The Greybus Lights Get Flash Fault response message payload contains a
4-byte bit mask with the current fault status of the flash controller,
as defined in table :num:`table-lights-get-flash-fault-response`

.. figtable::
    :nofig:
    :label: table-lights-get-flash-fault-response
    :caption: Lights Get Flash Fault Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        fault           4       Bit Mask        :ref:`lights-flash-fault-bits`
    =======  ==============  ======  ==========      ===========================

..

.. _lights-flash-fault-bits:

Greybus Lights Flash Fault Bit Masks
""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-flash-fault-bit-mask` defines the bit masks
which specify the fault status of the flash controller.

.. figtable::
    :nofig:
    :label: table-lights-flash-fault-bit-mask
    :caption: Lights Protocol Flash Fault Bit Mask
    :spec: l l l

    ============================================  =============================  ===============
    Symbol                                        Brief Description              Mask Value
    ============================================  =============================  ===============
    GB_LIGHTS_FLASH_FAULT_OVER_VOLTAGE            Over Voltage                   0x00000001
    GB_LIGHTS_FLASH_FAULT_TIMEOUT                 Timeout                        0x00000002
    GB_LIGHTS_FLASH_FAULT_OVER_TEMPERATURE        Over Temperature               0x00000004
    GB_LIGHTS_FLASH_FAULT_SHORT_CIRCUIT           Short Circuit                  0x00000008
    GB_LIGHTS_FLASH_FAULT_OVER_CURRENT            Over Current                   0x00000010
    GB_LIGHTS_FLASH_FAULT_INDICATOR               Indicator Fault                0x00000020
    GB_LIGHTS_FLASH_FAULT_UNDER_VOLTAGE           Under Voltage                  0x00000040
    GB_LIGHTS_FLASH_FAULT_INPUT_VOLTAGE           Input Voltage                  0x00000080
    GB_LIGHTS_FLASH_FAULT_LED_OVER_TEMPERATURE    LED Over Temperature           0x00000100
    |_|                                           (All other values reserved)    0x00000200..0x80000000
    ============================================  =============================  ===============

..

