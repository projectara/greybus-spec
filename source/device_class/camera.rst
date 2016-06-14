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
  Currently, the only defined Video Setup Operation is the Capabilities
  Operation.

* The Video Streaming Operations, which control the video streams and their
  parameters such as image resolution and image format.
  Currently, the two defined video streaming Operations are the Configure
  Streams and Flush Operations.

* The Image Processing Operations, which control all the Camera Module image
  capture and processing algorithms and their parameters.
  Currently, the only defined Image Processing Operation is the Capture
  Operation.

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
The supported methods shall be reported through the Camera Capabilities
Operation.

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
