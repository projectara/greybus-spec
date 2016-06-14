Camera Protocol
---------------

System Architecture (Informative)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Camera Device Class Protocol defines how Camera Modules communicate
with AP Modules in an Ara system.
MIPI has specified two interface protocols for camera integration relevant
to Ara systems, CSI-2 and CSI-3.

CSI-2 is a high-speed point-to-point unidirectional data transfer protocol.
It defines an interface between a camera peripheral device and a host processor.
CSI-2 usage is widespread in the mobile industry and is natively supported by
most mobile Application Processors.

CSI-3 is a high-speed bidirectional communication protocol for camera systems.
Based on |unipro|, it specifies communication between camera sensors, image
signal processors, bridge devices and host processors.
The Greybus Camera Device Class Specification currently does not support CSI-3
devices within Modules.

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
CSI-2 interface on each side of the CSI-2 over |unipro| tunnel.
Control messages exchanged over |unipro| outside of this are be
described in terms of Greybus Camera Management Operations as for all other
Greybus Device Class Protocols.

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
  initializing the peer.
  Currently, the only defined Video Setup Operation is the :ref:`Greybus Camera
  Management Capabilities Operation <camera-capabilities-operation>`.

* The Video Streaming Operations, which control the video streams and their
  parameters such as image resolution and image format.
  Currently, the two defined video streaming Operations are the
  :ref:`Greybus Camera Management Configure Streams Operation
  <camera-configure-streams-operation>` and Flush Operations.

* The Image Processing Operations, which control all the Camera Module image
  capture and processing algorithms and their parameters.
  Currently, the only defined image processing Operation is the :ref:`Greybus
  Camera Management Capture Operation <camera-capture-streams-operation>`.

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
by CSI-2.
The Camera Module shall use Packet Level Interleaving as defined in section
9.13.1 of [CSI-2]_.

.. pinchartl:
   TODO: What are the minimum demultiplexing requirements of the AP
   CSI-2 receiver ?

Metadata Transmission
"""""""""""""""""""""

Metadata is defined as data other than image content that relates to a
particular image frame.
Metadata is used by Camera Modules to inform the image receiver about the
characteristics of the transmitted frames, and the applied capture settings.

Metadata support is optional. However, when supported, it shall be implemented
according to this specification.

The Greybus Camera Device Class Protocol defines two transport methods for
metadata:

* using the Metadata Operation explicitly, through the Camera Management
  Connection.
* sending metadata along with image frames over the CSI-2 interface, through
  the Camera Data Connection.

Whenever possible, Camera Modules should use the CSI-2 transport to deliver
metadata.

Camera Modules may implement neither, one or both of these transport methods.
The supported methods shall be reported through the
:ref:`Greybus Camera Management Capabilities Operation
<camera-capabilities-operation>`

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
format defined in the Properties section of Greybus Camera Device Class
specifications.

.. TODO: jmondi: insert reference to that section, once added

However, when this isn’t possible or practical (for instance, when the Module
hardware dictates the metadata format), Modules may choose to encode metadata
using a custom method for metadata transmitted over CSI-2.

Metadata transmitted over CSI-2 using a custom encoding shall at minimum
contain the ID of the associated request.

.. TODO: jmondi: we probably want some other mandatory field here

**Metadata Operation**

When transmitting metadata through the dedicated Operation, the Camera Module
shall send a single Metadata Request per image frame.

Metadata transmitted over a Camera Management Connection using the Metadata
Operation shall be encoded as specified in the Properties section of
this specification.

.. TODO: jmondi: insert reference to that section, once added

Operational Model
^^^^^^^^^^^^^^^^^

Figure :num:`image-camera-operational-model` describes the operational model of
a Greybus Camera Bundle.

.. _image-camera-operational-model:
.. figure:: /img/dot/camera-operational-model.png
   :align: center

   Operational State Machine of a Greybus Camera Bundle

Upon a :ref:`Greybus Control Protocol Connected Operation <control-connected>`,
that notifies the Camera Interface that a Connection to its Camera Management
CPort has been successfully established, the Greybus Camera Device Class
Protocol state machine is entered, in the UNCONFIGURED state.

The Camera Device Class state machine is exited when the Camera Management
Connection is closed, either as notified by a :ref:`Greybus Control Protocol
Disonnected Operation <control-disconnected>` referring to the Camera
Management CPort, or as a consequence of forced removal.

The Greybus Camera Device Class state machine has 3 states: UNCONFIGURED,
CONFIGURED, and STREAMING.  Certain operations are only valid in specific
states, but the :ref:`Greybus Camera Management Capabilities Operation
<camera-capabilities-operation>`
may be used in any state, and shall always return the same set of camera
capabilities.

The states that define the Camera Device Class state machine are:

* **UNCONFIGURED:**
  In this state the Camera Management Connection is operational.
  The state transitions to CONFIGURED state happens upon receipt of a
  :ref:`Greybus Camera Management Configure Streams Request
  <camera-configure-streams-operation>` if the following conditions are
  respected:

  * The Configure Streams Operation return GB_SUCCESS;
  * The Configure Streams Request does not contain any flag that explicitly
    require the Module to remain in UNCONFIGURED state;
  * The Module fully support the requested streams configuration;

* **CONFIGURED:**
  In this state the module shall be ready to process ref:`Greybus Camera
  Management Capture Requests <camera-capture-streams-operation>`
  immediately as it receives them and then move to STREAMING state.
  Reception of a :ref:`Greybus Camera Management Configure Streams Request
  <camera-configure-streams-operation>` with a zero stream count returns
  the Bundle to the UNCONFIGURED state.

* **STREAMING:**
  In this state the Bundle transmits video frames in |unipro| Messages
  encapsulating CSI-2 packets, sent over the Greybus Camera Device Class Data
  Connection.
  Greybus Capture Stream Requests can be queued, and once there
  are no active or queued Requests, the Bundle moves back to CONFIGURED state.
  Reception of a Flush Operation Request clears the queue of pending capture
  requests and also moves the Bundle to the CONFIGURED state.

Greybus Camera Management Protocol
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Conceptually, the Operations in the Greybus Camera Management Protocol are:

.. c:function:: int ping(void);

    See :ref:`greybus-protocol-ping-operation`.

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
Greybus Camera Device Class Metadata Operation, which is, instead, initiated
by the Camera Module.

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
    Ping                         0x00           0x80
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

Greybus Camera Management Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Camera Management Ping Operation is the
:ref:`greybus-protocol-ping-operation` for the Greybus Camera Device Class
Protocol.
It consists of a Request containing no payload, and a Response
with no payload that indicates a successful result.

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
capabilities.
The capabilities may only change if the Module's Firmware gets changed.

Greybus Camera Management Capabilities Request
""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Camera Management Capabilities Request has no payload.

Greybus Camera Management Capabilities Response
"""""""""""""""""""""""""""""""""""""""""""""""
.. FIXME: jmondi Insert link to properties section

The Greybus Camera Management Capabilities Response contains a variable-size
capabilities block that shall conform to the format described in the Greybus
Camera Device Class Properties section of this specification.

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

When called with a non-zero number of streams the Operation configures the
Camera Module for capture with a list of stream parameters.
The Request is only valid in the UNCONFIGURED state, the Camera Bundle shall
reply with an empty payload and set the status to GB_OP_INVALID_STATE in all
other states.

Up to four streams are supported. A Request with a number of streams higher
than four shall be answered by an error Response with the status set to
GB_OP_INVALID.

If the requested streams configuration is supported by the Camera Module it
shall copy the configuration in its Response and additionally set the
virtual_channel, data_types and max_size for each stream.
As a result the Camera Bundle moves to the CONFIGURED state and shall be ready
to process Capture Requests with as little delay as possible.
In particular any time-consuming procedure which implements Module's specific
power management shall be performed when moving to the CONFIGURED
state.
Camera Modules shall not be kept in the CONFIGURED state unnecessarily.

In order to support negotiation of the stream configuration, the Module may
modify the requested configuration to match its capabilities.
This includes lowering the number of requested streams and modifying the width,
height and format of each stream. The Module shall, in that case, reply to the
Configure Streams Request with the configuration it can support according
to the Request and set the ADJUSTED bit in the Response flags field.
As a result the Camera Bundle shall stay in the UNCONFIGURED state without
modifying the device state.

.. TODO: pinchartl: "best configuration" needs to be defined.

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


Greybus Camera Configure Streams Operation Request
""""""""""""""""""""""""""""""""""""""""""""""""""

The Request supplies a set of stream configurations with the desired image
width, height and format for each stream as show in Table
:num:`table-camera-operations-configure-streams-request`
Both the width and height shall be multiples of 2.

The TEST_ONLY flag allows the AP to test a configuration without applying it.
When the flag is set the Camera Module shall process the Request normally but
stop from applying the configuration. The Module shall send the same Response
as it would if the TEST_ONLY flag wasn’t set and stay in the UNCONFIGURED state
without modifying the device state.

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
   :caption: The flag bitmask in Camera Class Configure Stream Request
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

Greybus Camera Configure Streams Operation Response
"""""""""""""""""""""""""""""""""""""""""""""""""""

The Camera Module reports its configuration in the Response message as shown
in Table :num:`table-camera-operations-configure-streams-response`.
If the Response configuration isn’t identical to the one supplied in the
Operation Request, the flag ADJUSTED shall be set.

The Camera Module shall report in the Response the Virtual Channel number
and Data Types for each stream regardless of whether the requested
configuration was supported. All Virtual Channel numbers shall be identical
and between zero and three inclusive.

All Data Types shall be different.

Up to two data types can be used to identify different components of the same
stream sent by a Camera Module. At least one data type shall be provided by the
Camera Module, the second is optional and shall be set to the reserved 0x00
value if not used.
The Data Types should be set to the CSI-2 Data Type value matching the streams
formats if possible, and may be set to a User Defined 8-bit Data Type
(0x30 to 0x37).

.. TODO: pinchartl: This requires a more detailed description.

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
    2           num_lanes      1       Number       The number of data lanes configured
    \                                               for the CSI-2 interface on the legacy
    \                                               side of the AP bridge
    3           padding        1       0            Shall be set to 0
    4           bus_freq       4       Number       The CSI-2 bus frequency in HZ
    8           lines_per_sec  4       Number       The total number of lines sent
    \                                               in a second of transmission
    \                                               (blankings included)

    *The following block appears num_streams times*
    ---------------------------------------------------------------------------

    12+(i*16)    width          2       Number      Image width in pixels
    14+(i*16)    height         2       Number      Image height in pixels
    16+(i*16)    format         2       Number      Image Format
    18+(i*16)    virtual_chan   1       Number      Virtual channel number
    19+(i*16)    data_type[2]   2       Number      Data types for the stream
    21+(i*16)    padding        3       0           Shall be set to 0
    24+(i*16)    max_size       4       Number      Maximum frame size in Bytes
    =========   =============  ======  ===========  ===========================
..

.. figtable::
   :nofig:
   :label: table-camera-configure-streams-response-flag-bitmask
   :caption: The flag bitmask in Camera Class Configure Stream Response
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
transmitting frames immediately.
Modules shall not transmit any |unipro| Segment on the
Camera Data Connection except as result of receiving a new Capture Request.

Greybus Camera Management Capture Streams Request
"""""""""""""""""""""""""""""""""""""""""""""""""

Each Camera Management Capture Stream Request contains an incrementing ID,
a bitmask of the streams it affects, a number of frames to capture for all the
streams in the bitmask and a list of settings to be applied to the transmitted
image.

The AP shall set the request_id field in the Request payload to
zero for the first Capture Streams Request it sends, and shall
increment the value in this payload by one in each subsequent Request.
If the value of the request_id field is not higher than the ID of the previous
Request the Camera Bundle shall ignore the Request and set the reply status to
GB_OP_INVALID.

Modules shall not use the value of the request_id field number for any purpose
other than synchronizing the Capture Operation with the Flush and Metadata
Operations.
In particular, Camera Bundle shall accept Requests with IDs higher than the
previous one by more than one.

.. TODO: jmondi: properly define the streams bitmaks

The num_frames field contains the number of times the Request shall be
repeated for all affected streams.
Camera Modules shall capture and transmit one frame per stream for every
repetition of the image capture request using the same capture settings.
When the num_frames field is set to zero the image capture request shall be
repeated indefinitely until the next Capture Operations Request, or a Flush
Operation Request, is received.

The Capture Streams Request is only valid in the CONFIGURED and STREAMING
states.
The Camera Module shall set the Response status to GB_OP_INVALID_STATE in all
other states.

The Capture Streams Request also contains a variable-size settings block that
shall conform to the format described in the Properties section of this
specification.
If no settings need to be applied for the Request the settings block size shall
be zero.

.. TODO: jmondi: Add reference to the properties section once added

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

Greybus Camera Management Capture Streams Respose
"""""""""""""""""""""""""""""""""""""""""""""""""

The Camera Management Operation Capture Response message has no payload.

If the Capture Request streams bitmask field contains non-configured streams
the Camera Module shall set the Response status to GB_OP_INVALID.
