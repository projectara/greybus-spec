.. include:: defines.rst

.. _device-class-protocols:

Device Class Connection Protocols
=================================

This section defines a group of protocols whose purpose is to provide
a device abstraction for functionality commonly found on mobile
handsets. Modules which implement at least one of the protocols
defined in this section, and which do not implement any of the
protocols defined below in :ref:`bridged-phy-protocols`,
are said to be *device class conformant*.

Vibrator Protocol
-----------------

This section defines the operations used on a connection implementing
the Greybus vibrator protocol.  This protocol allows an AP to manage
a vibrator device present on a module.  The protocol is very simple,
and maps almost directly to the userspace HAL vibrator interface.

The operations in the Greybus vibrator protocol are:

.. c:function:: int get_version(u8 *major, u8 *minor);

    Returns the major and minor Greybus vibrator protocol version
    number supported by the vibrator adapter.

.. c:function:: int vibrator_on(u16 timeout_ms);

   Turns on the vibrator for the number of specified milliseconds.

.. c:function:: int vibrator_off(void);

    Turns off the vibrator immediately.

Greybus Vibrator Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This table describes the Greybus vibrator operation types and their
values. A message type consists of an operation type combined with a
flag (0x80) indicating whether the operation is a request or a response.

.. list-table::
   :header-rows: 1

   * - Descriptor Type
     - Request Value
     - Response Value
   * - Invalid
     - 0x00
     - 0x80
   * - Protocol version
     - 0x01
     - 0x81
   * - Vibrator On
     - 0x02
     - 0x82
   * - Vibrator Off
     - 0x03
     - 0x83

Greybus Vibrator Protocol Version Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus vibrator protocol version operation allows the AP to
determine the version of this protocol to which the vibrator adapter
complies.

Greybus Vibrator Protocol Version Request
"""""""""""""""""""""""""""""""""""""""""

The Greybus vibrator protocol version request contains no data beyond
the Greybus vibrator message header.

Greybus Vibrator Protocol Version Response
""""""""""""""""""""""""""""""""""""""""""

The Greybus vibrator protcol version response contains a status byte,
followed by two 1-byte values. If the value of the status byte is
non-zero, any other bytes in the response shall be ignored. A Greybus
vibrator adapter adhering to the protocol specified herein shall
report major version |gb-major|, minor version |gb-minor|.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description

   * - 0
     - status
     - 1
     - Number
     - Success, or reason for failure

   * - 1
     - version_major
     - 1
     - |gb-major|
     - Greybus vibrator protocol major version

   * - 2
     - version_minor
     - 1
     - |gb-minor|
     - Greybus vibrator protocol minor version

Greybus Vibrator On Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Vibrator on operation allows the AP to request the
vibrator be enabled for the specified number of milliseconds.

Greybus Vibrator On Control Request
"""""""""""""""""""""""""""""""""""

The Greybus Vibrator on request supplies the amount of time that the
vibrator should now be enabled for.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description

   * - 0
     - timeout_ms
     - 2
     - Number
     - timeout in milliseconds

Greybus Vibrator On Control Response
""""""""""""""""""""""""""""""""""""

The Greybus Vibrator on control response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description

   * - 0
     - status
     - 1
     - Number
     - Success, or reason for failure

Greybus Vibrator Off Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Vibrator off operation allows the AP to request the
vibrator be turned off as soon as possible.

Greybus Vibrator Off Control Request
""""""""""""""""""""""""""""""""""""

The Greybus Vibrator off request contains no data beyond the Greybus
Vibrator message header.

Greybus Vibrator Off Control Response
"""""""""""""""""""""""""""""""""""""

The Greybus Vibrator off control response contains only the status byte.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description

   * - 0
     - status
     - 1
     - Number
     - Success, or reason for failure

Battery Protocol
----------------

This section defines the operations used on a connection implementing
the Greybus battery protocol. This protocol allows an AP to manage a
battery device present on a module. The protocol consists of few basic
operations, whose request and response message formats are defined
here.

Conceptually, the operations in the Greybus battery protocol are:

.. c:function:: int get_version(u8 *major, u8 *minor);

    Returns the major and minor Greybus battery protocol version
    number supported by the battery adapter.

.. c:function:: int get_technology(u16 *technology);

    Returns a value indicating the technology type that this battery
    adapter controls.

.. c:function:: int get_status(u16 *status);

    Returns a value indicating the current status of the battery.

.. c:function:: int get_max_voltage(u32 *voltage);

    Returns a value indicating the maximum voltage that the battery supports.

.. c:function:: int get_percent_capacity(u32 *capacity);

    Returns a value indicating the current percent capacity of the
    battery.

.. c:function:: int get_temperature(u32 *temperature);

    Returns a value indicating the current temperature of the battery.

.. c:function:: int get_voltage(u32 *voltage);

    Returns a value indicating the current voltage of the battery.

.. c:function:: int get_current(u32 *current);

    Returns a value indicating the current current supplied or drawn
    of the battery.

.. c:function:: int get_total_capacity(u32 *capacity);

    Returns a value indicating the total capacity in mAh of the battery.

.. c:function:: int get_shutdown_temperature(u32 *temperature);

    Returns a value indicating the total capacity in mAh of the battery.

Greybus Battery Message Types
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This table describes the Greybus battery operation types and their
values. A message type consists of an operation type combined with a
flag (0x80) indicating whether the operation is a request or a response.

===========================  =============  ==============
Descriptor Type              Request Value  Response Value
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

The Greybus battery protocol version operation allows the AP to
determine the version of this protocol to which the battery adapter
complies.

Greybus Battery Protocol Version Request
""""""""""""""""""""""""""""""""""""""""

The Greybus battery protocol version request contains no data beyond
the Greybus battery message header.

Greybus Battery Protocol Version Response
"""""""""""""""""""""""""""""""""""""""""

The Greybus battery protcol version response contains a status byte,
followed by two 1-byte values. If the value of the status byte is
non-zero, any other bytes in the response shall be ignored. A Greybus
battery adapter adhering to the protocol specified herein shall report
major version |gb-major|, minor version |gb-minor|.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     - Number
     - Success, or reason for failure
   * - 1
     - version_major
     - 1
     - |gb-major|
     - Greybus battery protocol major version
   * - 2
     - version_minor
     - 1
     - |gb-minor|
     - Greybus battery protocol minor version

Greybus Battery Technology Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery technology operation allows the AP to determine
the details of the battery technology controller by the battery
adapter.

Greybus Battery Technology Request
""""""""""""""""""""""""""""""""""

The Greybus battery functionality request contains no data beyond the
battery message header.

Greybus Battery Technology Response
"""""""""""""""""""""""""""""""""""

The Greybus battery functionality response contains the status byte
and a 2-byte value that represents the type of battery being
controlled.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     - Number
     - Success, or reason for failure
   * - 1
     - technology
     - 2
     - Number
     - Greybus battery technology

Greybus Battery Technology Types
""""""""""""""""""""""""""""""""

This table describes the defined battery technologies defined for
Greybus battery adapters.  These values are taken directly from the
<linux/power_supply.h> header file.

.. list-table::
   :header-rows: 1

   * - Battery Type
     - Value
   * - Unknown
     - 0x0000
   * - NiMH
     - 0x0001
   * - LION
     - 0x0002
   * - LIPO
     - 0x0003
   * - LiFe
     - 0x0004
   * - NiCd
     - 0x0005
   * - LiMn
     - 0x0006

Greybus Battery Status Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery status operation allows the AP to determine the
status of the battery by the battery adapter.

Greybus Battery Status Request
""""""""""""""""""""""""""""""

The Greybus battery status request contains no data beyond the battery
message header.

Greybus Battery Status Response
"""""""""""""""""""""""""""""""

The Greybus battery status response contains the status byte and a
2-byte value that represents the status of battery being controlled.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     - Number
     - Success, or reason for failure
   * - 1
     - battery status
     - 2
     - Number
     - Greybus battery status

Greybus Battery Status Types
""""""""""""""""""""""""""""

This table describes the defined battery status values defined for
Greybus battery adapters.  These values are taken directly from the
<linux/power_supply.h> header file.

.. list-table::
   :header-rows: 1

   * - Battery Status
     - Value
   * - Unknown
     - 0x0000
   * - Charging
     - 0x0001
   * - Discharging
     - 0x0002
   * - Not Charging
     - 0x0003
   * - Full
     - 0x0004

Greybus Battery Max Voltage Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery Max Voltage operation allows the AP to determine
the maximum possible voltage of the battery.

Greybus Battery Max Voltage Request
"""""""""""""""""""""""""""""""""""

The Greybus battery max voltage request contains no data beyond the
battery message header.

Greybus Battery Max Voltage Response
""""""""""""""""""""""""""""""""""""

The Greybus battery max voltage response contains the status byte and
a 4-byte value that represents the maximum voltage of the battery
being controlled, in µV.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     - Number
     - Success, or reason for failure
   * - 1
     - max voltage
     - 4
     - Number
     - Greybus battery maximum voltage in µV

Greybus Battery Capacity Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery Capacity operation allows the AP to determine the
current capacity percent of the battery.

Greybus Battery Percent Capacity Request
""""""""""""""""""""""""""""""""""""""""

The Greybus battery capacity request contains no data beyond the
battery message header.

Greybus Battery Percent Capacity Response
"""""""""""""""""""""""""""""""""""""""""

The Greybus battery capacity response contains the status byte and a
4-byte value that represents the capacity of the battery being
controlled, in percentage.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     - Number
     - Success, or reason for failure
   * - 1
     - capacity
     - 4
     - Number
     - Greybus battery capacity in %

Greybus Battery Temperature Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery temperature operation allows the AP to determine
the current temperature of the battery.

Greybus Battery Temperature Request
"""""""""""""""""""""""""""""""""""

The Greybus battery temperature request contains no data beyond the
battery message header.

Greybus Battery Temperature Response
""""""""""""""""""""""""""""""""""""

The Greybus battery temperature response contains the status byte and
a 4-byte value that represents the temperature of the battery being
controlled, in ⅒℃.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     - Number
     - Success, or reason for failure
   * - 1
     - temperature
     - 4
     - Number
     - Greybus battery temperature in ⅒℃

Greybus Battery Voltage Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery Voltage operation allows the AP to determine the
current voltage of the battery.

Greybus Battery Voltage Request
"""""""""""""""""""""""""""""""

The Greybus battery voltage request contains no data beyond the
battery message header.

Greybus Battery Voltage Response
""""""""""""""""""""""""""""""""

The Greybus battery voltage response contains the status byte and a
4-byte value that represents the voltage of the battery being
controlled, in µV.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description
   * - 0
     - status
     - 1
     - Number
     - Success, or reason for failure
   * - 1
     - voltage
     - 4
     - Number
     - Greybus battery voltage in µV

Greybus Battery Current Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus battery Current operation allows the AP to determine the
current current of the battery.

Greybus Battery Current Request
"""""""""""""""""""""""""""""""

The Greybus battery current request contains no data beyond the
battery message header.

Greybus Battery Current Response
""""""""""""""""""""""""""""""""

The Greybus battery current response contains the status byte and a
4-byte value that represents the current of the battery being
controlled, in µA.

======  ========  ====  ===============================
Offset  Field     Size  Description
======  ========  ====  ===============================
0       status    1     Success, or reason for failure
1       capacity  4     Greybus battery current in µA
======  ========  ====  ===============================

Greybus Battery Total Capacity Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The Greybus battery total capacity operation allows the AP to determine
the total capacity of the battery.

Greybus Battery Total Capacity Request
""""""""""""""""""""""""""""""""""""""
The Greybus battery total capacity request contains no data beyond the
battery message header.

Greybus Battery Total Capacity Response
"""""""""""""""""""""""""""""""""""""""
The Greybus battery total capacity response contains the status byte and a
4-byte value that represents the total capacity of the battery being
controlled, in mAh.

======  ========  ====  ===============================
Offset  Field     Size  Description
======  ========  ====  ===============================
0       status    1     Success, or reason for failure
1       capacity  4     Greybus battery current in mAh
======  ========  ====  ===============================

Greybus Battery Shutdown Temperature Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The Greybus battery shutdown temperature operation allows the AP to
determine the total capacity of the battery.

Greybus Battery Shutdown Temperature Request
""""""""""""""""""""""""""""""""""""""""""""
The Greybus battery shutdown temperature request contains no data beyond
the battery message header.

Greybus Battery Shutdown Temperature Response
"""""""""""""""""""""""""""""""""""""""""""""
The Greybus battery shutdown temperature response contains the status
byte and a 4-byte value that represents the temperature at which the
attery will shutdown.

======  ===========  ====  =====================================
Offset  Field        Size  Description
======  ===========  ====  =====================================
0       status       1     Success, or reason for failure
1       temperature  4     Greybus battery shutdown temperature
======  ===========  ====  =====================================

Audio Protocol
--------------

TBD

Baseband Modem Protocol
-----------------------

TBD

Bluetooth Protocol
------------------

TBD

Camera Protocol
---------------

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

Keymaster Protocol
------------------

TBD

Lights Protocol
---------------

TBD

NFC Protocol
------------

TBD

Power Profile Protocol
----------------------

TBD

Sensors Protocol
----------------

TBD

WiFi Protocol
-------------

TBD

