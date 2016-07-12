Power Supply Protocol
---------------------

This section defines the operations used on a connection implementing
the Greybus Power Supply Protocol. This Protocol allows to manage a
power supply controller present on a Module. The Protocol consists of few basic
operations, whose request and response message formats are defined
here.

Conceptually, the operations in the Greybus Power Supply Protocol are:

.. c:function:: int ping(void);

    See :ref:`greybus-protocol-ping-operation`.

.. c:function:: int get_power_supplies(u8 *psy_count);

    Returns a value indicating the number of devices that this power supply
    adapter controls.

.. c:function:: int get_description(u8 psy_id, struct gb_power_supply_description *description);

    Returns set of values related to a specific power supply controller defined
    by psy_id in the power supply adapter. The return structure elements shall
    map the fields of :ref:`power-supply-description`

.. c:function:: int get_property_descriptors(u8 psy_id, u8 *properties_count, struct gb_power_supply_property_desc *props);

    Returns the number of property descriptors and set of descriptors
    related to a specific power supply defined by psy_id in the power supply
    adapter. The property descriptor shall map to the fields of
    :ref:`power-supply-property-descriptor`. The number of properties can be
    zero.

.. c:function:: int get_property(u8 psy_id, u8 property, u32 *prop_val);

    Returns the current value of a property in a specific psy_id in the power
    supply adapter.

.. c:function:: int set_property(u8 psy_id, u8 property, u32 prop_val);

    It sets the value of a given property in a specified psy_id, if the property
    is not described in is descriptor as writable, this operation shall be
    discarded.

.. c:function:: int event(u8 *type);

    Input event sent from the device to host asynchronously.

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
    Ping                         0x00           0x80
    Reserved                     0x01           0x81
    Get Power Supplies           0x02           0x82
    Get Description              0x03           0x83
    Get Property Descriptors     0x04           0x84
    Get Property                 0x05           0x85
    Set Property                 0x06           0x86
    Event                        0x07           N/A
    (all other values reserved)  0x08..0x7e     0x88..0xfe
    Invalid                      0x7f           0xff
    ===========================  =============  ==============

..

Greybus Power Supply Ping Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Power Supply Ping Operation is the
:ref:`greybus-protocol-ping-operation` for the Power Supply Protocol.
It consists of a request containing no payload, and a response
with no payload that indicates a successful result.

Greybus Power Supply Get Power Supplies Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus power supply get power supplies operation allows requester to
determine the number of power supply devices controlled by the power supply
adapter. Power Supply Controllers shall be numbered sequentially starting at
zero and ending at psy_count less one.

Greybus Power Supply Get Power Supplies Request
"""""""""""""""""""""""""""""""""""""""""""""""

The Greybus power supply get power supplies request message has no payload.

Greybus Power Supply Get Power Supplies Response
""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus power supply get power supplies response contains a 1-byte value
that represents the number of power supply being controlled as defined in
Table :num:`table-power-supply-get-power-supplies-response`.

.. figtable::
    :nofig:
    :label: table-power-supply-get-power-supplies-response
    :caption: Power Supply Get Power Supplies Response
    :spec: l l c c l

    =======  ================  ======  ==========      ===========================
    Offset   Field             Size    Value           Description
    =======  ================  ======  ==========      ===========================
    0        psy_count         1       Number          Number of Power Supplies controlled
    =======  ================  ======  ==========      ===========================

..

Greybus Power Supply Get Description Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus power supply get description operation allows requester to determine
a set of configuration parameters from a specific power supply controller.

Greybus Power Supply Get Description Request
""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-get-description-request` describes the
Greybus Power Supply Get Description request. The request supplies only the
psy_id which is an unique identifier between 0 and power supplies_count less one.

.. figtable::
    :nofig:
    :label: table-power-supply-get-description-request
    :caption: Power Supply Get Description Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        psy_id          1       Number          Power Supply identification Number
    =======  ==============  ======  ==========      ===========================

..

.. _power-supply-description:

Greybus Power Supply Get Description Response
"""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-get-description-response` describes the
Greybus Power Supply Get Description response. The response payload
contains a set of parameters representing the configuration of a
power supply.


.. figtable::
    :nofig:
    :label: table-power-supply-get-description-response
    :caption: Power Supply Get Description Response
    :spec: l l c c l

    =======  ================  ======  ==========      ===========================
    Offset   Field             Size    Value           Description
    =======  ================  ======  ==========      ===========================
    0        manufacturer      32      UTF-8           Manufacturer name
    32       model             32      UTF-8           Model name
    64       serial_number     32      UTF-8           Serial Number
    96       type              2       Number          :ref:`power-supply-type`
    98       properties_count  1       Number          Number of properties
    =======  ================  ======  ==========      ===========================

..

.. _power-supply-type:

Greybus Power Supply Type
"""""""""""""""""""""""""

Table :num:`table-power-supply-type` describes the defined power supply
types defined for Greybus power supply adapters.

.. figtable::
    :nofig:
    :label: table-power-supply-type
    :caption: Power Supply Type
    :spec: l l

    ================================   ======
    Power Supply Type                  Value
    ================================   ======
    GB_POWER_SUPPLY_UNKNOWN_TYPE       0x0000
    GB_POWER_SUPPLY_BATTERY_TYPE       0x0001
    GB_POWER_SUPPLY_UPS_TYPE           0x0002
    GB_POWER_SUPPLY_MAINS_TYPE         0x0003
    GB_POWER_SUPPLY_USB_TYPE           0x0004
    GB_POWER_SUPPLY_USB_DCP_TYPE       0x0005
    GB_POWER_SUPPLY_USB_CDP_TYPE       0x0006
    GB_POWER_SUPPLY_USB_ACA_TYPE       0x0007
    GB_POWER_SUPPLY_USB_HVDCP_TYPE     0x0008
    GB_POWER_SUPPLY_USB_TYPE_C_TYPE    0x0009
    GB_POWER_SUPPLY_USB_PD_TYPE        0x000A
    GB_POWER_SUPPLY_USB_PD_DRP_TYPE    0x000B
    GB_POWER_SUPPLY_WIRELESS_TYPE      0x000C
    ================================   ======

..


Greybus Power Supply Get Property Descriptors Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus power supply get property descriptors operation allows requester to
determine the set of properties supported by the power supply controller and if
the property support the :ref:Set Property Operation.

Greybus Power Supply Get Property Descriptors Request
"""""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-get-prop-descriptors-request` describes the
Greybus Power Supply Get Property Descriptors request. The request supplies only
the psy_id which is an unique identifier between 0 and power supplies_count less
one.

.. figtable::
    :nofig:
    :label: table-power-supply-get-prop-descriptors-request
    :caption: Power Supply Get Property Descriptor Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        psy_id          1       Number          Power Supply identification Number
    =======  ==============  ======  ==========      ===========================

..

Greybus Power Supply Get Property Descriptors Response
""""""""""""""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-get-props-descriptors-response` describes the
Greybus Power Supply Get Property Descriptors response. The response payload
contains the number and the properties descriptors in this response.


.. figtable::
    :nofig:
    :label: table-power-supply-get-props-descriptors-response
    :caption: Power Supply Get Property Descriptors Response
    :spec: l l c c l

    =======  ================  ======  ==========      ===========================
    Offset   Field             Size    Value           Description
    =======  ================  ======  ==========      ===========================
    0        properties_count  1       Number          Number of properties descriptors
    1        props[N]          (2*N)   Structure       N Property Descriptors :ref:`power-supply-property-descriptor`
    =======  ================  ======  ==========      ===========================

..

.. _power-supply-property-descriptor:

Greybus Power Supply Property Descriptor
""""""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-property-descriptor` describes a property
descriptor which contains the descriptor type and writable indication.

.. figtable::
    :nofig:
    :label: table-power-supply-property-descriptor
    :caption: Power Supply Property Descriptor
    :spec: l l c c l

    =======  ================  ======  ==========      ===========================
    Offset   Field             Size    Value           Description
    =======  ================  ======  ==========      ===========================
    0        property          1       Number          :ref:`power-supply-property`
    1        is_writable       1       Number          Writable Property
    =======  ================  ======  ==========      ===========================

..

.. _power-supply-property:

Greybus Power Supply Property Type
""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-property` describes the defined power supply
properties for the Greybus power supply adapters. All voltages, currents,
charges, energies, time and temperatures in micro-volt(|mu| V),
micro-ampere(|mu| A), micro-ampere-hour(|mu| Ah), micro-watt-hour(|mu| Wh),
seconds and tenths of degrees Celsius unless otherwise stated.

.. figtable::
    :nofig:
    :label: table-power-supply-property
    :caption: Power Supply Property Type
    :spec: l l l

    =================================================== ====== ========================
    Power Supply Property                               Value  Description
    =================================================== ====== ========================
    GB_POWER_SUPPLY_PROP_STATUS                         0x00   :ref:`power-supply-status`
    GB_POWER_SUPPLY_PROP_CHARGE_TYPE                    0x01   :ref:`power-supply-charge`
    GB_POWER_SUPPLY_PROP_HEALTH                         0x02   :ref:`power-supply-health`
    GB_POWER_SUPPLY_PROP_PRESENT                        0x03   Presence indicator (1 is present, 0 is not present).
    GB_POWER_SUPPLY_PROP_ONLINE                         0x04   Online indicator (1 is online, 0 is not online)
    GB_POWER_SUPPLY_PROP_AUTHENTIC                      0x05   Authentic indicator (1 is authentic, 0 is not authentic)
    GB_POWER_SUPPLY_PROP_TECHNOLOGY                     0x06   :ref:`power-supply-technology`
    GB_POWER_SUPPLY_PROP_CYCLE_COUNT                    0x07   A complete charge cycle counter
    GB_POWER_SUPPLY_PROP_VOLTAGE_MAX                    0x08   Value from measure and retain maximum Voltage
    GB_POWER_SUPPLY_PROP_VOLTAGE_MIN                    0x09   Value from measure and retain minimum Voltage
    GB_POWER_SUPPLY_PROP_VOLTAGE_MAX_DESIGN             0x0A   Maximum value for Voltage by design
    GB_POWER_SUPPLY_PROP_VOLTAGE_MIN_DESIGN             0x0B   Minimum value for Voltage by design
    GB_POWER_SUPPLY_PROP_VOLTAGE_NOW                    0x0C   Instantaneous Voltage value
    GB_POWER_SUPPLY_PROP_VOLTAGE_AVG                    0x0D   Average Voltage value
    GB_POWER_SUPPLY_PROP_VOLTAGE_OCV                    0x0E   Open Circuit Voltage
    GB_POWER_SUPPLY_PROP_VOLTAGE_BOOT                   0x0F   Voltage during boot
    GB_POWER_SUPPLY_PROP_CURRENT_MAX                    0x10   Maximum Current Value
    GB_POWER_SUPPLY_PROP_CURRENT_NOW                    0x11   Instantaneous Current Value
    GB_POWER_SUPPLY_PROP_CURRENT_AVG                    0x12   Average Current value
    GB_POWER_SUPPLY_PROP_CURRENT_BOOT                   0x13   Current measured at boot
    GB_POWER_SUPPLY_PROP_POWER_NOW                      0x14   Instantaneous Power consumption
    GB_POWER_SUPPLY_PROP_POWER_AVG                      0x15   Average Power consumption
    GB_POWER_SUPPLY_PROP_CHARGE_FULL_DESIGN             0x16   Threshold for full charge by design
    GB_POWER_SUPPLY_PROP_CHARGE_EMPTY_DESIGN            0x17   Threshold for empty charge value by design
    GB_POWER_SUPPLY_PROP_CHARGE_FULL                    0x18   Value from measure and retain maximum charge
    GB_POWER_SUPPLY_PROP_CHARGE_EMPTY                   0x19   Value from measure and retain minimum charge
    GB_POWER_SUPPLY_PROP_CHARGE_NOW                     0x1A   Instantaneous charge value
    GB_POWER_SUPPLY_PROP_CHARGE_AVG                     0x1B   Average charge value
    GB_POWER_SUPPLY_PROP_CHARGE_COUNTER                 0x1C   Charge counter
    GB_POWER_SUPPLY_PROP_CONSTANT_CHARGE_CURRENT        0x1D   Charge Current programmed by charger
    GB_POWER_SUPPLY_PROP_CONSTANT_CHARGE_CURRENT_MAX    0x1E   Maximum charge current supported
    GB_POWER_SUPPLY_PROP_CONSTANT_CHARGE_VOLTAGE        0x1F   Charge Voltage programmed by charger
    GB_POWER_SUPPLY_PROP_CONSTANT_CHARGE_VOLTAGE_MAX    0x20   Maximum charge voltage supported
    GB_POWER_SUPPLY_PROP_CHARGE_CONTROL_LIMIT           0x21   Current charge control limit
    GB_POWER_SUPPLY_PROP_CHARGE_CONTROL_LIMIT_MAX       0x22   Maximum charge control limit
    GB_POWER_SUPPLY_PROP_INPUT_CURRENT_LIMIT            0x23   Input current limit programmed by charger
    GB_POWER_SUPPLY_PROP_ENERGY_FULL_DESIGN             0x24   Threshold for full energy by design
    GB_POWER_SUPPLY_PROP_ENERGY_EMPTY_DESIGN            0x25   Threshold for empty energy by design
    GB_POWER_SUPPLY_PROP_ENERGY_FULL                    0x26   Value from measure and retain maximum energy
    GB_POWER_SUPPLY_PROP_ENERGY_EMPTY                   0x27   Value from measure and retain minimum energy
    GB_POWER_SUPPLY_PROP_ENERGY_NOW                     0x28   Instantaneous energy value
    GB_POWER_SUPPLY_PROP_ENERGY_AVG                     0x29   Average energy value
    GB_POWER_SUPPLY_PROP_CAPACITY                       0x2A   Capacity in percents
    GB_POWER_SUPPLY_PROP_CAPACITY_ALERT_MIN             0x2B   Minimum capacity alert value in percents
    GB_POWER_SUPPLY_PROP_CAPACITY_ALERT_MAX             0x2C   Maximum capacity alert value in percents
    GB_POWER_SUPPLY_PROP_CAPACITY_LEVEL                 0x2D   :ref:`power-supply-capacity`
    GB_POWER_SUPPLY_PROP_TEMP                           0x2E   Temperature
    GB_POWER_SUPPLY_PROP_TEMP_MAX                       0x2F   Maximum operable temperature
    GB_POWER_SUPPLY_PROP_TEMP_MIN                       0x30   Minimum operable temperature
    GB_POWER_SUPPLY_PROP_TEMP_ALERT_MIN                 0x31   Minimum temperature alert
    GB_POWER_SUPPLY_PROP_TEMP_ALERT_MAX                 0x32   Maximum temperature alert
    GB_POWER_SUPPLY_PROP_TEMP_AMBIENT                   0x33   Ambient temperature
    GB_POWER_SUPPLY_PROP_TEMP_AMBIENT_ALERT_MIN         0x34   Minimum ambient temperature alert
    GB_POWER_SUPPLY_PROP_TEMP_AMBIENT_ALERT_MAX         0x35   Maximum ambient temperature alert
    GB_POWER_SUPPLY_PROP_TIME_TO_EMPTY_NOW              0x36   Instantaneous seconds left to be considered empty
    GB_POWER_SUPPLY_PROP_TIME_TO_EMPTY_AVG              0x37   Average seconds left to be considered empty
    GB_POWER_SUPPLY_PROP_TIME_TO_FULL_NOW               0x38   Instantaneous seconds left to be considered full
    GB_POWER_SUPPLY_PROP_TIME_TO_FULL_AVG               0x39   Average seconds left to be considered full
    GB_POWER_SUPPLY_PROP_TYPE                           0x3A   :ref:`power-supply-type`
    GB_POWER_SUPPLY_PROP_SCOPE                          0x3B   :ref:`power-supply-scope`
    GB_POWER_SUPPLY_PROP_CHARGE_TERM_CURRENT            0x3C   Charge Termination current
    GB_POWER_SUPPLY_PROP_CALIBRATE                      0x3D   Calibration status
    GB_POWER_SUPPLY_PROP_USB_HC                         0x3E   High Current USB
    GB_POWER_SUPPLY_PROP_USB_OTG                        0x3F   OTG boost property
    GB_POWER_SUPPLY_PROP_CHARGE_ENABLED                 0x40   Control charging status
    =================================================== ====== ========================

..

.. _power-supply-status:

Greybus Power Supply Property Status
""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-property-status` describes the defined power
supply status values available for Greybus power supply adapters.

.. figtable::
    :nofig:
    :label: table-power-supply-property-status
    :caption: Power Supply Property Status
    :spec: l l

    =======================================  ======
    Power Supply Status                      Value
    =======================================  ======
    GB_POWER_SUPPLY_STATUS_UNKNOWN           0x0000
    GB_POWER_SUPPLY_STATUS_CHARGING          0x0001
    GB_POWER_SUPPLY_STATUS_DISCHARGING       0x0002
    GB_POWER_SUPPLY_STATUS_NOT_CHARGING      0x0003
    GB_POWER_SUPPLY_STATUS_FULL              0x0004
    =======================================  ======

..
.. _power-supply-charge:

Greybus Power Supply Property Charge
""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-property-charge` describes the defined power
supply charge types available for Greybus power supply adapters.

.. figtable::
    :nofig:
    :label: table-power-supply-property-charge
    :caption: Power Supply Property Charge
    :spec: l l

    =======================================  ======
    Power Supply Charge                      Value
    =======================================  ======
    GB_POWER_SUPPLY_CHARGE_TYPE_NONE         0x0001
    GB_POWER_SUPPLY_CHARGE_TYPE_TRICKLE      0x0002
    GB_POWER_SUPPLY_CHARGE_TYPE_FAST         0x0003
    =======================================  ======

..
.. _power-supply-health:

Greybus Power Supply Property Health
""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-property-health` describes the defined power
supply health values available for Greybus power supply adapters.

.. figtable::
    :nofig:
    :label: table-power-supply-property-health
    :caption: Power Supply Property Health
    :spec: l l

    ============================================  ======
    Power Supply Health                           Value
    ============================================  ======
    GB_POWER_SUPPLY_HEALTH_UNKNOWN                0x0000
    GB_POWER_SUPPLY_HEALTH_GOOD                   0x0001
    GB_POWER_SUPPLY_HEALTH_OVERHEAT               0x0002
    GB_POWER_SUPPLY_HEALTH_DEAD                   0x0003
    GB_POWER_SUPPLY_HEALTH_OVERVOLTAGE            0x0004
    GB_POWER_SUPPLY_HEALTH_UNSPEC_FAILURE         0x0005
    GB_POWER_SUPPLY_HEALTH_COLD                   0x0006
    GB_POWER_SUPPLY_HEALTH_WATCHDOG_TIMER_EXPIRE  0x0007
    GB_POWER_SUPPLY_HEALTH_SAFETY_TIMER_EXPIRE    0x0008
    ============================================  ======

..
.. _power-supply-technology:

Greybus Power Supply Property Technology
""""""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-property-tech` describes the defined power supply
technologies available for Greybus power supply adapters.

.. figtable::
    :nofig:
    :label: table-power-supply-property-tech
    :caption: Power Supply Property Technology
    :spec: l l

    ============================================  ======
    Power Supply Technology                       Value
    ============================================  ======
    GB_POWER_SUPPLY_TECH_UNKNOWN                  0x0000
    GB_POWER_SUPPLY_TECH_NiMH                     0x0001
    GB_POWER_SUPPLY_TECH_LION                     0x0002
    GB_POWER_SUPPLY_TECH_LIPO                     0x0003
    GB_POWER_SUPPLY_TECH_LiFe                     0x0004
    GB_POWER_SUPPLY_TECH_NiCd                     0x0005
    GB_POWER_SUPPLY_TECH_LiMn                     0x0006
    ============================================  ======

..

.. _power-supply-capacity:

Greybus Power Supply Property Capacity
""""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-property-capacity` describes the defined power
supply capacity levels available for battery adapters.

.. figtable::
    :nofig:
    :label: table-power-supply-property-capacity
    :caption: Power Supply Property Capacity
    :spec: l l

    ============================================  ======
    Power Supply Capacity                         Value
    ============================================  ======
    GB_POWER_SUPPLY_CAPACITY_LEVEL_UNKNOWN        0x0000
    GB_POWER_SUPPLY_CAPACITY_LEVEL_CRITICAL       0x0001
    GB_POWER_SUPPLY_CAPACITY_LEVEL_LOW            0x0002
    GB_POWER_SUPPLY_CAPACITY_LEVEL_NORMAL         0x0003
    GB_POWER_SUPPLY_CAPACITY_LEVEL_HIGH           0x0004
    GB_POWER_SUPPLY_CAPACITY_LEVEL_FULL           0x0005
    ============================================  ======

..
.. _power-supply-scope:

Greybus Power Supply Property Scope
"""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-property-scope` describes the defined power supply
scopes available for Greybus power supply adapters.

.. figtable::
    :nofig:
    :label: table-power-supply-property-scope
    :caption: Power Supply Property Scope
    :spec: l l

    ============================================  ======
    Power Supply Scope                            Value
    ============================================  ======
    GB_POWER_SUPPLY_COPE_UNKNOWN                  0x0000
    GB_POWER_SUPPLY_COPE_SYSTEM                   0x0001
    GB_POWER_SUPPLY_COPE_DEVICE                   0x0002
    ============================================  ======

..

Greybus Power Supply Get Property Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus power supply get property operation allows requester to determine
the current value of a property supported by the power supply controller.

Greybus Power Supply Get Property Request
"""""""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-get-property-request` describes the Greybus Power
Supply Get Property request. The request supplies only the psy_id which is an
unique identifier between 0 and psy_count less one and the property to fetch the
value.

.. figtable::
    :nofig:
    :label: table-power-supply-get-property-request
    :caption: Power Supply Get Property Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        psy_id          1       Number          Power Supply identification Number
    1        property        1       Number          :ref:`power-supply-property`
    =======  ==============  ======  ==========      ===========================

..

Greybus Power Supply Get Property Response
""""""""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-get-property-response` describes the Greybus
Power Supply Get Property response. The response returns the current value of
the property issued in the request.

.. figtable::
    :nofig:
    :label: table-power-supply-get-property-response
    :caption: Power Supply Get Property Response
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        prop_val        4       Number          Property value
    =======  ==============  ======  ==========      ===========================

..

Greybus Power Supply Set Property Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus power supply set property operation allows requester to change
the current value of a property supported by the power supply controller.
This operation shall fail if the property is not set as writable.

Greybus Power Supply Set Property Request
"""""""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-set-property-request` describes the
Greybus Power Supply Set Property request. The request supplies the
psy_id which is an unique identifier between 0 and power supplies_count less one,
the property to alter and the new value.

.. figtable::
    :nofig:
    :label: table-power-supply-set-property-request
    :caption: Power Supply Set Property Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        psy_id          1       Number          Power Supply identification Number
    1        property        1       Number          :ref:`power-supply-property`
    2        prop_val        4       Number          Property value
    =======  ==============  ======  ==========      ===========================

..

Greybus Power Supply Set Property Response
""""""""""""""""""""""""""""""""""""""""""

The Greybus power supply Set Property response message has no payload.

Greybus Power Supply Event Request
""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-event-request` defines the Greybus Power Supply
Event request. The request payload supplies two 1-byte fields that
represent the psy_id and event bit mask.

.. figtable::
    :nofig:
    :label: table-power-supply-event-request
    :caption: Power Supply Event Request
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        psy_id          1       Number          Power Supply identification Number
    1        event           1       Bit Mask        :ref:`power-supply-event-bits`
    =======  ==============  ======  ==========      ===========================

..

.. _power-supply-event-bits:

Greybus Power Supply Event Bit Masks
""""""""""""""""""""""""""""""""""""

Table :num:`table-power-supply-event-bit-mask` defines the bit masks which
specify the set of events that occurred in the sending controller.

.. figtable::
    :nofig:
    :label: table-power-supply-event-bit-mask
    :caption: Power Supply Protocol Event Bit Mask
    :spec: l l l

    ===============================  =============================  ===============
    Symbol                           Brief Description              Mask Value
    ===============================  =============================  ===============
    GB_POWER_SUPPLY_UPDATE           Properties Update Event        0x01
    |_|                              (All other values reserved)    0x02..0x80
    ===============================  =============================  ===============

..

