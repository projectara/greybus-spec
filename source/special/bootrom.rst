.. _bootrom-protocol:

Bootrom Protocol
----------------

.. note:: **The Bootrom Protocol is deprecated for new Greybus
          implementations**.  The :ref:`firmware-download-protocol`
          should be used instead.

          While the Bootrom Protocol supports downloading
          :ref:`Interface Firmware <glossary-interface-firmware>` via
          Greybus, it lacks support for other features provided by the
          :ref:`firmware-management-protocol` and other related
          Protocols, such as:

          - Proper :ref:`lifecycles_connection_management`

          - Downloading :ref:`Interface Backend Firmware
            <glossary-interface-backend-firmware>`

          - Indicating to an Interface that it should store downloaded
            firmware on a non-volatile medium for later use

          However, an implementation of this Protocol is part of a
          Greybus implementation which can no longer be
          changed. Because of this, AP Modules should maintain legacy
          compatibility for this protocol.

The Greybus Bootrom Protocol may be used by an Interface to download
Interface Firmware via |unipro| when the Interface does not have
suitable Interface Firmware already available.

The Operations in the Greybus Bootrom Protocol are:

.. c:function:: int ping(void);

    See :ref:`greybus-protocol-ping-operation`.

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
    Ping                         0x00           0x80
    Protocol Version             0x01           0x81
    Firmware Size                0x02           0x82
    Get Firmware                 0x03           0x83
    Ready to Boot                0x04           0x84
    AP Ready                     0x05           0x85
    (all other values reserved)  0x06..0x7e     0x86..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

Greybus Bootrom Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Bootrom Ping Operation is the
:ref:`greybus-protocol-ping-operation` for the Bootrom Protocol.  It
consists of a Request containing no payload, and a Response with no
payload that indicates a successful result.

Greybus Bootrom Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Bootrom Protocol Version Operation is the
:ref:`greybus-protocol-version-operation` for the Bootrom Protocol.

Greybus implementations adhering to the Protocol specified herein
shall specify the value |gb-major| for the version_major and
|gb-minor| for the version_minor fields found in this Operation's
request and response messages.


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

The Greybus Bootrom firmware size operation allows the requestor to submit a
boot stage to the AP, so that the AP can associate a firmware blob with that
boot stage and respond with its size.  The AP keeps the firmware blob associated
with the boot stage until it receives another Firmware Size Request on the same
connection, but is not required to send identical firmware blobs in response to
different requests with identical boot stages, even to the same module.

.. _firmware-size-request:

Greybus Bootrom Firmware Size Request
"""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-size-request` defines the Greybus Bootrom Firmware Size
request payload.  The request supplies the boot stage of the module implementing
the Protocol.

.. figtable::
    :nofig:
    :label: table-firmware-size-request
    :caption: Bootrom Protocol Firmware Size Request
    :spec: l l c c l

    ======  =========  ====  ======  ===============================================
    Offset  Field      Size  Value   Description
    ======  =========  ====  ======  ===============================================
    0       stage      1     Number  :ref:`firmware-boot-stages`
    ======  =========  ====  ======  ===============================================

..

.. _firmware-boot-stages:

Greybus Bootrom Firmware Boot Stages
""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-boot-stages` defines the boot stages whose firmware
can be requested from the AP via the Protocol.

.. figtable::
    :nofig:
    :label: table-firmware-boot-stages
    :caption: Bootrom Protocol Firmware Boot Stages
    :spec: l l l

    ================  ======================================================  ==========
    Boot Stage        Brief Description                                       Value
    ================  ======================================================  ==========
    BOOT_STAGE_ONE    Reserved for the boot ROM.                              0x01
    BOOT_STAGE_TWO    Firmware package to be loaded by the boot ROM.          0x02
    BOOT_STAGE_THREE  Module personality package loaded by Stage 2 firmware.  0x03
    |_|               (Reserved Range)                                        0x04..0xFF
    ================  ======================================================  ==========

..

.. _firmware-size-response:

Greybus Bootrom Firmware Size Response
""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-size-response` defines the Greybus firmware size
response payload.  The response supplies the size of the AP's firmware blob for
the module implementing the Protocol.

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
    4       data   *size* Data    Data from the firmware blob
    ======  =====  ====== ======  =================================

..

Greybus Bootrom Ready to Boot Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Bootrom Ready To Boot Operation allows the requesting Interface to notify
the AP that it has successfully loaded the Connection's currently associated
firmware blob, and is able to execute that blob, as well as
indicate the status of its firmware blob.  The AP shall then send a Response
empty of payload, indicating via the header's status byte whether or not it
permits the Interface to continue booting.

The Interface shall send a Ready To Boot Request only when it has successfully
loaded a firmware blob and can execute that firmware.

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

.. _firmware-blob-status:

Greybus Bootrom Ready to Boot Firmware Blob Status
""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-blob-status` defines the constants by which the
Interface can indicate the status of its firmware blob to the AP in a Greybus
Bootrom Ready to Boot Request.

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
