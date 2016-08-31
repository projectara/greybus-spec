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

.. c:function:: int cport_shutdown(u8 phase);

    See :ref:`greybus-protocol-cport-shutdown-operation`.

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
    CPort Shutdown               0x00           0x80
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

.. _audio-cport-shutdown:

Greybus Audio CPort Shutdown Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Audio CPort Shutdown Operation is the
:ref:`greybus-protocol-cport-shutdown-operation` for the Audio
Protocol.

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

    =============================================== ============= ==== ========= ============================
    Offset                                          Field         Size Value     Description
    =============================================== ============= ==== ========= ============================
    0                                               num_dais      1    Number    Number of DAI structures
    1                                               num_controls  1    Number    Number of control structures
    2                                               num_widgets   1    Number    Number of widget structures
    3                                               num_routes    1    Number    Number of route structures
    4                                               size_dais     4    Number    Size of audio_dais
    8                                               size_controls 4    Number    Size of audio_controls
    12                                              size_widgets  4    Number    Size of audio_widgets
    16                                              size_routes   4    Number    Size of audio_routes
    20                                              dai[1]        120  Structure :ref:`audio-dai-struct`
    ...                                             ...           120  Structure :ref:`audio-dai-struct`
    20+120*(I-1)                                    dai[I]        120  Structure :ref:`audio-dai-struct`
    20+size_dais                                    control[1]    XX   Structure :ref:`audio-control-struct`
    ...                                             ...           XX   Structure :ref:`audio-control-struct`
    20+size_dais+XX*(J-1)                           control[J]    XX   Structure :ref:`audio-control-struct`
    20+size_dais+size_controls                      widget[1]     YY   Structure :ref:`audio-widget-struct`
    ...                                             ...           YY   Structure :ref:`audio-widget-struct`
    20+size_dais+size_controls+YY*(K-1)             widget[K]     YY   Structure :ref:`audio-widget-struct`
    20+size_dais+size_controls+size_widgets         route[1]      4    Structure :ref:`audio-route-struct`
    ...                                             ...           4    Structure :ref:`audio-route-struct`
    20+size_dais+size_controls+size_widgets+4*(L-1) route[L]      4    Structure :ref:`audio-route-struct`
    =============================================== ============= ==== ========= ============================

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
    36     access        4    Bit Mask  :ref:`audio-control-access-rights-flags`
    40     count         1    Number    Number of elements of this type
    41     count_values  1    Number    Number of values (max=2, L/R)
    42     info          XX   Structure :ref:`audio-ctl-elem-info`
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
    0      type          1    Bit Mask  :ref:`audio-ctl-elem-type`
    1      dimen[1]      2    Number    First dimension
    ...    ...           2    Number    ...
    7      dimen[4]      2    Number    Fourth dimension
    9      value         XX   Union     :ref:`audio-ctl-elem-val-range-union`
    ====== ============= ==== ========= ========================================

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
    4      names_length  2    Number    Length of names field
    6      names         XX   UTF-8     Enumerated type names
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

    ====== =========== ==== ========= =============================
    Offset Field       Size Value     Description
    ====== =========== ==== ========= =============================
    0      name        32   UTF-8     Widget Name
    32     name        32   UTF-8     Widget Stream Name
    64     id          1    Number    Widget ID
    65     type        1    Number    :ref:`audio-widget-type`
    66     state       1    Number    :ref:`audio-widget-state`
    67     ncontrols   1    Number    Number of widget controls
    68     ctl         XX   Structure :ref:`audio-control-struct`
    ====== =========== ==== ========= =============================

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

    ====== ============== ==== ====== =====================================
    Offset Field          Size Value  Description
    ====== ============== ==== ====== =====================================
    0      source_id      1    Number ID of source widget
    1      destination_id 1    Number ID of destination widget
    2      control_id     1    Number Control ID
    3      index          1    Number Index within the [enumerated] control
    ====== ============== ==== ====== =====================================

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
    1      index      1    Number Index
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
    0      timestamp  8    Number    Timestamp
    8      value      8    Union     :ref:`audio-ctl-elem-val-union`
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
    0      integer       8    Number    The 32-bit integer value
    0      integer64     16   Number    The 64-bit integer value
    0      enumerated    8    Number    Enumerated type item index
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
    1      index      1    Number    Index
    2      value      63   Structure :ref:`audio-ctl-elem-val-struct`
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
    0        widget_id   1     Number   Widget ID
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
    0        widget_id   1     Number   Widget ID
    1        button_id   1     Number   Button ID
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

