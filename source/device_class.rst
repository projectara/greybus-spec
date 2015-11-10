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

..

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

..

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

..

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

..

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

Power Supply Protocol
---------------------

This section defines the operations used on a connection implementing
the Greybus power supply Protocol. This Protocol allows an AP Module to manage a
power supply device present on a Module. The Protocol consists of few basic
operations, whose request and response message formats are defined
here.

Conceptually, the operations in the Greybus power supply Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the Protocol used for
    communication over the connection.  The sender offers the
    version of the Protocol it supports.  The receiver replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the Protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

.. c:function:: int get_technology(u32 *technology);

    Returns a value indicating the technology type that this power supply
    adapter controls.

.. c:function:: int get_status(u16 *status);

    Returns a value indicating the charging status of the power supply.

.. c:function:: int get_max_voltage(u32 *voltage);

    Returns a value indicating the maximum voltage that the power supply supports.

.. c:function:: int get_percent_capacity(u32 *capacity);

    Returns a value indicating the current percent capacity of the
    power supply.

.. c:function:: int get_temperature(u32 *temperature);

    Returns a value indicating the current temperature of the power supply.

.. c:function:: int get_voltage(u32 *voltage);

    Returns a value indicating the voltage level of the power supply.

.. c:function:: int get_current(u32 *current);

    Returns a value indicating the current being supplied or drawn
    from the power supply.

.. c:function:: int get_total_capacity(u32 *capacity);

    Returns a value indicating the total capacity in mAh of the power supply.

.. c:function:: int get_shutdown_temperature(u32 *temperature);

    Returns a value indicating the temperature at which a power supply
    will automatically shut down.

Greybus Power Supply Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-power-supply-operation-type` describes the Greybus
power supply operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-power-supply-operation-type
    :caption: Power Supply Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Power Supply Operation Type  Request Value  Response Value
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

..

Greybus Power Supply Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus power supply Protocol version operation allows the Protocol
handling software on both ends of a connection to negotiate the
version of the power supply Protocol to use.

Greybus Power Supply Protocol Version Request
"""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-version-request` defines the Greybus power supply
version request payload. The request supplies the greatest major and
minor version of the power supply Protocol supported by the sender.

.. figtable::
    :nofig:
    :label: table-power-supply-version-request
    :caption: Power Supply Protocol Version Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Offered power supply Protocol major version
    1        version_minor   1       |gb-minor|      Offered power supply Protocol minor version
    =======  ==============  ======  ==========      ===========================

..


Greybus Power Supply Protocol Version Response
""""""""""""""""""""""""""""""""""""""""""""""

The Greybus power supply Protocol version response payload contains two
one-byte values, as defined in table
:num:`table-power-supply-protocol-version-response`.
A Greybus power supply controller adhering to the Protocol specified herein
shall report major version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-power-supply-protocol-version-response
    :caption: Power Supply Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Power Supply Protocol major version
    1        version_minor   1       |gb-minor|      Power Supply Protocol minor version
    =======  ==============  ======  ==========      ===========================

..

Greybus Power Supply Technology Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus power supply technology operation allows the AP Module to determine
the details of the power supply technology controller by the power supply
adapter.

Greybus Power Supply Technology Request
"""""""""""""""""""""""""""""""""""""""

The Greybus power supply technology request message has no payload.

Greybus Power Supply Technology Response
""""""""""""""""""""""""""""""""""""""""

The Greybus power supply technology response contains a 4-byte value
that represents the type of power supply being controlled as defined in
Table :num:`table-power-supply-technology-response`.

.. figtable::
    :nofig:
    :label: table-power-supply-technology-response
    :caption: Power Supply Technology Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        technology      4       Number          :ref:`power-supply-technology-type`
    =======  ==============  ======  ==========      ===========================

..

.. _power-supply-technology-type:

Greybus Power Supply Technology Type
""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-tech-type` describes the defined power supply
technologies defined for Greybus power supply adapters.  These values are
taken directly from the <linux/power_supply.h> header file.

.. figtable::
    :nofig:
    :label: table-power-supply-tech-type
    :caption: Power Supply Technology Type
    :spec: l l

    ==================   ======
    Power Supply Type    Value
    ==================   ======
    Unknown              0x0000
    NiMH                 0x0001
    LION                 0x0002
    LIPO                 0x0003
    LiFe                 0x0004
    NiCd                 0x0005
    LiMn                 0x0006
    ==================   ======

..

Greybus Power Supply Status Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus power supply status operation allows the AP Module to determine the
status of the power supply by the power supply adapter.

Greybus Power Supply Status Request
"""""""""""""""""""""""""""""""""""

The Greybus power supply status request message has no payload.

Greybus Power Supply Status Response
""""""""""""""""""""""""""""""""""""

The Greybus power supply status response contains a 2-byte value that
represents the status of power supply being controlled as defined in
table :num:`table-power-supply-status-response`.

.. figtable::
    :nofig:
    :label: table-power-supply-status-response
    :caption: Power Supply Status Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        status          2       Number          :ref:`power-supply-status`
    =======  ==============  ======  ==========      ===========================

..

.. _power-supply-status:

Greybus Power Supply Status Type
""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-status-type` describes the defined power supply
status values defined for Greybus power supply adapters.  These values are
taken directly from the <linux/power_supply.h> header file.

.. figtable::
    :nofig:
    :label: table-power-supply-status-type
    :caption: Power Supply Status Type
    :spec: l l

    ====================   ======
    Power Supply Status    Value
    ====================   ======
    Unknown                0x0000
    Charging               0x0001
    Discharging            0x0002
    Not Charging           0x0003
    Full                   0x0004
    ====================   ======

..

Greybus Power Supply Max Voltage Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus power supply Max Voltage operation allows the AP Module to determine
the maximum possible voltage of the power supply.

Greybus Power Supply Max Voltage Request
""""""""""""""""""""""""""""""""""""""""

The Greybus power supply max voltage request message has no payload.

Greybus Power Supply Max Voltage Response
"""""""""""""""""""""""""""""""""""""""""

The Greybus power supply max voltage response contains a 4-byte value
that represents the maximum voltage of the power supply being controlled,
in |mu| V as defined in table :num:`table-power-supply-max-voltage-response`.

.. figtable::
    :nofig:
    :label: table-power-supply-max-voltage-response
    :caption: Power Supply Max Voltage Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        max_voltage     4       Number          Power Supply maximum voltage in |mu| V
    =======  ==============  ======  ==========      ===========================

..

Greybus Power Supply Capacity Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus power supply Capacity operation allows the AP Module to determine the
current capacity percent of the power supply.

Greybus Power Supply Percent Capacity Request
"""""""""""""""""""""""""""""""""""""""""""""

The Greybus power supply capacity request message has no payload.

Greybus Power Supply Percent Capacity Response
""""""""""""""""""""""""""""""""""""""""""""""

The Greybus power supply capacity response contains a 4-byte value that
represents the capacity of the power supply being controlled, in
percentage as defined in table
:num:`table-power-supply-percent-capacity-response`.

.. figtable::
    :nofig:
    :label: table-power-supply-percent-capacity-response
    :caption: Power Supply Percent Capacity Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        capacity        4       Number          Power Supply capacity in %
    =======  ==============  ======  ==========      ===========================

..

Greybus Power Supply Temperature Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus power supply temperature operation allows the AP Module to determine
the current temperature of the power supply.

Greybus Power Supply Temperature Request
""""""""""""""""""""""""""""""""""""""""

The Greybus power supply temperature request message has no payload.

Greybus Power Supply Temperature Response
"""""""""""""""""""""""""""""""""""""""""

The Greybus power supply temperature response contains a 4-byte value
that represents the temperature of the power supply being controlled, in
0.1 |degree-c| increments as defined in table
:num:`table-power-supply-temp-response`.

.. figtable::
    :nofig:
    :label: table-power-supply-temp-response
    :caption: Power Supply Temperature Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        temperature     4       Number          Power Supply temperature (0.1 |degree-c| units)
    =======  ==============  ======  ==========      ===========================

..

Greybus Power Supply Voltage Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus power supply Voltage operation allows the AP Module to determine the
voltage being supplied by the power supply.

Greybus Power Supply Voltage Request
""""""""""""""""""""""""""""""""""""

The Greybus power supply voltage request message has no payload.

Greybus Power Supply Voltage Response
"""""""""""""""""""""""""""""""""""""

The Greybus power supply voltage response contains a 4-byte value that
represents the voltage of the power supply being controlled, in |mu| V as
defined in table
:num:`table-power-supply-voltage-response`.

.. figtable::
    :nofig:
    :label: table-power-supply-voltage-response
    :caption: Power Supply Voltage Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        voltage         4       Number          Power Supply voltage in |mu| V
    =======  ==============  ======  ==========      ===========================

..

Greybus Power Supply Current Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus power supply Current operation allows the AP Module to determine the
current current of the power supply.

Greybus Power Supply Current Request
""""""""""""""""""""""""""""""""""""

The Greybus power supply current request message has no payload.

Greybus Power Supply Current Response
"""""""""""""""""""""""""""""""""""""

The Greybus power supply current response contains a 4-byte value that
represents the current of the power supply being controlled, in |mu| A as
defined in table :num:`table-power-supply-current-response`.

.. figtable::
    :nofig:
    :label: table-power-supply-current-response
    :caption: Power Supply Current Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        current         4       Number          Power Supply current in |mu| A
    =======  ==============  ======  ==========      ===========================

..

Greybus Power Supply Total Capacity Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus power supply total capacity operation allows the AP Module to determine
the total capacity of the power supply.

Greybus Power Supply Total Capacity Request
"""""""""""""""""""""""""""""""""""""""""""

The Greybus power supply total capacity request message has no payload.

Greybus Power Supply Total Capacity Response
""""""""""""""""""""""""""""""""""""""""""""
The Greybus power supply total capacity response contains a 4-byte value
that represents the total capacity of the power supply being controlled,
in mAh as defined in table :num:`table-power-supply-total-capacity-response`.

.. figtable::
    :nofig:
    :label: table-power-supply-total-capacity-response
    :caption: Power Supply Total Capacity Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        capacity        4       Number          Power Supply capacity in mAh
    =======  ==============  ======  ==========      ===========================

..

Greybus Power Supply Shutdown Temperature Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The Greybus power supply shutdown temperature operation allows the AP Module to
determine the power supply temperature at which the power supply will shut
itself down.

Greybus Power Supply Shutdown Temperature Request
"""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus power supply shutdown temperature request message has no payload.

Greybus Power Supply Shutdown Temperature Response
""""""""""""""""""""""""""""""""""""""""""""""""""
The Greybus power supply shutdown temperature response contains a 4-byte
value that represents the temperature at which the power supply shuts
down as defined in table :num:`table-power-supply-shutdown-temp-response`.

.. figtable::
    :nofig:
    :label: table-power-supply-shutdown-temp-response
    :caption: Power Supply Shutdown Temperature Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        temperature     4       Number          Power Supply temperature (0.1 |degree-c| units)
    =======  ==============  ======  ==========      ===========================

..

Audio Protocol
--------------

TBD

Bluetooth Protocol
------------------

TBD

Consumer IR Protocol
--------------------

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

..

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

..

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

..

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

..

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

..

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

..

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

This section defines operations used on a connection implementing the Greybus
Lights Protocol. This Protocol allows an AP Module to control Lights devices
present on a Module. The Protocol consists of some basic operations that are
defined here.

The operations in the Greybus Lights Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the Protocol used for
    communication over the connection.  The sender offers the
    version of the Protocol it supports.  The receiver replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the Protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

.. c:function:: int get_lights(u8 *lights_count);

   Return the number of lights devices supported. lights_id used
   in the following operations are sequential increments from 0 to
   lights_count less one.

.. c:function:: int get_light_config(u8 light_id, u8 *channel_count, u8 *name[32]);

   Request the number of channels controlled by a light controller
   and it's name, providing a valid identifier for that light.
   channel_id used in the following operations are sequential
   increments from 0 to channel_count less one.


.. c:function:: int get_channel_config(u8 light_id, u8 channel_id, u8 *channel_count, struct gb_channel_config *config);

   Request a set of configuration parameters related to a channel in a
   light controller. The return structure elements shall map the fields
   of :ref:`lights-get-channel-config-response`.

.. c:function:: int get_channel_flash_config(u8 light_id, u8 channel_id, struct gb_channel_flash_config *flash_config);

   Request a set of flash configuration parameters related to a
   channel in a light controller. The return structure elements shall
   map the fields of :ref:`lights-get-channel-flash-config-response`

.. c:function:: int set_blink(u8 light_id, u8 channel_id, u16 time_on_ms, u16 time_off_ms);

   Set hardware blink if supported by the device, the time values are
   specified in milliseconds. Setting time values to 0 shall disable
   blink.

.. c:function:: int set_brightness(u8 light_id, u8 channel_id, u8 brightness);

   Set the level of brightness with the specified value.

.. c:function:: int set_color(u8 light_id, u8 channel_id, u32 color);

   Set color code with the specified value.

.. c:function:: int set_fade(u8 light_id, u8 channel_id, u32 fade_in, u32 fade_out);

   Set fade in and out level with the specified values.

.. c:function:: int set_flash_intensity(u8 light_id, u8 channel_id, u32 intensity_uA);

   Set flash current intensity in micro Amperes with the specified
   value.

.. c:function:: int set_flash_strobe(u8 light_id, u8 channel_id, u8 state);

   Set flash strobe state with the specified value, value 0 means
   strobe off other value means strobe on.

.. c:function:: int set_flash_timeout(u8 light_id, u8 channel_id, u32 timeout_us);

   Set flash timeout value in micro seconds with the specified value.

.. c:function:: int get_flash_fault(u8 light_id, u8 channel_id, *u32 fault);

   Get flash fault status from controller.

Greybus Lights Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-lights-operation-type` describes the Greybus Lights
operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-lights-operation-type
    :caption: Lights Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Lights Operation Type        Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Get Lights                   0x02           0x82
    Get Light Config             0x03           0x83
    Get Channel Config           0x04           0x84
    Get Channel Flash Config     0x05           0x85
    Set Brightness               0x06           0x86
    Set Blink                    0x07           0x87
    Set Color                    0x08           0x88
    Set Fade                     0x09           0x89
    Event                        0x0a           N/A
    Set Flash Intensity          0x0b           0x8b
    Set Flash Strobe             0x0c           0x8c
    Set Flash Timeout            0x0d           0x8d
    Get Flash Fault              0x0e           0x8e
    (all other values reserved)  0x0f..0x7f     0x8f..0xff
    ===========================  =============  ==============

..

Greybus Lights Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Protocol version operation allows the Protocol handling
software on both ends of a connection to negotiate the version of the Greybus
Lights Protocol to use.

Greybus Lights Protocol Version Request
"""""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-version-request` defines the Greybus Lights version
request payload. The request supplies the greatest major and minor version of
the Greybus Lights Protocol supported by the sender.

.. figtable::
    :nofig:
    :label: table-lights-version-request
    :caption: Lights Protocol Version Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Offered Greybus Lights Protocol major version
    1        version_minor   1       |gb-minor|      Offered Greybus Lights Protocol minor version
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Protocol Version Response
""""""""""""""""""""""""""""""""""""""""

The Greybus Lights Protocol version response payload contains two 1-byte values,
as defined in table :num:`table-lights-protocol-version-response`. A Greybus
Lights controller adhering to the Protocol specified herein shall report major
version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-lights-protocol-version-response
    :caption: Lights Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Greybus Lights Protocol major version
    1        version_minor   1       |gb-minor|      Greybus Lights Protocol minor version
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Get Lights Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Get Lights operation allows the requester to
determine the actual number of Lights Controllers existing in the
Module. If this operation fail, no further operations related to
Greybus Lights shall occur.

Greybus Lights Get Lights Request
"""""""""""""""""""""""""""""""""

The Greybus Lights Get Lights request message has no payload.

Greybus Lights Get Lights Response
""""""""""""""""""""""""""""""""""

Table :num:`table-lights-get-lights-response` describes the Greybus
Lights Get Lights response. The response payload contains a one-byte
value defining the number of lights controllers in the Module.
If the value returned is 0 no further operations related to
Greybus Lights shall follow. Lights Controllers shall be numbered
sequentially starting at zero and ending in lights_count less one.

.. figtable::
    :nofig:
    :label: table-lights-get-lights-response
    :caption: Lights Get Lights Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        lights_count    1       Number          Number of Lights
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Get Light Config Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Get Light Config operation allows the requester to
collect a set of configuration parameters from a specific light
controller. If this operation fail, all Module lights controllers
configuration that already had occurred should be teared down and no
further operations related to Greybus Lights shall follow.

Greybus Lights Get Light Config Request
"""""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-get-light-config-request` describes the
Greybus Lights Get Light Config request. The request supplies only the
light_id which is an unique identifier between 0 and lights_count
less one.

.. figtable::
    :nofig:
    :label: table-lights-get-light-config-request
    :caption: Lights Get Light Config Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Get Light Config Response
""""""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-get-light-config-response` describes the
Greybus Lights Get Light Config response. The response payload
contains a one-byte value defining the number of existing channels in
the Controller and thirty two byte representing the name of the
Controller.

.. figtable::
    :nofig:
    :label: table-lights-get-light-config-response
    :caption: Lights Get Light Config Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        channel_count   1       Number          Number of Channels
    1        name            32      Characters      Light Controller name
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Get Channel Config Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Get Channel Config operation allows the requester
to collect a set of configuration parameters from a specific Channel
of a Light Controller. If this operation fail, all Module lights
Controllers configuration that already had occurred should be teared
down and no further operations related to Greybus Lights shall follow.

Greybus Lights Get Channel Config Request
"""""""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-get-channel-config-request` describes the
Greybus Lights Get Channel Config request. The request supplies the
light_id and channel_id which are unique identifiers between 0 and
lights_count or channel_count less one, respectively

.. figtable::
    :nofig:
    :label: table-lights-get-channel-config-request
    :caption: Lights Get Channel Config Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    =======  ==============  ======  ==========      ===========================

..

.. _lights-get-channel-config-response:

Greybus Lights Get Channel Config Response
""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-get-channel-config-response` describes the
Greybus Lights Get Channel Config response. The response payload
contains a set of parameters representing the configuration of the
channel.

.. figtable::
    :nofig:
    :label: table-lights-get-channel-config-response
    :caption: Lights Get Channel Config Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        max_brightness  1       Number          Maximum Supported Value for Brightness
    1        flags           4       Bit Mask        :ref:`lights-channel-flags`
    5        color           4       Number          Color code value
    9        color_name      32      Characters      Color name
    41       mode            4       Bit Mask        :ref:`lights-channel-mode`
    45       mode_name       32      Characters      Mode name
    =======  ==============  ======  ==========      ===========================

..

.. _lights-channel-flags:

Greybus Lights Channel Flags Bits
"""""""""""""""""""""""""""""""""

Table :num:`table-lights-channel-flag-bits` describes general flags
associated to a Channel. Only the listed values are valid.

.. figtable::
    :nofig:
    :label: table-lights-channel-flag-bits
    :caption: Lights Channel Flag Bits
    :spec: l l l

    ============================  ===================================================  ==========
    Symbol                        Brief Description                                    Mask Value
    ============================  ===================================================  ==========
    GB_LIGHT_CHANNEL_MULTICOLOR   Channel Support more than one color                  0x00000001
    GB_LIGHT_CHANNEL_FADER        Channel Support Hardware Fader                       0x00000002
    GB_LIGHT_CHANNEL_BLINK        Channel Support Hardware Blink                       0x00000004
    |_|                           (All other values reserved)                          0x00000008..0xffffffff
    ============================  ===================================================  ==========

..

.. _lights-channel-mode:

Greybus Lights Channel Mode Bits
""""""""""""""""""""""""""""""""

Table :num:`table-lights-channel-mode-bits` describes possible modes
associated to a Channel. Only the listed values are valid.

.. figtable::
    :nofig:
    :label: table-lights-channel-mode-bits
    :caption: Lights Channel Mode Bit Masks
    :spec: l l l

    ===============================  ===================================================  ========================
    Light Mode                       Brief Description                                    Mask Value
    ===============================  ===================================================  ========================
    GB_CHANNEL_MODE_NONE             Channel do not represent any specific mode           0x00000000
    GB_CHANNEL_MODE_BATTERY          Channel can represent the battery mode               0x00000001
    GB_CHANNEL_MODE_POWER            Channel can represent the power mode                 0x00000002
    GB_CHANNEL_MODE_WIRELESS         Channel can represent wifi activity mode             0x00000004
    GB_CHANNEL_MODE_BLUETOOTH        Channel can represent bluetooth activity mode        0x00000008
    GB_CHANNEL_MODE_KEYBOARD         Channel can represent light related to the keyboard  0x00000010
    GB_CHANNEL_MODE_BUTTONS          Channel can represent light related to buttons       0x00000020
    GB_CHANNEL_MODE_NOTIFICATION     Channel can represent general notification light     0x00000040
    GB_CHANNEL_MODE_ATTENTION        Channel can represent general attention light        0x00000080
    GB_CHANNEL_MODE_FLASH            Channel can be used as a flash light device          0x00000100
    GB_CHANNEL_MODE_TORCH            Channel can be used as a flash torch device          0x00000200
    GB_CHANNEL_MODE_INDICATOR        Channel can be used as a flash indicator device      0x00000400
    |_|                              (Reserved Range)                                     0x00000800..0x00080000
    GB_CHANNEL_MODE_VENDOR           Channel can be used as vendor specific mode          0x00100000..0x08000000
    |_|                              (Reserved Range)                                     0x10000000..0x80000000
    ===============================  ===================================================  ========================

..

Greybus Lights Get Channel Flash Config Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Get Channel Flash Config operation allows the
requester to collect a set of configuration parameters related to
flash type modes from a specific Channel of a Light Controller. If
this operation fail, all Module lights Controllers configuration that
already had occurred should be teared down and no further operations
related to Greybus Lights shall follow.

Greybus Lights Get Channel Flash Config Request
"""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-get-channel-flash-config-request` describes
the Greybus Lights Get Channel Config request. The request supplies
the light_id and channel_id which are unique identifiers between 0 and
lights_count or channel_count less one, respectively

.. figtable::
    :nofig:
    :label: table-lights-get-channel-flash-config-request
    :caption: Lights Get Channel Flash Config Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    =======  ==============  ======  ==========      ===========================

..

.. _lights-get-channel-flash-config-response:

Greybus Lights Get Channel Flash Config Response
""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-get-channel-flash-config-response` describes
the Greybus Lights Get Channel Flash Config response. The response
payload contains a set of flash type parameters representing the
configuration of the channel.

.. figtable::
    :nofig:
    :label: table-lights-get-channel-flash-config-response
    :caption: Lights Get Channel Flash Config Response
    :spec: l l c c l

    =======  =================  ======  ==========      ===========================
    Offset   Field              Size    Value           Description
    =======  =================  ======  ==========      ===========================
    0        intensity_min_uA   4       Number          Minimum Value for Current Intensity in microampere
    4        intensity_max_uA   4       Number          Maximum Value for Current Intensity in microampere
    8        intensity_step_uA  4       Number          Step Value for Current Intensity in microampere
    12       timeout_min_us     4       Number          Minimum Value for Strobe Flash timeout in milliseconds
    16       timeout_max_us     4       Number          Maximum Value for Strobe Flash timeout in milliseconds
    20       timeout_step_us    4       Number          Step Value for Strobe Flash timeout in milliseconds
    =======  =================  ======  ==========      ===========================

..

Greybus Lights Set Brightness Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Set Brightness operation allows the requester to
set brightness level of a specific Channel to the specified value.

Greybus Lights Set Brightness Request
"""""""""""""""""""""""""""""""""""""
The Greybus Lights Set Brightness request payload contains three
1-byte values that represents light_id, channel_id and the level of
brightness to be set by the light device channel being controlled, in
which 0 represent the lower level (off) and 255 represent the highest
possible brightness level as defined in table
:num:`table-lights-set-brightness-request`.

.. figtable::
    :nofig:
    :label: table-lights-set-brightness-request
    :caption: Lights Set Brightness Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    2        brightness      1       Number          Channel brightness level to set
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Set Brightness Response
""""""""""""""""""""""""""""""""""""""

The Greybus Lights Set Brightness response message has no payload.

Greybus Lights Set Blink Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Set Blink operation allows the requester to enable
the blink mode of a specific Channel. Setting time_on and time_off to
0 or setting brightness  level to a fixed value shall disable blink.

Greybus Lights Set Blink Request
""""""""""""""""""""""""""""""""

The Greybus Lights Set Blink request payload contains a two 1-byte
values that represent the light_id and channel_id, more two 2-byte
values that represents the duration in milliseconds of the on and off
period during the blink to be set by the light device channel being
controlled, as defined in table :num:`table-lights-set-blink-request`.

.. figtable::
    :nofig:
    :label: table-lights-set-blink-request
    :caption: Lights Set Blink Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    2        time_on_ms      2       Number          Time on in milliseconds
    4        time_off_ms     2       Number          Time off in milliseconds
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Set Blink Response
"""""""""""""""""""""""""""""""""

The Greybus Lights Set Blink response message has no payload.

Greybus Lights Set Color Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Set Color operation allows the requester to set a
value for a color space of a specific Channel to the specified value.

Greybus Lights Set Color Request
""""""""""""""""""""""""""""""""

The Greybus Lights Set Color request payload contains two 1-byte
values that represents light_id, channel_id and one 4-byte value which
represents a color code in any color space for the light device
channel, as defined in table
:num:`table-lights-set-color-request`.

.. figtable::
    :nofig:
    :label: table-lights-set-color-request
    :caption: Lights Set Color Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    2        color           4       Number          Channel color code
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Set Color Response
"""""""""""""""""""""""""""""""""

The Greybus Lights Set Color response message has no payload.

Greybus Lights Set Fade Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Set Fade operation allows the requester to enable
and set the parameters for fade effect of a specific Channel.

Greybus Lights Set Fade Request
"""""""""""""""""""""""""""""""

The Greybus Lights Set Fade request payload contains a two 1-byte
values that represent the light_id and channel_id, more two 2-byte
values that represents a level of the fade in and out effect during
brightness transitions by the light device channel being controlled,
as defined in table
:num:`table-lights-set-fade-request`.

.. figtable::
    :nofig:
    :label: table-lights-set-fade-request
    :caption: Lights Set Fade Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    2        fade_in         2       Number          Fade in level
    4        fade_out        2       Number          Fade out level
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Set Fade Response
""""""""""""""""""""""""""""""""

The Greybus Lights Set Fade response message has no payload.

Greybus Lights Event Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Event operation signals to the recipient that a
change in the device setup have occurred.

This event shall be discarded by the recipient until a valid light
controller configuration is known.

This operation is unidirectional and does not have a correspondent
response.

Greybus Lights Event Request
""""""""""""""""""""""""""""

Table :num:`table-lights-event-request` defines the Greybus Lights
Event request. The request payload supplies two 1-byte fields that
represent the light_id and event bit mask.

.. figtable::
    :nofig:
    :label: table-lights-event-request
    :caption: Lights Event Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        event           1       Bit Mask        :ref:`lights-event-bits`
    =======  ==============  ======  ==========      ===========================

..

.. _lights-event-bits:

Greybus Lights Event Bit Masks
""""""""""""""""""""""""""""""

Table :num:`table-lights-event-bit-mask` defines the bit masks which
specify the set of events that occurred in the sending controller.

.. figtable::
    :nofig:
    :label: table-lights-event-bit-mask
    :caption: Lights Protocol Event Bit Mask
    :spec: l l l

    ===============================  =============================  ===============
    Symbol                           Brief Description              Mask Value
    ===============================  =============================  ===============
    GB_LIGHTS_LIGHT_CONFIG           Configuration Changed          0x01
    |_|                              (All other values reserved)    0x02..0x80
    ===============================  =============================  ===============

..

Greybus Lights Set Flash Intensity Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Set Flash Intensity operation allows the requester
to set current Intensity level in microamperes of a Channel to the
specified value.

Greybus Lights Set Flash Intensity Request
""""""""""""""""""""""""""""""""""""""""""

The Greybus Lights Set Flash Intensity request payload contains two
1-byte values that represent the light_id and channel_id, and 4-byte
value that represents the current intensity in microamperes. The value
shall be set between the minimum and maximum values got from flash
configuration operation.
:num:`table-lights-set-flash-intensity-request`.

.. figtable::
    :nofig:
    :label: table-lights-set-flash-intensity-request
    :caption: Lights Set Flash Intensity Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    2        intensity_uA    4       Number          Current Intensity in microamperes
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Set Flash Intensity Response
"""""""""""""""""""""""""""""""""""""""""""

The Greybus Lights Set Flash Intensity response message has no payload.

Greybus Lights Set Flash Strobe Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Set Flash Strobe operation allows the requester
to enable or disable the strobe associated with a Channel.

Greybus Lights Set Flash Strobe Request
"""""""""""""""""""""""""""""""""""""""

The Greybus Lights Set Flash Strobe request payload contains three
1-byte values that represents light_id, channel_id and the strobe
state to be set. If state is 0 means disable, 1 means enable. Any
other value shall be considered invalid.
:num:`table-lights-set-flash-strobe-request`.

.. figtable::
    :nofig:
    :label: table-lights-set-flash-strobe-request
    :caption: Lights Set Flash Strobe Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    2        state           1       Number          Strobe state to be set
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Set Flash Strobe Response
""""""""""""""""""""""""""""""""""""""""

The Greybus Lights Set Flash Strobe response message has no payload.

Greybus Lights Set Flash Timeout Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Set Flash Timeout operation allows the requester to
set flash timeout in microseconds of a Channel to the specified value.

Greybus Lights Set Flash Timeout Request
""""""""""""""""""""""""""""""""""""""""

The Greybus Lights Set Flash Timeout request payload contains two
1-byte values that represent the light_id and channel_id, and 4-byte
value that represents the flash timeout in microseconds. The value
shall be set between the minimum and maximum values got from flash
configuration operation.
:num:`table-lights-set-flash-timeout-request`.

.. figtable::
    :nofig:
    :label: table-lights-set-flash-timeout-request
    :caption: Lights Set Flash Timeout Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    2        timeout_us      4       Number          Timeout Value in microseconds
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Set Flash Timeout Response
"""""""""""""""""""""""""""""""""""""""""

The Greybus Lights Set Flash Timeout response message has no payload.

Greybus Lights Get Flash Fault Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Lights Get Flash Fault operation allows the requester to
get a detailed information of the status and fault reasons of the
flash type controller.

Greybus Lights Get Flash Fault Request
""""""""""""""""""""""""""""""""""""""

The Greybus Lights Get Flash Fault request payload contains two
1-byte values that represent the light_id and channel_id.
:num:`table-lights-get-flash-fault-request`.

.. figtable::
    :nofig:
    :label: table-lights-get-flash-fault-request
    :caption: Lights Get Flash Fault Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        light_id        1       Number          Light identification Number
    1        channel_id      1       Number          Channel identification Number
    =======  ==============  ======  ==========      ===========================

..

Greybus Lights Get Flash Fault Response
"""""""""""""""""""""""""""""""""""""""

The Greybus Lights Get Flash Fault response message payload contains a
4-byte bit mask with the current fault status of the flash controller,
as defined in table :num:`table-lights-get-flash-fault-response`

.. figtable::
    :nofig:
    :label: table-lights-get-flash-fault-response
    :caption: Lights Get Flash Fault Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        fault           4       Bit Mask        :ref:`lights-flash-fault-bits`
    =======  ==============  ======  ==========      ===========================

..

.. _lights-flash-fault-bits:

Greybus Lights Flash Fault Bit Masks
""""""""""""""""""""""""""""""""""""

Table :num:`table-lights-flash-fault-bit-mask` defines the bit masks
which specify the fault status of the flash controller.

.. figtable::
    :nofig:
    :label: table-lights-flash-fault-bit-mask
    :caption: Lights Protocol Flash Fault Bit Mask
    :spec: l l l

    ============================================  =============================  ===============
    Symbol                                        Brief Description              Mask Value
    ============================================  =============================  ===============
    GB_LIGHTS_FLASH_FAULT_OVER_VOLTAGE            Over Voltage                   0x00000000
    GB_LIGHTS_FLASH_FAULT_TIMEOUT                 Timeout                        0x00000001
    GB_LIGHTS_FLASH_FAULT_OVER_TEMPERATURE        Over Temperature               0x00000002
    GB_LIGHTS_FLASH_FAULT_SHORT_CIRCUIT           Short Circuit                  0x00000004
    GB_LIGHTS_FLASH_FAULT_OVER_CURRENT            Over Current                   0x00000008
    GB_LIGHTS_FLASH_FAULT_INDICATOR               Indicator Fault                0x00000010
    GB_LIGHTS_FLASH_FAULT_UNDER_VOLTAGE           Under Voltage                  0x00000020
    GB_LIGHTS_FLASH_FAULT_INPUT_VOLTAGE           Input Voltage                  0x00000040
    GB_LIGHTS_FLASH_FAULT_LED_OVER_TEMPERATURE    LED Over Temperature           0x00000080
    |_|                                           (All other values reserved)    0x00000100..0x80000000
    ============================================  =============================  ===============

..

Sensors Protocol
----------------

TBD

Loopback Protocol
-----------------

This section defines the operations used on a connection implementing
the Greybus loopback Protocol.  This Protocol is used for testing a
Greybus device and the connection to the device, by sending and
receiving data in a "loop".

The operations in the Greybus loopback Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the Protocol used for
    communication over the connection.  The sender offers the
    version of the Protocol it supports.  The receiver replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the Protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

.. c:function:: int ping(void);

   Sends a "ping" message to the device, from the host, that needs to be
   acknowledged by the device.  By measuring how long this message takes
   to succeed, an idea of the speed of the connection can be made.

.. c:function:: int transfer(u32 len, char *send, char *receive);

   Sends a stream of bytes to the device and receives them back from the
   device.

.. c:function:: int sink(u32 len, char *send);

   Sends a stream of bytes to the device that needs to be acknowledged by the
   device. No data are sent back from the device.

Greybus Loopback Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-loopback-operation-type` describes the Greybus
loopback operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-loopback-operation-type
    :caption: Loopback Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Loopback Operation Type      Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Ping                         0x02           0x82
    Transfer                     0x03           0x83
    Sink                         0x04           0x84
    (all other values reserved)  0x05..0x7f     0x85..0xff
    ===========================  =============  ==============

..

Greybus Loopback Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus loopback Protocol version operation allows the Protocol
handling software on both ends of a connection to negotiate the
version of the loopback Protocol to use.

Greybus Loopback Protocol Version Request
"""""""""""""""""""""""""""""""""""""""""

Table :num:`table-loopback-version-request` defines the Greybus loopback
version request payload. The request supplies the greatest major and
minor version of the loopback Protocol supported by the sender.

.. figtable::
    :nofig:
    :label: table-loopback-version-request
    :caption: Loopback Protocol Version Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Offered loopback Protocol major version
    1        version_minor   1       |gb-minor|      Offered loopback Protocol minor version
    =======  ==============  ======  ==========      ===========================

..

Greybus Loopback Protocol Version Response
""""""""""""""""""""""""""""""""""""""""""

The Greybus loopback Protocol version response payload contains two
one-byte values, as defined in table
:num:`table-loopback-protocol-version-response`.
A Greybus loopback controller adhering to the Protocol specified herein
shall report major version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-loopback-protocol-version-response
    :caption: Loopback Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Loopback Protocol major version
    1        version_minor   1       |gb-minor|      Loopback Protocol minor version
    =======  ==============  ======  ==========      ===========================

..

Greybus Loopback Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus ping operation is a simple message that has no response.  It
is used to time how long a single message takes to be sent and
acknowledged from the receiver.

Greybus Loopback Ping Request
"""""""""""""""""""""""""""""

The Greybus ping request message has no payload.

Greybus Loopback Ping Response
""""""""""""""""""""""""""""""

The Greybus ping response message has no payload.

Greybus Loopback Transfer Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Loopback transfer operation sends data and then the same
data is returned.  This is used to determine the time required to
transfer different size messages.

Greybus Loopback Transfer Request
"""""""""""""""""""""""""""""""""

Table :num:`table-loopback-request` defines the Greybus Loopback
Transfer request.  The request supplies size of the data that is sent to
the device, and the data itself.

.. figtable::
    :nofig:
    :label: table-loopback-request
    :caption: Loopback Protocol Transfer Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        len             4       Number          length in bytes of the data field
    4        data            X       Data            array of data bytes
    =======  ==============  ======  ==========      ===========================

..

Greybus Loopback Transfer Response
""""""""""""""""""""""""""""""""""

Table :num:`table-loopback-response` defines the Greybus Loopback
Transfer response.  The response contains the same data that was sent in
the request.

.. figtable::
    :nofig:
    :label: table-loopback-response
    :caption: Loopback Protocol Transfer Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        len             4       Number          length in bytes of the data field
    4        reserved0       4       Number          reserved for use by the implementation
    8        reserved1       4       Number          reserved for use by the implementation
    12       data            X       Data            array of data bytes
    =======  ==============  ======  ==========      ===========================

..

Greybus Loopback Sink Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Loopback sink operation sends data to the device.
No data is returned back.

Greybus Loopback Sink Request
"""""""""""""""""""""""""""""

The Greybus sink request message is identical to the Greybus transfer request
message.

Greybus Loopback Sink Response
""""""""""""""""""""""""""""""

The Greybus sink response message has no payload.

Raw Protocol
------------

This section defines the operations used on a connection implementing
the Greybus Raw Protocol.  This Protocol is used for streaming "raw"
data from userspace directly to or from the device.  The data contained
by the protocol is not interpreted by the kernel, but requires a
userspace program to handle it.  It can almost be considered a "vendor
specific" protocol in that the format of the data is unspecified, and
will vary by device.

The operations in the Greybus Raw Protocol are:

.. c:function:: int version(u8 offer_major, u8 offer_minor, u8 *major, u8 *minor);

    Negotiates the major and minor version of the Protocol used for
    communication over the connection.  The sender offers the
    version of the Protocol it supports.  The receiver replies with
    the version that will be used--either the one offered if
    supported or its own (lower) version otherwise.  Protocol
    handling code adhering to the Protocol specified herein supports
    major version |gb-major|, minor version |gb-minor|.

.. c:function:: int send(u32 len, char *data);

   Sends a stream of data from the AP to the device.

Greybus Raw Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^

Table :num:`table-raw-operation-type` describes the Greybus
Raw operation types and their values. A message type consists of an
operation type combined with a flag (0x80) indicating whether the
operation is a request or a response.

.. figtable::
    :nofig:
    :label: table-raw-operation-type
    :caption: Raw Operation Types
    :spec: l l l

    ===========================  =============  ==============
    Raw Operation Type           Request Value  Response Value
    ===========================  =============  ==============
    Invalid                      0x00           0x80
    Protocol Version             0x01           0x81
    Send                         0x02           0x82
    (all other values reserved)  0x04..0x7f     0x84..0xff
    ===========================  =============  ==============

..

Greybus Raw Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Raw Protocol version operation allows the Protocol
handling software on both ends of a connection to negotiate the
version of the Raw Protocol to use.

Greybus Raw Protocol Version Request
""""""""""""""""""""""""""""""""""""

Table :num:`table-raw-version-request` defines the Greybus Raw
version request payload. The request supplies the greatest major and
minor version of the Raw Protocol supported by the requester.

.. figtable::
    :nofig:
    :label: table-raw-version-request
    :caption: Raw Protocol Version Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Offered Raw Protocol major version
    1        version_minor   1       |gb-minor|      Offered Raw Protocol minor version
    =======  ==============  ======  ==========      ===========================

..

Greybus Raw Protocol Version Response
"""""""""""""""""""""""""""""""""""""

The Greybus Raw Protocol version response payload contains two
one-byte values, as defined in table
:num:`table-raw-protocol-version-response`.
A Greybus Raw controller adhering to the Protocol specified herein
shall report major version |gb-major|, minor version |gb-minor|.

.. figtable::
    :nofig:
    :label: table-raw-protocol-version-response
    :caption: Raw Protocol Version Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        version_major   1       |gb-major|      Raw Protocol major version
    1        version_minor   1       |gb-minor|      Raw Protocol minor version
    =======  ==============  ======  ==========      ===========================

..

Greybus Raw Send Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Raw send operation sends data from the requester to the
respondent.

Greybus Raw Send Request
""""""""""""""""""""""""

Table :num:`table-raw-send-request` defines the Greybus Raw Send
request.  The request supplies size of the data that is sent to the
device, and the data itself.

.. figtable::
    :nofig:
    :label: table-raw-send-request
    :caption: Raw Send Protocol Transfer Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        len             4       Number          length in bytes of the data field
    4        data            *len*   Data            data to be sent
    =======  ==============  ======  ==========      ===========================

..

Greybus Raw Send Response
"""""""""""""""""""""""""

The Greybus Raw send response message has no payload.
