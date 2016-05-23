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
.. include:: device_class/audio.txt
.. include:: device_class/hid.txt
.. include:: device_class/lights.txt
.. include:: device_class/loopback.txt
.. include:: device_class/raw.txt

