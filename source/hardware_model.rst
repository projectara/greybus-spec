.. highlight:: text

Greybus Hardware Model
======================

Overview
^^^^^^^^

An implementation of the Project Ara platform which complies with the
Greybus Specification is a *Greybus System*.

A Greybus System has the following physical components:

- A :ref:`Frame <glossary-frame>`, which contains at least one
  :ref:`Slot <glossary-slot>`.

- A collection of Slots on the Frame, each of which contains at least
  one :ref:`Interface Block <glossary-interface>`. Each Interface
  Block contains several pins, which allow for power distribution,
  module hotplug detection, and communication between the Frame and
  inserted Modules.

Interface Blocks are separated into Slots by the spine and ribs of the
Frame.  The Frame additionally contains the :ref:`SVC <glossary-svc>`,
which, in collaboration with the :ref:`AP Module
<glossary-ap-module>`, manages the |unipro| network in the Frame,
along with other physical signals present on the Interface Blocks.

The following sections define abstract representations of state
present in a Greybus System for use within the Greybus Specification.

- The first subsection, :ref:`hardware-model-interface-states`,
  defines the *Interface State* data structure, which represents
  components in, and state managed by, a Greybus System that are
  related to each Interface Block.

  Though Interface States are an abstraction, the dynamics of a Greybus
  System effect changes to Interface States as defined in the remainder
  of this document. For this reason, the phrase "Interface States in a
  Greybus System" is sometimes used to denote the abstract states
  associated with a particular Greybus System at a given time.

- The subsequent section, :ref:`hardware-model-initial-states`,
  defines the initial values of each Interface State.

Subsequent definitions within the Greybus Specification define how
certain Greybus :ref:`Operations <glossary-operation>` affect
Interface States in a Greybus System.

.. _hardware-model-interface-states:

Interface States
^^^^^^^^^^^^^^^^

An *Interface State* is a tuple containing "sub-state" values.

As stated above, each Interface Block in a Greybus System has an
associated Interface State. The value of an Interface State varies
over time, but its contents are well defined before a Greybus
Operation's request is transmitted or its response is received.

Changes to the value of an Interface State are defined by any
Operation which may alter an Interface State. The initial value of
each Interface State is given in
:ref:`hardware-model-initial-states`. Some Operations additionally
define transient changes to Interface State values that take place
after the request is transmitted, but before the response is received.

The names of the sub-states of each Interface State are as follows,
along with an overview of their meaning within a Greybus System.

.. NOTE: the WAKE signal is intentionally under-specified at the
   present. There is enough here for module activation by the SVC
   sending a "wake out pulse" for enough time to cause a power-on
   reset of the bridge ASIC. Later work to integrate time-sync and
   power management into the hardware model will need to extend the
   WAKE sub-state and the operation definitions that rely on it under
   the hood.

- V_SYS: whether system power is supplied from the Frame to the
  Interface Block.
- V_CHG: whether the Interface Block can supply power to the Frame.
- WAKE: whether the Frame is "activating" the Interface Block for
  communication via Greybus.
- DETECT: whether the SVC has sensed that a Module is attached to the
  Interface Block.
- UNIPRO: a simplified representation of the state of the |unipro|
  port within the Frame connected to the Interface Block.
- REFCLK: whether the Frame is providing a reference clock signal to
  the Interface Block.
- RELEASE: indicates whether the Frame is attempting to physically
  eject a Module attached to the Interface Block.
- INTF_TYPE: an indicator of what communication is supported by a
  Module connected to the Interface Block, if any.
- ORDER: If the Interface Block is attached to a Module, an indicator
  of whether this is the "primary interface" or a "secondary
  interface" to the Module.
- MAILBOX: the value of a special-purpose and Greybus
  implementation-specific |unipro| DME attribute used by Modules as a
  non-CPort based means of communication with the Frame.

An Interface State is written as a tuple as follows::

  (V_SYS=<v_sys>, V_CHG=<v_chg>, WAKE=<wake>,
   DETECT=<detect>, UNIPRO=<unipro>, REFCLK=<refclk>,
   RELEASE=<release>, INTF_TYPE=<type>, ORDER=<ord>,
   MAILBOX=<mbox>)

Where in each case <v_sys>, <v_chg>, etc. are the values of the
corresponding sub-states.

For brevity, the phrase "an Interface State's V_SYS" is used to denote
the value of the V_SYS sub-state of that Interface State, and
similarly for the other sub-states.

V_SYS
"""""

The values of the V_SYS sub-state are given in Table
:num:`table-interface-state-vsys`.

.. figtable::
     :nofig:
     :label: table-interface-state-vsys
     :caption: V_SYS sub-state values

     =========  =======================================================
     Value      Description
     =========  =======================================================
     V_SYS_ON   The Frame supplies system power to the Interface Block
     V_SYS_OFF  The Frame does not supply system power to the Interface Block
     =========  =======================================================

..

The value of the V_SYS sub-state is set by the SVC.

The V_SYS sub-state of an Interface State represents the state of
system power as supplied by the Frame to the corresponding Interface
Block via the Interface Block's connection to the system power bus.

Modules may draw power from Interface Blocks, depending on the V_SYS
sub-state of the corresponding Interface State. A Module can only draw
power from an Interface Block whose Interface State's V_SYS sub-state
is V_SYS_ON.

V_CHG
"""""

The values of the V_CHG sub-state are given in Table
:num:`table-interface-state-vchg`.

.. figtable::
   :nofig:
   :label: table-interface-state-vchg
   :caption: V_CHG sub-state values

   =========  ================================================
   Value      Description
   =========  ================================================
   V_CHG_ON   The Interface Block may supply power to the Frame
   V_CHG_OFF  The Interface Block cannot supply power to the Frame
   =========  ================================================
..

The value of the V_CHG sub-state is set by the SVC.

The V_CHG sub-state of an Interface State represents whether power is
supplied by an Interface Block to the Frame, via the Interface Block's
charger power bus.

The Frame may draw power from an Interface Block, depending on the
V_CHG sub-state of the corresponding Interface State. The Frame can
only draw power from an Interface Block whose Interface State's V_CHG
sub-state is V_CHG_ON.

WAKE
""""

The values of the WAKE sub-state are given in Table
:num:`table-interface-state-wake`.

.. figtable::
   :nofig:
   :label: table-interface-state-wake
   :caption: WAKE sub-state values

   ==============  ================================================
   Value           Description
   ==============  ================================================
   WAKE_UNDEFINED  Module is not attached, or power and clock are not supplied
   WAKE_ACTIVE     Wake signal is asserted to an attached, powered, and clocked Module
   WAKE_INACTIVE   Wake signal is deasserted to an attached, powered, and clocked Module
   ==============  ================================================
..

The WAKE sub-state of an Interface State represents the state of a
signal used to initialize and power manage an attached Module. The
value of the WAKE sub-state is controlled by the SVC and any Module
attached to the Interface Block.

The WAKE sub-state is only meaningful when an Interface State's V_SYS
is V_SYS_ON and REFCLK is REFCLK_ON. The value of the WAKE sub-state
for other combinations of V_SYS and REFCLK values is always
WAKE_UNDEFINED.

If WAKE is not WAKE_UNDEFINED, the SVC may assert and deassert the
WAKE sub-state by setting its value to WAKE_ACTIVE, then setting it to
WAKE_INACTIVE after some duration. This is called a "WAKE pulse". When
the duration of the WAKE pulse exceeds an implementation-defined
threshold, this is a signal to the attached Module to initiate (or
re-initiate) Greybus communication, as described in later sections.

.. XXX this "as described" descriptions are currently not described
   anywhere; later updates will need to fix that once Interface States
   are in the spec as mechanism to do so.

DETECT
""""""

The values of the DETECT sub-state are given in Table
:num:`table-interface-state-detect`.

.. figtable::
   :nofig:
   :label: table-interface-state-detect
   :caption: DETECT sub-state values

   ========================  ================================================
   Value                     Description
   ========================  ================================================
   DETECT_UNKNOWN            Whether a Module is attached to the Interface Block is unknown
   DETECT_INACTIVE           No Module is currently attached to the Interface Block
   DETECT_ACTIVE             A Module is attached to the Interface Block
   ========================  ================================================
..

The DETECT sub-state of an Interface State represents the state of
signals used to determine whether the Interface Block currently has a
Module attached to it. This determination shall be performed by the
SVC. The means by which the SVC does so are implementation-defined.

UNIPRO
""""""

The values of the UNIPRO sub-state are given in Table
:num:`table-interface-state-unipro`.

.. figtable::
   :nofig:
   :label: table-interface-state-unipro
   :caption: UNIPRO sub-state values

   =============  ================================================
   Value          Description
   =============  ================================================
   UPRO_OFF       |unipro| port is powered off
   UPRO_DOWN      |unipro| port is powered on, and the link is down
   UPRO_LSS       |unipro| link startup sequence is ongoing between Module and Frame
   UPRO_LOST      |unipro| link loss was detected
   UPRO_UP        |unipro| link is established
   =============  ================================================
..

The value of the UNIPRO sub-state changes due to |unipro| protocol
communication exchanged between the Frame and any Modules attached to
the corresponding Interface Block.

Since all Greybus Protocols exchange data via |unipro| Messages, each
Interface Block contains the necessary signals to connect a Module
attached to that Interface Block to the |unipro| switch inside the
Frame.

The UNIPRO sub-state is an intentionally simplified abstraction for
the state of the |unipro| port inside the Frame.

Greybus communication between Modules (including the AP Module) is
only possible through Interface Blocks whose Interface State's UNIPRO
sub-state is UPRO_UP: it is only after the |unipro| link is
established that the CPort connections used by Greybus :ref:`Protocols
<glossary-protocol>` can be created.

Other UNIPRO sub-state values are used primarily during communication
between the SVC and AP during Module initialization, teardown, power
management, and error handling, as described in later sections.

A Module must be attached to an Interface Block its UNIPRO state to be
UPRO_LSS, UPRO_LOST, or UPRO_UP. When no Module is attached, UNIPRO is
either UPRO_OFF or UPRO_DOWN. The SVC can set the UNIPRO sub-state to
either UPRO_OFF or UPRO_DOWN at any time.

.. XXX those later sections don't have those descriptions yet. But
   they will need these definitions to exist in order to be written.

REFCLK
""""""

The values of the REFCLK sub-state are given in Table
:num:`table-interface-state-refclk`.

.. figtable::
   :nofig:
   :label: table-interface-state-refclk
   :caption: REFCLK sub-state values

   =============  ================================================
   Value          Description
   =============  ================================================
   REFCLK_ON      The Frame is supplying a reference clock signal to the Interface Block
   REFCLK_OFF     The Frame is not supplying a reference clock signal to the Interface Block
   =============  ================================================
..

The value of the REFCLK sub-state is set by the SVC.

The Frame may transmit a reference clock signal of an
implementation-defined frequency to any attached Modules through the
Interface Blocks the Modules are attached to. The REFCLK sub-state
indicates whether this transmission is currently ongoing.

RELEASE
"""""""

The values of the RELEASE sub-state are given in Table
:num:`table-interface-state-release`.

.. figtable::
   :nofig:
   :label: table-interface-state-release
   :caption: RELEASE sub-state values

   =============  ================================================
   Value          Description
   =============  ================================================
   RELEASE_ON     The Frame is supplying ejection signalling to the Interface Block
   RELEASE_OFF    The Frame is not supplying ejection signalling to the Interface Block
   =============  ================================================
..

The value of the RELEASE sub-state is set by the SVC.

The Frame may physically eject any attached Modules through
implementation-defined means. Any attached Module has exactly one
primary interface, and may contain secondary interfaces, as described
in :ref:`hardware-model-order`. The SVC may set the RELEASE sub-state
of an Interface Block which is the primary interface to an attached
module to RELEASE_ON for an implementation-defined duration, then set
RELEASE to RELEASE_OFF, in order to attempt to eject the attached
module from the Frame.

The consequences of setting an Interface State's RELEASE sub-state for
a secondary interface to a Module, or when the Interface State's
DETECT state is not DETECT_ACTIVE, are not defined by the Greybus
Specification.

INTF_TYPE
"""""""""

The values of the INTF_TYPE sub-state are given in Table
:num:`table-interface-state-type`.

.. figtable::
   :nofig:
   :label: table-interface-state-type
   :caption: INTF_TYPE sub-state values

   =============  ================================================
   Value          Description
   =============  ================================================
   IFT_UNKNOWN    Interface Block is not attached to Module, type not yet determined, or error occurred
   IFT_DUMMY      Interface Block is attached to Module; |unipro| communication is not possible
   IFT_UNIPRO     Interface Block is attached to Module; |unipro| communication is possible, but Greybus protocols are unsupported
   IFT_GREYBUS    Interface Block is attached to Module and supports Greybus Protocols
   =============  ================================================

..

The value of the INTF_TYPE sub-state is set by the SVC.

From the module perspective, the physical connections made to
Interface Blocks may not always support Greybus
communications. Additionally, Greybus Systems are intended to
concurrently support non-Greybus |unipro|\ -based application
protocols, such as UFS [JEDEC-UFS]_.

The INTF_TYPE sub-state encodes this distinction for each Interface
State.

When it is unknown whether a Module is attached to an Interface Block
(DETECT sub-state is DETECT_UNKNOWN), or it is known that no Module is
attached to an Interface Block (DETECT is DETECT_INACTIVE), the
INTF_TYPE sub-state is IFT_UNKNOWN.

Subsequent sections describe how the AP and SVC coordinate during the
module detection and boot process to allow the SVC to set the
INTF_TYPE sub-state, and how the AP is informed of its value.

.. XXX this isn't true yet -- but we need this text here so the later
   patches which explain this in terms of Greybus operations can refer
   to this sub-state.

.. _hardware-model-order:

ORDER
"""""

The values of the ORDER sub-state are given in Table
:num:`table-interface-state-order`.

.. figtable::
   :nofig:
   :label: table-interface-state-order
   :caption: ORDER sub-state values

   ===============  ================================================
   Value            Description
   ===============  ================================================
   ORDER_UNKNOWN    No Module is attached to the interface, or SVC cannot determine primary versus secondary interface status
   ORDER_PRIMARY    Interface is the primary interface to an inserted Module
   ORDER_SECONDARY  Interface is a secondary interface to an inserted Module
   ===============  ================================================
..

The value of the ORDER sub-state is set by the SVC.

A :ref:`Module <glossary-module>` may attach to one or more Interface
Blocks on a Slot in the Frame. Exactly one of these Interface Blocks
is the "primary interface" to the Module; signalling on this interface
may be used to physically eject the Module from the Frame. All other
Interface Blocks attached to the Module, if any, are "secondary
interfaces": they may communicate via Greybus to the AP and the SVC,
but the Frame cannot eject the Module through these Interface Blocks.

Whether an Interface Block is the primary or a secondary interface to
a Module is mirrored in the Interface State abstraction using the
ORDER sub-state. The correspondence between the physical and abstract
states is given in Table :num:`table-interface-state-order`.

After a Module is attached to a Greybus System, the SVC determines
which of the Interface Blocks it is attached to is primary, and which
are secondary, through implementation-defined means.

.. CONNS
.. """""

.. XXX We need a way to represent the open UniPro connections on an
   Interface. This will be needed to specify what connection setup and
   teardown means in terms of Greybus -- and to explain why the way
   the bootrom works has some problems (it causes a CPort leak that
   has to be cleaned up). This section will contain that information.

MAILBOX
"""""""

The MAILBOX sub-state is either the value NULL or a positive integer.

The MAILBOX sub-state represents the value of an
implementation-defined DME attribute, named the "mailbox", which is
present on each port in the |unipro| switch inside the Frame.

When an Interface State's UNIPRO sub-state is UPRO_OFF, its MAILBOX
sub-state is NULL. Otherwise, it is a positive integer.

When an Interface State's UNIPRO sub-state is UPRO_UP, a Module may
write to this DME attribute using a |unipro| peer write. In a Greybus
System, the SVC is able to detect this write and subsequently read the
value of the mailbox attribute.

.. _hardware-model-initial-states:

Initial States
^^^^^^^^^^^^^^

At the power-on reset of a Greybus System, the initial value of each
Interface State is::

  (V_SYS=V_SYS_OFF, V_CHG=V_CHG_OFF, WAKE=WAKE_UNDEFINED,
   DETECT=DETECT_UNKNOWN, UNIPRO=UPRO_OFF, REFCLK=REFCLK_OFF,
   RELEASE=RELEASE_OFF, INTF_TYPE=IFT_UNKNOWN, ORDER=ORDER_UNKNOWN,
   MAILBOX=NULL)
