.. _firmware-download-protocol:

Firmware Download Protocol
--------------------------

The Greybus Firmware Download Protocol can be used by an Interface to
communicate with the AP and receive firmware packages over |unipro|.

If an Interface requires to download a firmware package, it shall first
request the AP to find a firmware package for the Interface using a
:ref:`find-firmware-operation`.  This may be followed by one or more
:ref:`Greybus Firmware Download Protocol Fetch Firmware Operations
<fetch-firmware-operation>` to receive the firmware package block by
block.  Finally the Interface shall request the AP to release the
firmware package using a :ref:`release-firmware-operation`.

Conceptually, the Operations in the Greybus Firmware Download Protocol
are:

.. c:function:: int cport_shutdown(u8 phase);

    See :ref:`greybus-protocol-cport-shutdown-operation`.

.. c:function:: int find_firmware(u8 firmware_tag[10], u8 *firmware_id, u32 *size);

    This Operation can be initiated only by an Interface to request the
    AP to find a firmware package for the Interface.

.. c:function:: int fetch_firmware(u8 firmware_id, u32 offset, u32 size, void *data);

    This Operation can be initiated only by an Interface to fetch a
    block of data from the AP in the firmware package previously
    requested from the AP.

.. c:function:: int release_firmware(u8 firmware_id);

    If the Interface has requested the AP to find a firmware package
    using a :ref:`find-firmware-operation` earlier, it shall use this
    Operation to request the AP to release that firmware package.

Greybus Firmware Download Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All Firmware Download Protocol Operations are initiated using a Greybus
Firmware Download Protocol Request message, which results in a matching
Response message.  The Request and Response messages for each Operation
are defined below.

Table :num:`table-firmware-download-operation-type` defines the Greybus
Firmware Download Protocol Operation types and their values.  Both the
Request type and the Response type values are shown below.

.. figtable::
    :nofig:
    :label: table-firmware-download-operation-type
    :caption: Firmware Download Protocol Operation Types
    :spec: l l l

    =================================  =============  ===============
    Firmware Operation Type            Request Value  Response Value
    =================================  =============  ===============
    CPort Shutdown                     0x00           0x80
    Find Firmware                      0x01           0x81
    Fetch Firmware                     0x02           0x82
    Release Firmware                   0x03           0x83
    (all other values reserved)        0x04..0x7e     0x84..0xfe
    Invalid                            0x7f           0xff
    =================================  =============  ===============
..

.. _firmware-download-cport-shutdown:

Greybus Firmware Download CPort Shutdown Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Firmware Download CPort Shutdown Operation is the
:ref:`greybus-protocol-cport-shutdown-operation` for the Firmware Download
Protocol.

.. _find-firmware-operation:

Greybus Firmware Download Find Firmware Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Firmware Download Find Firmware Operation Request can be
sent only by an Interface to request the AP to find a firmware package
for the Interface.

The Interface provides a firmware_tag to the AP as part of the request,
which may be used by the AP in an implementation-defined way to find the
firmware package for the Interface.

In response, the AP locates a matching firmware package and returns to
the Interface the size of the firmware package and a unique firmware_id
associated with the firmware package.

The same firmware_id shall be sent by the Interface as part of the Fetch
Firmware or the Release Firmware Requests sent later.

This may be followed by one or more :ref:`Greybus Firmware Download
Fetch Firmware Operation Requests <fetch-firmware-operation>` from the
Interface to the AP, in order to receive the firmware package block by
block.

Once the firmware is successfully requested by the Interface using a
:ref:`find-firmware-operation`, the AP shall support all valid
:ref:`Greybus Firmware Download Fetch Firmware Operation Requests
<fetch-firmware-operation>` until the Interface initiates a
:ref:`release-firmware-operation` or the AP times out waiting for a
request from the Interface.

An Interface may request the AP to find one or more firmware packages
using separate :ref:`Greybus Firmware Download Find Firmware Operations
<find-firmware-operation>` and fetch them in parallel by using the
firmware_id received from the AP earlier in the Find Firmware Response.

The AP may impose implementation-defined timeouts for:

- The time interval between the Find Firmware Response and the first
  Fetch Firmware Request.
- The time interval between a Fetch Firmware Response and the next Fetch
  Firmware Request.
- The time interval between a Fetch Firmware Response and the Release
  Firmware Request.
- The time interval between the Find Firmware Response and the Release
  Firmware Request.

If any of the above timeouts occur, the AP shall respond with
GB_OP_TIMEOUT in the status byte of the Response header, to the next
Request from the Interface that uses the same firmware_id for the which
the AP has timed out.

Greybus Firmware Download Find Firmware Request
"""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-download-find-firmware-request` defines the
Greybus Firmware Download Find Firmware Request payload.  The Request
contains a 10-byte firmware_tag of the firmware package requested for
download.  This may be used by the AP in an implementation-defined way
to find the requested firmware package.

.. figtable::
    :nofig:
    :label: table-firmware-download-find-firmware-request
    :caption: Firmware Download Find Firmware Request
    :spec: l l c c l

    ======  =============  ======  ===========  ===========================
    Offset  Field          Size    Value        Description
    ======  =============  ======  ===========  ===========================
    0       firmware_tag   10      [US-ASCII]_  A null-terminated character string used to identify the firmware package.
    ======  =============  ======  ===========  ===========================
..

Greybus Firmware Download Find Firmware Response
""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-download-find-firmware-response` defines the
Greybus Firmware Download Find Firmware Response payload.  The Response
contains a one-byte firmware_id and a four-byte size of the
firmware package in bytes.

The firmware_id is unique and the same firmware_id shall not be used by
the AP in another :ref:`find-firmware-operation` Request, until the
Interface has initiated the :ref:`release-firmware-operation` with the
same firmware_id.

If the AP fails to find a firmware package for the Interface, it shall
return GB_OP_INVALID in the status byte of the Response header.

.. figtable::
    :nofig:
    :label: table-firmware-download-find-firmware-response
    :caption: Firmware Download Find Firmware Response
    :spec: l l c c l

    ======  ============  ====  ======  ===================================
    Offset  Field         Size  Value   Description
    ======  ============  ====  ======  ===================================
    0       firmware_id   1     Number  Unique firmware package identifier.
    1       size          4     Number  Size of the firmware package in bytes.
    ======  ============  ====  ======  ===================================
..

.. _fetch-firmware-operation:

Greybus Firmware Download Fetch Firmware Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Firmware Download Fetch Firmware Operation Request can be
sent only by an Interface to request the AP to provide a block of data,
from the firmware package the Interface has previously requested from
the AP.

The Interface sends to the AP the firmware_id of the firmware package,
received as part of the Find Firmware Response earlier, the offset
within the firmware package, and the size in bytes of the block of data
to fetch from the offset.

Unless the AP finds the Request to be invalid or if the AP hasn't timed
out waiting for a Fetch Firmware Request, it shall respond with exactly
the number of bytes requested by the Interface, from the firmware
package associated with the firmware_id.

The AP may consider a Request as invalid if:

- The AP couldn't associate the firmware_id sent by the Interface to an
  already requested firmware package.
- The Interface tries to read past the end of the firmware package.
- Size field in the Request is set to 0.

The Interface may send one or more Fetch Firmware Requests to receive
the firmware package.  The access to the firmware package isn't required
to be sequential and the Interface may download the firmware package in
any order.  The Interface may download a section of the firmware package
multiple times.

Greybus Firmware Download Fetch Firmware Request
""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-download-fetch-firmware-request` defines the
Greybus Firmware Download Fetch Firmware Request payload.  The Request
contains a one-byte firmware_id associated with the firmware package, a
four-byte offset within the firmware package, and a four-byte size of
the block of data requested in bytes.

The requested size must be less than or equal to the firmware size
received with the Find Firmware Response, minus the requested offset
into the firmware package.

The Interface is responsible for tracking its offset into the firmware
package as needed.

.. figtable::
    :nofig:
    :label: table-firmware-download-fetch-firmware-request
    :caption: Firmware Download Fetch Firmware Request
    :spec: l l c c l

    ======  ============  ====  ======  =================================
    Offset  Field         Size  Value   Description
    ======  ============  ====  ======  =================================
    0       firmware_id   1     Number  Unique firmware package identifier.
    1       offset        4     Number  Offset into the firmware package.
    5       size          4     Number  Size of block of data in bytes.
    ======  ============  ====  ======  =================================
..

Greybus Firmware Download Fetch Firmware Response
"""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-download-fetch-firmware-response` defines the
Greybus Firmware Download Fetch Firmware Response payload.  The Response
contains the block of data requested by the Interface.

The AP may return GB_OP_INVALID in the status byte of the Response
header, if the AP finds the Request sent by an Interface as invalid, as
described in the :ref:`fetch-firmware-operation` section.

Upon receiving a Response with status equal to GB_OP_INVALID, the
Interface may resend this Request after verifying its parameters.

The AP may return GB_OP_TIMEOUT in the status byte of the Response
header, if the AP has timed out waiting for the Fetch Firmware Request.

If this occurs, the firmware_id is no longer valid.  Upon receiving a
Response with status equal to GB_OP_TIMEOUT, the Interface shall not
send additional Fetch Firmware Requests with the same firmware_id,
unless a subsequent :ref:`find-firmware-operation` Response includes
that firmware_id.  The Interface may initiate another
:ref:`find-firmware-operation` with the same firmware_tag in order to
attempt to subsequently recover from the timeout and retrieve the same
firmware package.

.. figtable::
    :nofig:
    :label: table-firmware-download-fetch-firmware-response
    :caption: Firmware Download Fetch Firmware Response
    :spec: l l c c l

    ======  =====  ====== ======  =================================
    Offset  Field  Size   Value   Description
    ======  =====  ====== ======  =================================
    0       data   *size* Data    Block of data within the firmware package.
    ======  =====  ====== ======  =================================
..

.. _release-firmware-operation:

Greybus Firmware Download Release Firmware Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Firmware Download Release Firmware Operation Request can be
sent only by an Interface to request the AP to release a firmware
package it has requested earlier.

The Interface sends to the AP the firmware_id associated with the
firmware package, provided earlier by the AP in the response to the
:ref:`find-firmware-operation`.

Greybus Firmware Download Release Firmware Request
""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-firmware-download-release-firmware-request` defines
the Greybus Firmware Download Release Firmware Request payload.  The
Request contains a one-byte firmware_id associated with the firmware
package to be released.

.. figtable::
    :nofig:
    :label: table-firmware-download-release-firmware-request
    :caption: Firmware Download Release Firmware Request
    :spec: l l c c l

    ======  ============  ====  ======  =================================
    Offset  Field         Size  Value   Description
    ======  ============  ====  ======  =================================
    0       firmware_id   1     Number  Unique firmware package identifier.
    ======  ============  ====  ======  =================================
..

Greybus Firmware Download Release Firmware Response
"""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Firmware Download Release Firmware Response has no payload.

If the AP couldn't associate the firmware_id sent by the Interface to a
firmware package, then the AP shall return GB_OP_INVALID in the status
byte of the Response header.

If the AP has timed out waiting for the Release Firmware Request, it
shall return GB_OP_TIMEOUT in the status byte of the Response header.

On any such errors, the Interface shall do nothing as the firmware
package shall already have been released by the AP.

.. _firmware-management-protocol:

Firmware Management Protocol
----------------------------

The Firmware Management Protocol can be used by the Application
Processor (AP) to communicate with an Interface to:

- Load and Validate an :term:`Interface Firmware`
  package for an Interface.
- Prepare the Interface to enter the
  :ref:`hardware-model-lifecycle-mode-switching` :ref:`Interface
  Lifecycle State <hardware-model-lifecycle-states>`.
- Update :term:`Interface Backend Firmware` packages on an Interface.

The :term:`Interface Firmware` that
requires the capability to enter the
:ref:`hardware-model-lifecycle-mode-switching`
:ref:`Interface Lifecycle State <hardware-model-lifecycle-states>`, may
provide a CPort that implements the Firmware Management Protocol.

In order to use the Firmware Management Protocol for an Interface, the
Interface :ref:`manifest-description` received by the AP from the
Interface over the :ref:`control-protocol` shall contain a
:ref:`bundle-descriptor` with the Class Type Firmware-Management.  This
Bundle shall contain one :ref:`cport-descriptor` with the Protocol Type
Firmware-Management.

The Firmware Management Protocol shall not be used by the AP, if its
:ref:`cport-descriptor` isn't part of the :ref:`bundle-descriptor` with
the Class Type Firmware-Management.

The Firmware-Management Bundle may contain another
:ref:`cport-descriptor` with the Protocol Type SPI, if the Interface
contains a local SPI flash and the Interface Firmware running on the
Interface is designed to allow the AP to manage updates to the SPI
flash.  The AP shall communicate over this SPI CPort using the
:ref:`spi-protocol`.

The Firmware-Management Bundle may contain another
:ref:`cport-descriptor` with the Protocol Type Firmware-Download.  The
Interface Firmware may use this CPort to receive firmware packages from
the AP using the :ref:`firmware-download-protocol`.

The Firmware-Management Bundle may contain another
:ref:`cport-descriptor` with the Protocol Type Component Authentication
Protocol (CAP).  The AP may use this CPort to Authenticate the
Interface.

.. todo::
    Add Component Authentication Protocol (CAP) to Greybus
    Specifications.

The rest of this section defines the Firmware Management Protocol.

Conceptually, the Operations of the Greybus Firmware Management Protocol
are:

.. c:function:: int cport_shutdown(u8 phase);

    See :ref:`greybus-protocol-cport-shutdown-operation`.

.. note::
    Below Operations are specific to the :term:`Interface Firmware`
    for an Interface.

.. c:function:: int interface_firmware_version(u8 firmware_tag[10], u16 *major, u16 *minor);

    This Operation can be initiated only by the AP to get the
    firmware_tag and the version of the Interface Firmware currently
    running on an Interface.

.. c:function:: int interface_firmware_load_and_validate(u8 request_id, u8 load_method, u8 firmware_tag[10]);

    This Operation can be initiated only by the AP to instruct an
    Interface to load and validate an Interface Firmware package.

.. c:function:: int interface_firmware_loaded(u8 request_id, u8 status, u16 major, u16 minor);

    If the AP has requested an Interface to load an Interface Firmware
    using the :ref:`interface-firmware-load-and-validate-operation`
    earlier, then the Interface shall use this Operation to inform the
    AP once the requested Interface Firmware package is loaded and
    validated by the Interface.

.. note::
    Below Operations are specific to the :term:`Interface Backend
    Firmware` for an Interface.

.. c:function:: int interface_backend_firmware_version(u16 *major, u16 *minor, u8 *status);

    This Operation can be initiated only by the AP to get the current
    version of the Interface Backend Firmware packages available locally
    with an Interface.

.. c:function:: int interface_backend_firmware_update(u8 request_id);

    This Operation can be initiated only by the AP to request an
    Interface to update the Interface Backend Firmware packages.

.. c:function:: int interface_backend_firmware_updated(u8 request_id, u8 status);

    If the AP has requested an Interface to update an Interface Backend
    Firmware using the
    :ref:`interface-backend-firmware-update-operation` earlier, then the
    Interface shall use this Operation to inform the AP once the update
    to the Interface Backend Firmware has finished.

Greybus Firmware Management Protocol Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All Firmware Management Protocol Operations are initiated using a
Greybus Firmware Management Protocol Request message, which results in a
matching Response message.  The Request and Response messages for each
Operation are defined below.

Table :num:`table-firmware-management-operation-type` defines the
Greybus Firmware Management Protocol Operation types and their values.
Both the Request type and the Response type values are shown below.

.. figtable::
    :nofig:
    :label: table-firmware-management-operation-type
    :caption: Firmware Management Protocol Operation Types
    :spec: l l l

    =====================================  =============  =================
    Firmware Management Operation Type     Request Value  Response Value
    =====================================  =============  =================
    CPort Shutdown                         0x00           0x80
    Interface Firmware Version             0x01           0x81
    Interface Firmware Load and Validate   0x02           0x82
    Interface Firmware Loaded              0x03           0x83
    Interface Backend Firmware Version     0x04           0x84
    Interface Backend Firmware Update      0x05           0x85
    Interface Backend Firmware Updated     0x06           0x86
    (all other values reserved)            0x07..0x7e     0x87..0xfe
    Invalid                                0x7f           0xff
    =====================================  =============  =================
..

.. _firmware-management-cport-shutdown:

Greybus Firmware Management CPort Shutdown Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Firmware Management CPort Shutdown Operation is the
:ref:`greybus-protocol-cport-shutdown-operation` for the Firmware
Management Protocol.

.. _interface-firmware-version-operation:

Greybus Firmware Management Interface Firmware Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Firmware Management Interface Firmware Version Operation
Request can be sent only by the AP to an Interface.  The Interface shall
respond with the firmware_tag, and the version of the Interface Firmware
currently running on the Interface.

Greybus Firmware Management Interface Firmware Version Request
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Firmware Management Interface Firmware Version Request has
no payload.

Greybus Firmware Management Interface Firmware Version Response
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-interface-firmware-version-response` defines the
Greybus Firmware Management Interface Firmware Version Response payload.
The Response contains a 10-byte firmware_tag, and two 2-byte version
numbers, major and minor.  The firmware_tag may be used by the AP in an
implementation-defined way to identify the currently running Interface
Firmware.

.. figtable::
    :nofig:
    :label: table-interface-firmware-version-response
    :caption: Firmware Management Interface Firmware Version Response
    :spec: l l c c l

    ======  =============  ======  ===========  ===========================
    Offset  Field          Size    Value        Description
    ======  =============  ======  ===========  ===========================
    0       firmware_tag   10      [US-ASCII]_  A null-terminated character string used to identify the Interface Firmware.
    10      major          2       Number       Major version number of the currently running Interface Firmware.
    12      minor          2       Number       Minor version number of the currently running Interface Firmware.
    ======  =============  ======  ===========  ===========================
..

.. _interface-firmware-load-and-validate-operation:

Greybus Firmware Management Interface Firmware Load and Validate Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Firmware Management Interface Firmware Load and Validate
Operation Request can be sent only by the AP to an Interface.

On receiving this Request, the Interface shall respond immediately and
start loading the requested Interface Firmware package using the
specified load_method and then validate it using implementation-defined
means.  Once the Interface has loaded and validated the Interface
Firmware package or if the Interface failed to load or validate the
Interface Firmware package, it shall initiate a
:ref:`interface-firmware-loaded-operation`.

The Interface shall load at most one Interface Firmware package at a
time.  A Request to load a new Interface Firmware package may replace
the Interface Firmware package loaded earlier.

The process of validating an Interface Firmware package is
implementation-defined.

The AP sends a unique request_id to the Interface and the Interface
shall use the same request_id while sending the
:ref:`interface-firmware-loaded-operation` Request.

The AP may wait for an implementation-defined time interval, for the
Interface to initiate a :ref:`interface-firmware-loaded-operation`.  If
the AP times out waiting for it, the AP may re-initiate this Operation
with a new request_id.

If an Interface receives another Interface Firmware Load and Validate
Request with a different request_id, before it has initiated a
:ref:`interface-firmware-loaded-operation` for the earlier Load and
Validate Firmware Request, then the Interface shall abort the previous
Load and Validate Firmware Request and start servicing the new Request.

The AP may initiate this Operation any number of times.

If the AP is using the :ref:`firmware-download-protocol` to prepare an
Interface to enter the :ref:`hardware-model-lifecycle-mode-switching`
:ref:`Interface Lifecycle State <hardware-model-lifecycle-states>`, then
the AP shall initiate the :ref:`control-mode-switch` only after it has
received a successful :ref:`interface-firmware-loaded-operation` Request
from the Interface.

Greybus Firmware Management Interface Firmware Load and Validate Request
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Firmware Management Interface Firmware Load and Validate
Request contains a one-byte request_id, a one-byte load_method, which
identifies the method to be used to load the Interface Firmware, and a
10-byte firmware_tag of the Interface Firmware that is requested to be
loaded.  The firmware_tag may be used by the Interface in an
implementation-defined way to identify the requested Interface Firmware
package.

The request_id is unique and the same request_id shall not be used by
the AP in another :ref:`interface-firmware-load-and-validate-operation`
Request until the Interface has initiated a
:ref:`interface-firmware-loaded-operation` with the same request_id.

If the load_method specified in the Request is set to
FIRMWARE_LOAD_METHOD_UNIPRO, then the Interface shall receive the
Interface Firmware package using the :ref:`firmware-download-protocol`
and send the same firmware_tag value received from the AP to the
:ref:`find-firmware-operation` Request.

If load_method specified in the Request from the AP is set to
FIRMWARE_LOAD_METHOD_INTERNAL, then the Interface shall load the
Interface Firmware package available locally with the Interface, in an
implementation-defined way.

.. figtable::
    :nofig:
    :label: table-interface-firmware-load-and-validate-request
    :caption: Firmware Management Interface Firmware Load and Validate Request
    :spec: l l c c l

    ======  =============  ======  ===========  ===========================
    Offset  Field          Size    Value        Description
    ======  =============  ======  ===========  ===========================
    0       request_id     1       Number       Unique Request Identifier.
    1       load_method    1       Number       Possible values of load_method are specified in table :num:`table-interface-firmware-load-method`.
    2       firmware_tag   10      [US-ASCII]_  A null-terminated character string used to identify the Interface Firmware.
    ======  =============  ======  ===========  ===========================
..

.. figtable::
    :nofig:
    :label: table-interface-firmware-load-method
    :caption: Firmware Management Interface Firmware Load Method
    :spec: l l l

    ==============================  ===========================================  ============
    Interface Firmware Load Method  Brief Description                            Value
    ==============================  ===========================================  ============
    FIRMWARE_LOAD_METHOD_INVALID    Invalid                                      0x00
    FIRMWARE_LOAD_METHOD_UNIPRO     Load Interface Firmware package over         0x01
                                    |unipro|.
    FIRMWARE_LOAD_METHOD_INTERNAL   Load Interface Firmware package internally   0x02
                                    available to the Interface.
    |_|                             (Reserved Range)                             0x03..0xFF
    ==============================  ===========================================  ============
..

Greybus Firmware Management Interface Firmware Load and Validate Response
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Firmware Management Interface Firmware Load and Validate
Response has no payload.

.. _interface-firmware-loaded-operation:

Greybus Firmware Management Interface Firmware Loaded Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Firmware Management Interface Firmware Loaded Operation
Request can be sent only by an Interface to indicate to the AP that an
earlier :ref:`Interface Firmware Load and Validate Operation Request
<interface-firmware-load-and-validate-operation>` from the AP has
finished.

On receiving this Request, the AP may check the status byte from the
Request and compare the version of the loaded Interface Firmware with
the Interface Firmware packages available with the AP.  The AP may
subsequently choose to initiate another
:ref:`interface-firmware-load-and-validate-operation`, to load a new
Interface Firmware package.

If the AP is using the :ref:`firmware-download-protocol` to prepare an
Interface to enter the :ref:`hardware-model-lifecycle-mode-switching`
:ref:`Interface Lifecycle State <hardware-model-lifecycle-states>`, then
the AP shall initiate the :ref:`control-mode-switch` only after it has
received a successful :ref:`interface-firmware-loaded-operation` Request
from the Interface.

Greybus Firmware Management Interface Firmware Loaded Request
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Firmware Management Interface Firmware Loaded Request
contains a one-byte request_id, a one-byte status of the loaded
Interface Firmware package, a two-byte major version, a two-byte minor
version.

The value of the request_id field shall be set to the value of the
request_id field sent by the AP in the
:ref:`interface-firmware-load-and-validate-operation` Request, in
response to which the Interface is sending this Request.

If the AP has initiated another
:ref:`interface-firmware-load-and-validate-operation` before receiving a
:ref:`interface-firmware-loaded-operation` Response from the Interface
for the previous :ref:`interface-firmware-load-and-validate-operation`
Request, then the AP shall ignore the Interface Firmware Loaded Request
with the request_id matching the request_id of the first
:ref:`interface-firmware-load-and-validate-operation` Request.

.. figtable::
    :nofig:
    :label: table-interface-firmware-loaded-response
    :caption: Firmware Management Interface Firmware Loaded Response
    :spec: l l c c l

    =======  ==========  ===========  =======  ==================================================================
    Offset   Field       Size         Value    Description
    =======  ==========  ===========  =======  ==================================================================
    0        request_id  1            Number   Unique Request Identifier.
    1        status      1            Number   Status of the Interface Firmware loading and validation is
                                               defined by the table :num:`table-interface-firmware-loaded-status`
                                               and is set by the Interface in an implementation-defined way.
    2        major       2            Number   Major version number of the loaded Interface Firmware package.
    4        minor       2            Number   Minor version number of the loaded Interface Firmware package.
    =======  ==========  ===========  =======  ==================================================================
..

.. figtable::
    :nofig:
    :label: table-interface-firmware-loaded-status
    :caption: Firmware Management Interface Firmware Loaded Status
    :spec: l l l

    ===========================  ====================================  ============
    Interface Firmware Status    Brief Description                     Status Value
    ===========================  ====================================  ============
    FW_STATUS_LOAD_FAILED        Failed to Load the Interface          0x00
                                 Firmware package.
    FW_STATUS_UNVALIDATED        Loaded Interface Firmware Package     0x01
                                 is not signed.
    FW_STATUS_VALIDATED          Loaded Interface Firmware Package     0x02
                                 is signed and is validated by the
                                 Interface.
    FW_STATUS_VALIDATION_FAILED  Loaded Interface Firmware Package     0x03
                                 is signed and the Interface failed
                                 to validate it.
    |_|                          (Reserved Range)                      0x04..0xFF
    ===========================  ====================================  ============
..

Greybus Firmware Management Interface Firmware Loaded Response
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Firmware Management Interface Firmware Loaded Response has
no payload.

.. _interface-backend-firmware-version-operation:

Greybus Firmware Management Interface Backend Firmware Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The Greybus Firmware Management Interface Backend Firmware Version
Operation Request can be sent only by the AP to an Interface, to request
the version of the Interface Backend Firmware Packages available locally
with the Interface. The same version shall apply to all the Backend
Firmware Packages.

Greybus Firmware Management Interface Backend Firmware Version Request
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Firmware Management Interface Backend Firmware Version
Request has no payload.

Greybus Firmware Management Interface Backend Firmware Version Response
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-interface-backend-firmware-version-response` defines
the Greybus Firmware Management Interface Backend Firmware Version
Response payload.  The Response contains two 2-byte numbers, major and
minor, and a 1-byte status.

The major and minor numbers shall be ignored by the AP if the status
contains value other than FW_STATUS_SUCCESS.

If the Interface doesn't require any Interface Backend Firmware package
for its functioning, then the Interface shall set the status to
FW_STATUS_NOT_SUPPORTED.

If the Interface doesn't have all Interface Backend Firmware package
available with it, then it shall set the status to
FW_STATUS_NOT_AVAILABLE.

Otherwise, the Interface shall set both major and minor fields in its
Response with the major and minor version of its Interface Backend
Firmware packages.

The Interface may require some time before providing the version of the
Interface Backend Firmware packages.  This may happen, for example, if
the Interface needs to boot the Backend Device Processors before getting
the version of the available Interface Backend Firmware.  On such an
event, the Interface shall set the status to FW_STATUS_RETRY.

On receiving FW_STATUS_RETRY from the Interface, the AP may re-initiate
this Operation after an implementation-defined time interval.  The AP
may keep sending this Request until the time it receives the Interface
Backend Firmware version, or the Request fails and returns some other
error value.

.. figtable::
    :nofig:
    :label: table-interface-backend-firmware-version-response
    :caption: Firmware Management Interface Backend Firmware Version Response
    :spec: l l c c l

    =======  ==================  ===========  =======  ===========================
    Offset   Field               Size         Value    Description
    =======  ==================  ===========  =======  ===========================
    0        major               2            Number   Major version number of the Interface Backend Firmware packages.
    2        minor               2            Number   Minor version number of the Interface Backend Firmware packages.
    4        status              1            Number   Status of the Interface Backend Firmware version
                                                       operation is defined by the table
                                                       :num:`table-interface-backend-firmware-version-status`.
    =======  ==================  ===========  =======  ===========================
..

.. figtable::
    :nofig:
    :label: table-interface-backend-firmware-version-status
    :caption: Firmware Interface Backend Firmware Version Status
    :spec: l l l

    ========================  ===========================================  ==========
    Update Status             Brief Description                            Value
    ========================  ===========================================  ==========
    FW_STATUS_INVALID         Invalid Status.                              0x00
    FW_STATUS_SUCCESS         Firmware version successfully retrieved.     0x01
    FW_STATUS_NOT_AVAILABLE   Firmware not available.                      0x02
    FW_STATUS_NOT_SUPPORTED   No Backend Firmware is required for
                              functioning of Interface.                    0x03
    FW_STATUS_RETRY           Not ready to respond currently, retry.       0x04
    FW_STATUS_FAIL_INTERNAL   Failed due to internal errors.               0x05
    |_|                       (Reserved Range)                             0x06..0xFF
    ========================  ===========================================  ==========

..

.. _interface-backend-firmware-update-operation:

Greybus Firmware Management Interface Backend Firmware Update Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Firmware Management Interface Backend Firmware Update
Operation Request can be sent only by the AP to request an Interface, to
update the Interface Backend Firmware packages.

The Interface shall update all the Interface Backend Firmware packages.

If the Interface can not service the Interface Backend Firmware Update
Request or if the Interface doesn't require any Interface Backend
Firmware for its functioning, then it shall send GB_OP_INVALID in the
status field of the Response header.

Otherwise, the Interface shall immediately respond to this Request and
start downloading the Interface Backend Firmware packages from the AP,
in any order it finds suitable.

If the Interface is designed to use the
:ref:`firmware-download-protocol` for downloading firmware packages,
then it shall contain a :ref:`cport-descriptor` with the Protocol Type
Firmware-Download in its :ref:`bundle-descriptor` whose Class Type is
Firmware-Management, in the Interface :ref:`manifest-description` sent
to the AP.

The rest of this section uses the :ref:`firmware-download-protocol` as
the Interface Backend Firmware download method.  The Interface may
choose another implementation-defined method for receiving the Interface
Backend Firmware packages.

Once the specific Interface Backend Firmware package is updated on the
Interface, the Interface shall initiate a
:ref:`interface-backend-firmware-updated-operation`.

The AP sends a unique request_id to the Interface and the Interface
shall use the same request_id while sending the
:ref:`interface-backend-firmware-updated-operation` Request.

The same request_id shall not be used by the AP in another
:ref:`interface-backend-firmware-update-operation` Request until the
Interface has initiated a
:ref:`interface-backend-firmware-updated-operation` with the same
request_id.

The AP may wait for an implementation-defined time interval, for the
Interface to initiate a
:ref:`interface-backend-firmware-updated-operation`.  In case the AP
times out waiting for it, the AP may re-initiate this Operation with a
different request_id.

If the Interface receives another Interface Backend Firmware Update
Request before it has initiated a
:ref:`interface-backend-firmware-updated-operation` for the earlier
Interface Backend Firmware Update Request, the Interface shall abort the
previous Interface Backend Firmware Update Request and start servicing
the new Request.

The Module can download Interface Backend Firmware packages in parallel
on receiving this request.

Greybus Firmware Management Interface Backend Firmware Update Request
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-interface-backend-firmware-update-request` defines the
Greybus Firmware Management Interface Backend Firmware Update Request
payload.  The Request contains a one-byte request_id.

The request_id is unique and the same request_id shall not be used by
the AP in another :ref:`interface-backend-firmware-update-operation`
Request until the Interface has initiated a
:ref:`interface-backend-firmware-updated-operation` with the same
request_id.

.. figtable::
    :nofig:
    :label: table-interface-backend-firmware-update-request
    :caption: Firmware Management Interface Backend Firmware Update Request
    :spec: l l c c l

    ======  =============  ======  ===========  ===========================
    Offset  Field          Size    Value        Description
    ======  =============  ======  ===========  ===========================
    0       request_id     1       Number       Unique Request Identifier.
    ======  =============  ======  ===========  ===========================
..

Greybus Firmware Management Interface Backend Firmware Update Response
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Firmware Management Interface Backend Firmware Update
Response has no payload.

.. _interface-backend-firmware-updated-operation:

Greybus Firmware Management Interface Backend Firmware Updated Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Firmware Management Interface Backend Firmware Updated
Operation Request can be send only by an Interface to inform the AP that
the Interface Backend Firmware update to a specific Interface Backend
Firmware package has finished.  This shall be sent by the Interface
after it has downloaded the requested Interface Backend Firmware package
using the :ref:`firmware-download-protocol` and updated it internally in
an implementation-defined way.

The Interface shall also initiate this Operation if it has failed to
update the requested Interface Backend Firmware package.  It shall
specify the reason of the failure in the status field of the Request.

The AP may initiate another
:ref:`interface-backend-firmware-update-operation` now.

Greybus Firmware Management Interface Backend Firmware Updated Request
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-interface-backend-firmware-updated-request` defines
the Greybus Firmware Management Interface Backend Firmware Updated
Request payload.  The Request contains a one-byte request_id, and a
one-byte status of the Firmware update.

The value of the request_id field shall be set to the value of the
request_id field sent by the AP in the
:ref:`interface-backend-firmware-update-operation` Request, in response
to which the Interface is sending this Request.

If the AP initiates another
:ref:`interface-backend-firmware-update-operation` before receiving a
:ref:`interface-backend-firmware-updated-operation` Request from the
Interface for the previous
:ref:`interface-backend-firmware-update-operation` Request, then the AP
shall ignore the Interface Backend Firmware Updated Request with the
request_id matching the request_id of the first
:ref:`interface-backend-firmware-update-operation` Request.

.. figtable::
    :nofig:
    :label: table-interface-backend-firmware-updated-request
    :caption: Firmware Management Interface Backend Firmware Updated Request
    :spec: l l c c l

    ======  =============  ======  ===========  ===================================================================
    Offset  Field          Size    Value        Description
    ======  =============  ======  ===========  ===================================================================
    0       request_id     1       Number       Unique Request Identifier.
    1       status         1       Number       Status of the Interface Backend Firmware update is defined by the
                                                table :num:`table-interface-backend-firmware-update-status` and
                                                is set by the Interface in an implementation-defined way.
    ======  =============  ======  ===========  ===================================================================
..

.. figtable::
    :nofig:
    :label: table-interface-backend-firmware-update-status
    :caption: Firmware Interface Backend Firmware Update Status
    :spec: l l l

    ========================  ===========================================  ==========
    Update Status             Brief Description                            Value
    ========================  ===========================================  ==========
    FW_STATUS_INVALID         Invalid Status.                              0x00
    FW_STATUS_SUCCESS         Interface Backend Firmware package           0x01
                              successfully updated.
    FW_STATUS_FAIL_FIND       Failed to find Interface Backend Firmware    0x02
                              package.
    FW_STATUS_FAIL_FETCH      Failed to fetch Interface Backend Firmware   0x03
                              package.
    FW_STATUS_FAIL_WRITE      Failed to write downloaded Interface         0x04
                              Backend Firmware package.
    FW_STATUS_FAIL_INTERNAL   Failed due to internal errors.               0x05
    FW_STATUS_RETRY           Not ready to respond currently, retry.       0x06
    FW_STATUS_NOT_SUPPORTED   No Backend Firmware is required for
                              functioning of Interface.                    0x07
    |_|                       (Reserved Range)                             0x08..0xFF
    ========================  ===========================================  ==========

..

Greybus Firmware Management Interface Backend Firmware Updated Response
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Firmware Interface Backend Firmware Updated Response has no
payload.
