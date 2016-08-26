.. _bootrom-protocol:

Bootrom Protocol
----------------

.. note:: **The Bootrom Protocol is deprecated for new Greybus
          implementations**.  The :ref:`firmware-download-protocol`
          should be used instead.

          While the Bootrom Protocol supports downloading
          :term:`Interface Firmware` via
          Greybus, it lacks support for other features provided by the
          :ref:`firmware-management-protocol` and other related
          Protocols, such as:

          - Proper :ref:`lifecycles_connection_management`

          - Downloading :term:`Interface Backend Firmware`

          - Indicating to an Interface that it should store downloaded
            firmware on a non-volatile medium for later use

          However, an implementation of this Protocol is part of a
          Greybus implementation which can no longer be
          changed. Because of this, AP Modules should maintain legacy
          compatibility for this protocol.

The Greybus Bootrom Protocol may be used by an Interface to download
Interface Firmware via |unipro| when the Interface does not have
suitable Interface Firmware already available.

If an Interface implements this Greybus Protocol, the following
additional requirements or exceptions hold:

- Any :ref:`manifest-description` the Interface transmits to the AP via
  the :ref:`control-protocol` shall contain exactly one CPort Descriptor
  with id field different than zero.  The protocol field in that CPort
  Descriptor shall equal "Bootrom" (0x15), as described in Table
  :num:`table-cport-protocol`.

  As a special exception, the Manifest may also contain one additional
  CPort Descriptor with id field equal to zero. This descriptor, if
  present, shall be ignored when received by the AP, along with any
  Bundle Descriptors it refers to, if any.

- The Interface shall implement the
  :ref:`greybus-interface-attributes`.  The value of the Ara
  Initialization Status attribute shall be set to one of 0x00000006 or
  0x00000009 before any time the Interface sets the value of
  :ref:`hardware-model-mailbox`.

- If the AP detects one of these reserved Ara Initialization Status
  attribute values has been set, it shall not enable |unipro|
  End-to-End Flow Control on any Connections it establishes with the
  Interface.

The Operations in the Greybus Bootrom Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Refer to :ref:`greybus-protocol-version-operation`.

.. c:function:: int ap_ready(void);

    The AP may send this Request to the Interface to confirm that the AP
    is now ready to receive Requests over the Connection, and the
    Interface can start the firmware download process.  Until this Request is
    received by the Interface, it shall not send any Requests on the
    Connection.

.. c:function:: int firmware_size(u8 stage, u32 *size);

    The Interface requests from the AP the size of the Interface Firmware to
    load, specifying the stage of the boot sequence for which the Interface is
    requesting firmware.  The AP then locates a suitable firmware blob, and
    associates that firmware blob with the requested boot stage until it next
    receives a Firmware Size Request, and responds with the blob's size in
    bytes, which must be nonzero.

.. c:function:: int get_firmware(u32 offset, u32 size, void *data);

    The Interface requests a finite stream of bytes in the firmware blob
    from the AP, passing its current offset into the firmware blob, and the size
    of the stream it currently needs.  The AP responds with exactly the number
    of bytes requested, taken from the firmware blob currently associated with
    this Connection at the specified offset.

.. c:function:: int ready_to_boot(u8 status);

    The Interface implementing the Protocol requests permission from the AP to jump
    into the firmware blob it has loaded.  The Request sent to the AP includes a
    status indicating whether the retrieved firmware blob is valid and secure,
    valid but insecure, or invalid.  The AP decides whether to permit the module
    to boot in its current condition: if so, it sends a success code in its
    Response's status byte, otherwise, it sends an error code in its Response's
    status byte.

Greybus Bootrom Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-bootrom-operation-type` describes the Greybus Bootrom
Operation Types and their values.  A Message Type consists of an Operation Type
combined with a flag (0x80) indicating whether the Operation is a Request or a
Response.

.. figtable::
    :nofig:
    :label: table-bootrom-operation-type
    :caption: Bootrom Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Bootrom Operation Type       Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Firmware Size                0x02           0x82
    Get Firmware                 0x03           0x83
    Ready to Boot                0x04           0x84
    AP Ready                     0x05           0x85
    (all other values reserved)  0x06..0x7e     0x86..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

Greybus Bootrom Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Bootrom Protocol Version Operation is the
:ref:`greybus-protocol-version-operation` for the Bootrom Protocol.

Greybus implementations adhering to the Protocol specified herein
shall specify the value zero (0) for the version_major and
one (1) for the version_minor fields found in this Operation's
Request and Response messages.

The Greybus Bootrom Protocol definition shall not change the required
values for the version_major or version_minor fields in the
future. This Protocol's Operations are fixed and shall not change in
future versions of the Greybus Specification.


Greybus Bootrom Protocol AP Ready Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Bootrom Protocol AP Ready Operation allows the AP to
indicate that it is ready to receive Requests from the Interface over the
Bootrom Connection.

Greybus Bootrom Protocol AP Ready Request
"""""""""""""""""""""""""""""""""""""""""

The Greybus Bootrom AP Ready Request Message has no payload.

Before receiving this Request, the Interface shall not send any
Requests on the Bootrom Connection. After receiving this Request, the
Interface may send Requests on the Bootrom Connection.

Greybus Bootrom Protocol AP Ready Response
""""""""""""""""""""""""""""""""""""""""""

The Greybus Bootrom AP Ready Response Message has no payload.

Greybus Bootrom Firmware Size Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Bootrom Firmware Size Operation allows the Interface to submit a
boot stage to the AP, so that the AP can associate a firmware blob with that
boot stage and respond with its size.  The AP keeps the firmware blob associated
with the boot stage until it receives another Firmware Size Request on the same
Connection, but is not required to send identical firmware blobs in Response to
different Requests with identical boot stages, even to the same Interface.

The boot stage parameter is fixed as a result of this Protocol's deprecation.

.. _firmware-size-request:

Greybus Bootrom Firmware Size Request
"""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-size-request` defines the Greybus Bootrom Firmware Size
Request payload.  The Request supplies the boot stage of the Interface implementing
the Protocol. The stage shall equal two.

.. figtable::
    :nofig:
    :label: table-firmware-size-request
    :caption: Bootrom Protocol Firmware Size Request
    :spec: l l c c l

    ======  =========  ====  ======  ===============================================
    Offset  Field      Size  Value   Description
    ======  =========  ====  ======  ===============================================
    0       stage      1     2       Stage is fixed to two.
    ======  =========  ====  ======  ===============================================

..

.. _firmware-size-response:

Greybus Bootrom Firmware Size Response
""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-size-response` defines the Greybus Firmware
Size Response payload.  The Response supplies the size of the firmware
blob which the AP has made available to the Interface for download.

.. figtable::
    :nofig:
    :label: table-firmware-size-response
    :caption: Bootrom Protocol Firmware Size Response
    :spec: l l c c l

    ======  =====  ====  ======  =========================
    Offset  Field  Size  Value   Description
    ======  =====  ====  ======  =========================
    0       size   4     Number  Size of the blob in bytes
    ======  =====  ====  ======  =========================

..

.. _firmware-get-firmware:

Greybus Bootrom Get Firmware Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Bootrom Get Firmware Operation allows the Interface to retrieve a
stream of bytes at an offset within the firmware blob from the AP.  The AP
responds with the requested number of bytes from the Connection's associated
firmware blob at the requested offset, or with an error status without payload
if no firmware blob has yet been associated with this Connection or if the
requested stream size exceeds the firmware blob's size minus the requested
offset.

Greybus Bootrom Get Firmware Request
""""""""""""""""""""""""""""""""""""

Table :num:`table-bootrom-get-firmware-request` defines the Greybus Bootrom
Get Firmware Request payload.  The Request specifies an offset into the firmware
blob, and the size of the stream of bytes requested.  The stream size requested
must be less than or equal to the size given by the most recent Firmware Size
Response (:ref:`firmware-size-response`) minus the offset; when it is not, the
AP shall signal an error in its Response.  The Interface is responsible for
tracking its offset into the firmware blob as needed.

.. figtable::
    :nofig:
    :label: table-bootrom-get-firmware-request
    :caption: Bootrom Protocol Get Firmware Request
    :spec: l l c c l

    ======  ====== ====  ======  =================================
    Offset  Field  Size  Value   Description
    ======  ====== ====  ======  =================================
    0       offset 4     Number  Offset into the firmware blob
    4       size   4     Number  Size of the byte stream requested
    ======  ====== ====  ======  =================================

..

Greybus Bootrom Get Firmware Response
"""""""""""""""""""""""""""""""""""""

Table :num:`table-bootrom-get-firmware-response` defines the Greybus Bootrom
Get Firmware Response payload.  The Response includes the stream of bytes
requested by the Interface.  In the case that the AP cannot fulfill the Request,
such as when the requested stream size was greater than the total size of the
firmware blob, it shall signal an error in the status byte of the Response
header.

.. figtable::
    :nofig:
    :label: table-bootrom-get-firmware-response
    :caption: Bootrom Protocol Get Firmware Response
    :spec: l l c c l

    ======  =====  ====== ======  =================================
    Offset  Field  Size   Value   Description
    ======  =====  ====== ======  =================================
    0       data   *size* Data    Data from the firmware blob
    ======  =====  ====== ======  =================================

..

Greybus Bootrom Ready to Boot Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Bootrom Ready To Boot Operation allows the requesting
Interface to notify the AP that it has successfully loaded the
Connection's currently associated firmware blob, and is able to
execute that blob, as well as indicate the status of its firmware
blob.  The AP shall then send a Response empty of payload, indicating
via the header's status byte whether or not it permits the Interface
to continue booting.

The Interface shall send a Ready To Boot Request only when it has
successfully loaded a firmware blob and can execute that firmware.

Greybus Bootrom Ready to Boot Request
"""""""""""""""""""""""""""""""""""""

Table :num:`table-bootrom-ready-to-boot-request` defines the Greybus Bootrom
Ready To Boot Request payload.  The Request gives the security status of its
firmware blob.

.. figtable::
    :nofig:
    :label: table-bootrom-ready-to-boot-request
    :caption: Bootrom Protocol Ready to Boot Request
    :spec: l l c c l

    ======  ======  ====  ======  ===========================
    Offset  Field   Size  Value   Description
    ======  ======  ====  ======  ===========================
    0       status  1     Number  :ref:`firmware-blob-status`
    ======  ======  ====  ======  ===========================

..

Before sending this Request, the Interface should ensure that all
outstanding :ref:`Get Firmware <firmware-get-firmware>` Operation
Requests it has sent have received Responses from the AP. The
Interface should also not transmit any additional |unipro| Segments
with nonempty L4 payload on any Connection after those containing this
Request payload. The effect of sending this Request under other
conditions are undefined.

.. _firmware-blob-status:

Greybus Bootrom Ready to Boot Firmware Blob Status
""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-blob-status` defines the constants by which
the Interface can indicate the status of its firmware blob to the AP
in a Greybus Bootrom Ready to Boot Request.

.. figtable::
    :nofig:
    :label: table-firmware-blob-status
    :caption: Bootrom Ready to Boot Firmware Blob Statuses
    :spec: l l l

    ====================  ====================================  ============
    Firmware Blob Status  Brief Description                     Status Value
    ====================  ====================================  ============
    BOOT_STATUS_INVALID   Firmware blob could not be validated  0x00
    BOOT_STATUS_INSECURE  Firmware blob is valid but insecure   0x01
    BOOT_STATUS_SECURE    Firmware blob is valid and secure     0x02
    |_|                   (Reserved Range)                      0x03..0xFF
    ====================  ====================================  ============

..

Greybus Bootrom Ready to Boot Response
""""""""""""""""""""""""""""""""""""""

The Greybus Bootrom Ready to Boot Response has no payload.

In the case that the AP forbids the Interface from booting, it shall
signal an error in the status byte of the Response Message's
header. Otherwise, the status byte shall equal GB_OP_SUCCESS,
indicating permission to boot.

Before sending the Response, the AP should ensure that all outstanding
Control Protocol Requests to the Interface have received Responses.
The effect of sending this Request under other conditions is undefined.

Provided that the recommendations for the Interface and the AP defined
in this Protocol are followed, the Request and Response of the single
Ready to Boot Operation exchanged between the Interface and the AP are
the final |unipro| Messages exchanged between the two.

When this occurs, the Interface may execute the downloaded firmware
blob previously retrieved using this Protocol, and the following is
permitted as a special case exception to restrictions made elsewhere
in this Specification.

1. The Interface may treat its Control and Bootrom Connections as
   though they had been closed as described in
   :ref:`lifecycles_connection_management`.

2. The Interface may, at most once, make a new Manifest available for
   retrieval to the AP, and thus send different Response payloads to
   the :ref:`control-get-manifest-size` and
   :ref:`control-get-manifest` Requests, should new Requests on the
   Control Connection be received later.

   The new Manifest shall not contain any CPort Descriptors whose
   protocol field equals "Bootrom" (0x15).

3. The Interface shall set the Ara Initialization Status attribute to
   a value different than 0x00000006 or 0x00000009.

4. The Interface may subsequently set :ref:`hardware-model-mailbox` to
   MAILBOX_GREYBUS, causing the SVC to exchange a
   :ref:`svc-interface-mailbox-event` with the AP. If the
   Interface does so, it shall:

        - ensure that if its Control CPort is subsequently
          reconnected, |unipro| Flow Control Tokens shall subsequently
          be transmitted to the AP as buffer space for receiving
          Control Protocol Requests becomes available, and

        - subsequently respond to incoming :ref:`control-protocol`
          Operation Requests as defined in that section if the Control
          CPort is connected and used for Greybus communication.

5. The AP should, after exchanging the Interface Mailbox Event
   Operation with the SVC, attempt to release system resources
   associated with the Control and Bootrom Connections to the
   Interface.

6. The AP should then attempt to open a Control Connection with the
   Interface, and retrieve its Manifest once more.

This sequence, when possible, is a **Legacy Mode Switch**. Though the
Interface remains in the ENUMERATED Interface Lifecycle State
throughout a Legacy Mode Switch and afterwards, its Manifest may
change at most once as a result.
