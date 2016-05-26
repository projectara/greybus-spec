.. highlight:: text

Firmware Lifecycle on ARA Phone Module (Informative)
====================================================

This appendix describes the Firmware Lifecycle on an ARA Phone Module's
Interface, that includes a bridge ASIC to communicate to the |unipro|
network.  The term 'Interface' will be used by rest of this section for
such an ARA Phone Module's Interface.

Firmware Types and Protocols
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Firmware images required for an Interface can be classified broadly into
two categories:

- :ref:`Interface Firmware <glossary-interface-firmware>`

  These are the Firmware Images that run on the bridge ASIC present on
  the ARA Phone Module.

- :ref:`Interface Backend Firmware <glossary-interface-backend-firmware>`

  These are the Firmware Images that run on a Device Processor sitting
  behind the bridge ASIC, for example Camera.

The term Mode-Switch will be used by rest of this section, for referring
to transition from one Interface Firmware Image to another Interface
Firmware Image for an Interface using the
:ref:`control-mode-switch`.

The :ref:`firmware-download-protocol` can be used by an Interface to
download Firmware Packages over |unipro|.

The :ref:`firmware-management-protocol` can be used by the Application
Processor (AP) to prepare the Interface State to enter MODE_SWITCHING
Interface Lifecycle State.  The Firmware Management Protocol can also be
used by the AP to update the Interface Backend Firmware Images for an
Interface.

Ideally, every Interface Firmware Stage for the Interface shall contain
a CPort for Firmware Management Protocol.  Without that, the firmware
wouldn't be able to load another firmware and boot into it.

ARA Boot Stages
~~~~~~~~~~~~~~~

The current design of Interface Firmware stages for an Interface on ARA
Phone forces the Interface to have three or four stages:

- boot ROM (Stage 1 or S1)
- Stage 2 Loader (S2L)
- Stage 3 Firmware (S3F)
- Stage 3 Backend Firmware Updater (S3-BFU, Used for updating backend
  device processor firmware packages).


One of the main purpose of the S2 Loader stage is to get the Interface
hardware Authenticated.  For security reasons, the AP may want to verify
if a connected Module is authorized by Google to be part of the ARA
phone.  The AP and the Interface takes part in the Authentication dialog
using the Component Authentication Protocol (CAP).  The AP sends a CAP
Message to the Interface which contains a cryptographically
unpredictable message.  The Interface decodes the same using a set of
private keys burned into the Interface at the time of Manufacturing.
Only an Authorized Interface Firmware can read these keys and get the
Module authenticated.

.. todo::
    Add Component Authentication Protocol (CAP) to Greybus
    Specifications.

The Backend Device Processors can only be made functional while the
current Interface Firmware stage is S3F or S3-BFU, as the S2 Loader
doesn't have any knowledge of the Backed Device Processors and it can't
talk to them.

The Interface Firmware stages shall have the capability to Mode-Switch
from:

- boot ROM to Stage 2 Loader (For future boot-ROMs only, boot ROM of ES3
  chips is fixed as the chip is already taped out).
- Stage 2 Loader to another Stage 2 Loader Firmware Image (If S2L is
  updated).
- Stage 2 Loader to Stage 3 Interface Firmware.
- Stage 3 Interface Firmware to Stage 3 Backend Firmware Updater.
- Stage 3 Backend Firmware Updater to Stage 3 Interface Firmware.

Interface Manifest Layout
~~~~~~~~~~~~~~~~~~~~~~~~~

This section describes how the Interface :ref:`manifest-description`
received by the AP from an Interface over :ref:`control-protocol` shall
look like, in order to support Mode-Switch and updates to Interface
Backend Firmware Packages.

The Manifest may contain other Bundles and CPorts as well, like Control
CPort, etc..

Firmware Management Bundle (Bundle 1):

- class = 0x16
- (Mandatory) Firmware Management Protocol on CPort 1 talks over :ref:`firmware-management-protocol`.

  - protocol = 0x18

- (Optional) Firmware Download Protocol on CPort 2 talks over :ref:`firmware-download-protocol`.

  - protocol = 0x17

- (Optional) SPI Protocol on CPort 3 talks over :ref:`spi-protocol`.

  - protocol = 0x0b

- (Optional) Component Authentication Protocol (CAP) on CPort 4 talks over CAP Protocol :ref:`auth-protocol`.

  - protocol = 0x19

Identify Current Interface Firmware Stage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Android userspace or the kernel running on the AP may be required to do
different things based on the current Firmware Stage of an Interface.
For example, in S2L stage, the AP may Authenticate the Interface using
CAP Protocol or update bridge ASIC's SPI flash using SPI Protocol, etc..

And so can be quite useful for the AP to know the current implementation
defined Interface Firmware Stage.

This can be retrieved by the AP from the Interface using
:ref:`interface-firmware-version-operation`.  The Interface shall return
an implementation defined "firmware_tag" to the AP, which can be used by
the AP to know the current boot stage.  For example, in the current
implementation we can keep its values as "s2l", "s3f", "s3-bfu".

.. _prepare-to-mode-switch:

Prepare an Interface Firmware to enter MODE_SWITCHING Lifecycle State
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The AP may want to Mode Switch to another Interface Firmware Stage.  For
that it first needs to ask the Interface to load and validate the next
stage Firmware package.  Following sequence of events describes how that
can be achieved to Mode-Switch from S2L to S3F Interface Firmware stage,
by first downloading the Firmware Package over |unipro|.

- The AP initiates a
  :ref:`interface-firmware-load-and-validate-operation` over Firmware
  Management CPort and passes request-id as '1', firmware-tag as "s3f",
  and load-method as FIRMWARE_LOAD_METHOD_UNIPRO.
- The Interface responds to the request from the AP immediately and
  initiates a :ref:`find-firmware-operation` request over Firmware
  Download CPort and passes it the firmware-tag received from the AP in
  Load and Validate Operation.
- The AP finds the requested firmware package and responds with
  GB_OP_SUCCESS in the status of the response header and provides
  firmware size as 16380 bytes and unique firmware-ID as 0x05.
- The Interface initiates a number of :ref:`Fetch Firmware Operations
  <fetch-firmware-operation>` using firmware-ID 0x05 and loads the
  entire firmware package block by block.
- The Interface initiates a :ref:`release-firmware-operation` using
  firmware-ID 0x05 to request the AP to release the firmware.
- The Interface parses the firmware image header and validates its
  signature in an implementation defined way.
- The Interface initiates a :ref:`interface-firmware-loaded-operation`
  to the AP and passes the request-id as '1' (same as that received from
  the AP), status of validation and major/minor version of the loaded
  firmware.
- The AP finds that the Interface has verified the signatures of the
  Interface Firmware Package.
- The Interface has an Interface Firmware Package with now and needs to
  Mode Switch into that.
- The AP starts tearing down of the connections and issue a
  :ref:`control-mode-switch`.

Update S2L and S3F in bridge ASIC's SPI Flash
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Lets consider that the Interface is running its S3F stage currently.
Following sequence of events will lead to updating Images in the bridge
ASIC SPI flash.

- Android receives a MSP update for the Interface and downloads it from
  Android Play-store (or whatever).
- AP receives the current Interface Firmware version using
  :ref:`interface-firmware-version-operation`.
- AP compares that to the version of the firmware it has downloaded and
  decides if an update is required or not.
- If an update is required, the AP prepares the Interface to Mode Switch
  into S2L Firmware Stage as described in the
  :ref:`prepare-to-mode-switch` section.
- Once the AP has Mode-Switched to S2L Firmware Stage, the AP will get
  an additional SPI CPort and the AP can update the SPI flash using
  :ref:`spi-protocol`.
- If the S2 Loader firmware is also updated, and then we may need to
  Mode-Switch to the new S2L Firmware Image first, which will eventually
  Mode-Switch into the S3F.  Otherwise, we can directly Mode-Switch from
  old S2L to the S3F Image.  All Mode-Switch operations can be done as
  defined in :ref:`prepare-to-mode-switch` section.

Update Device Processor Firmware Images
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is perhaps the most complicated of all the use cases we may have.

Consider that the bridge ASIC is running its S3F Interface Firmware
Stage and the device processors are running their respective firmware
images.

Following sequence of events will lead to updating device firmware
images.

- The AP receives the version of the individual Device Processor
  Firmware Images using
  :ref:`interface-backend-firmware-version-operation` over the Firmware
  Management CPort.
- If the AP finds at least one Device Processor firmware image that
  needs update, it Mode-Switches the Interface to S3-BFU Interface
  Firmware Stage as described in :ref:`prepare-to-mode-switch` section.
- This is important to guarantee that the Interface and its device
  processors aren't being used by the AP concurrently while the update
  in progress.
- During the above Mode Switch, the Device Processors aren't required to
  be reseted as power to them is never cut-off on Mode Switch, but this
  is going to be implementation defined really.
- The new Interface personality provided by the S3-BFU will only contain
  the CPorts necessary for firmware update, i.e. Firmware Management
  CPort and Firmware Download CPort.
- Once the S3-BFU Interface Firmware Stage has booted, the AP (again)
  starts again matching versions of all the backend device processor
  firmwares using :ref:`interface-backend-firmware-version-operation`
  over the Firmware Management CPort, as it may not have cached them
  earlier.
- As soon as a mismatch in version is found between the backend firmware
  on the Interface and the version available with the AP, the AP starts
  updating them by issuing
  :ref:`interface-backend-firmware-update-operation` requests over the
  Firmware Management CPort.
- On receiving these requests, S3-BFU Interface Firmware Stage will
  immediately respond to the AP and start downloading the specific
  backend device processor firmware using
  :ref:`firmware-download-protocol` as explained earlier.
- Once the individual device processor firmware is downloaded by the
  bridge ASIC, it will flash that to the internal flash memory in an
  implementation dependent way and send a
  :ref:`interface-backend-firmware-updated-operation`.
- Similarly all the device processor firmware images, that the AP wants
  to update or reflash, can be updated.
- Now the AP needs to Mode-Switch the Interface to normal S3F Interface
  Firmware Stage personality as described in
  :ref:`prepare-to-mode-switch` section.
