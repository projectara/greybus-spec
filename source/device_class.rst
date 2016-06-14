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

.. toctree::
    :maxdepth: 2

    device_class/audio.rst
    device_class/camera.rst
    device_class/component_authentication.rst
    device_class/firmware.rst
    device_class/hid.rst
    device_class/lights.rst
    device_class/loopback.rst
    device_class/power.rst
    device_class/raw.rst
    device_class/vibrator.rst

