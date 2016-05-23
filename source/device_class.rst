.. _device-class-protocols:

Device Class Connection Protocols
=================================

This section defines a group of Protocols whose purpose is to provide
a device abstraction for functionality commonly found on mobile
handsets. Modules which implement at least one of the Protocols
defined in this section, and which do not implement any of the
Protocols defined below in :ref:`bridged-phy-protocols`,
are said to be *device class conformant*.

.. note:: Two |unipro|\ -based protocols will take the place of device
          class Protocol definitions in this section:

          - MIPI CSI-3: for camera Modules
          - JEDEC UFS: for storage Modules


.. include:: device_class/firmware.txt
.. include:: device_class/vibrator.txt
.. include:: device_class/power.txt

Audio Protocol
--------------

This section defines the operations used on connections implementing
the Greybus Audio Protocol.  This Protocol allows an AP Module to manage
audio devices present on a Module.  The Protocol is strongly influenced
by the *Advanced Linux Sound Architecture* (ALSA) and is designed to fit
closely with it.

There are two types of Audio Connections defined by the Greybus Audio
Protocol: *Audio Management Connections* and *Audio Data Connections*.
Audio Management Connections are used to communicate management related
operations.  Audio Data Connections are used to stream audio data.
All Greybus Audio Protocol operations except for the :ref:`audio-send-data`
are sent over an Audio Management Connection.  There shall be at least
one Audio Data Connection associated with each Audio Management Connection.

The audio data shall be generated using *Pulse-Code Modulation*.

Required Functionality and Controls
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A Greybus Audio Module shall have at least one endpoint (e.g., speaker,
microphone, headphone jack, headset jack).  There are two types of endpoints,
input and output endpoints.  Input endpoints are used when converting
sounds into digital audio data that are sent to an AP Module
(e.g., microphone).  Output endpoints are used when converting digital
audio data received from an AP Module into sounds (e.g., speaker).
Some endpoints are used for both (e.g., headset jack).

Each endpoint shall support stereo audio data even when the
underlying hardware does not.  When the underlying hardware does not
support stereo audio data, the module shall make the necessary
conversions in order to support it.  Exactly how that is done is left
to the audio manufacturer.

Additionally, all endpoints shall support volume and mute controls
for each channel.

Extended Functionality and Controls
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A Greybus Audio Module may support functionality and controls that are
far more elaborate than the required set.  These extended features shall
be supported by the AP Module downloading a matching MSP with the necessary
support.  How this is done is out of the scope of this document.

Audio Management Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The operations in the Greybus Audio Protocol are:

.. c:function:: int ping(void);

    See :ref:`greybus-protocol-ping-operation`.

.. c:function:: int get_topology_size(u16 *descriptor_size);

   Returns the size of the audio device's topology data structure.

.. c:function:: int get_topology(struct gb_audio_descriptor *descriptor);

   Returns a data structure containing the audio device's supported
   Digital Audio Interfaces (DAIs), controls, widget, and how the DAIs
   and widgets can be connected.

.. c:function:: int get_control(u8 control_id,
                                struct gb_audio_control_element_value *value);

   Returns the current value of the specified control.

.. c:function:: int set_control(u8 control_id,
                                struct gb_audio_control_element_value *value);

   Sets a control to the specified value.

.. c:function:: int enable_widget(u8 widget_id);

   Enables the specified widget.

.. c:function:: int disable_widget(u8 widget_id);

   Disables the specified widget.

.. c:function:: int get_pcm(u16 dai_cport, u64 *format, u32 *rate, u8 *channels u8 sig_bits);

   Returns the current PCM values of the specified DAI.

.. c:function:: int set_pcm(u16 dai_cport, u64 format, u32 rate, u8 channels u8 ig_bits);

   Sets the PCM values of the specified DAI.

.. c:function:: int set_tx_data_size(u16 dai_cport, u16 size);

   Sets the number of bytes in the audio data portion of Greybus
   audio messages going from the AP Module to the Audio Module.

.. c:function:: int get_tx_delay(u16 dai_cport, u32 *delay);

   Returns the delay from the time the Audio Module receives the
   first Greybus Audio Messages until the first sound can be heard
   in microseconds.

.. c:function:: int activate_tx(u16 dai_cport);

   Requests that the Audio Module begin accepting Greybus audio messages
   and output them on the configured audio widget.

.. c:function:: int deactivate_tx(u16 dai_cport);

   Requests that the Audio Module stop accepting Greybus audio messages
   and stop outputting them on the configured audio endpoint.

.. c:function:: int set_rx_data_size(u16 dai_cport, u16 size);

   Sets the number of bytes in the audio data portion of Greybus
   audio messages going from the Audio Module to the AP Module.

.. c:function:: int get_rx_delay(u16 dai_cport, u32 *delay);

   Returns the delay from the time the Audio Module first
   receives a Activate RX Message until the first Greybus audio
   message is sent in microseconds (given the current PCM and
   RX data size configuration).

.. c:function:: int activate_rx(u16 dai_cport);

   Requests that the Audio Module begin capturing audio data
   and sending it to the AP Module.

.. c:function:: int deactivate_rx(u16 dai_cport);

   Requests that the Audio Module stop capturing audio data
   and sending it to the AP Module.

.. c:function:: int jack_event(u8 widget_id, u8 widget_type, u8 *event);

   Reports a jack related event to the AP Module.

.. c:function:: int button_event(u8 widget_id, u8 button_id, u8 *event);

   Reports a jack related event to the AP Module.

.. c:function:: int streaming_event(u16 dai_cport, u8 *event);

   Reports a streaming related event to the AP Module.

.. c:function:: int send_data(u64 timestamp, u32 size, u8 *data);

    Sends an integer number of audio samples over an Audio Data Connection.

Greybus Audio Management Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-audio-mgmt-operation-type` describes the Greybus
audio operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-audio-mgmt-operation-type
    :caption: Audio Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Audio Operation Type         Request Value  Response Value
    ===========================  =============  ==============
    Ping                         0x00           0x80
    Reserved                     0x01           0x81
    Get Topology Size            0x02           0x82
    Get Topology                 0x03           0x83
    Get Control                  0x04           0x86
    Set Control                  0x05           0x87
    Enable Widget                0x06           0x88
    Disable Widget               0x07           0x89
    Get PCM                      0x08           0x84
    Set PCM                      0x09           0x85
    Set TX Data Size             0x0a           0x8a
    Get TX Delay                 0x0b           0x8b
    Activate TX                  0x0c           0x8c
    Deactivate TX                0x0d           0x8d
    Set RX Data Size             0x0e           0x8e
    Get RX Delay                 0x0f           0x8f
    Activate RX                  0x10           0x90
    Deactivate RX                0x11           0x91
    Jack Event                   0x12           0x92
    Button Event                 0x13           0x93
    Streaming Event              0x14           0x94
    Send Data                    0x15           0x95
    (all other values reserved)  0x16..0x7e     0x96..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

Greybus Audio Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Ping Operation is the
:ref:`greybus-protocol-ping-operation` for the Audio Protocol.
It consists of a request containing no payload, and a response
with no payload that indicates a successful result.

Greybus Audio Get Topology Size Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Get Topology Size operation allows the requester to
determine the number of bytes required to hold the topology information
structure returned by the :ref:`audio-get-topology`.
If this operation fails, no further operations related to Greybus
Audio shall occur.

Greybus Audio Get Topology Size Request
"""""""""""""""""""""""""""""""""""""""

The Greybus Audio Get Topology Size request message has no payload.

Greybus Audio Get Topology Size Response
""""""""""""""""""""""""""""""""""""""""

Table :num:`table-audio-get-topology-size-response` describes the Greybus
Audio Get Topology Size response. The response payload contains a
two-byte value defining the number of bytes in the topology information
structure returned by :ref:`audio-get-topology`.  If the value
returned is 0 no further operations related to Greybus Audio shall
follow.

.. figtable::
    :nofig:
    :label: table-audio-get-topology-size-response
    :caption: Audio Get Topology Size Response
    :spec: l l c c l

    ====== ===== ==== ====== ================================
    Offset Field Size Value  Description
    ====== ===== ==== ====== ================================
    0      size  2    Number Number of bytes of topology data
    ====== ===== ==== ====== ================================

..

.. _audio-get-topology:

Greybus Audio Get Topology Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Get Topology operation allows the requester to
retrieve audio topology information from an Audio Module.
If this operation fails, no further operations related to Greybus
Audio shall occur.

Greybus Audio Get Topology Request
""""""""""""""""""""""""""""""""""

The Greybus Audio Get Topology request message has no payload.

Greybus Audio Get Topology Response
"""""""""""""""""""""""""""""""""""

Table :num:`table-audio-get-topology-response` describes the Greybus
Audio Get Topology response. The response payload contains a set of
fixed size fields and a variable number of DAI, control, widget, and
route structures.

.. figtable::
    :nofig:
    :label: table-audio-get-topology-response
    :caption: Audio Get Topology Response
    :spec: l l c c l

    ========================= ============ ==== ========= ============================
    Offset                    Field        Size Value     Description
    ========================= ============ ==== ========= ============================
    0                         num_dais     1    Number    Number of DAI structures
    1                         num_controls 1    Number    Number of control structures
    2                         num_widgets  1    Number    Number of widget structures
    3                         num_routes   1    Number    Number of route structures
    4                         dai[1]       120  Structure :ref:`audio-dai-struct`
    ...                       ...          120  Structure :ref:`audio-dai-struct`
    4+120*(I-1)               dai[I]       120  Structure :ref:`audio-dai-struct`
    4+120*I                   control[1]   54   Structure :ref:`audio-control-struct`
    ...                       ...          54   Structure :ref:`audio-control-struct`
    4+120*I+54*(J-1)          control[J]   54   Structure :ref:`audio-control-struct`
    4+120*I+54*J              widget[1]    43   Structure :ref:`audio-widget-struct`
    ...                       ...          43   Structure :ref:`audio-widget-struct`
    4+120*I+54*(J-1)+43*(K-1) widget[K]    43   Structure :ref:`audio-widget-struct`
    4+120*I+54*J+43*K         route[1]     3    Structure :ref:`audio-route-struct`
    ...                       ...          3    Structure :ref:`audio-route-struct`
    4+120*I+54*J+43*K+3*(L-1) route[L]     3    Structure :ref:`audio-route-struct`
    ========================= ============ ==== ========= ============================

..

.. _audio-dai-struct:

Greybus Audio DAI Structure
"""""""""""""""""""""""""""

Table :num:`table-audio-dai-structure` describes the structure containing
DAI information for Audio Modules.

.. figtable::
    :nofig:
    :label: table-audio-dai-structure
    :caption: Audio DAI Structure
    :spec: l l c c l

    ====== ======== ==== ========= =============================
    Offset Field    Size Value     Description
    ====== ======== ==== ========= =============================
    0      name     32   UTF-8     DAI Name
    32     cport    2    Number    CPort for DAI Data Connection
    34     capture  43   Structure :ref:`audio-pcm-struct`
    77     playback 43   Structure :ref:`audio-pcm-struct`
    ====== ======== ==== ========= =============================

..

.. _audio-pcm-struct:

Greybus Audio PCM Structure
"""""""""""""""""""""""""""

Table :num:`table-audio-pcm-structure` describes the structure containing
PCM information for Audio Modules.

.. figtable::
    :nofig:
    :label: table-audio-pcm-structure
    :caption: Audio PCM Structure
    :spec: l l c c l

    ====== =========== ==== ======== ===========================
    Offset Field       Size Value    Description
    ====== =========== ==== ======== ===========================
    0      stream_name 32   UTF-8    Stream Name
    32     formats     4    Bit Mask :ref:`audio-pcm-format-flags`
    36     rates       4    Bit Mask :ref:`audio-pcm-rate-flags`
    40     chan_min    1    Number   Minimum number of channels
    41     chan_max    1    Number   Maximum number of channels
    42     sig_bits    1    Number   Number of bits of content
    ====== =========== ==== ======== ===========================

..

.. _audio-pcm-format-flags:

Greybus Audio Format Flags Bits
"""""""""""""""""""""""""""""""

Table :num:`table-audio-pcm-format-flag-bits` describes the audio data formats.

.. figtable::
    :nofig:
    :label: table-audio-pcm-format-flag-bits
    :caption: Audio Format Flag Bits
    :spec: l l l

    ======================= ================================================ ==============
    Symbol                  Brief Description                                Mask Value
    ======================= ================================================ ==============
    GB_AUDIO_PCM_FMT_S8     Eight bit signed PCM data                        0x00000001
    GB_AUDIO_PCM_FMT_U8     Eight bit unsigned PCM data                      0x00000002
    GB_AUDIO_PCM_FMT_S16_LE Sixteen bit signed PCM data, little endian       0x00000004
    GB_AUDIO_PCM_FMT_U16_LE Sixteen bit unsigned PCM data, little endian     0x00000008
    GB_AUDIO_PCM_FMT_S16_BE Sixteen bit signed PCM data, big endian          0x00000010
    GB_AUDIO_PCM_FMT_U16_BE Sixteen bit unsigned PCM data, big endian        0x00000020
    GB_AUDIO_PCM_FMT_S24_LE Twenty-four bit signed PCM data, little endian   0x00000040
    GB_AUDIO_PCM_FMT_U24_LE Twenty-four bit unsigned PCM data, little endian 0x00000080
    GB_AUDIO_PCM_FMT_S24_BE Twenty-four bit signed PCM data, big endian      0x00000100
    GB_AUDIO_PCM_FMT_U24_BE Twenty-four bit unsigned PCM data, big endian    0x00000200
    GB_AUDIO_PCM_FMT_S32_LE Thirty-two bit signed PCM data, little endian    0x00000400
    GB_AUDIO_PCM_FMT_U32_LE Thirty-two bit unsigned PCM data, little endian  0x00000800
    GB_AUDIO_PCM_FMT_S32_BE Thirty-two bit signed PCM data, big endian       0x00001000
    GB_AUDIO_PCM_FMT_U32_BE Thirty-two bit unsigned PCM data, big endian     0x00002000
    ======================= ================================================ ==============

..

.. _audio-pcm-rate-flags:

Greybus Audio Rate Flags Bits
"""""""""""""""""""""""""""""

Table :num:`table-audio-pcm-rate-flag-bits` describes the audio data rates.

.. figtable::
    :nofig:
    :label: table-audio-pcm-rate-flag-bits
    :caption: Audio Rate Flag Bits
    :spec: l l l

    ======================== ========================= ==========
    Symbol                   Brief Description         Mask Value
    ======================== ========================= ==========
    GB_AUDIO_PCM_RATE_5512   5512 samples per second   0x00000001
    GB_AUDIO_PCM_RATE_8000   8000 samples per second   0x00000002
    GB_AUDIO_PCM_RATE_11025  11025 samples per second  0x00000004
    GB_AUDIO_PCM_RATE_16000  16000 samples per second  0x00000008
    GB_AUDIO_PCM_RATE_22050  22050 samples per second  0x00000010
    GB_AUDIO_PCM_RATE_32000  32000 samples per second  0x00000020
    GB_AUDIO_PCM_RATE_44100  44100 samples per second  0x00000040
    GB_AUDIO_PCM_RATE_48000  48000 samples per second  0x00000080
    GB_AUDIO_PCM_RATE_64000  64000 samples per second  0x00000100
    GB_AUDIO_PCM_RATE_88200  88200 samples per second  0x00000200
    GB_AUDIO_PCM_RATE_96000  96000 samples per second  0x00000400
    GB_AUDIO_PCM_RATE_176400 176400 samples per second 0x00000800
    GB_AUDIO_PCM_RATE_192000 192000 samples per second 0x00001000
    ======================== ========================= ==========

..

.. _audio-control-struct:

Greybus Audio Control Structure
"""""""""""""""""""""""""""""""

Table :num:`table-audio-control-structure` describes the structure containing
control information for Audio Modules.

.. figtable::
    :nofig:
    :label: table-audio-control-structure
    :caption: Audio Control Structure
    :spec: l l c c l

    ====== ============= ==== ========= ========================================
    Offset Field         Size Value     Description
    ====== ============= ==== ========= ========================================
    0      name          32   UTF-8     Control Name
    32     id            1    Number    Control ID
    33     iface         1    Number    :ref:`audio-control-iface-type`
    34     dai_cport     2    Number    DAI CPort
    36     access        1    Bit Mask  :ref:`audio-control-access-rights-flags`
    37     count         1    Number    Number of elements of this type
    38     info          XX   Structure :ref:`audio-ctl-elem-info`
    ====== ============= ==== ========= ========================================

..

.. _audio-control-iface-type:

Greybus Audio Control Iface Type
""""""""""""""""""""""""""""""""

Table :num:`table-audio-control-iface-type` describes the audio control
interface type.

.. figtable::
    :nofig:
    :label: table-audio-control-iface-type
    :caption: Audio Control Interface Type
    :spec: l l l

    ======================== ========================= ==========
    Symbol                   Brief Description         Mask Value
    ======================== ========================= ==========
    GB_AUDIO_IFACE_CARD      Global control            0x01
    GB_AUDIO_IFACE_HWDEP     Hardware depedent device  0x02
    GB_AUDIO_IFACE_MIXER     Mixer device              0x03
    GB_AUDIO_IFACE_PCM       PCM device                0x04
    GB_AUDIO_IFACE_RAWMIDI   Raw MIDI device           0x05
    GB_AUDIO_IFACE_TIMER     Timer device              0x06
    GB_AUDIO_IFACE_SEQUENCER Sequencer device          0x07
    ======================== ========================= ==========

..

.. _audio-control-access-rights-flags:

Greybus Audio Control Access Rights Flags
"""""""""""""""""""""""""""""""""""""""""

Table :num:`table-audio-control-access-rights-flag-bits` describes the audio
control access rights.

.. figtable::
    :nofig:
    :label: table-audio-control-access-rights-flag-bits
    :caption: Audio Control Access Rights Flag Bits
    :spec: l l l

    ===================== =================  ==========
    Symbol                Brief Description  Mask Value
    ===================== =================  ==========
    GB_AUDIO_ACCESS_READ  Read access        0x01
    GB_AUDIO_ACCESS_WRITE Write access       0x02
    ===================== =================  ==========

..

.. _audio-ctl-elem-info:

Greybus Audio Control Element Info Structure
""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-audio-ctl-elem-info-structure` describes the
structure containing control element information for Audio Modules.

.. figtable::
    :nofig:
    :label: table-audio-ctl-elem-info-structure
    :caption: Audio Control Element Info Structure
    :spec: l l c c l

    ====== ============= ==== ========= ========================================
    Offset Field         Size Value     Description
    ====== ============= ==== ========= ========================================
    0      id            47   Structure :ref:`audio-ctl-elem-id`
    47     type          1    Bit Mask  :ref:`audio-ctl-elem-type`
    48     access        1    Bit Mask  :ref:`audio-control-access-rights-flags`
    49     count         1    Number    Number of values
    50     dimen[1]      2    Number    First dimension
    ...    ...           2    Number    ...
    56     dimen[4]      2    Number    Fourth dimension
    58     value         XX   Union     :ref:`audio-ctl-elem-val-range-union`
    ====== ============= ==== ========= ========================================

..

.. _audio-ctl-elem-id:

Greybus Audio Control Element ID Structure
""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-audio-ctl-elem-id-structure` describes the
structure containing a control element ID value for Audio Modules.

.. figtable::
    :nofig:
    :label: table-audio-ctl-elem-id-structure
    :caption: Audio Control Element ID Structure
    :spec: l l c c l

    ====== ============= ==== ========= =================
    Offset Field         Size Value     Description
    ====== ============= ==== ========= =================
    0      numid         1    Number    Numeric ID
    1      iface         1    Number    :ref:`audio-control-iface-type`
    2      name          44   UTF-8     Name
    46     index         46   Number    index of element
    ====== ============= ==== ========= =================

..

.. _audio-ctl-elem-type:

Greybus Audio Control Element Type
""""""""""""""""""""""""""""""""""

Table :num:`table-audio-ctl-elem-type` describes the audio control
element type.

.. figtable::
    :nofig:
    :label: table-audio-ctl-elem-type
    :caption: Audio Control Elemente Type
    :spec: l l l

    ================================= ========================= ==========
    Symbol                            Brief Description         Mask Value
    ================================= ========================= ==========
    GB_AUDIO_CTL_ELEM_TYPE_BOOLEAN    Boolean                   0x01
    GB_AUDIO_CTL_ELEM_TYPE_INTEGER    32-bit Integer            0x02
    GB_AUDIO_CTL_ELEM_TYPE_ENUMERATED Enumerated type           0x03
    GB_AUDIO_CTL_ELEM_TYPE_INTEGER64  64-bit Integer            0x06
    ================================= ========================= ==========

..

.. _audio-ctl-elem-val-range-union:

Greybus Audio Control Element Value Range Union
"""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-audio-ctl-elem-val-range-union` describes the
union containing control element value ranges for Audio Modules.

.. figtable::
    :nofig:
    :label: table-audio-ctl-elem-val-range-union
    :caption: Audio Control Element Value Range Union
    :spec: l l c c l

    ====== ============= ==== ========= ========================================
    Offset Field         Size Value     Description
    ====== ============= ==== ========= ========================================
    0      integer       12   Structure :ref:`audio-ctl-elem-val-range-int`
    0      integer64     24   Structure :ref:`audio-ctl-elem-val-range-int64`
    0      enumerated    xxx  Structure :ref:`audio-ctl-elem-val-range-enum`
    ====== ============= ==== ========= ========================================

..

.. _audio-ctl-elem-val-range-int:

Greybus Audio Control Element Integer Value Range Structure
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-audio-ctl-elem-val-range-int-structure` describes the
structure containing a control element integer value range for Audio Modules.

.. figtable::
    :nofig:
    :label: table-audio-ctl-elem-val-range-int-structure
    :caption: Audio Control Element Integer Value Range Structure
    :spec: l l c c l

    ====== ============= ==== ========= =================
    Offset Field         Size Value     Description
    ====== ============= ==== ========= =================
    0      min           4    Number    Minimum value
    4      max           4    Number    Maximum value
    8      step          4    Number    Increment amount
    ====== ============= ==== ========= =================

..

.. _audio-ctl-elem-val-range-int64:

Greybus Audio Control Element Integer64 Value Range Structure
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-audio-ctl-elem-val-range-int64-structure` describes the
structure containing a control element integer64 value for range Audio Modules.

.. figtable::
    :nofig:
    :label: table-audio-ctl-elem-val-range-int64-structure
    :caption: Audio Control Element Integer64 Value Range Structure
    :spec: l l c c l

    ====== ============= ==== ========= =================
    Offset Field         Size Value     Description
    ====== ============= ==== ========= =================
    0      min           8    Number    Minimum value
    8      max           8    Number    Maximum value
    16     step          8    Number    Increment amount
    ====== ============= ==== ========= =================

..

.. _audio-ctl-elem-val-range-enum:

Greybus Audio Control Element Enumerated Value Range Structure
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-audio-ctl-elem-val-range-enum-structure` describes the
structure containing a control element enumerated value for range
Audio Modules.

.. figtable::
    :nofig:
    :label: table-audio-ctl-elem-val-range-enum-structure
    :caption: Audio Control Element Enumerated Value Range Structure
    :spec: l l c c l

    ====== ============= ==== ========= ======================
    Offset Field         Size Value     Description
    ====== ============= ==== ========= ======================
    0      items         4    Number    Number of items
    4      names_length  4    Number    Length of names field
    8      names         XX   UTF-8     Enumerated type names
    ====== ============= ==== ========= ======================

..

.. _audio-widget-struct:

Greybus Audio Widget Structure
""""""""""""""""""""""""""""""

Table :num:`table-audio-widget-structure` describes the structure containing
widget information for Audio Modules.

.. figtable::
    :nofig:
    :label: table-audio-widget-structure
    :caption: Audio Widget Structure
    :spec: l l c c l

    ====== =========== ==== ======== =============================
    Offset Field       Size Value    Description
    ====== =========== ==== ======== =============================
    0      name        32   UTF-8    Widget Name
    32     id          1    Number   Widget ID
    33     type        1    Number   :ref:`audio-widget-type`
    34     state       1    Number   :ref:`audio-widget-state`
    35     control_ids 8    Bit Mask Control IDs
    ====== =========== ==== ======== =============================

..

.. _audio-widget-type:

Greybus Audio Widget Type
"""""""""""""""""""""""""

Table :num:`table-audio-widget-type` describes the audio widget type.

.. figtable::
    :nofig:
    :label: table-audio-widget-type
    :caption: Audio Widget Type
    :spec: l l

    ===================================== =====
    Widget Type                           Value
    ===================================== =====
    Invalid                               0x00
    GB_AUDIO_WIDGET_TYPE_INPUT            0x01
    GB_AUDIO_WIDGET_TYPE_OUTPUT           0x02
    GB_AUDIO_WIDGET_TYPE_MUX              0x03
    GB_AUDIO_WIDGET_TYPE_VIRT_MUX         0x04
    GB_AUDIO_WIDGET_TYPE_VALUE_MUX        0x05
    GB_AUDIO_WIDGET_TYPE_MIXER            0x06
    GB_AUDIO_WIDGET_TYPE_MIXER_NAMED_CTL  0x07
    GB_AUDIO_WIDGET_TYPE_PGA              0x08
    GB_AUDIO_WIDGET_TYPE_OUT_DRV          0x09
    GB_AUDIO_WIDGET_TYPE_ADC              0x0a
    GB_AUDIO_WIDGET_TYPE_DAC              0x0b
    GB_AUDIO_WIDGET_TYPE_MICBIAS          0x0c
    GB_AUDIO_WIDGET_TYPE_MIC              0x0d
    GB_AUDIO_WIDGET_TYPE_HP               0x0e
    GB_AUDIO_WIDGET_TYPE_SPK              0x0f
    GB_AUDIO_WIDGET_TYPE_LINE             0x10
    GB_AUDIO_WIDGET_TYPE_SWITCH           0x11
    GB_AUDIO_WIDGET_TYPE_VMID             0x12
    GB_AUDIO_WIDGET_TYPE_PRE              0x13
    GB_AUDIO_WIDGET_TYPE_POST             0x14
    GB_AUDIO_WIDGET_TYPE_SUPPLY           0x15
    GB_AUDIO_WIDGET_TYPE_REGULATOR_SUPPLY 0x16
    GB_AUDIO_WIDGET_TYPE_CLOCK_SUPPLY     0x17
    GB_AUDIO_WIDGET_TYPE_AIF_IN           0x18
    GB_AUDIO_WIDGET_TYPE_AIF_OUT          0x19
    GB_AUDIO_WIDGET_TYPE_SIGGEN           0x1a
    GB_AUDIO_WIDGET_TYPE_DAI_IN           0x1b
    GB_AUDIO_WIDGET_TYPE_DAI_OUT          0x1c
    GB_AUDIO_WIDGET_TYPE_DAI_LINK         0x1d
    ===================================== =====

..

.. _audio-widget-state:

Greybus Audio Widget State
""""""""""""""""""""""""""

Table :num:`table-audio-widget-state` describes the audio widget state.

.. figtable::
    :nofig:
    :label: table-audio-widget-state
    :caption: Audio Widget State
    :spec: l l

    ============================== =====
    Widget State                   Value
    ============================== =====
    Invalid                        0x00
    GB_AUDIO_WIDGET_STATE_DISABLED 0x01
    GB_AUDIO_WIDGET_STATE_ENABLED  0x02
    ============================== =====

..

.. _audio-route-struct:

Greybus Audio Route Structure
"""""""""""""""""""""""""""""

Table :num:`table-audio-route-structure` describes the structure containing
route information for Audio Modules.

.. figtable::
    :nofig:
    :label: table-audio-route-structure
    :caption: Audio Route Structure
    :spec: l l c c l

    ====== ============== ==== ====== ========================
    Offset Field          Size Value  Description
    ====== ============== ==== ====== ========================
    0      source_id      1    Number ID of source widget
    1      destination_id 1    Number ID of destination widget
    2      control_id     1    Number Control ID
    ====== ============== ==== ====== ========================

..

Greybus Audio Get Control Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Get Control operation allows the requester to
retrieve the current value of an audio control from an Audio Module.

Greybus Audio Get Control Request
"""""""""""""""""""""""""""""""""

Table :num:`table-audio-get-control-request` describes the
Greybus Audio Get Control request. The request contains a
one-byte control ID which uniquely identifies the audio control.

.. figtable::
    :nofig:
    :label: table-audio-get-control-request
    :caption: Audio Get Control Request
    :spec: l l c c l

    ====== ========== ==== ====== ===========
    Offset Field      Size Value  Description
    ====== ========== ==== ====== ===========
    0      control_id 1    Number Control ID
    ====== ========== ==== ====== ===========

..

Greybus Audio Get Control Response
""""""""""""""""""""""""""""""""""

Table :num:`table-audio-get-control-response` describes the Greybus
Audio Get Control response. The response payload contains a four-byte
value specifying the current value for a control.

.. figtable::
    :nofig:
    :label: table-audio-get-control-response
    :caption: Audio Get Control Response
    :spec: l l c c l

    ====== ========== ==== ========= ========================================
    Offset Field      Size Value     Description
    ====== ========== ==== ========= ========================================
    0      value      63   Structure :ref:`audio-ctl-elem-val-struct`
    ====== ========== ==== ========= ========================================

..

.. _audio-ctl-elem-val-struct:

Greybus Audio Control Element Value Structure
"""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-audio-ctl-elem-val-struct` describes the structure containing
control element identification and values for Audio Modules.

.. figtable::
    :nofig:
    :label: table-audio-ctl-elem-val-struct
    :caption: Audio Control Element Value Structure
    :spec: l l c c l

    ====== ========== ==== ========= ========================================
    Offset Field      Size Value     Description
    ====== ========== ==== ========= ========================================
    0      id         47   Structure :ref:`audio-ctl-elem-id`
    47     timestamp  8    Number    Timestamp
    55     value      8    Union     :ref:`audio-ctl-elem-val-union`
    ====== ========== ==== ========= ========================================

..

.. _audio-ctl-elem-val-union:

Greybus Audio Control Element Value Union
"""""""""""""""""""""""""""""""""""""""""

Table :num:`table-audio-ctl-elem-val-union` describes the
union containing control element values for Audio Modules.

.. figtable::
    :nofig:
    :label: table-audio-ctl-elem-val-union
    :caption: Audio Control Element Value Union
    :spec: l l c c l

    ====== ============= ==== ========= ============================
    Offset Field         Size Value     Description
    ====== ============= ==== ========= ============================
    0      integer       4    Number    The 32-bit integer value
    0      integer64     8    Number    The 64-bit integer value
    0      enumerated    4    Number    Enumerated type item index
    ====== ============= ==== ========= ============================

..

Greybus Audio Set Control Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Set Control operation allows the requester to
set the current value of an audio control on an Audio Module.

Greybus Audio Set Control Request
"""""""""""""""""""""""""""""""""

Table :num:`table-audio-set-control-request` describes the
Greybus Audio Set Control request. The request contains a
one-byte control ID which uniquely identifies the audio control
and a 63-byte structure that specifies the new value.

.. figtable::
    :nofig:
    :label: table-audio-set-control-request
    :caption: Audio Set Control Request
    :spec: l l c c l

    ====== ========== ==== ========= ========================================
    Offset Field      Size Value     Description
    ====== ========== ==== ========= ========================================
    0      control_id 1    Number    Control ID
    1      value      63   Structure :ref:`audio-ctl-elem-val-struct`
    ====== ========== ==== ========= ========================================

..

Greybus Audio Set Control Response
""""""""""""""""""""""""""""""""""

The Greybus Audio Set Control response has no payload.

Greybus Audio Enable Widget Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Enable Widget operation allows the requester to
enable a widget on an Audio Module.

Greybus Audio Enable Widget Request
"""""""""""""""""""""""""""""""""""

The Greybus Audio Enable Widget request has no payload.

Greybus Audio Enable Widget Response
""""""""""""""""""""""""""""""""""""

The Greybus Audio Enable Widget response has no payload.

Greybus Audio Get PCM Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Get PCM operation allows the requester to
retrieve the current audio PCM settings from an Audio Module.

Greybus Audio Get PCM Request
"""""""""""""""""""""""""""""

Table :num:`table-audio-get-pcm-request` describes the
Greybus Audio Get PCM request. The request supplies the
DAI CPort which uniquely identifies the DAI whose configuration
is being queried.

.. figtable::
    :nofig:
    :label: table-audio-get-pcm-request
    :caption: Audio Get PCM Request
    :spec: l l c c l

    ====== ========= ==== ======== ================================
    Offset Field     Size Value    Description
    ====== ========= ==== ======== ================================
    0      dai_cport 2    Number   DAI's CPort
    ====== ========= ==== ======== ================================

..

Greybus Audio Get PCM Response
""""""""""""""""""""""""""""""

Table :num:`table-audio-get-pcm-response` describes the Greybus
Audio Get PCM response. The response payload contains a four-byte value
specifying the current PCM format, a four-byte value specifying the
current sampling rate, a one-byte value specifying the number of audio
channels, and a one-byte value specifying the number of significant
bits of audio data in each channel.

.. figtable::
    :nofig:
    :label: table-audio-get-pcm-response
    :caption: Audio Get PCM Response
    :spec: l l c c l

    ====== ======== ==== ======== ==================================
    Offset Field    Size Value    Description
    ====== ======== ==== ======== ==================================
    0      format   4    Bit mask :ref:`audio-pcm-format-flags`
    4      rate     4    Bit mask :ref:`audio-pcm-rate-flags`
    8      channels 1    Number   Number of audio channels
    9      sig_bits 1    Number   Number of significant bits of data
    ====== ======== ==== ======== ==================================

..

Greybus Audio Set PCM Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Set PCM operation allows the requester to
set the current audio PCM settings on an Audio Module.

Greybus Audio Set PCM Request
"""""""""""""""""""""""""""""

Table :num:`table-audio-set-pcm-request` describes the
Greybus Audio Set PCM request. The request supplies the
DAI CPort which uniquely identifies the DAI whose configuration
is being set.

.. figtable::
    :nofig:
    :label: table-audio-set-pcm-request
    :caption: Audio Set PCM Request
    :spec: l l c c l

    =======  =========  ====  ======== ==================================
    Offset   Field      Size  Value    Description
    =======  =========  ====  ======== ==================================
    0        dai_cport  2     Number   DAI's CPort
    2        format     4     Bit mask :ref:`audio-pcm-format-flags`
    6        rate       4     Bit mask :ref:`audio-pcm-rate-flags`
    10       channels   1     Number   Number of audio channels
    11       sig_bits   1     Number   Number of significant bits of data
    =======  =========  ====  ======== ==================================

..

Greybus Audio Set PCM Response
""""""""""""""""""""""""""""""

The Greybus Audio Set PCM response has no payload.

.. _audio-set-tx-data-size-operation:

Greybus Audio Set TX Data Size Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Set TX Data Size operation allows the requester to
set the number of bytes of audio data contained in a
:ref:`audio-send-data` going from the AP Module to an Audio Module.

Greybus Audio Set TX Data Size Request
""""""""""""""""""""""""""""""""""""""

Table :num:`table-audio-set-tx-data-size-request` describes the
Greybus Audio Set TX Data Size request. The request supplies the
DAI CPort, which uniquely identifies the DAI, and the number of
bytes of audio data that shall be contained in a :ref:`audio-send-data`.
The size shall be an integer multiple of the number of bytes in a
complete audio sample (i.e., number of bytes per channel times the
number of channels).

.. figtable::
    :nofig:
    :label: table-audio-set-tx-data-size-request
    :caption: Audio Set TX Data Size Request
    :spec: l l c c l

    =======  =========  ====  ======== ================================
    Offset   Field      Size  Value    Description
    =======  =========  ====  ======== ================================
    0        dai_cport  2     Number   DAI's CPort
    2        size       2     Number   Number of audio data bytes
    =======  =========  ====  ======== ================================

..

Greybus Audio Set TX Data Size Response
"""""""""""""""""""""""""""""""""""""""

The Greybus Audio Set TX Data Size response has no payload.

Greybus Audio Get TX Delay Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Get TX Delay operation allows the requester to
retrieve the amount of time the module requires from when the first
:ref:`audio-send-data` is received until the first audio sample
contained in that message is audible.  The delay value is in microseconds.

Greybus Audio Get TX Delay Request
""""""""""""""""""""""""""""""""""

Table :num:`table-audio-get-tx-delay-request` describes the
Greybus Audio Get TX Delay request. The request supplies the
DAI CPort which uniquely identifies the DAI.

.. figtable::
    :nofig:
    :label: table-audio-get-tx-delay-request
    :caption: Audio Get TX Delay Request
    :spec: l l c c l

    ====== ========= ==== ======== ================================
    Offset Field     Size Value    Description
    ====== ========= ==== ======== ================================
    0      dai_cport 2    Number   DAI's CPort
    ====== ========= ==== ======== ================================

..

Greybus Audio Get TX Delay Response
"""""""""""""""""""""""""""""""""""

Table :num:`table-audio-get-tx-delay-response` describes the Greybus
Audio Get TX Delay response. The response payload contains a four-byte
unsigned value specifying the amount of time the module requires from
when the first :ref:`audio-send-data` is received until the first audio
sample contained in that message is audible.  The delay value is in
microseconds.

.. figtable::
    :nofig:
    :label: table-audio-get-tx-delay-response
    :caption: Audio Get TX Delay Response
    :spec: l l c c l

    ====== ======== ==== ======== ==================================
    Offset Field    Size Value    Description
    ====== ======== ==== ======== ==================================
    0      delay    4    Number   Delay in microseconds
    ====== ======== ==== ======== ==================================

..

.. _audio-activate-tx-operation:

Greybus Audio Activate TX Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Activate TX operation requests that the Audio Module
prepare to receive audio data on the specified Audio Data Connection.
The audio data shall be output using an audio output device (e.g., speaker).

Greybus Audio Activate TX Request
"""""""""""""""""""""""""""""""""

Table :num:`table-audio-activate-tx-request` describes the
Greybus Audio Activate TX request. The request supplies the
DAI CPort which uniquely identifies the DAI.

.. figtable::
    :nofig:
    :label: table-audio-activate-tx-request
    :caption: Audio Activate TX Request
    :spec: l l c c l

    =======  =========  ====  ======== ================================
    Offset   Field      Size  Value    Description
    =======  =========  ====  ======== ================================
    0        dai_cport  2     Number   DAI's CPort
    =======  =========  ====  ======== ================================

..

Greybus Audio Activate TX Response
""""""""""""""""""""""""""""""""""

The Greybus Audio Activate TX response has no payload.

Greybus Audio Deactivate TX Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Deactivate TX operation requests that the AP Module
no longer accept audio data on the specified CPort.  The AP Module may
free any resources allocated by the corresponding
:ref:`audio-activate-tx-operation`.  Any audio data received on a
deactivated Audio Data Connection shall be ignored.

Greybus Audio Deactivate TX Request
"""""""""""""""""""""""""""""""""""

Table :num:`table-audio-deactivate-tx-request` describes the
Greybus Audio Deactivate TX request. The request supplies the
DAI CPort which uniquely identifies the DAI.

.. figtable::
    :nofig:
    :label: table-audio-deactivate-tx-request
    :caption: Audio Deactivate TX Request
    :spec: l l c c l

    =======  =========  ====  ======== ================================
    Offset   Field      Size  Value    Description
    =======  =========  ====  ======== ================================
    0        dai_cport  2     Number   DAI's CPort
    =======  =========  ====  ======== ================================

..

Greybus Audio Deactivate TX Response
""""""""""""""""""""""""""""""""""""

The Greybus Audio Deactivate TX response has no payload.

.. _audio-set-rx-data-size-operation:

Greybus Audio Set RX Data Size Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Set RX Data Size operation allows the requester to
set the number of bytes of audio data contained in a
:ref:`audio-send-data` going from an Audio Module to the AP Module.

Greybus Audio Set RX Data Size Request
""""""""""""""""""""""""""""""""""""""

Table :num:`table-audio-set-rx-data-size-request` describes the
Greybus Audio Set RX Data Size request. The request supplies the
DAI CPort, which uniquely identifies the DAI, and the number of
bytes of audio data that shall be contained in a :ref:`audio-send-data`.
The size shall be an integer multiple of the number of bytes in a
complete audio sample (i.e., number of bytes per channel times the
number of channels).

.. figtable::
    :nofig:
    :label: table-audio-set-rx-data-size-request
    :caption: Audio Set RX Data Size Request
    :spec: l l c c l

    =======  =========  ====  ======== ================================
    Offset   Field      Size  Value    Description
    =======  =========  ====  ======== ================================
    0        dai_cport  2     Number   DAI's CPort
    2        size       2     Number   Number of audio data bytes
    =======  =========  ====  ======== ================================

..

Greybus Audio Set RX Data Size Response
"""""""""""""""""""""""""""""""""""""""

The Greybus Audio Set RX Data Size response has no payload.

Greybus Audio Get RX Delay Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Get RX Delay operation allows the requester to
retrieve the amount of time the module requires from when the
receive function is activated until the first :ref:`audio-send-data`
is sent.  The delay value is in microseconds.

Greybus Audio Get RX Delay Request
""""""""""""""""""""""""""""""""""

Table :num:`table-audio-get-rx-delay-request` describes the
Greybus Audio Get RX Delay request. The request supplies the
DAI CPort which uniquely identifies the DAI.

.. figtable::
    :nofig:
    :label: table-audio-get-rx-delay-request
    :caption: Audio Get RX Delay Request
    :spec: l l c c l

    ====== ========= ==== ======== ================================
    Offset Field     Size Value    Description
    ====== ========= ==== ======== ================================
    0      dai_cport 2    Number   DAI's CPort
    ====== ========= ==== ======== ================================

..

Greybus Audio Get RX Delay Response
"""""""""""""""""""""""""""""""""""

Table :num:`table-audio-get-rx-delay-response` describes the Greybus
Audio Get RX Delay response. The response payload contains a four-byte
unsigned value specifying the amount of time the module requires from
when the receive function is activated until the first
:ref:`audio-send-data` is sent in the current configuration.
The delay value is in microseconds.

.. figtable::
    :nofig:
    :label: table-audio-get-rx-delay-response
    :caption: Audio Get RX Delay Response
    :spec: l l c c l

    ====== ======== ==== ======== ==================================
    Offset Field    Size Value    Description
    ====== ======== ==== ======== ==================================
    0      delay    4    Number   Delay in microseconds
    ====== ======== ==== ======== ==================================

..

.. _audio-activate-rx-operation:

Greybus Audio Activate RX Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Activate RX operation requests that the Audio Module
begin capturing audio data and sending it to the AP Modules using the
specified CPort.

Greybus Audio Activate RX Request
"""""""""""""""""""""""""""""""""

Table :num:`table-audio-activate-rx-request` describes the
Greybus Audio Activate RX request. The request supplies the
DAI CPort which uniquely identifies the DAI.

.. figtable::
    :nofig:
    :label: table-audio-activate-rx-request
    :caption: Audio Activate RX Request
    :spec: l l c c l

    =======  =========  ====  ======== ================================
    Offset   Field      Size  Value    Description
    =======  =========  ====  ======== ================================
    0        dai_cport  2     Number   DAI's CPort
    =======  =========  ====  ======== ================================

..

Greybus Audio Activate RX Response
""""""""""""""""""""""""""""""""""

The Greybus Audio Activate RX response has no payload.

Greybus Audio Deactivate RX Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Deactivate RX operation requests that the Audio Module
stop capturing audio data and sending it to the AP Module.  The AP Module
may free any resources allocated by the corresponding
:ref:`audio-activate-rx-operation`.

Greybus Audio Deactivate RX Request
"""""""""""""""""""""""""""""""""""

Table :num:`table-audio-deactivate-rx-request` describes the
Greybus Audio Deactivate RX request. The request supplies the
DAI CPort which uniquely identifies the DAI.

.. figtable::
    :nofig:
    :label: table-audio-deactivate-rx-request
    :caption: Audio Deactivate RX Request
    :spec: l l c c l

    =======  =========  ====  ======== ================================
    Offset   Field      Size  Value    Description
    =======  =========  ====  ======== ================================
    0        dai_cport  2     Number   DAI's CPort
    =======  =========  ====  ======== ================================

..

Greybus Audio Deactivate RX Response
""""""""""""""""""""""""""""""""""""

The Greybus Audio Deactivate RX response has no payload.

Greybus Audio Jack Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Jack Event operation allows the requester
to notify the AP Module of audio jack events.

Greybus Audio Jack Event Request
""""""""""""""""""""""""""""""""

Table :num:`table-audio-jack-event-request` defines the Greybus Audio
Jack Event Request.  The request supplies a one-byte widget ID,
a one-byte widget type, and the one-byte event being reported.

.. figtable::
    :nofig:
    :label: table-audio-jack-event-request
    :caption: Audio Jack Event Request
    :spec: l l c c l

    =======  ==========  ====  ======== ================================
    Offset   Field       Size  Value    Description
    =======  ==========  ====  ======== ================================
    0        widget id   1     Number   Widget ID
    1        type        1     Number   :ref:`audio-widget-type`
    2        event       1     Number   :ref:`audio-jack-events`
    =======  ==========  ====  ======== ================================

..

.. _audio-jack-events:

Greybus Audio Jack Events
"""""""""""""""""""""""""

Table :num:`table-audio-jack-events` defines the Greybus Audio
audio jack events and their values.

.. figtable::
    :nofig:
    :label: table-audio-jack-events
    :caption: Audio Events
    :spec: l l l

    ============================== ========================== =====
    Symbol                         Brief Description          Value
    ============================== ========================== =====
    GB_AUDIO_JACK_EVENT_INSERTION  Device inserted into jack  0x01
    GB_AUDIO_JACK_EVENT_REMOVAL    Device removed from jack   0x02
    ============================== ========================== =====

..

Greybus Audio Jack Event Response
"""""""""""""""""""""""""""""""""

The Greybus Audio Jack Event response message has no payload.

Greybus Audio Button Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Button Event operation allows the requester
to notify the AP Module of audio button events.

Greybus Audio Button Event Request
""""""""""""""""""""""""""""""""""

Table :num:`table-audio-button-event-request` defines the Greybus Audio
Button Event Request.  The request supplies a one-byte widget ID,
a one-byte button ID, and the one-byte button event being reported.

.. figtable::
    :nofig:
    :label: table-audio-button-event-request
    :caption: Audio Button Event Request
    :spec: l l c c l

    =======  ==========  ====  ======== ================================
    Offset   Field       Size  Value    Description
    =======  ==========  ====  ======== ================================
    0        widget id   1     Number   Widget ID
    1        button id   1     Number   Button ID
    2        event       1     Number   :ref:`audio-button-events`
    =======  ==========  ====  ======== ================================

..

.. _audio-button-events:

Greybus Audio Button Events
"""""""""""""""""""""""""""

Table :num:`table-audio-button-events` defines the Greybus Audio
audio button events and their values.

.. figtable::
    :nofig:
    :label: table-audio-button-events
    :caption: Audio Events
    :spec: l l l

    ============================== ==================== =====
    Symbol                         Brief Description    Value
    ============================== ==================== =====
    GB_AUDIO_BUTTON_EVENT_PRESS    Button was pressed   0x01
    GB_AUDIO_BUTTON_EVENT_RELEASE  Button was released  0x02
    ============================== ==================== =====

..

Greybus Audio Button Event Response
"""""""""""""""""""""""""""""""""""

The Greybus Audio Button Event response message has no payload.

Greybus Audio Streaming Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Streaming Event operation allows the requester
to notify the AP Module of audio streaming events.

Greybus Audio Streaming Event Request
"""""""""""""""""""""""""""""""""""""

Table :num:`table-audio-streaming-event-request` defines the Greybus Audio
Streaming Event Request.  The request supplies the DAI CPort, which uniquely
identifies the DAI, and the one-byte event being reported.

.. figtable::
    :nofig:
    :label: table-audio-streaming-event-request
    :caption: Audio Streaming Event Request
    :spec: l l c c l

    =======  =========  ====  ========= ================================
    Offset   Field      Size  Value     Description
    =======  =========  ====  ========= ================================
    0        dai_cport  2     Number    DAI's CPort
    2        event      1     Number    :ref:`audio-streaming-events`
    =======  =========  ====  ========= ================================

..

.. _audio-streaming-events:

Greybus Audio Streaming Events
""""""""""""""""""""""""""""""

Table :num:`table-audio-streaming-events` defines the Greybus Audio
audio streaming events and their values.

.. figtable::
    :nofig:
    :label: table-audio-streaming-events
    :caption: Audio Events
    :spec: l l l

    ======================================= ======================== =====
    Symbol                                  Brief Description        Value
    ======================================= ======================== =====
    GB_AUDIO_STREAMING_EVENT_UNSPECIFIED    Catch-all for events     0x01
                                            not in this table
    GB_AUDIO_STREAMING_EVENT_HALT           Streaming has halted     0x02
    GB_AUDIO_STREAMING_EVENT_INTERNAL_ERROR Internal error that      0x03
                                            should never happen
    GB_AUDIO_STREAMING_EVENT_PROTOCOL_ERROR Incorrect Operation      0x04
                                            order, etc.
    GB_AUDIO_STREAMING_EVENT_FAILURE        Operation failed         0x05
    GB_AUDIO_STREAMING_EVENT_UNDERRUN       No data to send          0x06
    GB_AUDIO_STREAMING_EVENT_OVERRUN        Flooded by data          0x07
    GB_AUDIO_STREAMING_EVENT_CLOCKING       Low-level clocking issue 0x08
    GB_AUDIO_STREAMING_EVENT_DATA_LEN       Invalid message data     0x09
                                            length
    ======================================= ======================== =====

..

Greybus Audio Streaming Event Response
""""""""""""""""""""""""""""""""""""""

The Greybus Audio Streaming Event response message has no payload.

.. _audio-send-data:

Greybus Audio Send Data Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio Send Data Operation sends audio data over a
Greybus Audio Data Connection.  No response message shall be sent.

Greybus Audio Send Data Request
"""""""""""""""""""""""""""""""

Table :num:`table-audio-send-data-request` Greybus Audio Send Data Request
sends one or more complete audio samples.  The size of the audio data is
shall match the value specified in the most recent
:ref:`audio-set-rx-data-size-operation`.  It is a protocol error to send
this message without first setting the data size.

.. figtable::
    :nofig:
    :label: table-audio-send-data-request
    :caption: Audio Protocol Send Data Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        timestamp       8       Number          Time that audio sample
                                                     is to be output
    8        data            *size*  Data            Audio data
    =======  ==============  ======  ==========      ===========================

..

Greybus Audio Send Data Response
""""""""""""""""""""""""""""""""

There shall be no response message for the Greybus Audio send data request.

Bluetooth Protocol
------------------

TBD

Consumer IR Protocol
--------------------

TBD

GPS Protocol
------------

TBD

HID Protocol
------------

This section defines the operations used on a connection implementing
the Greybus Human Interface Device (HID) Protocol. The HID class is
used primarily for devices that take input from humans or may give
output to humans.  Typical examples of HID class devices include:

* Keyboards and pointing devices
* Front panel controls, like: knobs, buttons, switches, etc.
* Steering wheels, rudder pedals found on gaming devices.
* Buttons, touchscreen found on phones.
* Bar-code readers, thermometers, or voltmeters.

The Greybus HID Protocol uses *descriptors* and *reports* to
interact with a HID device.  A HID Descriptor defines all
capabilities of a HID device.   Before exchanging data with
a HID device, the AP Module can configure a HID device based on
these capabilities by sending Feature Reports.  Data exchange
between the AP Module and a HID device are implemented by
sending Input or Output Reports.

This document focuses on how the HID protocol is implemented over
Greybus.  The HID Protocol (as implemented over USB) is well defined
by [HID01]_.

Greybus HID Descriptors
^^^^^^^^^^^^^^^^^^^^^^^
The following section identifies the key data structures (referred to as
HID Descriptors) that need to be exchanged between the host and the device
during initialization.

.. _hid-descriptor:

HID Descriptor
""""""""""""""
The HID Descriptor is the top-level mandatory descriptor that every Greybus
based HID device must have. The purpose of the HID Descriptor is to
define all capabilities of the HID device with the host. These
attributes describe the version of the HID Protocol the HID device
is compliant with, the length of HID Descriptors, and other
capabilities of the device. Please refer to Table
:num:`table-hid-descriptor` for further details.

HID Report Descriptor
"""""""""""""""""""""
A HID Report Descriptor describes the data generated by the HID
device, and how to interpret that data. Details of the HID Report
Descriptor are outside of the scope of this document and are defined
in [HID01]_.

HID Report Protocol
^^^^^^^^^^^^^^^^^^^
The Report is the fundamental block exchanged between the host and the device.
Reports are well defined by [HID01]_, and the the same will be followed here.

HID Input Report
""""""""""""""""
The input reports are generated on the device and are sent from device to host.
This can be requested synchronously or asynchronously.

In the asynchronous case, when the device has active data it wishes to report to
the host, it will generate an data request towards the host. When the host
receives the receive request, it is responsible for reading the data from the
receive request.

In the synchronous case, the host can generate a get-report request to HID
device, in response to which the device must respond with data.

HID Output Report
"""""""""""""""""
The output report is generated on the host and is sent from host to device over
the Greybus transport. When the host has active data it wishes to report to the
device, it must generate a set-report request.

HID Feature Report
""""""""""""""""""
The feature report is a bidirectional report and can be exchanged between the
host and the device. They are normally used by the host to program the device
into different configurations.

For the host to get/set a feature-report on the device, it must use the
get-report and set-report requests described later.

Greybus HID Operations
^^^^^^^^^^^^^^^^^^^^^^

Greybus HID Protocol allows an AP to manage a HID device present on a module.
The Protocol consists of few basic operations, whose request and response
message formats are defined here.

Conceptually, the operations in the greybus HID Protocol are:

.. c:function:: int ping(void);

    See :ref:`greybus-protocol-ping-operation`.

.. c:function:: int get_descriptor(struct gb_hid_desc_response *desc);

    Returns :ref:`hid-descriptor`, that specifies details of the HID device.

.. c:function:: int get_report_descriptor(u8 *report_desc);

    Returns a HID Report Descriptor, defined by [HID01]_.

.. c:function:: int power_on(void);

    Power-on the HID device.

.. c:function:: int power_off(void);

    Power-off the HID device.

.. c:function:: int get_report(u8 *report);

    Gets input or feature report from device to host synchronously.

.. c:function:: int set_report(u8 *report);

    Sets output or feature report from host to device synchronously.

.. c:function:: int irq_event(u8 *report);

    Input report sent from device to host asynchronously.

Greybus HID Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-hid-operation-type` describes the Greybus HID operation types
and their values. A message type consists of an operation type combined with a
flag (0x80) indicating whether the operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-hid-operation-type
    :caption: HID Operation Types
    :spec: l l l

    ===========================  =============  ==============
    HID Operation Type           Request Value  Response Value
    ===========================  =============  ==============
    Ping                         0x00           0x80
    Reserved                     0x01           0x81
    Get Descriptor               0x02           0x82
    Get Report Descriptor        0x03           0x83
    Power On                     0x04           0x84
    Power Off                    0x05           0x85
    Get Report                   0x06           0x86
    Set Report                   0x07           0x87
    IRQ Event                    0x08           0x88
    (all other values reserved)  0x09..0x7e     0x89..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

Greybus HID Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus HID Ping Operation is the
:ref:`greybus-protocol-ping-operation` for the HID Protocol.
It consists of a request containing no payload, and a response
with no payload that indicates a successful result.

Greybus HID Get Descriptor Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus HID Get Descriptor operation is issued on the host and the HID
device must respond with an :ref:`hid-descriptor`.

Greybus HID Get Descriptor Request
""""""""""""""""""""""""""""""""""

The Greybus HID Get Descriptor request is sent from host to device and
it has no payload.

Greybus HID Get Descriptor Response
"""""""""""""""""""""""""""""""""""

The Greybus HID Get Descriptor response is sent from device to host and is
described in Table :num:`table-hid-descriptor`.

.. figtable::
    :nofig:
    :label: table-hid-descriptor
    :caption: Greybus HID Descriptor
    :spec: l l c c l

    =======  ==================  ======  ==========      ===========================
    Offset   Field               Size    Value           Description
    =======  ==================  ======  ==========      ===========================
    0        length              1       Number          Length of this descriptor
    1        report_desc_length  2       Number          Length of the report descriptor
    3        hid_version         2       Number          Version of the HID Protocol, as defined by [HID01]_
    5        product_id          2       Number          Product ID of the device
    7        vendor_id           2       Number          Vendor ID of the device
    9        country_code        1       Number          Country code of the localized hardware; see [HID01]_
    =======  ==================  ======  ==========      ===========================

..

Greybus HID Get Report Descriptor Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus HID Get Report Descriptor operation is issued on host and the HID
device must respond with an report descriptor as defined by [HID01]_.

Greybus HID Get Report Descriptor Request
"""""""""""""""""""""""""""""""""""""""""

The Greybus HID Get Report Descriptor request is sent from host to device and
the request has no payload.

Greybus HID Get Report Descriptor Response
""""""""""""""""""""""""""""""""""""""""""

The Greybus HID Get Report Descriptor response is sent from device to host and
it consists of a HID Report Descriptor defined by [HID01]_.

Greybus HID Power ON Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus HID power-on operation is sent from host to device to power on the HID device.

Greybus HID Power ON Request
""""""""""""""""""""""""""""

The Greybus HID power-on operation request has no payload.

Greybus HID Power ON Response
"""""""""""""""""""""""""""""

The Greybus HID power-on response has no payload.


Greybus HID Power OFF Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus HID power-off operation is sent from host to device to power off the
HID device.

Greybus HID Power OFF Request
"""""""""""""""""""""""""""""

The Greybus HID power-off operation request has no payload.

Greybus HID Power OFF Response
""""""""""""""""""""""""""""""

The Greybus HID power-off response has no payload.


Greybus HID Get Report Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus HID get report operation allows the host to fetch feature or input
report synchronously from a HID device.

The get-report command is a mandatory request (if the device contains Input or
Feature reports) that the host can issue to the device at any time after
initialization to get a singular report from the device. The device is
responsible for responding with the last known input or feature for the report
id. If the value has not been set for that report yet, the device must return 0
for the length of report item.

Get-report is often used by applications on startup to retrieve the “current
state” of the device rather than waiting for the device to generate the next
Input/Feature Report.

Greybus HID Get Report Request
""""""""""""""""""""""""""""""

The Greybus HID get report request contain 1-byte report-type and report-id as
defined by Table :num:`table-hid-get-report-request`.

.. figtable::
    :nofig:
    :label: table-hid-get-report-request
    :caption: HID Get Report Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        report_type     1       Number          :ref:`hid-report-type`
    1        report_id       1       Number          Report ID defined by [HID01]_
    =======  ==============  ======  ==========      ===========================

..

.. _hid-report-type:

Greybus HID Report Type
"""""""""""""""""""""""

Table :num:`table-hid-report-type` describes the defined HID report type values
defined for Greybus HID devices.

.. figtable::
    :nofig:
    :label: table-hid-report-type
    :caption: HID ReportType
    :spec: l l

    ===============     ======
    HID Report Type     Value
    ===============     ======
    Input Report        0x0000
    Output Report       0x0001
    Feature Report      0x0002
    ===============     ======

..

Greybus HID Get Report Response
"""""""""""""""""""""""""""""""

The Greybus HID Get Report response returns report as defined by
[HID01]_.

Greybus HID Set Report Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus HID set report operation allows the host to send feature or output
report synchronously to a HID device.

The set-report command is a specific request that the host may issue to the
device at any time after initialization to set a singular report on the device.
The device is responsible for accepting the value provided in the operation and
updating its state.

Greybus HID Set Report Request
""""""""""""""""""""""""""""""

.. figtable::
    :nofig:
    :label: table-hid-set-report-request
    :caption: HID Set Report Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        report_type     1       Number          :ref:`hid-report-type`
    1        report_id       1       Number          Report ID defined by [HID01]_
    2        report          ...     Data            Report defined by [HID01]_
    =======  ==============  ======  ==========      ===========================

The Greybus HID set report request contain report-type, report-id and
report (as defined by [HID01]_, and as defined in Table
:num:`table-hid-set-report-request`).

Greybus HID Set Report Response
"""""""""""""""""""""""""""""""

The Greybus HID Set Report response has no payload.

Greybus HID IRQ Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus IRQ Event operation allows the AP to receive input-report
asynchronously, when HID device has some data available to send to the AP.

Greybus HID IRQ Event Request
"""""""""""""""""""""""""""""

When the HID device has active data it wishes to report to the host, it will
generate an data request towards the host. When the host receives the receive
request, it is responsible for reading the data from the receive request.

The format of the input-report is defined by [HID01]_.

Greybus HID IRQ Event Response
""""""""""""""""""""""""""""""

The Greybus IRQ Event response has no payload.


Keymaster Protocol
------------------

TBD

Lights Protocol
---------------

This section defines operations used on a connection implementing the Greybus
Lights Protocol. This Protocol allows an AP Module to control Lights devices
present on a Module. The Protocol consists of some basic operations that are
defined here.

The operations in the Greybus Lights Protocol are:

.. c:function:: int ping(void);

    See :ref:`greybus-protocol-ping-operation`.

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
    Ping                         0x00           0x80
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

Greybus Lights Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Ping Operation is the
:ref:`greybus-protocol-ping-operation` for the Lights Protocol.
It consists of a request containing no payload, and a response
with no payload that indicates a successful result.

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

Sensors Protocol
----------------

TBD

Loopback Protocol
-----------------

This section defines the operations used on a connection implementing
the Greybus loopback Protocol.  This Protocol is used for testing a
Greybus device and the connection to the device, by sending and
receiving data in a "loop".

The operations in the Greybus loopback Protocol are:

.. c:function:: int ping(void);

    See :ref:`greybus-protocol-ping-operation`.

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
    Ping                         0x00           0x80
    Reserved                     0x01           0x81
    Ping                         0x02           0x82
    Transfer                     0x03           0x83
    Sink                         0x04           0x84
    (all other values reserved)  0x05..0x7e     0x85..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

Greybus Loopback Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Loopback Ping Operation is the
:ref:`greybus-protocol-ping-operation` for the Loopback Protocol.
It consists of a request containing no payload, and a response
with no payload that indicates a successful result.

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

.. c:function:: int ping(void);

    See :ref:`greybus-protocol-ping-operation`.

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
    Ping                         0x00           0x80
    Reserved                     0x01           0x81
    Send                         0x02           0x82
    (all other values reserved)  0x04..0x7e     0x84..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

Greybus Raw Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Raw Ping Operation is the
:ref:`greybus-protocol-ping-operation` for the Raw Protocol.
It consists of a request containing no payload, and a response
with no payload that indicates a successful result.

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
