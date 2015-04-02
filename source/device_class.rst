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

Vibrator Protocol
-----------------

This section defines the operations used on a connection implementing
the Greybus vibrator Protocol.  This Protocol allows an AP Module to manage
a vibrator device present on a Module.  The Protocol is very simple,
and maps almost directly to the Android HAL vibrator interface.

The operations in the Greybus vibrator Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the Protocol used for
    communication over the connection.  The sender offers the
    version of the Protocol it supports.  The receiver replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the Protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

.. c:function:: int vibrator_on(u16 timeout_ms);

   Turns on the vibrator for the number of specified milliseconds.

.. c:function:: int vibrator_off(void);

    Turns off the vibrator immediately.

Greybus Vibrator Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-vibrator-operation-type` describes the Greybus
vibrator operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-vibrator-operation-type
    :caption: Vibrator Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Vibrator Operation Type      Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Vibrator On                  0x02           0x82
    Vibrator Off                 0x03           0x83
    (all other values reserved)  0x04..0x7f     0x84..0xff
    ===========================  =============  ==============

Greybus Vibrator Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus vibrator Protocol version operation allows the Protocol
handling software on both ends of a connection to negotiate the
version of the vibrator Protocol to use.

Greybus Vibrator Protocol Version Request
"""""""""""""""""""""""""""""""""""""""""

Table :num:`table-vibrator-version-request` defines the Greybus vibrator
version request payload. The request supplies the greatest major and
minor version of the vibrator Protocol supported by the sender.

.. figtable::
    :nofig:
    :label: table-vibrator-version-request
    :caption: Vibrator Protocol Version Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Offered vibrator Protocol major version
    1        version_minor   1       |gb-minor|      Offered vibrator Protocol minor version
    =======  ==============  ======  ==========      ===========================

Greybus Vibrator Protocol Version Response
""""""""""""""""""""""""""""""""""""""""""

The Greybus vibrator Protocol version response payload contains two
one-byte values, as defined in table
:num:`table-vibrator-protocol-version-response`.
A Greybus vibrator controller adhering to the Protocol specified herein
shall report major version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-vibrator-protocol-version-response
    :caption: Vibrator Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Vibrator Protocol major version
    1        version_minor   1       |gb-minor|      Vibrator Protocol minor version
    =======  ==============  ======  ==========      ===========================

Greybus Vibrator On Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus vibrator on operation allows the AP Module to request the
vibrator be enabled for the specified number of milliseconds.

Greybus Vibrator On Request
"""""""""""""""""""""""""""

Table :num:`table-vibrator-on-request` defines the Greybus Vibrator
On request.  The request supplies the amount of time that the
vibrator should now be enabled for.

.. figtable::
    :nofig:
    :label: table-vibrator-on-request
    :caption: Vibrator Protocol On Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        timeout_ms      2       Number          timeout in milliseconds
    =======  ==============  ======  ==========      ===========================

Greybus Vibrator On Response
""""""""""""""""""""""""""""

The Greybus vibrator on response message has no payload.

Greybus Vibrator Off Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Vibrator off operation allows the AP Module to request the
vibrator be turned off as soon as possible.

Greybus Vibrator Off Request
""""""""""""""""""""""""""""

The Greybus vibrator off request message has no payload.

Greybus Vibrator Off Response
"""""""""""""""""""""""""""""

The Greybus vibrator off response message has no payload.

Battery Protocol
----------------

This section defines the operations used on a connection implementing
the Greybus battery Protocol. This Protocol allows an AP Module to manage a
battery device present on a Module. The Protocol consists of few basic
operations, whose request and response message formats are defined
here.

Conceptually, the operations in the Greybus battery Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the Protocol used for
    communication over the connection.  The sender offers the
    version of the Protocol it supports.  The receiver replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the Protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

.. c:function:: int get_technology(u16 *technology);

    Returns a value indicating the technology type that this battery
    adapter controls.

.. c:function:: int get_status(u16 *status);

    Returns a value indicating the charging status of the battery.

.. c:function:: int get_max_voltage(u32 *voltage);

    Returns a value indicating the maximum voltage that the battery supports.

.. c:function:: int get_percent_capacity(u32 *capacity);

    Returns a value indicating the current percent capacity of the
    battery.

.. c:function:: int get_temperature(u32 *temperature);

    Returns a value indicating the current temperature of the battery.

.. c:function:: int get_voltage(u32 *voltage);

    Returns a value indicating the voltage level of the battery.

.. c:function:: int get_current(u32 *current);

    Returns a value indicating the current being supplied or drawn
    from the battery.

.. c:function:: int get_total_capacity(u32 *capacity);

    Returns a value indicating the total capacity in mAh of the battery.

.. c:function:: int get_shutdown_temperature(u32 *temperature);

    Returns a value indicating the temperature at which a battery
    will automatically shut down.

Greybus Battery Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-battery-operation-type` describes the Greybus
battery operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-battery-operation-type
    :caption: Battery Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Battery Operation Type       Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Technology                   0x02           0x82
    Status                       0x03           0x83
    Max Voltage                  0x04           0x84
    Percent Capacity             0x05           0x85
    Temperature                  0x06           0x86
    Voltage                      0x07           0x87
    Current                      0x08           0x88
    Capacity mAh                 0x09           0x89
    Shutdown Temperature         0x0a           0x8a
    (all other values reserved)  0x0b..0x7f     0x8b..0xff
    ===========================  =============  ==============

Greybus Battery Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery Protocol version operation allows the Protocol
handling software on both ends of a connection to negotiate the
version of the battery Protocol to use.

Greybus Battery Protocol Version Request
""""""""""""""""""""""""""""""""""""""""

Table :num:`table-battery-version-request` defines the Greybus battery
version request payload. The request supplies the greatest major and
minor version of the battery Protocol supported by the sender.

.. figtable::
    :nofig:
    :label: table-battery-version-request
    :caption: Battery Protocol Version Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Offered battery Protocol major version
    1        version_minor   1       |gb-minor|      Offered battery Protocol minor version
    =======  ==============  ======  ==========      ===========================


Greybus Battery Protocol Version Response
"""""""""""""""""""""""""""""""""""""""""

The Greybus battery Protocol version response payload contains two
one-byte values, as defined in table
:num:`table-battery-protocol-version-response`.
A Greybus battery controller adhering to the Protocol specified herein
shall report major version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-battery-protocol-version-response
    :caption: Battery Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Battery Protocol major version
    1        version_minor   1       |gb-minor|      Battery Protocol minor version
    =======  ==============  ======  ==========      ===========================

Greybus Battery Technology Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery technology operation allows the AP Module to determine
the details of the battery technology controller by the battery
adapter.

Greybus Battery Technology Request
""""""""""""""""""""""""""""""""""

The Greybus battery technology request message has no payload.

Greybus Battery Technology Response
"""""""""""""""""""""""""""""""""""

The Greybus battery technology response contains a 2-byte value
that represents the type of battery being controlled as defined in
Table :num:`table-battery-technology-response`.

.. figtable::
    :nofig:
    :label: table-battery-technology-response
    :caption: Battery Technology Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        technology      2       Number          :ref:`battery-technology-type`
    =======  ==============  ======  ==========      ===========================

.. _battery-technology-type:

Greybus Battery Technology Type
"""""""""""""""""""""""""""""""

Table :num:`table-battery-tech-type` describes the defined battery
technologies defined for Greybus battery adapters.  These values are
taken directly from the <linux/power_supply.h> header file.

.. figtable::
    :nofig:
    :label: table-battery-tech-type
    :caption: Battery Technology Type
    :spec: l l

    =============   ======
    Battery Type    Value
    =============   ======
    Unknown         0x0000
    NiMH            0x0001
    LION            0x0002
    LIPO            0x0003
    LiFe            0x0004
    NiCd            0x0005
    LiMn            0x0006
    =============   ======

Greybus Battery Status Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery status operation allows the AP Module to determine the
status of the battery by the battery adapter.

Greybus Battery Status Request
""""""""""""""""""""""""""""""

The Greybus battery status request message has no payload.

Greybus Battery Status Response
"""""""""""""""""""""""""""""""

The Greybus battery status response contains a 2-byte value that
represents the status of battery being controlled as defined in
table :num:`table-battery-status-response`.

.. figtable::
    :nofig:
    :label: table-battery-status-response
    :caption: Battery Status Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        battery_status  2       Number          :ref:`battery-status`
    =======  ==============  ======  ==========      ===========================

.. _battery-status:

Greybus Battery Status Type
"""""""""""""""""""""""""""

Table :num:`table-battery-status-type` describes the defined battery
status values defined for Greybus battery adapters.  These values are
taken directly from the <linux/power_supply.h> header file.

.. figtable::
    :nofig:
    :label: table-battery-status-type
    :caption: Battery Status Type
    :spec: l l

    ==============  ======
    Battery Status  Value
    ==============  ======
    Unknown         0x0000
    Charging        0x0001
    Discharging     0x0002
    Not Charging    0x0003
    Full            0x0004
    ==============  ======

Greybus Battery Max Voltage Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery Max Voltage operation allows the AP Module to determine
the maximum possible voltage of the battery.

Greybus Battery Max Voltage Request
"""""""""""""""""""""""""""""""""""

The Greybus battery max voltage request message has no payload.

Greybus Battery Max Voltage Response
""""""""""""""""""""""""""""""""""""

The Greybus battery max voltage response contains a 4-byte value
that represents the maximum voltage of the battery being controlled,
in |mu| V as defined in table :num:`table-battery-max-voltage-response`.

.. figtable::
    :nofig:
    :label: table-battery-max-voltage-response
    :caption: Battery Max Voltage Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        max_voltage     4       Number          Battery maximum voltage in |mu| V
    =======  ==============  ======  ==========      ===========================

Greybus Battery Capacity Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery Capacity operation allows the AP Module to determine the
current capacity percent of the battery.

Greybus Battery Percent Capacity Request
""""""""""""""""""""""""""""""""""""""""

The Greybus battery capacity request message has no payload.

Greybus Battery Percent Capacity Response
"""""""""""""""""""""""""""""""""""""""""

The Greybus battery capacity response contains a 4-byte value that
represents the capacity of the battery being controlled, in
percentage as defined in table
:num:`table-battery-percent-capacity-response`.

.. figtable::
    :nofig:
    :label: table-battery-percent-capacity-response
    :caption: Battery Percent Capacity Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        capacity        4       Number          Battery capacity in %
    =======  ==============  ======  ==========      ===========================

Greybus Battery Temperature Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery temperature operation allows the AP Module to determine
the current temperature of the battery.

Greybus Battery Temperature Request
"""""""""""""""""""""""""""""""""""

The Greybus battery temperature request message has no payload.

Greybus Battery Temperature Response
""""""""""""""""""""""""""""""""""""

The Greybus battery temperature response contains a 4-byte value
that represents the temperature of the battery being controlled, in
0.1 |degree-c| increments as defined in table
:num:`table-battery-temp-response`.

.. figtable::
    :nofig:
    :label: table-battery-temp-response
    :caption: Battery Temperature Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        temperature     4       Number          Battery temperature (0.1 |degree-c| units)
    =======  ==============  ======  ==========      ===========================

Greybus Battery Voltage Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery Voltage operation allows the AP Module to determine the
voltage being supplied by the battery.

Greybus Battery Voltage Request
"""""""""""""""""""""""""""""""

The Greybus battery voltage request message has no payload.

Greybus Battery Voltage Response
""""""""""""""""""""""""""""""""

The Greybus battery voltage response contains a 4-byte value that
represents the voltage of the battery being controlled, in |mu| V as
defined in table
:num:`table-battery-voltage-response`.

.. figtable::
    :nofig:
    :label: table-battery-voltage-response
    :caption: Battery Voltage Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        voltage         4       Number          Battery voltage in |mu| V
    =======  ==============  ======  ==========      ===========================

Greybus Battery Current Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery Current operation allows the AP Module to determine the
current current of the battery.

Greybus Battery Current Request
"""""""""""""""""""""""""""""""

The Greybus battery current request message has no payload.

Greybus Battery Current Response
""""""""""""""""""""""""""""""""

The Greybus battery current response contains a 4-byte value that
represents the current of the battery being controlled, in |mu| A as
defined in table :num:`table-battery-current-response`.

.. figtable::
    :nofig:
    :label: table-battery-current-response
    :caption: Battery Current Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        current         4       Number          Battery current in |mu| A
    =======  ==============  ======  ==========      ===========================

Greybus Battery Total Capacity Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery total capacity operation allows the AP Module to determine
the total capacity of the battery.

Greybus Battery Total Capacity Request
""""""""""""""""""""""""""""""""""""""

The Greybus battery total capacity request message has no payload.

Greybus Battery Total Capacity Response
"""""""""""""""""""""""""""""""""""""""
The Greybus battery total capacity response contains a 4-byte value
that represents the total capacity of the battery being controlled,
in mAh as defined in table :num:`table-battery-total-capacity-response`.

.. figtable::
    :nofig:
    :label: table-battery-total-capacity-response
    :caption: Battery Total Capacity Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        capacity        4       Number          Battery capacity in mAh
    =======  ==============  ======  ==========      ===========================

Greybus Battery Shutdown Temperature Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The Greybus battery shutdown temperature operation allows the AP Module to
determine the battery temperature at which the battery will shut
itself down.

Greybus Battery Shutdown Temperature Request
""""""""""""""""""""""""""""""""""""""""""""

The Greybus battery shutdown temperature request message has no payload.

Greybus Battery Shutdown Temperature Response
"""""""""""""""""""""""""""""""""""""""""""""
The Greybus battery shutdown temperature response contains a 4-byte
value that represents the temperature at which the battery shuts
down as defined in table :num:`table-battery-shutdown-temp-response`.

.. figtable::
    :nofig:
    :label: table-battery-shutdown-temp-response
    :caption: Battery Shutdown Temperature Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        temperature     4       Number          Battery temperature (0.1 |degree-c| units)
    =======  ==============  ======  ==========      ===========================

Audio Protocol
--------------

TBD

Baseband Modem Protocol
-----------------------

TBD

Bluetooth Protocol
------------------

TBD

Consumer IR Protocol
--------------------

TBD

Display Protocol
----------------

TBD

GPS Protocol
------------

TBD

HID Protocol
------------

This section defines the operations used on a connection implementing
the Greybus Human Interface Device (HID) Protocol. The HID class is
used primarily for devices that take input from humans or may give
output to humans.  Typical examples of HID class devices include:

* Keyboards and pointing devices
* Front panel controls, like: knobs, buttons, switches, etc.
* Steering wheels, rudder pedals found on gaming devices.
* Buttons, touchscreen found on phones.
* Bar-code readers, thermometers, or voltmeters.

The Greybus HID Protocol uses *descriptors* and *reports* to
interact with a HID device.  A HID Descriptor defines all
capabilities of a HID device.   Before exchanging data with
a HID device, the AP Module can configure a HID device based on
these capabilities by sending Feature Reports.  Data exchange
between the AP Module and a HID device are implemented by
sending Input or Output Reports.

This document focuses on how the HID protocol is implemented over
Greybus.  The HID Protocol (as implemented over USB) is well defined
by [HID01]_.

Greybus HID Descriptors
^^^^^^^^^^^^^^^^^^^^^^^
The following section identifies the key data structures (referred to as
HID Descriptors) that need to be exchanged between the host and the device
during initialization.

.. _hid-descriptor:

HID Descriptor
""""""""""""""
The HID Descriptor is the top-level mandatory descriptor that every Greybus
based HID device must have. The purpose of the HID Descriptor is to
define all capabilities of the HID device with the host. These
attributes describe the version of the HID Protocol the HID device
is compliant with, the length of HID Descriptors, and other
capabilities of the device. Please refer to Table
:num:`table-hid-descriptor` for further details.

HID Report Descriptor
"""""""""""""""""""""
A HID Report Descriptor describes the data generated by the HID
device, and how to interpret that data. Details of the HID Report
Descriptor are outside of the scope of this document and are defined
in [HID01]_.

HID Report Protocol
^^^^^^^^^^^^^^^^^^^
The Report is the fundamental block exchanged between the host and the device.
Reports are well defined by [HID01]_, and the the same will be followed here.

HID Input Report
""""""""""""""""
The input reports are generated on the device and are sent from device to host.
This can be requested synchronously or asynchronously.

In the asynchronous case, when the device has active data it wishes to report to
the host, it will generate an data request towards the host. When the host
receives the receive request, it is responsible for reading the data from the
receive request.

In the synchronous case, the host can generate a get-report request to HID
device, in response to which the device must respond with data.

HID Output Report
"""""""""""""""""
The output report is generated on the host and is sent from host to device over
the Greybus transport. When the host has active data it wishes to report to the
device, it must generate a set-report request.

HID Feature Report
""""""""""""""""""
The feature report is a bidirectional report and can be exchanged between the
host and the device. They are normally used by the host to program the device
into different configurations.

For the host to get/set a feature-report on the device, it must use the
get-report and set-report requests described later.

Greybus HID Operations
^^^^^^^^^^^^^^^^^^^^^^

Greybus HID Protocol allows an AP to manage a HID device present on a module.
The Protocol consists of few basic operations, whose request and response
message formats are defined here.

Conceptually, the operations in the greybus HID Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the Protocol used for
    communication over the connection. The sender offers the version of the
    Protocol it supports. The receiver replies with the version that will be
    used--either the one offered if supported or its own (lower) version
    otherwise. Protocol handling code adhering to the Protocol specified herein
    supports major version |gb-major|, minor version |gb-minor|.

.. c:function:: int get_descriptor(struct gb_hid_desc_response *desc);

    Returns :ref:`hid-descriptor`, that specifies details of the HID device.

.. c:function:: int get_report_descriptor(u8 *report_desc);

    Returns a HID Report Descriptor, defined by [HID01]_.

.. c:function:: int power_on(void);

    Power-on the HID device.

.. c:function:: int power_off(void);

    Power-off the HID device.

.. c:function:: int get_report(u8 *report);

    Gets input or feature report from device to host synchronously.

.. c:function:: int set_report(u8 *report);

    Sets output or feature report from host to device synchronously.

.. c:function:: int irq_event(u8 *report);

    Input report sent from device to host asynchronously.

Greybus HID Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-hid-operation-type` describes the Greybus HID operation types
and their values. A message type consists of an operation type combined with a
flag (0x80) indicating whether the operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-hid-operation-type
    :caption: HID Operation Types
    :spec: l l l

    ===========================  =============  ==============
    HID Operation Type           Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Get Descriptor               0x02           0x82
    Get Report Descriptor        0x03           0x83
    Power On                     0x04           0x84
    Power Off                    0x05           0x85
    Get Report                   0x06           0x86
    Set Report                   0x07           0x87
    IRQ Event                    0x08           0x88
    (all other values reserved)  0x09..0x7f     0x89..0xff
    ===========================  =============  ==============

Greybus HID Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus HID Protocol version operation allows the Protocol handling software
on both ends of a connection to negotiate the version of the Greybus HID
Protocol to use.

Greybus HID Protocol Version Request
""""""""""""""""""""""""""""""""""""

Table :num:`table-hid-version-request` defines the Greybus HID version request
payload. The request supplies the greatest major and minor version of the
Greybus HID Protocol supported by the sender.

.. figtable::
    :nofig:
    :label: table-hid-version-request
    :caption: HID Protocol Version Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Offered Greybus HID Protocol major version
    1        version_minor   1       |gb-minor|      Offered Greybus HID Protocol minor version
    =======  ==============  ======  ==========      ===========================


Greybus HID Protocol Version Response
"""""""""""""""""""""""""""""""""""""

The Greybus HID Protocol version response payload contains two 1-byte values, as
defined in table :num:`table-hid-protocol-version-response`. A Greybus HID
controller adhering to the Protocol specified herein shall report major version
|gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-hid-protocol-version-response
    :caption: HID Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Greybus HID Protocol major version
    1        version_minor   1       |gb-minor|      Greybus HID Protocol minor version
    =======  ==============  ======  ==========      ===========================


Greybus HID Get Descriptor Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus HID Get Descriptor operation is issued on the host and the HID
device must respond with an :ref:`hid-descriptor`.

Greybus HID Get Descriptor Request
""""""""""""""""""""""""""""""""""

The Greybus HID Get Descriptor request is sent from host to device and
it has no payload.

Greybus HID Get Descriptor Response
"""""""""""""""""""""""""""""""""""

The Greybus HID Get Descriptor response is sent from device to host and is
described in Table :num:`table-hid-descriptor`.

.. figtable::
    :nofig:
    :label: table-hid-descriptor
    :caption: Greybus HID Descriptor
    :spec: l l c c l

    =======  ==================  ======  ==========      ===========================
    Offset   Field               Size    Value           Description
    =======  ==================  ======  ==========      ===========================
    0        length              1       Number          Length of this descriptor
    1        report_desc_length  2       Number          Length of the report descriptor
    3        hid_version         2       Number          Version of the HID Protocol, as defined by [HID01]_
    5        product_id          2       Number          Product ID of the device
    7        vendor_id           2       Number          Vendor ID of the device
    9        country_code        1       Number          Country code of the localized hardware; see [HID01]_
    =======  ==================  ======  ==========      ===========================


Greybus HID Get Report Descriptor Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus HID Get Report Descriptor operation is issued on host and the HID
device must respond with an report descriptor as defined by [HID01]_.

Greybus HID Get Report Descriptor Request
"""""""""""""""""""""""""""""""""""""""""

The Greybus HID Get Report Descriptor request is sent from host to device and
the request has no payload.

Greybus HID Get Report Descriptor Response
""""""""""""""""""""""""""""""""""""""""""

The Greybus HID Get Report Descriptor response is sent from device to host and
it consists of a HID Report Descriptor defined by [HID01]_.

Greybus HID Power ON Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus HID power-on operation is sent from host to device to power on the HID device.

Greybus HID Power ON Request
""""""""""""""""""""""""""""

The Greybus HID power-on operation request has no payload.

Greybus HID Power ON Response
"""""""""""""""""""""""""""""

The Greybus HID power-on response has no payload.


Greybus HID Power OFF Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus HID power-off operation is sent from host to device to power off the
HID device.

Greybus HID Power OFF Request
"""""""""""""""""""""""""""""

The Greybus HID power-off operation request has no payload.

Greybus HID Power OFF Response
""""""""""""""""""""""""""""""

The Greybus HID power-off response has no payload.


Greybus HID Get Report Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus HID get report operation allows the host to fetch feature or input
report synchronously from a HID device.

The get-report command is a mandatory request (if the device contains Input or
Feature reports) that the host can issue to the device at any time after
initialization to get a singular report from the device. The device is
responsible for responding with the last known input or feature for the report
id. If the value has not been set for that report yet, the device must return 0
for the length of report item.

Get-report is often used by applications on startup to retrieve the “current
state” of the device rather than waiting for the device to generate the next
Input/Feature Report.

Greybus HID Get Report Request
""""""""""""""""""""""""""""""

The Greybus HID get report request contain 1-byte report-type and report-id as
defined by Table :num:`table-hid-get-report-request`.

.. figtable::
    :nofig:
    :label: table-hid-get-report-request
    :caption: HID Get Report Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        report_type     1       Number          :ref:`hid-report-type`
    1        report_id       1       Number          Report ID defined by [HID01]_
    =======  ==============  ======  ==========      ===========================

.. _hid-report-type:

Greybus HID Report Type
"""""""""""""""""""""""

Table :num:`table-hid-report-type` describes the defined HID report type values
defined for Greybus HID devices.

.. figtable::
    :nofig:
    :label: table-hid-report-type
    :caption: HID ReportType
    :spec: l l

    ===============     ======
    HID Report Type     Value
    ===============     ======
    Input Report        0x0000
    Output Report       0x0001
    Feature Report      0x0002
    ===============     ======

Greybus HID Get Report Response
"""""""""""""""""""""""""""""""

The Greybus HID Get Report response returns report as defined by
[HID01]_.

Greybus HID Set Report Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus HID set report operation allows the host to send feature or output
report synchronously to a HID device.

The set-report command is a specific request that the host may issue to the
device at any time after initialization to set a singular report on the device.
The device is responsible for accepting the value provided in the operation and
updating its state.

Greybus HID Set Report Request
""""""""""""""""""""""""""""""

.. figtable::
    :nofig:
    :label: table-hid-set-report-request
    :caption: HID Set Report Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        report_type     1       Number          :ref:`hid-report-type`
    1        report_id       1       Number          Report ID defined by [HID01]_
    2        report          ...     Data            Report defined by [HID01]_
    =======  ==============  ======  ==========      ===========================

The Greybus HID set report request contain report-type, report-id and
report (as defined by [HID01]_, and as defined in Table
:num:`table-hid-set-report-request`).

Greybus HID Set Report Response
"""""""""""""""""""""""""""""""

The Greybus HID Set Report response has no payload.

Greybus HID IRQ Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus IRQ Event operation allows the AP to receive input-report
asynchronously, when HID device has some data available to send to the AP.

Greybus HID IRQ Event Request
"""""""""""""""""""""""""""""

When the HID device has active data it wishes to report to the host, it will
generate an data request towards the host. When the host receives the receive
request, it is responsible for reading the data from the receive request.

The format of the input-report is defined by [HID01]_.

Greybus HID IRQ Event Response
""""""""""""""""""""""""""""""

The Greybus IRQ Event response has no payload.


Keymaster Protocol
------------------

TBD

Lights Protocol
---------------

TBD

NFC Protocol
------------

This section defines the operations used on a connection implementing
the Greybus Near Field Communication (NFC) Protocol.  This Protocol
allows an AP Module (Device Host (DH) in NFC's NFC Controller Interface (NCI)
terminology) to communicate with a Greybus NFC Module (NFC Controller
(NFCC) in NFC NCI terminology) using the NFC Forum's NCI Specification
version 1.1.  This specification is available from the
`NFC Forum's website <http://nfc-forum.org>`_.

Section 11 of the NFC NCI Specification (version 1.1) describes NCI
Transport Mapping requirements.  Those requirements are summarized here:

*   Transport shall support bidirectional transfers for both data
    and control packets.
*   Transport shall provide reliable data transfer.
*   Transport may provide flow control but should rely on the flow
    control built into the NCI protocol.
*   Transport shall not forward packets with size smaller than 3 bytes.

To support these requirements, the underlying |unipro| connection shall
have E2EFC disabled and CSD and CSV enabled.

The operations in the Greybus NFC Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the Protocol used for
    communication over the connection.  The sender offers the
    version of the Protocol it supports.  The receiver replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the Protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

.. c:function:: int send_packet(u32 size, u8 *packet);

    Sends an NFC NCI Packet of the specified size from an AP Module
    (or NFC Module) to the associated NFC Module (or AP Module).

Greybus NFC Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-nfc-operation-type` describes the Greybus NFC
operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-nfc-operation-type
    :caption: NFC Operation Types
    :spec: l l l

    ===========================  =============  ==============
    NFC Operation Type           Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Send Packet                  0x02           0x82
    (all other values reserved)  0x03..0x7f     0x83..0xff
    ===========================  =============  ==============

Greybus NFC Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus NFC Protocol version operation allows the Protocol
handling software on both ends of a connection to negotiate the
version of the NFC Protocol to use.

Greybus NFC Protocol Version Request
""""""""""""""""""""""""""""""""""""

Table :num:`table-nfc-version-request` defines the Greybus NFC
version request payload. The request supplies the greatest major and
minor version of the NFC Protocol supported by the sender.

.. figtable::
    :nofig:
    :label: table-nfc-version-request
    :caption: NFC Protocol Version Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Offered NFC Protocol major version
    1        version_minor   1       |gb-minor|      Offered NFC Protocol minor version
    =======  ==============  ======  ==========      ===========================

Greybus NFC Protocol Version Response
"""""""""""""""""""""""""""""""""""""

The Greybus NFC Protocol version response payload contains two
one-byte values, as defined in table
:num:`table-nfc-protocol-version-response`.
A Greybus NFC controller adhering to the Protocol specified herein
shall report major version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-nfc-protocol-version-response
    :caption: NFC Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      NFC Protocol major version
    1        version_minor   1       |gb-minor|      NFC Protocol minor version
    =======  ==============  ======  ==========      ===========================

Greybus NFC Send Packet Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus NFC Send Packet Operation allows an AP Module or NFC Module
to send an NFC NCI Packet to the associated NFC Module or AP Module,
respectively.

Greybus NFC Send Packet Request
"""""""""""""""""""""""""""""""

The Greybus NFC Send Packet Request contains a 4-byte size and
a valid NFC NCI Packet of *size* bytes as defined in table
:num:`table-nfc-send-packet-request`.

.. figtable::
    :nofig:
    :label: table-nfc-send-packet-request
    :caption: NFC Send Packet Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        size            4       Number          Size of the NFC NCI packet
    4        packet          *size*  Data            NFC NCI Packet
    =======  ==============  ======  ==========      ===========================

Greybus NFC Send Packet Response
""""""""""""""""""""""""""""""""

The Greybus NFS send packet response message has no payload.

Power Profile Protocol
----------------------

TBD

Sensors Protocol
----------------

TBD

WiFi Protocol
-------------

TBD

