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

