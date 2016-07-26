Camera Protocol
---------------

System Architecture (Informative)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Camera Device Class Protocol defines how Camera Modules communicate
with AP Modules in an Ara system. MIPI has specified two interface protocols
for camera integration relevant to Ara systems, CSI-2 and CSI-3.

CSI-2 is a high-speed point-to-point unidirectional data transfer protocol.
It defines an interface between a camera peripheral device and a host processor.
CSI-2 usage is widespread in the mobile industry and is natively supported by
most mobile Application Processors.

CSI-3 is a high-speed bidirectional communication protocol for camera systems.
Based on |unipro|, it specifies communication between camera sensors, image
signal processors, bridge devices and host processors. The Greybus Camera
Device Class Specification currently does not support CSI-3 devices within
Modules.

The current Greybus Camera Device Class Protocol assumes that the AP Module and
any Camera Modules in the system tunnel CSI-2 protocol data through the
|unipro| switch using the |unipro| Bridge vendor proprietary protocol.

.. FIXME: jmondi: Add reference to the forthcoming APBridge-AP connection
    and re-phrase the following paragraph as:
    The Camera AP Bridge encapsulates the CSI-2 stream received from the camera
    into packets and sends them to the application processor, as described in
    the :ref:`name-of-ref-target-to-introduction-which-also-needs-to-be-added`

The Camera AP Bridge encapsulates the CSI-2 stream received from the camera into
packets and sends them on the |unipro| network. On the receiving side the
Application Processor AP Bridge extracts the stream and outputs it over CSI-2
to the application processor.

The Greybus Camera Device Class Protocol describes transmission of image
frames on the Greybus Camera Device Class Data Connections in terms of the
CSI-2 interface on each side of the CSI-2 over |unipro| tunnel. Control
messages exchanged over |unipro| outside of this are be described in terms of
Greybus Camera Management Operations as for all other Greybus Device Class
Protocols.

The specific protocol used to communicate between the Camera AP Bridge
and the components internal to the Camera Module is considered to be
implementation-specific and outside the scope of this document.

Connection
^^^^^^^^^^

Camera Bundle
"""""""""""""

Camera Modules shall have at least one Greybus Interface that contains a Camera
Bundle. The Camera Bundle, whose class is specified in Table
:num:`table-bundle-class`, shall contain exactly two CPorts referred to as the
Camera Management CPort and the Camera Data CPort. Protocol numbers assigned to
these CPorts are specified in Table :num:`table-cport-protocol`.

Camera Management Connection
""""""""""""""""""""""""""""

A Camera Interface is configured and managed via its Camera Management
Connection, which exchanges Operations defined by the Camera Management
Protocol.

Camera Data Connection
""""""""""""""""""""""

Transmission of image data streams shall happen over a single CSI-2 port,
through the Camera Data Connection, where CSI-2 packet transfer is implemented
using the |unipro| AP Bridge vendor proprietary CSI-2 encapsulation protocol.

The Camera Module may select the number of CSI-2 data lanes to setup between
its CSI-2 transmitter and the AP Bridge CSI-2 receiver up to a maximum of four
lanes.

Communications
^^^^^^^^^^^^^^

Camera Management Protocol
""""""""""""""""""""""""""

.. TODO: jmondi: add reference to the list of camera management operations

The Camera Management Protocol is implemented by a set of Camera Management
Operations, split in three categories:

* The Video Setup Operations, which handle capability enumeration and generally
  any retrieval of information from the Camera Interface, for the purpose of
  initializing the peer. Currently, the only defined Video Setup Operation is
  the :ref:`camera-capabilities-operation`.

* The Video Streaming Operations, which control the video streams and their
  parameters such as image resolution and image format. Currently, the two
  defined video streaming Operations are the
  :ref:`camera-configure-streams-operation` and
  :ref:`camera-flush-operation`.

* The Image Processing Operations, which control all the Camera Module image
  capture and processing algorithms and their parameters. Currently, the only
  defined image processing Operation is the
  :ref:`camera-capture-streams-operation`.

Camera Modules shall implement all the Operations defined in this
specification.

When explicitly allowed, Camera Modules may freely select implementation
options but shall ensure that the options are compatible with each other
as mandated by this specification, and shall report the selected options
through capabilities.

Image Data Transmission
"""""""""""""""""""""""

.. pinchartl:
   TODO: Add descriptions of use cases (in particular still image capture)
   somewhere.

All Camera Modules shall support transmission of one video stream over CSI-2.
Additionally, Camera Modules may support additional concurrent video streams,
for instance, to transmit still images or auxiliary channels such as depth maps
or resized images.

Camera Modules shall transmit all streams multiplexed over a single CSI-2 port
and a single Virtual Channel using the Data Type Interleaving method defined
by CSI-2. The Camera Module shall use Packet Level Interleaving as defined in
section 9.13.1 of [CSI-2]_.

.. pinchartl:
   TODO: What are the minimum demultiplexing requirements of the AP
   CSI-2 receiver ?

Metadata Transmission
"""""""""""""""""""""

Metadata is defined as data other than image content that relates to a
particular image frame. Metadata is used by Camera Modules to inform the image
receiver about the characteristics of the transmitted frames, and the applied
capture settings.

Metadata support is optional. However, when supported, it shall be implemented
according to this specification.

The Greybus Camera Device Class Protocol defines two transport methods for
metadata:

* using the :ref:`camera-metadata-operation` explicitly, through the Camera
  Management Connection.
* sending metadata along with image frames over the CSI-2 interface, through
  the Camera Data Connection.

Whenever possible, Camera Modules should use the CSI-2 transport to deliver
metadata.

Camera Modules may implement neither, one or both of these transport methods.
The supported methods shall be reported through the
:ref:`camera-capabilities-operation`

Camera Modules that support metadata transmission shall implement the
CSI-2 frame number counter for all streams that can generate metadata.

.. pinchartl: TODO: Define the minimum counter period.

**CSI-2 Transport**

..  pinchartl:
    TODO: To be revised, meta-data stream configuration needs to be specified.

When transmitting metadata over CSI-2, the Camera Module shall send the metadata
using the same Virtual Channel number as the image frames and set the Data Type
to User Defined 8-bit Data Type 8 (0x37).

Camera Modules should encode metadata using the properties and serialization
format defined in the :ref:`camera-properties` section of Greybus
Camera Device Class specifications.

However, when this isn’t possible or practical (for instance, when the Module
hardware dictates the metadata format), Modules may choose to encode metadata
using a custom method for metadata transmitted over CSI-2.

Metadata transmitted over CSI-2 using a custom encoding shall at minimum
contain the ID of the associated request.

.. TODO: jmondi: we probably want some other mandatory field here

**Metadata Operation**

When transmitting metadata through the dedicated Operation, the Camera Module
shall send a single
:ref:`camera-metadata-request` per image frame.

Metadata transmitted over Camera Management Connection using the
:ref:`camera-metadata-request` shall always be encoded as specified in the
:ref:`camera-properties` section of this specification.

Operational Model
^^^^^^^^^^^^^^^^^

Figure :num:`image-camera-operational-model` describes the operational model of
a Greybus Camera Bundle.

.. _image-camera-operational-model:
.. figure:: /img/dot/camera-operational-model.png
   :align: center

   Operational State Machine of a Greybus Camera Bundle

Upon a :ref:`control-connected`,
that notifies the Camera Interface that a Connection to its Camera Management
CPort has been successfully established, the Greybus Camera Device Class
Protocol state machine is entered, in the UNCONFIGURED state.

The Camera Device Class state machine is exited when the Camera Management
Connection is closed, either as notified by a
:ref:`control-disconnected` referring to the Camera Management CPort, or as a
consequence of forced removal.

The Greybus Camera Device Class state machine has 3 states: UNCONFIGURED,
CONFIGURED, and STREAMING.  Certain Operations are only valid in specific
states, but the :ref:`camera-capabilities-operation`
may be used in any state, and shall always return the same set of camera
capabilities.

The states that define the Camera Device Class state machine are:

* **UNCONFIGURED:**
  In this state the Camera Management Connection is operational.
  The state transitions to CONFIGURED state happens upon receipt of a
  :ref:`camera-configure-streams-request` if the following conditions are
  respected:

  * The Configure Streams Operation return GB_SUCCESS;
  * The Configure Streams Request does not contain any flag that explicitly
    require the Module to remain in UNCONFIGURED state;
  * The Module fully support the requested streams configuration;

* **CONFIGURED:**
  In this state the Bundle shall be ready to process
  :ref:`camera-capture-streams-request`
  immediately as it receives them and then move to STREAMING state.
  Reception of a :ref:`camera-configure-streams-request` with a zero stream
  count returns the Bundle to the UNCONFIGURED state.

* **STREAMING:**
  In this state the Bundle transmits video frames in |unipro| Messages
  encapsulating CSI-2 packets, sent over the Greybus Camera Device Class Data
  Connection. Greybus Capture Stream Requests can be queued, and once there
  are no active or queued Requests, the Bundle moves back to CONFIGURED state.
  Reception of a :ref:`camera-flush-request` clears the queue of pending
  capture requests and also moves the Bundle to the CONFIGURED state.

Greybus Camera Management Protocol
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Conceptually, the Operations in the Greybus Camera Management Protocol are:

.. c:function:: int cport_shutdown(u8 phase);

    See :ref:`greybus-protocol-cport-shutdown-operation`.

.. c:function:: int capabilities(u8 *capabilities);

   Retrieve the list of camera capabilities.

.. c:function:: int configure_streams(u8 num_streams, u8 *flags, struct stream_config *streams);

   Prepares for or halts video streams.

.. c:function:: int capture(u32 request_id, u8 streams, u16 num_frames, const u8 *settings, u16 size);

   Enqueue a frame capture request.

.. c:function:: int flush(u32 *request_id);

   Removes all capture requests from the request queue.

.. c:function:: void metadata(u8 *metadata);

    Send image metadata to the AP.

All the above Operations shall be initiated by the AP Module, except for the
:ref:`camera-metadata-operation` which is, instead, initiated by the Camera
Module.

Greybus Camera Management Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-camera-operations` describes the Greybus Camera Management
Message Types and their values.

.. figtable::
   :nofig:
   :label: table-camera-operations
   :caption: Camera Device Class operations
   :spec: l l l

    ===========================  =============  ==============
    Camera Operation Type        Request Value  Response Value
    ===========================  =============  ==============
    CPort Shutdown               0x00           0x80
    Reserved                     0x01           0x81
    Capabilities                 0x02           0x82
    Configure Streams            0x03           0x83
    Capture                      0x04           0x84
    Flush                        0x05           0x85
    Metadata                     0x06           N/A
    (all other values reserved)  0x07..0x7f     0x87..0xff
    ===========================  =============  ==============
..

.. FIXME: jmondi: the 0x86 Response Value shall be Reserved or N/A
   mbolivar: If you all decide to keep this as a unidirectional Operation,
   please make the response value column just "N/A" -- it's not reserved, it
   just doesn't exist.

.. _camera-cport-shutdown-operation:

Greybus Camera Management CPort Shutdown Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Camera Management CPort Shutdown Operation is the
:ref:`greybus-protocol-cport-shutdown-operation` for the Camera
Management Protocol.

.. _camera-capabilities-operation:

Greybus Camera Management Capabilities Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To allow support for various features and levels of complexity, the
Greybus Camera Device Class defines optional features, which may be
implemented by Camera Bundles.

Using this Operation the sender can dynamically query the Camera Module for its
capabilities.

Once the Camera Management Connection has been set up, the Camera Module shall
respond to all Camera Management Capabilities Requests with the same set of
capabilities. The Interface shall ensure identical capabilities are available as
long as its Interface Lifecycle State remains ENUMERATED.

.. _camera-capabilities-request:

Greybus Camera Management Capabilities Request
""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Camera Management Capabilities Request has no payload.

.. _camera-capabilities-response:

Greybus Camera Management Capabilities Response
"""""""""""""""""""""""""""""""""""""""""""""""
.. FIXME: jmondi Insert link to properties section

The Greybus Camera Management Capabilities Response contains a variable-size
capabilities block that shall conform to the format described in the
:ref:`camera-properties` section of this specification.

The Response payload is shown in Table
:num:`table-camera-operations-capabilities-response`.

.. figtable::
   :nofig:
   :label: table-camera-operations-capabilities-response
   :caption: Camera Class Capabilities response
   :spec: l l c c l

    ======  =============  ======  ===========  ===========================
    Offset  Field          Size    Value        Description
    ======  =============  ======  ===========  ===========================
    0       capabilities   n       Data         Capabilities of Camera Module
    ======  =============  ======  ===========  ===========================
..

.. _camera-configure-streams-operation:

Greybus Camera Management Configure Streams Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Camera Management Configure Streams Operation is used to prepare
the Camera Bundle for image transmission. When applied to a non-zero number of
streams the Operation configures the Camera Module for capture with a list of
stream parameters. A non-zero streams Request is only valid in the UNCONFIGURED
state, the Camera Bundle shall reply with an empty payload and set the status to
GB_OP_INVALID_STATE in all other states.

When instead applied to zero streams, the Operation removes the existing stream
configuration, and moves back the Camera Bundle to the UNCONFIGURED state.

If the requested streams configuration is supported the Camera Bundle moves to
the CONFIGURED state and shall be ready to process Capture Requests with as
little delay as possible. In particular any time-consuming procedure which
implements Module's specific power management shall be performed when moving to
the CONFIGURED state. Camera Modules shall not be kept in the CONFIGURED state
unnecessarily.

Streams shall be transmitted over CSI-2 using the reported Virtual Channels
and Data Types.

All replies to Requests with the same set of parameters shall be identical.

.. TODO: jmondi: properly define the parameters for bandwidth requirement
   extimation

.. TODO: jmondi: The following section shall be revised and included
   Moreover, the camera module, shall report in the operation response
   configuration parameters that will be used to set-up the CSI interfaces
   between AP side and on Bridge side.
   The supplied parameters describe the functional requirements that have to be
   respected in order to guarantee a working image transmission, and they
   will be applied to the CSI receiver of the AP, and to the CSI transmitter
   connected to it, installed on the AP-Bridge.
   The CSI configuration parameters, are be also used to compute the minimum
   bandwidth requirement, not only during the CSI interface configuration
   process, but also for tuning the UNIPRO network speed constraints.
   It is thus important that camera module reports their maximum required
   bandwidth expressed as number of lines sent in a second of transmission,
   blanking included. This [and possibly other parameters] will be used for
   the end-2-end configuration of the image transmission system.

.. _camera-configure-streams-request:

Greybus Camera Configure Streams Operation Request
""""""""""""""""""""""""""""""""""""""""""""""""""

The Request specifies the number of streams to be configured. Up to four
streams are supported. A Request with a number of streams higher
than four shall be answered by an error Response with the status set to
GB_OP_INVALID. A request with a zero number of streams remove the existing
configuration and moves the Camera Bundle to the UNCONFIGURED state.

The flags field allows the AP Module to inform the Camera Bundle about special
requirements applied to the Request. Accepted values for the Request flags field
are listed in Table :num:`table-camera-configure-streams-request-flag-bitmask`.

The TEST_ONLY bit of the Request flags field allows the AP to test a
configuration without applying it. When the bit is set the Camera Module shall
process the Request normally but stop from applying the configuration. The
Module shall send the same Response as it would if the TEST_ONLY bit wasn’t set
and stay in the UNCONFIGURED state without modifying the device state.

The Request supplies a set of stream configurations with the desired image
width, height and format for each stream, as show in Table
:num:`table-camera-operations-configure-streams-request`.
Both the width and height shall be multiples of 2. For each supplied stream
configuration, the width, height and format fields shall be copied in the
:ref:`camera-configure-streams-response` payload.

.. figtable::
   :nofig:
   :label: table-camera-operations-configure-streams-request
   :caption: Camera Class Configure Streams Request
   :spec: l l c c l

    =========   =============  ======  ===========  ===========================
    Offset      Field          Size    Value        Description
    =========   =============  ======  ===========  ===========================
    0           num_streams    1       Number       Number of streams. Between 0
                                                    and 4
    1           flags          1       Number       Table :num:`table-camera-configure-streams-request-flag-bitmask`
    2           padding        2       0            Shall be set to 0

    *The following block appears num_streams times*
    ---------------------------------------------------------------------------

    4+(i*8)     width          2       Number       Image width in pixels
    6+(i*8)     height         2       Number       Image height in pixels
    8+(i*8)     format         2       Number       Image Format
    10+(i*8)    padding        2       0            Shall be set to 0
    =========   =============  ======  ===========  ===========================
..

.. figtable::
   :nofig:
   :label: table-camera-configure-streams-request-flag-bitmask
   :caption: The flags bitmask in Camera Class Configure Stream Request
   :spec: l l c c l

    =============  ===========  =============================================
    Field (Bit)    Value        Description
    =============  ===========  =============================================
    0              TEST-ONLY    The requested configuration shall not
    \                           be applied but Camera Module shall
    \                           only verify it is supported or not.
    1\-7           Reserved     Shall be set to 0
    =============  ===========  =============================================
..

.. _camera-configure-streams-response:

Greybus Camera Configure Streams Operation Response
"""""""""""""""""""""""""""""""""""""""""""""""""""

The Camera Module reports its stream configuration in the Response message as
shown in Table :num:`table-camera-operations-configure-streams-response`.
The value of the num_streams field report the number of actually configured
streams.

The flags field allows the Camera Bundle to provide additional information on
the delivered Response. Accepted values for the Response flags field are listed
in Table :num:`table-camera-configure-streams-response-flag-bitmask`.

.. TODO: pinchartl: "best configuration" needs to be defined.

The ADJUSTED bit of the Response flags field is used to support
negotiation of the stream configuration. The Camera Module may modify the
requested configuration to match its capabilities.
This includes lowering the number of requested streams, originally reported in
the num_streams Request field, and modifying the width, height and format of
each stream. The Module shall, in that case, reply with a configuration it can
support, and set the ADJUSTED bit in the Response flags field. As a result the
Camera Bundle shall stay in the UNCONFIGURED state without modifying the device
state.

The data_rate field shall contain the total CSI-2 data rate expressed
in Mbits per second, rounded up.

The Camera Module shall report in the Response, along with the (optionally
adjusted) image format, width and height, the Virtual Channel number
and Data Types for each stream, regardless of whether the  response
was adjusted or not

All Virtual Channel numbers shall be identical and between zero and three
inclusive. All Data Types shall be different.

Up to two data types can be used to identify different components of the same
stream sent by a Camera Module. At least one data type shall be provided by the
Camera Module, the second is optional and shall be set to the reserved 0x00
value if not used. The Data Types should be set to the CSI-2 Data Type value
matching the streams formats if possible, and may be set to a User Defined
8-bit Data Type (0x30 to 0x37).

.. TODO: pinchartl: This requires a more detailed description.

The Camera Module shall report in the max_pkt_size field the size in bytes of
the largest CSI-2 Long Packet payload for the stream. CSI-2 Long packets are
defined in section 9.1 of [CSI-2]_.

For non-binary image formats Camera Modules shall transmit each line of the
image individually in a single CSI-2 Long Packet. Image lines may have different
sizes depending on the image format. The max_pkt_size is the size in bytes of
the largest line of the image.

Binary image formats do not split the image in lines but encode it as a single
block of bytes. Binary non-image formats transmit arbitrary non-image data in a
single block of bytes. Camera Modules shall split the data in chunks in an
implementation-defined way and send each chunk in a separate CSI-2 Long Packet.
The max_pkt_size is then the size in bytes of the largest data chunk.

Binary and non-binary formats IDs are defined in the :ref:`camera-imgfmt-ids`
section of this specifications.

.. figtable::
   :nofig:
   :label: table-camera-operations-configure-streams-response
   :caption: Camera Class Configure Streams Response
   :spec: l l c c l

    =========   =============  ======  ===========  ===========================
    Offset      Field          Size    Value        Description
    =========   =============  ======  ===========  ===========================
    0           num_streams    1       Number       Number of streams. Between 0
                                                    and 4
    1           flags          1       Number       Table :num:`table-camera-configure-streams-response-flag-bitmask`
    2           padding        2       0            Shall be set to 0
    4           data_rate      4       Number       The CSI-2 data rate, expressed
    \                                               in Mbits per second (rounded up)

    *The following block appears num_streams times*
    ---------------------------------------------------------------------------

    8+(i*16)     width          2       Number      Image width in pixels
    10+(i*16)    height         2       Number      Image height in pixels
    12+(i*16)    format         2       Number      Image Format
    14+(i*16)    virtual_chan   1       Number      Virtual channel number
    15+(i*16)    data_type[2]   2       Number      Data types for the stream
    17+(i*16)    max_pkt_size   2       Number      The length in bytes of largets CSI
    \                                               Long Packet that transmits frame
    \                                               lines
    19+(i*16)    padding        1       0           Shall be set to 0
    20+(i*16)    max_size       4       Number      Maximum frame size in Bytes
    =========   =============  ======  ===========  ===========================
..

.. figtable::
   :nofig:
   :label: table-camera-configure-streams-response-flag-bitmask
   :caption: The flags bitmask in Camera Class Configure Stream Response
   :spec: l l c c l

    =============  ===========  =============================================
    Field (Bit)    Value        Description
    =============  ===========  =============================================
    0              ADJUSTED     The requested configuration is not
    \                           supported and has been adjusted
    1\-7           Reserved     Shall be set to 0
    =============  ===========  =============================================
..

.. _camera-capture-streams-operation:

Greybus Camera Management Capture Streams Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. pinchartl: TODO: Explain the bitmask in more details.
              In particular, what's the behavior for a request with 0 bitmask?

.. pinchartl: TODO: Define the behaviour for concurrent requests affecting
              separate streams.
   binchen:   What does concurrent thread means here? From Android side, for
              one single camera, all the requests from camera service will be
              serialized (sending from one thread).
   pinchartl: What happens if request n is received from stream 1 and request
              n + 1 for stream 2 ? Can they complete out of order ?
              Are they added to separate queues ? What if request n + 2 then
              targets both streams 1 and 2 ? All the corner cases need to be
              documented explicitly. The current text is too vague
   pinchartl: For reference: concurrent requests that affect separate streams
              should not block each other, and thus somehow need separate
              queues.

The Capture Streams Operation is used to submit a request for a new image frame
transmission on the Camera Data Connection.

Upon receiving a valid Greybus Camera Management Capture Streams Request, the
Camera Bundle shall return a Response immediately. The capture and
transmission of the resulting frames via the Camera Data Connection
occurs asynchronously to the processing of this Operation. These
Requests shall be processed in the order they are received.

Camera Modules should minimize the delay between Requests by pre-processing
pending Requests ahead of time as necessary.

When the first Request is queued, the Camera Module moves to the STREAMING
state and starts transmitting frames as soon as possible. When the last
Request completes the Bundle moves to the CONFIGURED state and stops
transmitting frames immediately. Modules shall not transmit any |unipro|
Segment on the Camera Data Connection except as result of receiving a new
Capture Request.

.. _camera-capture-streams-request:

Greybus Camera Management Capture Streams Request
"""""""""""""""""""""""""""""""""""""""""""""""""

Each Camera Management Capture Stream Request contains an incrementing ID,
a bitmask of the streams it affects, a number of frames to capture for all the
streams in the bitmask and a list of settings to be applied to the transmitted
image.

The AP shall set the request_id field in the Request payload to
zero for the first Capture Streams Request it sends, and shall
increment the value in this payload by one in each subsequent Request. If the
value of the request_id field is not higher than the ID of the previous
Request the Camera Bundle shall ignore the Request and set the reply status to
GB_OP_INVALID.

Modules shall not use the value of the request_id field number for any purpose
other than synchronizing the Capture Operation with the Flush and Metadata
Operations. In particular, Camera Bundle shall accept Requests with IDs higher
than the previous one by more than one.

.. TODO: jmondi: properly define the streams bitmaks

The num_frames field contains the number of times the Request shall be
repeated for all affected streams. Camera Modules shall capture and transmit
one frame per stream for every repetition of the image capture request using
the same capture settings. When the num_frames field is set to zero the image
capture request shall be repeated indefinitely until the next Capture
Operations Request, or a Flush Operation Request, is received.

The Capture Streams Request is only valid in the CONFIGURED and STREAMING
states. The Camera Module shall set the Response status to GB_OP_INVALID_STATE
in all other states.

The Capture Streams Request also contains a variable-size settings block that
shall conform to the format described in the
:ref:`Properties Section <camera-properties>` of this specification.
If no settings need to be applied for the Request the settings block shall
have zero size.

Parameters for the Capture Stream Request are shown in Table
:num:`table-camera-operations-capture-request`

.. figtable::
   :nofig:
   :label: table-camera-operations-capture-request
   :caption: Camera Class Capture response
   :spec: l l c c l

    ======  =============  ======  ===========  ===============================
    Offset  Field          Size    Value        Description
    ======  =============  ======  ===========  ===============================
    0       request_id     4       number       An incrementing integer to
                                                uniquely identify the capture
                                                request
    4       streams        1       bitmask      Bitmask of the streams included
                                                in the capture request
    5       padding        1       0            Shall be set to 0
    6       num_frames     2       number       Number of frames to capture
                                                (0 for infinite)
    8       settings       n       data         Capture Request settings
    ======  =============  ======  ===========  ===============================
..

.. _camera-capture-streams-response:

Greybus Camera Management Capture Streams Respose
"""""""""""""""""""""""""""""""""""""""""""""""""

The Camera Management Operation Capture Response message has no payload.

If the Capture Request streams bitmask field contains non-configured streams
the Camera Module shall set the Response status to GB_OP_INVALID.

.. _camera-flush-operation:

Greybus Camera Flush Streams Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Camera Management Flush Operation removes all Capture requests
from the queue and stops frame transmission as soon as possible.

Delays are permitted to the extent they are necessary to flush hardware
pipelines.

After finishing processing of that Request the module moves to the CONFIGURED
state and shall not transmit any more frames.

The Request is only valid in the CONFIGURED and STREAMING states,
the Camera Bundle shall reply with an empty payload and set the status
to GB_OP_INVALID_STATE in all other states.

.. _camera-flush-request:

Greybus Camera Flush Streams Operation Request
""""""""""""""""""""""""""""""""""""""""""""""

The Camera Flush Request Message has no payload.

.. _camera-flush-response:

Greybus Camera Flush Streams Operation Respose
""""""""""""""""""""""""""""""""""""""""""""""

In order to allow synchronization, the Greybus Camera Management Flush
Response reports the ID contained in the request_id field of the
last processed :ref:`camera-capture-streams-request`

When the Flush Operation is invoked while the Bundle is in the CONFIGURED
state, the request_id field shall report the ID of the last frame transmitted
over the Camera Data Connection. If no frames have been transmitted yet, the
response_id field shall be set to zero.

Payload description for Flush Operation Response is reported in Table
:num:`table-camera-operations-flush-response`

.. figtable::
   :nofig:
   :label: table-camera-operations-flush-response
   :caption: Camera Class Flush response
   :spec: l l c c l

    =========   =============  ======  ===========  ===========================
    Offset      Field          Size    Value        Description
    =========   =============  ======  ===========  ===========================
    0           request_id     4       Number       The last Request that will
    \                                               be processed before the
    \                                               module stops transmitting
    \                                               frames
    =========   =============  ======  ===========  ===========================
..

.. _camera-metadata-operation:

Greybus Camera Metadata Streams Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. pinchartl: TODO: Describe metadata operation with multiple streams.
             We can't have one metadata stream per video stream.
             The "stream" field thus doesn't make sense.

The Greybus Camera Management Metadata Operation allows the Camera Module to
transmit metadata associated with a frame though the Camera Management
Connection.

The frame the delivered metadata is associated with is identified by the
request_id field, the frame_number field and the stream_id field.

.. _camera-metadata-request:

Greybus Camera Metadata Streams Operation Request
"""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Camera Management Metadata Request is sent by the Camera Module
over the Camera Management Connection. It contains a variable-size metadata
block that shall conform to the format described in the :ref:`camera-properties`
section of this specification.

If no metadata needs to be reported for a particular frame the metadata block
shall have zero size.

The Greybus Camera Metadata Streams Operation Request is defined in Table
:num:`table-camera-operations-metadata-request`

.. figtable::
   :nofig:
   :label: table-camera-operations-metadata-request
   :caption: Camera Class Metadata Request
   :spec: l l c c l

    =========   =============  ======  ===========  ===========================
    Offset      Field          Size    Value        Description
    =========   =============  ======  ===========  ===========================
    0           request_id     4       Number       The ID of the corresponding
                                                    frame request
    4           frame_number   2       Number       The CSI-2 frame number
    6           stream_id      1       Number       The stream number
    7           padding        1       0            Shall be set to zero
    8           metadata       n       metadata     Metadata block
    =========   =============  ======  ===========  ===========================
..

.. _camera-properties:

Greybus Camera Properties
^^^^^^^^^^^^^^^^^^^^^^^^^

The Capabilities, Capture and Metadata operations modify or report the value of
a set of Camera Module properties. Properties are defined as parameters that can
report or modify the nature, state or operation of the Camera Module.

This section defines the structure of a property and a simple and efficient
method to encode a set of property values in a binary data block that can be
transmitted over Greybus.

Properties Definition
"""""""""""""""""""""

The Camera Class Protocol specifications defines properties through the
following information.

* *name*

  A human readable string used to refer to the property in documentation.

* *key*

  An integer value that uniquely identifies the property.

* *data type*

  Type of the property value data that determines how the value is
  to be interpreted.

* *values*

  List, range or otherwise description of acceptable values for the property.

Properties defined in this specification are considered as standard Greybus
Camera Device Class properties. Camera Module vendors are allowed to define
additional properties to the extent allowed by the specification.
If they chose to do so they shall define such additional properties using the
mechanism described in this specification.

Property keys range from 0x0000 to 0xffff organized as follows:

* 0x0000 - 0x7fff: Standard Greybus Camera properties
* 0x8000 - 0x8fff: Vendor-specific properties
* 0x9000 - 0xffff: Reserved

A property stores a value using one of the following data types.

* int8: a signed 8-bit integer
* uint8: an unsigned 8-bit integer
* int32: a signed 32-bit integer
* uint32: an unsigned 32-bit integer
* int64: a signed 64-bit integer
* uint64: an unsigned 64-bit integer
* float: a single-precision (32-bit) IEEE 754 floating-point value, as defined
  in [IEEE745]_
* double: a double-precision (64-bit) IEEE 754 floating-point value, as defined
  in [IEEE745]_
* rational: a rational expressed as a 32-bit integer numerator and a 32-bit
  integer denominator. The denominator shall not be zero

Properties can also store an array of values of the same data type.
In that case the property data type is postfixed with ‘[]’ to denote the array
nature of the data. For instance the data type of an array of 32-bit integers
would be described as ‘int32[]’.

When the property is directed to (or comes from) the Android Camera framework,
only its name and TAG value are shown.

When a property, instead, is Greybus Camera specific, and not directed to
the Android camera framework, a more detailed description and a range of
accepted values (when applicable) is provided, as shown in figure
:num:`table-camera-properties-example`.

.. figtable::
   :nofig:
   :label: table-camera-properties-example
   :caption: Camera Class Property Example
   :spec: l l c l

    ========================  =======  ==========  ============================
    Property Name             TAG      Type        Description
    ========================  =======  ==========  ============================
    GB_CAM_SAMPLE_PROPERTY    0xXXXX   type[]      Description of property and
    \                                              intended use-cases
    ========================  =======  ==========  ============================
..

Properties Value Encoding
"""""""""""""""""""""""""

Greybus Camera Device Class Operations need to transmit a set of property
values.

A Property values set is an unordered list of property keys associated with
values. To transport it over Greybus the set shall be serialized into an array
of bytes called Properties Packets as follows.

Unless stated otherwise, all numerical fields shall be stored in little-endian
format. Signed integers shall be encoded using a two's complement
representation.

The memory of a Greybus Camera Device Class defined property is shown in Figure
:num:`camera-prop-layout`.

.. _camera-prop-layout:
.. figure:: /img/svg/ara-camera-properties-layout.png
    :align: center

    Memory layout of a Greybus Camera Device Class Property Packet
..

The packet starts with a fixed-size header that contains the payload size and
the number of Properties it contains, as shown in Table
:num:`table-camera-properties-packet-header`.

.. figtable::
   :nofig:
   :label: table-camera-properties-packet-header
   :caption: Camera Class Property Packet Header
   :spec: l l c l l

    =========   =============  ======  ===========  ===========================
    Offset      Field          Size    Value        Description
    =========   =============  ======  ===========  ===========================
    0           size           2       number       Size of the payload, header excluded
    2           nprops         2       number       Number of properties in the packet
    =========   =============  ======  ===========  ===========================
..

The header is followed by a payload that stores Property value entries.
Each entry contains the Property key, the Property value length and the
Property value, as shown in table :num:`table-camera-properties-prop`.

.. figtable::
   :nofig:
   :label: table-camera-properties-prop
   :caption: Camera Class Property Entry
   :spec: l l c l l

    =========   =============  ======  ===========  ===========================
    Offset      Field          Size    Value        Description
    =========   =============  ======  ===========  ===========================
    0           key            2       number       Property key
    2           length         2       number       Property length in bytes,
    \                                               padding excluded
    4           value          n       property     Value of the property
                                       specific
    =========   =============  ======  ===========  ===========================
..

The packet shall not contain multiple entries with the same key. The order of
payload entries is unspecified and shall not be relied upon when interpreting
the content of the packet.

All value fields shall be padded to a multiple of 4 bytes. The size of the
defined data types makes padding needed for int8 values only.

Values of array data type properties shall be encoded by storing the array
elements sequentially without any space or padding between elements.

Padding is only required at the end of the array to align its size to a
multiple of 4 bytes.

.. FIXME: jmondi: need to check when the JPEG_ information shall come from:
          Camera Module or HAL...

Capabilities
""""""""""""

Capabilities tags are reported by Camera Modules in order to describe
their characteristics and their available features.

Capabilities tags defined in Table :num:`table-camera-capabilities-tags` are
directed to the Android framework, for this reason their types, supported
values and detailed description are documented by the Android system
documentation.

.. figtable::
    :label: table-camera-capabilities-tags
    :caption: Camera Device Class Capababilities IDs
    :spec: l l l l

    ==================================================   =======  ==================================================   =======
    Property Name                                        TAG      Property Name                                        TAG
    ==================================================   =======  ==================================================   =======
    COLOR_CORRECTION_AVAILABLE_ABERRATION_MODES          0x0004   SCALER_AVAILABLE_JPEG_SIZES                          0x0d03
    CONTROL_AE_AVAILABLE_ANTIBANDING_MODES               0x0112   SCALER_AVAILABLE_MAX_DIGITAL_ZOOM                    0x0d04
    CONTROL_AE_AVAILABLE_MODES                           0x0113   SCALER_AVAILABLE_PROCESSED_MIN_DURATIONS             0x0d05
    CONTROL_AE_AVAILABLE_TARGET_FPS_RANGES               0x0114   SCALER_AVAILABLE_PROCESSED_SIZES                     0x0d06
    CONTROL_AE_COMPENSATION_RANGE                        0x0115   SCALER_AVAILABLE_RAW_MIN_DURATIONS                   0x0d07
    CONTROL_AE_COMPENSATION_STEP                         0x0116   SCALER_AVAILABLE_RAW_SIZES                           0x0d08
    CONTROL_AF_AVAILABLE_MODES                           0x0117   SCALER_AVAILABLE_INPUT_OUTPUT_FORMATS_MAP            0x0d09
    CONTROL_AVAILABLE_EFFECTS                            0x0118   SCALER_AVAILABLE_STREAM_CONFIGURATIONS               0x0d0a
    CONTROL_AVAILABLE_SCENE_MODES                        0x0119   SCALER_AVAILABLE_MIN_FRAME_DURATIONS                 0x0d0b
    CONTROL_AVAILABLE_VIDEO_STABILIZATION_MODES          0x011a   SCALER_AVAILABLE_STALL_DURATIONS                     0x0d0c
    CONTROL_AWB_AVAILABLE_MODES                          0x011b   SCALER_CROPPING_TYPE                                 0x0d0d
    CONTROL_MAX_REGIONS                                  0x011c   SENSOR_INFO_ACTIVE_ARRAY_SIZE                        0x0f00
    CONTROL_SCENE_MODE_OVERRIDES                         0x011d   SENSOR_INFO_SENSITIVITY_RANGE                        0x0f01
    CONTROL_AVAILABLE_HIGH_SPEED_VIDEO_CONFIGURATIONS    0x0123   SENSOR_INFO_COLOR_FILTER_ARRANGEMENT                 0x0f02
    CONTROL_AE_LOCK_AVAILABLE                            0x0124   SENSOR_INFO_EXPOSURE_TIME_RANGE                      0x0f03
    CONTROL_AWB_LOCK_AVAILABLE                           0x0125   SENSOR_INFO_MAX_FRAME_DURATION                       0x0f04
    CONTROL_AVAILABLE_MODES                              0x0126   SENSOR_INFO_PHYSICAL_SIZE                            0x0f05
    FLASH_INFO_AVAILABLE                                 0x0500   SENSOR_INFO_PIXEL_ARRAY_SIZE                         0x0f06
    HOT_PIXEL_AVAILABLE_HOT_PIXEL_MODES                  0x0601   SENSOR_INFO_WHITE_LEVEL                              0x0f07
    JPEG_AVAILABLE_THUMBNAIL_SIZES                       0x0707   SENSOR_INFO_TIMESTAMP_SOURCE                         0x0f08
    JPEG_MAX_SIZE                                        0x0708   SENSOR_INFO_LENS_SHADING_APPLIED                     0x0f09
    LENS_FACING                                          0x0805   SENSOR_INFO_PRE_CORRECTION_ACTIVE_ARRAY_SIZE         0x0f0a
    LENS_POSE_ROTATION                                   0x0806   SENSOR_CALIBRATION_TRANSFORM1                        0x0e05
    LENS_POSE_TRANSLATION                                0x0807   SENSOR_CALIBRATION_TRANSFORM2                        0x0e06
    LENS_INFO_AVAILABLE_APERTURES                        0x0900   SENSOR_COLOR_TRANSFORM1                              0x0e07
    LENS_INFO_AVAILABLE_FILTER_DENSITIES                 0x0901   SENSOR_COLOR_TRANSFORM2                              0x0e08
    LENS_INFO_AVAILABLE_FOCAL_LENGTHS                    0x0902   SENSOR_FORWARD_MATRIX1                               0x0e09
    LENS_INFO_AVAILABLE_OPTICAL_STABILIZATION            0x0903   SENSOR_FORWARD_MATRIX2                               0x0e0a
    LENS_INFO_HYPERFOCAL_DISTANCE                        0x0904   SENSOR_BLACK_LEVEL_PATTERN                           0x0e0c
    LENS_INFO_MINIMUM_FOCUS_DISTANCE                     0x0905   SENSOR_MAX_ANALOG_SENSITIVITY                        0x0e0d
    LENS_INFO_SHADING_MAP_SIZE                           0x0906   SENSOR_ORIENTATION                                   0x0e0e
    LENS_INFO_FOCUS_DISTANCE_CALIBRATION                 0x0907   SENSOR_PROFILE_HUE_SAT_MAP_DIMENSIONS                0x0e0f
    LENS_INTRINSIC_CALIBRATION                           0x080a   SENSOR_AVAILABLE_TEST_PATTERN_MODES                  0x0e19
    LENS_RADIAL_DISTORTION                               0x080b   SHADING_AVAILABLE_MODES                              0x1002
    QUIRKS_METERING_CROP_REGION                          0x0b00   STATISTICS_INFO_AVAILABLE_FACE_DETECT_MODES          0x1200
    QUIRKS_TRIGGER_AF_WITH_AUTO                          0x0b01   STATISTICS_INFO_MAX_FACE_COUNT                       0x1202
    QUIRKS_USE_ZSL_FORMAT                                0x0b02   STATISTICS_INFO_AVAILABLE_HOT_PIXEL_MAP_MODES        0x1206
    QUIRKS_USE_PARTIAL_RESULT                            0x0b03   STATISTICS_INFO_AVAILABLE_LENS_SHADING_MAP_MODES     0x1207
    REQUEST_MAX_NUM_OUTPUT_STREAMS                       0x0c06   TONEMAP_MAX_CURVE_POINTS                             0x1304
    REQUEST_MAX_NUM_REPROCESS_STREAMS                    0x0c07   TONEMAP_AVAILABLE_TONE_MAP_MODES                     0x1305
    REQUEST_PIPELINE_MAX_DEPTH                           0x0c0a   LED_AVAILABLE_LEDS                                   0x1401
    REQUEST_PARTIAL_RESULT_COUNT                         0x0c0b   INFO_SUPPORTED_HARDWARE_LEVEL                        0x1500
    REQUEST_AVAILABLE_CAPABILITIES                       0x0c0c   SYNC_MAX_LATENCY                                     0x1701
    REQUEST_AVAILABLE_REQUEST_KEYS                       0x0c0d   DEPTH_MAX_DEPTH_SAMPLES                              0x1900
    REQUEST_AVAILABLE_RESULT_KEYS                        0x0c0e   DEPTH_AVAILABLE_DEPTH_STREAM_CONFIGURATIONS          0x1901
    REQUEST_AVAILABLE_CHARACTERISTICS_KEYS               0x0c0f   DEPTH_AVAILABLE_DEPTH_MIN_FRAME_DURATIONS            0x1902
    SCALER_AVAILABLE_FORMATS                             0x0d01   DEPTH_AVAILABLE_DEPTH_STALL_DURATIONS                0x1903
    SCALER_AVAILABLE_JPEG_MIN_DURATIONS                  0x0d02   DEPTH_DEPTH_IS_EXCLUSIVE                             0x1904
    ==================================================   =======  ==================================================   =======
..

Greybus Camera Device Class specific capabilities tags are defined in Table
:num:`table-camera-ara-tags`. Greybus Camera Device Class tags are used to
describe Greybus Camera specific attributes and Camera Module shall include all
of them in their reported Capabilities packets.

.. figtable::
    :label: table-camera-ara-tags
    :caption: Camera Device Class Capabilities IDs
    :spec: l l l l

    ==========================   =======  ========  =================================
    Property Name                TAG      Type      Description
    ==========================   =======  ========  =================================
    GB_CAM_FEATURE_JPEG          0X7f00   bool      The Camera Module supports on-board
    \                                               JPEG encoding
    GB_CAM_FEATURE_SCALER        0X7f01   bool      The Camera Module supports on-board
    \                                               image scaling
    GB_CAM_METADATA_FORMAT       0x7f02   int8      Supported metadata format as defined
    \                                               in Table :num:`table-camera-metadata-fmt`
    GB_CAM_METADATA_TRANSPORT    0x7f03   int8      Supported metadata transport as defined
    \                                               in Table :num:`table-camera-metadata-trans`
    GB_CAM_PER_FRAME_CONTROL     0x7f04   bool      The Camera Module support per-frame Control
    GB_CAM_PRE_CROP_REGIONS      0x7f05   uint32[]  Field of view cropping, applied by Camera
    \                                               Module on its full pixel array size.
    \                                               Array members are shown in Table
    \                                               :num:`table-camera-metadata-crop`
    ==========================   =======  ========  =================================
..

The accepted values for the reported GB_CAM_METADATA_FORMAT tag are listed in
Table :num:`table-camera-metadata-fmt`.

.. figtable::
    :nofig:
    :label: table-camera-metadata-fmt
    :caption: Camera Device Class Accepted Metadata Format
    :spec: l l l

    =========================  =======  =================================
    Property Name              Value    Description
    =========================  =======  =================================
    METADATA_TRANSPORT_GB      0        The Camera Module sends metadata encoded
    \                                   as prescribed by this Specifications
    METADATA_TRANSPORT_CUSTOM  1        The Camera Module sends metadata encoded
    \                                   in custom format
    =========================  =======  =================================
..

The accepted values for the reported GB_CAM_METADATA_TRANSPORT tag are listed in
Table :num:`table-camera-metadata-trans`.

.. figtable::
    :nofig:
    :label: table-camera-metadata-trans
    :caption: Camera Device Class Accepted Metadata Transport Methods
    :spec: l l l

    ========================   =======  =================================
    Property Name              Value    Description
    ========================   =======  =================================
    METADATA_TRANSPORT_NONE    0        The Camera Module does not send metadata
    METADATA_TRANSPORT_CSI     1        The Camera Module sends metadata interleaved
    \                                   to image frames on the CSI-2 transport
    METADATA_TRANSPORT_OP      2        The Camera Module sends metadata using the
    \                                   :ref:`camera-metadata-operation`
    ========================   =======  =================================
..

The GB_CAM_PRE_CROP_REGIONS specifies  an array of uint32_t fields,
whose values are listed in Table :num:`table-camera-metadata-crop`.

Camera Modules can crop and/or scale the full sensor's field of view to
achieve desired output resolutions. This property is used to describe, for
each supported stream configuration, the associated cropping applied to the
sensor's pixel array.

Camera Modules shall report, for each stream configuration listed in the
SCALER_AVAILABLE_STREAM_CONFIGURATIONS property, the coordinates of the top-left
corner of the associated cropping rectangle, expressed as displacement (in
pixels) from the top-left corner of the sensor's active pixel array, and the
cropping rectangle horizontal and vertical dimensions.

The data transported by GB_CAM_PRE_CROP_REGIONS property shall have an exact
multiple of twenty-eight bytes as size, being composed by a number of tuples of
seven elements, each of them four bytes long.

The number of seven element tuples reported in this property shall correspond
to the number of elements reported in the SCALER_AVAILABLE_STREAM_CONFIGURATIONS
property, one for each supported stream configuration.
The elements shall be stored in the same order as the
SCALER_AVAILABLE_STREAM_CONFIGURATIONS entries.

.. figtable::
    :nofig:
    :label: table-camera-metadata-crop
    :caption: Camera Device Class Pre Crop Region Array
    :spec: c l l

    =================   ==============  =================================
    Array Entry Index   Name            Description
    =================   ==============  =================================
    0                   Stream Format   Greybus wire image format, as defined
    \                                   in Table :num:`table-camera-image-formats`
    1                   Stream Width    Width, in pixels, of the video stream
    2                   Stream Height   Height, in pixels, of the video stream
    3                   Crop Top        Vertical offset, in pixels, of the
    \                                   top-left corner of the cropping
    \                                   rectangle
    4                   Crop Left       Horizontal offset, in pixels, of the
    \                                   top-left corner of the cropping
    \                                   rectangle
    5                   Crop Width      Width, in pixels, of the cropping
    \                                   rectangle
    6                   Crop Height     Height, in pixels, of the cropping
    \                                   rectangle
    =================   ==============  =================================
..

Capture Settings
""""""""""""""""

Capture Setting tags are used to provide to the Camera Module the desired image
processing settings it shall apply to the next captured frames. Camera Modules
should minimize the delay required to apply the received settings as much as
possible.

Capture Settings are generated by the Android framework, and sent on the wire
along with each :ref:`camera-capture-streams-request`. For this reason, their
types, accepted values and detailed description are provided by the Android
system documentation.

.. figtable::
    :nofig:
    :label: table-camera-capture-tags
    :caption: Camera Device Class Capture Settings IDs
    :spec: l l l l

    ==================================================   =======    ==================================================   =======
    Property Name                                        TAG        Property Name                                        TAG
    ==================================================   =======    ==================================================   =======
    COLOR_CORRECTION_MODE                                0x0000     JPEG_THUMBNAIL_SIZE                                  0x0706
    COLOR_CORRECTION_TRANSFORM                           0x0001     LENS_APERTURE                                        0x0800
    COLOR_CORRECTION_GAINS                               0x0002     LENS_FILTER_DENSITY                                  0x0801
    COLOR_CORRECTION_ABERRATION_MODE                     0x0003     LENS_FOCAL_LENGTH                                    0x0802
    CONTROL_AE_ANTIBANDING_MODE                          0x0100     LENS_FOCUS_DISTANCE                                  0x0803
    CONTROL_AE_EXPOSURE_COMPENSATION                     0x0101     LENS_OPTICAL_STABILIZATION_MODE                      0x0804
    CONTROL_AE_LOCK                                      0x0102     REQUEST_FRAME_COUNT                                  0x0c00
    CONTROL_AE_MODE                                      0x0103     REQUEST_ID                                           0x0c01
    CONTROL_AE_REGIONS                                   0x0104     REQUEST_INPUT_STREAMS                                0x0c02
    CONTROL_AE_TARGET_FPS_RANGE                          0x0105     REQUEST_OUTPUT_STREAMS                               0x0c04
    CONTROL_AE_PRECAPTURE_TRIGGER                        0x0106     REQUEST_TYPE                                         0x0c05
    CONTROL_AF_MODE                                      0x0107     SCALER_CROP_REGION                                   0x0d00
    CONTROL_AF_REGIONS                                   0x0108     SENSOR_EXPOSURE_TIME                                 0x0e00
    CONTROL_AF_TRIGGER                                   0x0109     SENSOR_FRAME_DURATION                                0x0e01
    CONTROL_AWB_LOCK                                     0x010a     SENSOR_SENSITIVITY                                   0x0e02
    CONTROL_AWB_MODE                                     0x010b     SENSOR_TEST_PATTERN_DATA                             0x0e17
    CONTROL_AWB_REGIONS                                  0x010c     SENSOR_TEST_PATTERN_MODE                             0x0e18
    CONTROL_CAPTURE_INTENT                               0x010d     SHADING_MODE                                         0x1000
    CONTROL_EFFECT_MODE                                  0x010e     STATISTICS_FACE_DETECT_MODE                          0x1100
    CONTROL_MODE                                         0x010f     STATISTICS_HOT_PIXEL_MAP_MODE                        0x1103
    CONTROL_SCENE_MODE                                   0x0110     STATISTICS_LENS_SHADING_MAP_MODE                     0x1110
    CONTROL_VIDEO_STABILIZATION_MODE                     0x0111     TONEMAP_CURVE_BLUE                                   0x1300
    FLASH_MODE                                           0x0402     TONEMAP_CURVE_GREEN                                  0x1301
    HOT_PIXEL_MODE                                       0x0600     TONEMAP_CURVE_RED                                    0x1302
    JPEG_GPS_COORDINATES                                 0x0700     TONEMAP_MODE                                         0x1303
    JPEG_GPS_PROCESSING_METHOD                           0x0701     TONEMAP_GAMMA                                        0x1306
    JPEG_GPS_TIMESTAMP                                   0x0702     TONEMAP_PRESET_CURVE                                 0x1307
    JPEG_ORIENTATION                                     0x0703     LED_TRANSMIT                                         0x1400
    JPEG_QUALITY                                         0x0704     BLACK_LEVEL_LOCK                                     0x1600
    JPEG_THUMBNAIL_QUALITY                               0x0705
    ==================================================   =======    ==================================================   =======

..

Metadata
""""""""

Camera Modules should encode metadata using the properties and serialization
format defined in this section.

However, when this isn’t possible or practical (for instance when the module
hardware dictates the metadata format), modules may chose to encode metadata
using a custom method for metadata transmitted over CSI-2.

Metadata transmitted over Greybus using the
:ref:`camera-metadata-request` shall always be encoded as specified in this
section.

Metadata transmitted over CSI-2 using a custom encoding shall at minimum
contain the ID of the associated request.

.. jmondi: FIXME: expand the list of minimum required field for custom metadata
           formats

Table :num:`table-camera-metadata-tags` define the IDs of metadata tags
accepted by the Greybus Camera Device Class. Metadata tags are sent to the
Android framework, for this reason their types, accepted values and detailed
description are provided by the Android system documentation.

.. figtable::
    :nofig:
    :label: table-camera-metadata-tags
    :caption: Camera Device Class Metadata IDs
    :spec: l l l l

    ==================================================   =======    ==================================================   =======
    Property Name                                        TAG        Property Name                                        TAG
    ==================================================   =======    ==================================================   =======
    COLOR_CORRECTION_MODE                                0x0000     LENS_POSE_TRANSLATION                                0x0807
    COLOR_CORRECTION_TRANSFORM                           0x0001     LENS_INTRINSIC_CALIBRATION                           0x080a
    COLOR_CORRECTION_GAINS                               0x0002     LENS_RADIAL_DISTORTION                               0x080b
    COLOR_CORRECTION_ABERRATION_MODE                     0x0003     QUIRKS_PARTIAL_RESULT                                0x0b04
    CONTROL_AE_PRECAPTURE_ID                             0x011e     REQUEST_ID                                           0x0c01
    CONTROL_AE_ANTIBANDING_MODE                          0x0100     REQUEST_OUTPUT_STREAMS                               0x0c04
    CONTROL_AE_EXPOSURE_COMPENSATION                     0x0101     REQUEST_PIPELINE_DEPTH                               0x0c09
    CONTROL_AE_LOCK                                      0x0102     SCALER_CROP_REGION                                   0x0d00
    CONTROL_AE_MODE                                      0x0103     SENSOR_EXPOSURE_TIME                                 0x0e00
    CONTROL_AE_REGIONS                                   0x0104     SENSOR_FRAME_DURATION                                0x0e01
    CONTROL_AE_TARGET_FPS_RANGE                          0x0105     SENSOR_SENSITIVITY                                   0x0e02
    CONTROL_AE_PRECAPTURE_TRIGGER                        0x0106     SENSOR_TIMESTAMP                                     0x0e10
    CONTROL_AE_STATE                                     0x011f     SENSOR_NEUTRAL_COLOR_POINT                           0x0e12
    CONTROL_AF_MODE                                      0x0107     SENSOR_NOISE_PROFILE                                 0x0e13
    CONTROL_AF_REGIONS                                   0x0108     SENSOR_PROFILE_HUE_SAT_MAP                           0x0e14
    CONTROL_AF_TRIGGER                                   0x0109     SENSOR_PROFILE_TONE_CURVE                            0x0e15
    CONTROL_AF_STATE                                     0x0120     SENSOR_TEST_PATTERN_DATA                             0x0e17
    CONTROL_AF_TRIGGER_ID                                0x0121     SENSOR_TEST_PATTERN_MODE                             0x0e18
    CONTROL_AWB_LOCK                                     0x010a     SENSOR_ROLLING_SHUTTER_SKEW                          0x0e1a
    CONTROL_AWB_MODE                                     0x010b     SHADING_MODE                                         0x1000
    CONTROL_AWB_REGIONS                                  0x010c     STATISTICS_FACE_DETECT_MODE                          0x1100
    CONTROL_CAPTURE_INTENT                               0x010d     STATISTICS_FACE_LANDMARKS                            0x1105
    CONTROL_AWB_STATE                                    0x0122     STATISTICS_FACE_RECTANGLES                           0x1106
    CONTROL_EFFECT_MODE                                  0x010e     STATISTICS_FACE_SCORES                               0x1107
    CONTROL_MODE                                         0x010f     STATISTICS_LENS_SHADING_CORRECTION_MAP               0x110a
    CONTROL_SCENE_MODE                                   0x0110     STATISTICS_LENS_SHADING_MAP                          0x110b
    CONTROL_VIDEO_STABILIZATION_MODE                     0x0111     STATISTICS_PREDICTED_COLOR_GAINS                     0x110c
    FLASH_MODE                                           0x0402     STATISTICS_PREDICTED_COLOR_TRANSFORM                 0x110d
    FLASH_STATE                                          0x0405     STATISTICS_SCENE_FLICKER                             0x110e
    HOT_PIXEL_MODE                                       0x0600     STATISTICS_HOT_PIXEL_MAP_MODE                        0x1103
    JPEG_GPS_COORDINATES                                 0x0700     STATISTICS_HOT_PIXEL_MAP                             0x110f
    JPEG_GPS_PROCESSING_METHOD                           0x0701     STATISTICS_LENS_SHADING_MAP_MODE                     0x1110
    JPEG_GPS_TIMESTAMP                                   0x0702     TONEMAP_CURVE_BLUE                                   0x1300
    JPEG_ORIENTATION                                     0x0703     TONEMAP_CURVE_GREEN                                  0x1301
    JPEG_QUALITY                                         0x0704     TONEMAP_CURVE_RED                                    0x1302
    JPEG_THUMBNAIL_QUALITY                               0x0705     TONEMAP_MODE                                         0x1303
    JPEG_THUMBNAIL_SIZE                                  0x0706     TONEMAP_GAMMA                                        0x1306
    LENS_APERTURE                                        0x0800     TONEMAP_PRESET_CURVE                                 0x1307
    LENS_FILTER_DENSITY                                  0x0801     LED_TRANSMIT                                         0x1400
    LENS_FOCAL_LENGTH                                    0x0802     BLACK_LEVEL_LOCK                                     0x1600
    LENS_FOCUS_DISTANCE                                  0x0803     SYNC_FRAME_NUMBER                                    0x1700
    LENS_OPTICAL_STABILIZATION_MODE                      0x0804     REPROCESS_EFFECTIVE_EXPOSURE_FACTOR                  0x1800
    LENS_POSE_ROTATION                                   0x0806
    ==================================================   =======    ==================================================   =======

..

Greybus Camera Image Formats (Informative)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Introduction
""""""""""""

Image formats specify how image data is structured to be sent over CSI-2.

A format defines the following properties.

* *The color encoding*

    Colors are encoded as three integer values called components.
    The components most frequently represent RGB or YUV values.

    In RGB encoding each pixel is described by Red, Green and Blue components.
    For sensors using a color filter array such as a Bayer filter, only one of
    the components is available for a given pixel.

    In YUV encoding each pixel is described by its Luma (Y), Blue Chroma (Cb
    or U) and Red Chroma (Cr or V). The red and blue chroma are collectively
    called chroma components or chroma and abbreviated UV.

* *The color depth*

    Also known as bit depth, the color depth is the number of bits used for
    each color component of a pixel.

    The Camera Class Protocol uses the same number of bits of all color
    components of a pixel. Typical values are 8, 10 and 12.

* *The components interleaving method*

    Components of a pixel may be transmitted together or separately. A format
    that transmits all components together is called a packed format. Figure
    :num:`camera-imgfmt-rgb-example` shows how the first three pixels of an
    image are transmitted in a packed RGB format.

.. _camera-imgfmt-rgb-example:
.. figure:: /img/svg/ara-camera-image-rgb-example.png
    :align: center

    Three pixels encoded in packed RGB format
..

    The same component arrangement is repeated for the remaining pixels of the
    image, line after line.

    A format that transmit components separately is called a planar format.
    Figure :num:`camera-imgfmt-yuv-example` shows how an image may be
    transmitted in a planar YUV format.

.. _camera-imgfmt-yuv-example:
.. figure:: /img/svg/ara-camera-image-yuv-example.png
    :align: center

    Planar YUV image encoding
..

    The ellipsis patterns (...) denote the rest of all luma, blue chroma and red
    chroma components respectively.

    A format may also combine planar and packed components arrangements.
    Such a format is called semi-planar. In practice semi-planar formats are
    used with YUV encoding only and split components in a Y plane and a packed
    UV plane, as shown in Figure :num:`camera-imgfmt-yuv-semiplanar-example`.

.. _camera-imgfmt-yuv-semiplanar-example:
.. figure:: /img/svg/ara-camera-image-yuv-example2.png
    :align: center

    Semi-planar YUV image encoding
..

    In full planar YUV formats luma and chroma components are separated in three
    planes, one for each component.

    In semi-planar YUV formats luma and chroma components are separated in two
    planes. The luma plane contains the luma components only, and the chroma
    plane contains the blue and red chroma components interleaved. Every
    semi-planar format comes in two chroma interleaving variants, in the UV or
    VU order.

* *The components ordering*

    Within a given interleaving method components may be arranged differently.
    For instance, a packed RGB format may transmit the three pixel components
    in the (R, G, B) or (B, G, R) order. Similarly, a planar YUV format may
    transfer the U plane before the V plane or the V plane before the U plane.

* *The components subsampling ratios*

    In YUV formats the chroma components may be sub-sampled horizontally and/or
    vertically to reduce bandwidth.

    The most common subsampling ratios are:

    - 4:4:4 - No subsampling, every pixel has three color components
    - 4:2:2 - Horizontal subsampling by 1/2
    - 4:2:0 - Horizontal and vertical subsampling by 1/2

    Figure :num:`camera-imgfmt-sampling` shows the relationship between pixels
    and luma and chroma components in a 8x2 pixels image.

.. _camera-imgfmt-sampling:
.. figure:: /img/svg/ara-camera-image-sampling.png
    :align: center

    YUV4:2:2 and YUV4:2:0 sampling examples
..

When subsampling chroma components the location of the components relatively to
the pixels must be specified.

Data Transmission
"""""""""""""""""

Unless otherwise noted all image frames shall be transmitted in accordance with
section 9 of [CSI-2]_.

Camera Modules shall transmit all streams multiplexed over a single CSI-2 port
and a single Virtual Channel, using the Data Type Interleaving method defined
by CSI-2. The modules shall use Packet Level Interleaving as defined in section
9.13.1 of [CSI-2]_.

Each format defined in this specification may add specific requirements.

In the following figures symbols shall be interpreted as follows.

* FS: Frame Start
* FE: Frame End
* PH: Packet Header
* PF: Packet Footer

Packed Formats
""""""""""""""

All packed formats are sent using a single CSI-2 Data Type

**Packed YUV4:2:2 Image Format**

This format transmits pixels encoded in YUV with 8 bits per component and a
4:2:2 subsampling. The image width shall be a multiple of two pixels.

Packed YUV 4:2:2 shall be transmitted as specified in section 11.2.4 of
[CSI-2]_.

Figure :num:`camera-imgfmt-packed-yuv422` illustrates how to transmit one line
of the image.

.. _camera-imgfmt-packed-yuv422:
.. figure:: /img/svg/ara-camera-image-packed422.png
    :align: center

    Packed YUV4:2:2 image transmission format
..

Chroma components are spatially sampled at the same location as the luma
components with a corresponding sample number.

**Packed YUV4:2:0 Image Format**

This format transmits pixels encoded in YUV with 8 bits per component and a
4:2:0 subsampling. The image width and height shall be multiples of two pixels.

Packed YUV 4:2:0 shall be transmitted as specified in sections 11.2.2 and
11.2.1 (legacy format) of [CSI-2]_.

Figure :num:`camera-imgfmt-packed-yuv420` and
:num:`camera-imgfmt-packed-yuv420l` illustrate how to transmit image lines in
YUV4:2:0 non-legacy and legacy format respectively.

.. _camera-imgfmt-packed-yuv420:
.. figure:: /img/svg/ara-camera-image-packed420.png
    :align: center

    Packed YUV4:2:0 Non-Legacy image transmission format
..

.. _camera-imgfmt-packed-yuv420l:
.. figure:: /img/svg/ara-camera-image-packed420l.png
    :align: center

    Packed YUV4:2:0 Legacy image transmission format
..

In the non-legacy format even lines are twice as long as odd lines.

Chroma components x transmitted on odd line y and even line y+1 are spatially
sampled in the middle of the four pixels at locations (x,y), (x+1,y), (x,y+1),
(x+1,y+1).

Planar and Semi-Planar Formats
""""""""""""""""""""""""""""""

Planar and semi-planar formats separate pixel components in two or more planes.

Planes from one image frame shall be transmitted using line interleaving or
plane sequential mode.

* In line interleaving mode, samples from a single line of a plane shall be
  transmitted in one or more consecutive CSI-2 packets. Lines shall then be
  interleaved as specified by each format. All samples from a line are thus
  transmitted contiguously relatively to samples from different planes of the
  same frame.
* In plane sequential mode, samples from a single plane shall be transmitted in
  consecutive CSI-2 packets. All samples from a plane are thus transmitted
  contiguously relatively to samples from different planes of the same frame.

In both modes packets from multiple streams may be interleaved freely.

Planar formats can come in two variants, one with all planes transmitted using
a single Data Type, and one with planes transmitted using separate Data Types.

**Semi-Planar YUV4:2:2 Image Format**

These formats transmit pixels encoded in YUV with 8 bits per component and a
4:2:2 subsampling. The image width shall be a multiple of two pixels.
The number of chroma line is equal to the number of luma lines.

The semi-planar YUV 4:2:2 formats are Ara-specific, they are not defined in
[CSI-2]_. They come in eight variants with all combinations of number of Data
Types, U/V ordering and interleaving mode.

In line-interleaved mode a luma line is sent first followed by one chroma line.
The chroma line contains samples related to the same pixels as the luma line.
The same pattern repeats until the end of the frame. Figure
:num:`camera-imgfmt-line-interleaving` illustrates how to transmit one
frame in line-interleaved mode with the UV chroma interleaving order.

.. _camera-imgfmt-line-interleaving:
.. figure:: /img/svg/ara-camera-image-line-interleaving.png
    :align: center

    Example of image transmission using line interleaving mode and YUV4:2:2
    semi-planar sampling mode
..

In plane-interleaved mode all luma lines are sent first followed by all chroma
lines. Figure :num:`camera-imgfmt-plane-interleaving` illustrates how to
transmit one frame in plane sequential mode with the UV chroma interleaving
order.

.. _camera-imgfmt-plane-interleaving:
.. figure:: /img/svg/ara-camera-image-plane-interleaving.png
    :align: center

    Example of image transmission using plane interleaving mode and YUV4:2:2
    semi-planar sampling mode
..

Chroma components are spatially sampled at the same location as the luma
components with a corresponding sample number.

**Semi-Planar YUV4:2:0 Image Format**

These formats transmit pixels encoded in YUV with 8 bits per component and a
4:2:0 subsampling. The image width and height shall be multiples of two pixels.
The number of chroma lines is half the number of luma lines. Each chroma line
stores values related to two lines of pixels.

The semi-planar YUV 4:2:0 formats are Ara-specific, they are not defined in
[CSI-2]_. They come in eight variants with all combinations of number of Data
Types, U/V ordering and interleaving mode.

In line-interleaved mode lines are sent in groups of two luma lines and one
chroma line. The group starts with an odd luma line, followed by one chroma
line, followed by an even luma line. The chroma line contains samples related
to the same pixels as the two luma lines. The same pattern repeats until the
end of the frame.

Figure :num:`camera-imgfmt-420-line-interleaved` illustrates how to transmit
one frame in line-interleaved mode with the UV chroma interleaving order.

.. _camera-imgfmt-420-line-interleaved:
.. figure:: /img/svg/ara-camera-image-sp420.png
    :align: center

    Example of image transmission using line interleaving mode and YUV4:2:0
    semi-planar sampling mode
..

In plane-interleaved mode all luma lines are sent first followed by all chroma
lines. Figure :num:`camera-imgfmt-420-plane-interleaved` illustrates how to
transmit one frame in plane sequential mode with the UV chroma interleaving
order.

.. _camera-imgfmt-420-plane-interleaved:
.. figure:: /img/svg/ara-camera-image-p420.png
    :align: center

    Example of image transmission using plane interleaving mode and YUV4:2:0
    semi-planar sampling mode
..

Chroma components x transmitted on odd line y and even line y+1 are spatially
sampled in the middle of the four pixels at locations (x,y), (x+1,y), (x,y+1),
(x+1,y+1).

**Planar YUV4:2:2 Image Format**

These formats transmit pixels encoded in YUV with 8 bits per component and a
4:2:2 subsampling. The image width shall be a multiple of two pixels. The
number of chroma line is equal to the number of luma lines.

The planar YUV 4:2:2 formats are Ara-specific, they are not defined in
[CSI-2]_. They come in two variants for U/V ordering.

Only plane-interleaved is supported. All luma lines are sent first, followed
by all blue or red chroma lines, followed by all remaining (red or blue) chroma
lines. Figure :num:`camera-img-fmt-planar-422` illustrates how to transmit one
frame in plane sequential mode with the UV chroma order.

.. _camera-img-fmt-planar-422:
.. figure:: /img/svg/ara-camera-image-p422.png
    :align: center

    Example of image transmission using plane interleaving mode and YUV4:2:2
    planar sampling mode
..

Chroma components are spatially sampled at the same location as the luma
components with a corresponding sample number.

**Planar YUV4:2:0 Image Format**

These formats transmit pixels encoded in YUV with 8 bits per component and a
4:2:0 subsampling. The image width and height shall be multiples of two pixels.
The number of chroma lines is half the number of luma lines. Each chroma line
stores values related to two lines of pixels.

The planar YUV 4:2:0 formats are Ara-specific, they are not defined in
[CSI-2]_. They come in two variants for U\/V ordering.

Only plane-interleaved is supported. All luma lines are sent first, followed
by all blue or red chroma lines, followed by all remaining (red or blue)
chroma lines.

Figure :num:`camera-img-fmt-planar-420` illustrates how to transmit one frame
in plane sequential mode with the UV chroma order.

.. _camera-img-fmt-planar-420:
.. figure:: /img/svg/ara-camera-image-p420-2.png
    :align: center

    Example of image transmission using plane interleaving mode and YUV4:2:2
    planar sampling mode
..

Chroma components x transmitted on odd line y and even line y+1 are spatially
sampled in the middle of the four pixels at locations (x,y), (x+1,y), (x,y+1),
(x+1,y+1).

.. _camera-imgfmt-ids:

Image Format Identifiers
^^^^^^^^^^^^^^^^^^^^^^^^

Image formats are identified by a numeric ID, as reported in table
:num:`table-camera-image-formats`.

.. figtable::
    :nofig:
    :label: table-camera-image-formats
    :caption: Camera Device Class Image Format Identifiers

     ===========================  ====  ===========  ===  =====
     Format                       ID    Packing      DT   UV
     ===========================  ====  ===========  ===  =====
     Reserved shall not be used   0x00  \            \    \
     \

     *YUV Formats*
     ----------------------------------------------------------

     UYVY422_PACKED               0x01  Packed       1    \
     UYVY420_PACKED               0x02  Packed       1    \
     UYYVYY420_PACKED             0x03  Packed       1    \
     YUV422_SEMIPLANAR_LINE_1DT   0x04  Semi Planar  1    UV
     YVU422_SEMIPLANAR_LINE_1DT   0x05  Semi Planar  1    VU
     YUV422_SEMIPLANAR_LINE_2DT   0x06  Semi Planar  2    UV
     YVU422_SEMIPLANAR_LINE_2DT   0x07  Semi Planar  2    VU
     YUV422_SEMIPLANAR_PLANE_1DT  0x08  Semi Planar  1    UV
     YVU422_SEMIPLANAR_PLANE_1DT  0x09  Semi Planar  1    VU
     YUV422_SEMIPLANAR_PLANE_2DT  0x0A  Semi Planar  2    UV
     YVU422_SEMIPLANAR_PLANE_2DT  0x0B  Semi Planar  2    VU
     YUV422_PLANAR_PLANE_1DT      0x0C  Planar       1    UV
     YVU422_PLANAR_PLANE_1DT      0x0D  Planar       1    VU
     YUV420_SEMIPLANAR_LINE_1DT   0x0E  Semi Planar  1    UV
     YVU420_SEMIPLANAR_LINE_1DT   0x0F  Semi Planar  1    VU
     YUV420_SEMIPLANAR_LINE_2DT   0x10  Semi Planar  2    UV
     YVU420_SEMIPLANAR_LINE_2DT   0x11  Semi Planar  2    VU
     YUV420_SEMIPLANAR_PLANE_1DT  0x12  Semi Planar  1    UV
     YVU420_SEMIPLANAR_PLANE_1DT  0x13  Semi Planar  1    VU
     YUV420_SEMIPLANAR_PLANE_2DT  0x14  Semi Planar  2    UV
     YVU420_SEMIPLANAR_PLANE_2DT  0x15  Semi Planar  2    VU
     YUV420_PLANAR_PLANE_1DT      0x16  Planar       1    UV
     YVU420_PLANAR_PLANE_1DT      0x17  Planar       1    VU
     \

     *Binary Formats*
     ----------------------------------------------------------

     JPEG                         0x40  \            \    \
     Metadata                     0x41  \            \    \
     \

     *Raw Formats*
     ----------------------------------------------------------

     RAW1 (FIXME)                 0x80  \            \    \
     ===========================  ====  ===========  ===  =====
..
