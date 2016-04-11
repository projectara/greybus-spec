.. highlight:: text

.. _hardware_model:

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

- Zero or more :ref:`Modules <glossary-module>`, which are attached to
  the Frame via one or more Interface Blocks. Individual Modules
  cannot attach to Interface Blocks which are in different Slots: all
  of the Interface Blocks a Module is attached to are in the same
  Slot. Two different Modules cannot attach to the same Interface
  Block at the same time.

Interface Blocks are separated into Slots by the spine and ribs of the
Frame.  The Frame additionally contains the :ref:`SVC <glossary-svc>`,
which, in collaboration with the :ref:`AP Module
<glossary-ap-module>`, manages physical signals present on the
Interface Blocks.

The Frame also contains a :ref:`Switch <glossary-switch>`, which can
be directly configured by the SVC. Each Interface Block contains
connections for |m-phy| [MIPI02]_ LINK establishment between attached
Modules and the Switch. The SVC can configure the Switch and attempt
to exchange communication between the Switch and attached Modules, and
thereby indirectly between Modules themselves, via these LINKs. The AP
is also able, as a Module, to communicate with other Modules, as well
as the SVC, using these LINKs.

The following sections define abstract representations of state
present in a Greybus System for use representing these components
within the Greybus Specification.

- The first subsection, :ref:`hardware-model-interface-states`,
  defines the *Interface State* data structure, which is an entity
  that represents components in, and state managed by, a Greybus
  System that are part of the Frame and are related to each Interface Block.

  The dynamics of a Greybus System effect changes to Interface States
  as defined in the remainder of this document. These changes map in
  implementation-defined ways to these components within the Frame.

- The subsequent section, :ref:`hardware-model-initial-states`,
  defines the initial values of each Interface State.

- :ref:`hardware-model-interfaces` then defines the Interface, which
  models the entities within attached Modules that communicate with
  the Frame via Greybus.

- Following that, :ref:`hardware-model-lifecycle-states` provides a
  state machine diagram which describes Interface lifetimes within a
  Greybus System. The states in this diagram are *Interface Lifecycle
  States*.

- In conclusion, :ref:`hardware-model-ap-module-requirements` defines
  special requirements related to the AP Module and SVC.

Each Interface State in a Greybus System is given a unique identifier,
its Interface ID.  Interface IDs increase consecutively, moving
counter-clockwise around the Frame.

For convenience, the Interface Blocks in a Greybus System are also
indexed by the Interface IDs for their corresponding Interface
States. Any Interfaces within Modules attached to those Interface
Blocks are also indexed by the same Interface IDs as the Interface
Blocks to which they are attached.

Subsequent definitions within the Greybus Specification define how
certain Greybus :ref:`Operations <glossary-operation>` affect
Interface States and Interface Lifecycle States in a Greybus System.

.. _hardware-model-interface-states:

Interface States
^^^^^^^^^^^^^^^^

An *Interface State* is a tuple containing "sub-state" values.  This
represents state within the Frame related to each Interface Block.

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

- DETECT: whether the SVC has sensed that a Module is attached to the
  Interface Block.
- V_SYS: whether system power is supplied from the Frame to the
  Interface Block.
- V_CHG: whether the Interface Block can supply power to the Frame.
- WAKE: whether the Frame is "activating" the Interface Block for
  communication via Greybus.
- UNIPRO: a representation of the state of the Switch components
  connected to the Interface Block.
- REFCLK: whether the Frame is providing a reference clock signal to
  the Interface Block.
- RELEASE: whether the Frame is attempting to physically
  eject a Module attached to the Interface Block.
- INTF_TYPE: denotes capabilities the SVC has determined related to
  the Interface communicating with the Interface Block.
- ORDER: If the SVC has determined the Interface Block is attached to
  a Module, this indicates whether the SVC has determined the
  Interface Block is the ":ref:`Primary Interface
  <glossary-primary-interface>`" or a ":ref:`Secondary Interface
  <glossary-secondary-interface>`" to the Module.
- MAILBOX: the value of a special-purpose and Greybus
  implementation-specific |unipro| DME attribute within the Switch
  used by Modules as a non-CPort based means of communication with the
  Frame.

An Interface State is written as a tuple as follows::

  (DETECT=<detect>, V_SYS=<v_sys>, V_CHG=<v_chg>,
   WAKE=<wake>, UNIPRO=<unipro>, REFCLK=<refclk>,
   RELEASE=<release>, INTF_TYPE=<type>, ORDER=<ord>,
   MAILBOX=<mbox>)

Where in each case <detect>, <v_sys>, etc. are the values of the
corresponding sub-states.

For brevity, the phrase "an Interface State's DETECT" is used to
denote the value of the DETECT sub-state of that Interface State, and
similarly for the other sub-states.

.. _hardware-model-detect:

DETECT
""""""

The values of the DETECT sub-state are given in Table
:num:`table-interface-state-detect`.

.. figtable::
   :nofig:
   :label: table-interface-state-detect
   :caption: DETECT sub-state values
   :spec: l l

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

Under normal operation, a Module shall be physically removed from a Greybus
System as a consequence of Operations exchanged between the AP and SVC
only. However, it is possible that a Module can be physically removed
from the system without intervention from the AP and SVC. This condition
is a *forcible removal* of the Module; alternatively, the Module is
said to have been *forcibly removed*.

If a Module attached to an Interface Block is forcibly removed, there
may be an implementation-defined delay during which the DETECT
sub-state of the corresponding Interface State remains DETECT_ACTIVE.
Furthermore, the DETECT sub-state may become DETECT_UNKNOWN following
a forcible removal. However, the SVC shall, potentially following such
a delay and period during which DETECT is DETECT_UNKNOWN, determine
that the DETECT sub-state is DETECT_INACTIVE.

.. _hardware-model-vsys:

V_SYS
"""""

The values of the V_SYS sub-state are given in Table
:num:`table-interface-state-vsys`.

.. figtable::
     :nofig:
     :label: table-interface-state-vsys
     :caption: V_SYS sub-state values
     :spec: l l

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

Note that the V_SYS sub-state only indicates whether the Frame is
supplying system power to the corresponding Interface Block; it does
*not* imply that a Module is attached to the Interface Block.

The SVC shall set the V_SYS sub-state of any Interface States
associated with a :ref:`forcibly removed <hardware-model-detect>`
Module to V_SYS_OFF after an implementation-defined delay.

.. _hardware-model-vchg:

V_CHG
"""""

The values of the V_CHG sub-state are given in Table
:num:`table-interface-state-vchg`.

.. figtable::
   :nofig:
   :label: table-interface-state-vchg
   :caption: V_CHG sub-state values
   :spec: l l

   =========  ================================================
   Value      Description
   =========  ================================================
   V_CHG_ON   The Interface Block may supply power to the Frame
   V_CHG_OFF  The Interface Block cannot supply power to the Frame
   =========  ================================================
..

The value of the V_CHG sub-state is set by the SVC.

The V_CHG sub-state of an Interface State represents whether power may
be supplied to the Frame via that Interface Block, via the Interface Block's
charger power bus.

The Frame may draw power from an Interface Block, depending on the
V_CHG sub-state of the corresponding Interface State. The Frame can
only draw power from an Interface Block whose Interface State's V_CHG
sub-state is V_CHG_ON.

Note that the V_CHG sub-state only indicates whether the Frame may
draw power from the corresponding Interface Block; it does *not* imply
that a Module is attached to the Interface Block.

The SVC shall set the V_CHG sub-state of any Interface States
associated with a :ref:`forcibly removed <hardware-model-detect>`
Module to V_CHG_OFF after an implementation-defined delay.

.. _hardware-model-wake:

WAKE
""""

The values of the WAKE sub-state are given in Table
:num:`table-interface-state-wake`.

.. figtable::
   :nofig:
   :label: table-interface-state-wake
   :caption: WAKE sub-state values
   :spec: l l

   ===============  ================================================
   Value            Description
   ===============  ================================================
   WAKE_UNSET       Wake signal is neither asserted nor deasserted
   WAKE_ASSERTED    Wake signal is asserted to an Interface Block
   WAKE_DEASSERTED  Wake signal is deasserted to an Interface Block
   ===============  ================================================
..

The WAKE sub-state of an Interface State represents the state of a
signal used to initialize an attached Module. The value of the WAKE
sub-state is set by the SVC.

During the initialization of a Greybus System, all Interface States
have WAKE equal to WAKE_UNSET. The SVC shall only set WAKE to a value
other than WAKE_UNSET for an Interface State whose DETECT sub-state is
DETECT_ACTIVE and V_SYS is V_SYS_ON.

Subject to the above restrictions, the SVC may assert and deassert the
WAKE sub-state by following this sequence, assuming WAKE is WAKE_UNSET.

1. Set WAKE to WAKE_ASSERTED
2. Delay for some duration
3. Set WAKE to WAKE_DEASSERTED
4. Set WAKE to WAKE_UNSET

This is called a *WAKE Pulse*. When the duration of the WAKE Pulse
equals or exceeds an implementation-defined threshold, the *WAKE Pulse
Cold Boot Threshold*, this is a signal to any attached Interface to
initiate (or reinitiate) |unipro|, and subsequently Greybus,
communication, as described in later sections.

.. XXX this "as described" descriptions are currently not described
   anywhere; later updates will need to fix that once Interface States
   are in the spec as mechanism to do so.

Note that the WAKE sub-state only indicates whether the wake signal is
asserted, deasserted, or neither to corresponding Interface Block; it
does *not* imply that a Module is attached to the Interface Block.

The SVC shall set the WAKE sub-state of any Interface States
associated with a :ref:`forcibly removed <hardware-model-detect>`
Module to WAKE_UNSET after an implementation-defined delay.

.. _hardware-model-unipro:

UNIPRO
""""""

The values of the UNIPRO sub-state are given in Table
:num:`table-interface-state-unipro`.

.. figtable::
   :nofig:
   :label: table-interface-state-unipro
   :caption: UNIPRO sub-state values
   :spec: l l

   ==============  ================================================
   Value           Description
   ==============  ================================================
   UPRO_OFF        |unipro| port is powered off
   UPRO_DOWN       |unipro| port is powered on, and the link is down
   UPRO_LSS        |unipro| link startup sequence is ongoing between Module and Frame
   UPRO_UP         |unipro| link is established
   UPRO_HIBERNATE  |unipro| link is in low-power hibernate state
   UPRO_RELINK     |unipro| peer is attempting to re-initiate linkup
   ==============  ================================================
..

The UNIPRO sub-state of each Interface State represents entities
within the Switch. These entities can communicate with Interfaces
within Modules, and can be configured by the SVC.

Since all Greybus Protocols exchange data via |unipro| Messages, each
Interface Block contains the necessary signals to connect a |unipro|
implementation within a Module attached to that Interface Block to the
Switch, which can route these Messages to other Modules, and perform
some other |unipro| protocol communiction with attached Modules.

Transitions between successive values of the UNIPRO sub-state are
shown in the following figure. All other transitions are illegal.

.. image:: /img/dot/unipro-sub-state-transitions.png
   :align: center

Greybus communication between Modules (including the AP Module) is
only possible through Interface Blocks whose Interface State's UNIPRO
sub-state is UPRO_UP: this is required to allow CPorts managed by
Module Interfaces to exchange Greybus Operations via |unipro|
Messages. It is also necessary for *routes* within the Switch to be
established to allow |unipro| Messages sent by Interfaces to be
relayed through the Switch to the Interfaces which are their intended
recipients.

Other UNIPRO sub-state values are used primarily during communication
between the SVC and AP during Module initialization, teardown, power
management, and error handling, and are subject to the following
constraints:

- Before a Module is first attached to an Interface Block, and during
  the initialization of a Greybus System, UNIPRO is either UPRO_OFF or
  UPRO_DOWN.

- If a Module is not attached to an Interface Block, UNIPRO cannot
  become UPRO_UP, UPRO_HIBERNATE, or UPRO_RELINK.

- The SVC can set UNIPRO to either UPRO_OFF (and subsequently to
  UPRO_DOWN) at any time, regardless of whether a Module is attached
  to the Interface Block.

- Both the SVC and any attached Module's Interface shall be notified,
  by implementation-specific means, if UNIPRO becomes any of the
  values UPRO_LSS, UPRO_UP, UPRO_HIBERNATE, or UPRO_RELINK.

- If UNIPRO is UPRO_DOWN, either the SVC or an attached Module's
  Interface may set UNIPRO to UPRO_LSS.

- If the SVC sets UNIPRO to UPRO_LSS, the attached Module's Interface
  may subsequently set UNIPRO to UPRO_UP, within a duration defined by
  the |unipro| standard.

- If an attached Module's Interface sets UNIPRO to UPRO_LSS, the SVC
  may subsequently set UNIPRO to UPRO_UP, within the same duration.

- If UNIPRO remains UPRO_LSS for a duration defined by the |unipro|
  standard, it autonomously (i.e., without the SVC or Module making
  the change) is set to UPRO_DOWN.

  When this occurs, if the SVC set UNIPRO to UPRO_LSS, the SVC shall
  be notified by implementation-specific means; similarly, if the
  Interface sets UNIPRO to UPRO_LSS, the Interface shall be notified by
  implementation-specific means.

- The SVC can set UNIPRO to UPRO_HIBERNATE.

- If UNIPRO is UPRO_HIBERNATE, the SVC can attempt to set UNIPRO to
  UPRO_UP.

  The SVC shall be notified whether the attempt succeeds or fails.  If
  a Module is attached to the Interface Block, the Interface on the
  Module may be notified if the attempt succeeds or fails. In both
  cases, the notification is through implementation-specific means.

- An attached Module can, but should not, set UNIPRO to UPRO_HIBERNATE
  or UPRO_RELINK.

- The SVC can, but should not, set UNIPRO to UPRO_RELINK.

.. XXX those later sections don't have those descriptions yet. But
   they will need these definitions to exist in order to be written.

Note that the UNIPRO sub-state is a Frame-centric view of the state of
entities within the Switch. Following a :ref:`forcible removal
<hardware-model-detect>` of a Module which had established a LINK to
the Frame via the corresponding Interface Block, the UNIPRO sub-state
may retain its previous value or change values. This may depend upon
its current value and any ongoing activity on the LINK.

.. _hardware-model-refclk:

REFCLK
""""""

The values of the REFCLK sub-state are given in Table
:num:`table-interface-state-refclk`.

.. figtable::
   :nofig:
   :label: table-interface-state-refclk
   :caption: REFCLK sub-state values
   :spec: l l

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

Note that the REFCLK sub-state only indicates whether the Frame is
supplying a reference clock signal to the corresponding Interface
Block; it does *not* imply that a Module is attached to the Interface
Block.

The SVC shall set the REFCLK sub-state of any Interface States
associated with a :ref:`forcibly removed <hardware-model-detect>`
Module to REFCLK_OFF after an implementation-defined delay.

.. _hardware-model-release:

RELEASE
"""""""

The values of the RELEASE sub-state are given in Table
:num:`table-interface-state-release`.

.. figtable::
   :nofig:
   :label: table-interface-state-release
   :caption: RELEASE sub-state values
   :spec: l l

   ==================  ================================================
   Value               Description
   ==================  ================================================
   RELEASE_ASSERTED    Frame is asserting ejection signal to the Interface Block
   RELEASE_DEASSERTED  Frame is not asserting ejection signal to the Interface Block
   ==================  ================================================
..

The value of the RELEASE sub-state is set by the SVC.

The Frame may physically eject any attached Modules through
implementation-defined means. Any attached Module has exactly one
Primary Interface, and may contain Secondary Interfaces, as described
in :ref:`hardware-model-order`. The SVC may set the RELEASE sub-state
of an Interface Block which is the Primary Interface to an attached
module to RELEASE_ASSERTED for an implementation-defined duration, then set
RELEASE to RELEASE_DEASSERTED, in order to attempt to eject the attached
module from the Frame. This is called a "RELEASE pulse".

The consequences of setting an Interface State's RELEASE sub-state for
a Secondary Interface to a Module, or when the Interface State's
DETECT state is not DETECT_ACTIVE, are not defined by the Greybus
Specification.

Note that the RELEASE sub-state only indicates whether the Frame is
supplying ejection signaling to the corresponding Interface Block; it
does *not* imply that a Module is attached to the Interface Block.

The SVC shall set the RELEASE sub-state of any Interface States
associated with a :ref:`forcibly removed <hardware-model-detect>`
Module to RELEASE_DEASSERTED after an implementation-defined delay.

.. _hardware-model-intf-type:

INTF_TYPE
"""""""""

The values of the INTF_TYPE sub-state are given in Table
:num:`table-interface-state-type`.

.. figtable::
   :nofig:
   :label: table-interface-state-type
   :caption: INTF_TYPE sub-state values
   :spec: l l l

   =============  ======  ================================================
   INTF_TYPE      Value   Description
   =============  ======  ================================================
   IFT_UNKNOWN    0       Module not attached, type is undetermined, or error occurred
   IFT_DUMMY      1       Module attached does not support |unipro| communication
   IFT_UNIPRO     2       Module attached supports |unipro|, but not Greybus Protocols
   IFT_GREYBUS    3       Module attached supports Greybus Protocols
   =============  ======  ================================================

..

The value of the INTF_TYPE sub-state is set by the SVC. Because the
INTF_TYPE sub-state is communicated to the AP via Greybus Operations,
its symbolic names are also given numeric values as shown in the
table.

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
   :spec: l l

   ===============  ================================================
   Value            Description
   ===============  ================================================
   ORDER_UNKNOWN    No Module is attached, or Primary vs. Secondary status unknown
   ORDER_PRIMARY    Interface is the Primary Interface to an attached Module
   ORDER_SECONDARY  Interface is a Secondary Interface to an attached Module
   ===============  ================================================
..

The value of the ORDER sub-state is set by the SVC.

A :ref:`Module <glossary-module>` may attach to one or more Interface
Blocks on a Slot in the Frame. Exactly one of these Interface Blocks
is the "Primary Interface" to the Module; signaling on this Interface
Block may be used to physically eject the Module from the Frame. All
other Interface Blocks attached to the Module, if any, are "Secondary
Interfaces": they may communicate via Greybus to the AP and the SVC,
but the Frame cannot eject the Module through these Interface Blocks.

Whether an Interface Block is the Primary or a Secondary Interface to
a Module is mirrored in the Interface State abstraction using the
ORDER sub-state. The correspondence between the physical and abstract
states is given in Table :num:`table-interface-state-order`.

After a Module is attached to a Greybus System, the SVC determines
which of the Interface Blocks it is attached to is the Primary
Interface, and which are Secondary Interfaces, through
implementation-defined means.

Note that the ORDER sub-state only indicates the most recent value set
by the SVC, if any. It does *not* imply that a Module is attached to
the Interface Block.

The SVC shall set the ORDER sub-state of any Interface States
associated with a :ref:`forcibly removed <hardware-model-detect>`
Module to ORDER_UNKNOWN after an implementation-defined delay.

.. CONNS
.. """""

.. XXX We need a way to represent the open UniPro connections on an
   Interface. This will be needed to specify what connection setup and
   teardown means in terms of Greybus -- and to explain why the way
   the bootrom works has some problems (it causes a CPort leak that
   has to be cleaned up). This section will contain that information.

.. _hardware-model-mailbox:

MAILBOX
"""""""

The MAILBOX sub-state is either the value MAILBOX_NULL or a
32-bit unsigned integer.

The MAILBOX sub-state represents the value of an
implementation-defined DME attribute, named the "mailbox", which is
present on each port in the |unipro| switch inside the Frame.

The mailbox attribute ID is 0xA000, and its selector index is ignored.

When an Interface State's UNIPRO sub-state is UPRO_OFF, its MAILBOX
sub-state is NULL. Otherwise, it is a positive integer.

When an Interface State's UNIPRO sub-state is UPRO_UP, a Module may
write to this DME attribute using a |unipro| peer write. In a Greybus
System, the SVC shall detect such a write and subsequently read the
value of the mailbox attribute.

The values that a Module may write to the mailbox attribute are given
in Table :num:`table-interface-state-mailbox`.

.. figtable::
   :nofig:
   :label: table-interface-state-mailbox
   :caption: MAILBOX sub-state values
   :spec: l l l

   =======================    ===============  ========================================================
   MAILBOX sub-state          Value            Description
   =======================    ===============  ========================================================
   MAILBOX_NULL               (none)           UNIPRO is UPRO_OFF; DME attribute access is not possible
   MAILBOX_NONE (Reserved)    0x0              Initial DME attribute value; reserved for internal use
   MAILBOX_AP                 0x1              AP Interface is ready for :ref:`svc-protocol` Connection
   MAILBOX_GREYBUS            0x2              Module is ready for :ref:`control-protocol` Connection
   (Reserved)                 0x3..0xFFFFFFFF  Reserved for future use
   =======================    ===============  ========================================================

..

.. _hardware-model-initial-states:

Initial Interface States
^^^^^^^^^^^^^^^^^^^^^^^^

During the initialization of a Greybus System, the initial value of
each Interface State is::

  (DETECT=DETECT_UNKNOWN, V_SYS=V_SYS_OFF, V_CHG=V_CHG_OFF,
   WAKE=WAKE_UNSET, UNIPRO=UPRO_OFF, REFCLK=REFCLK_OFF,
   RELEASE=RELEASE_DEASSERTED, INTF_TYPE=IFT_UNKNOWN, ORDER=ORDER_UNKNOWN,
   MAILBOX=MAILBOX_NULL)

As a consequence of the reset sequence of a Greybus System, the SVC
determines a value of DETECT for each Interface State in the
system. This is explained in more detail in later sections, and forms
the basis of the state machine described in
:ref:`hardware-model-lifecycle-states`.

.. _hardware-model-interfaces:

Interfaces
^^^^^^^^^^

As stated above, a Module attached to the Frame may contain one or
more entities called *Interfaces*, each of which is able to detect and
respond to signals at a unique Interface Block to which the Module is
attached. That is, each Interface communicates with the Frame via
exactly one Interface Block, and no two Interfaces communicate with
the Frame via the same Interface Block.

A Module shall contain exactly one Interface for each of the Interface
Blocks to which it is attached. For brevity, it is written that an
Interface "is connected to the Frame" via this Interface Block.

Interfaces within Modules shall communicate with the Frame as
specified in this document, but Interfaces may vary in their
capabilities. For example, an Interface may not be able to communicate
via |unipro|. Certain Interface communication capabilities can be
discovered by the AP and SVC, which can record the information
discovered in the :ref:`hardware-model-intf-type` sub-state of the
Interface State associated with that Interface.

.. _hardware-model-lifecycle-states:

Interface Lifecycle States
^^^^^^^^^^^^^^^^^^^^^^^^^^

This section briefly introduces the *Interface Lifecycle* state
machine, shown in the following figure. A detailed description of this
state machine is provided in :ref:`lifecycles_interface_lifecycle`.

.. image:: /img/dot/interface-lifecycle.png
   :align: center

Each of the states is a *Lifecycle State*. Lifecycle States denote the
current status of an Interface, and transitions between Lifecycle
States manage the dynamic behavior of the Interface as it interacts
with the Frame. For example, in the ATTACHED Lifecycle State, the SVC
has determined a Module is attached to an Interface Block, and thus an
Interface can communicate with the Frame via that Interface Block. No
other action has been taken by the Greybus System to communicate with
the Interface, and it is unknown whether the Interface supports
|unipro| commmunication.

The DETACHED Lifecycle State is a special case. In this state, the SVC
has determined an Interface Block has no Module attached. In this
case, no Interface is connected to the Frame.

This section defines a group of Interface States which are the legal
Interface States within the Frame when an Interface is in each
Interface Lifecycle State.

For example, when an Interface is in the ACTIVATED Lifecycle State,
the Interface State within the frame has an INTF_TYPE other than
IFT_UNKNOWN. Multiple permitted values for the sub-states of the
Interface States within each Interface Lifecycle State are shown
between angle brackets (<>).

The square node labeled "Any State" denotes that the transition is
allowed from any Interface status whatsoever, and models the
consequences of a :ref:`forcible removal <hardware-model-detect>`.

The Interface Lifecycle States are introduced, and their associated
Interface States are defined, in the following sections.

Subsequent chapters define Greybus :ref:`Protocols
<glossary-protocol>`, of which the :ref:`control-protocol` and
:ref:`svc-protocol` are especially significant in terms of their
impact on an Interface's Lifecycle State. Following those chapters, a
detailed description of the actions taken by the AP, SVC, and each
Interface is given describing how transitions between Lifecycle States
are managed.

.. FIXME The following "Interface States are allowed" language is
   ugly and a better definition should be developed.

.. _hardware-model-lifecycle-attached:

ATTACHED
""""""""

In the ATTACHED Lifecycle State, the SVC has:

- determined that a Module is attached to the Interface Block, setting
  DETECT to DETECT_ACTIVE
- determined whether this is the :ref:`Primary
  <glossary-primary-interface>` or a :ref:`Secondary
  <glossary-secondary-interface>` Interface to the Module, setting
  ORDER.

No actions have been taken to boot the module, communicate with it via
|unipro|, etc. That is, in the ATTACHED Lifecycle State, the Interface
State is otherwise identical to its :ref:`initial state
<hardware-model-initial-states>`.

In the ATTACHED Lifecycle State, the following Interface States are
allowed as described in later sections:

.. include:: lifecycle-states/attached.txt

.. _hardware-model-lifecycle-activated:

ACTIVATED
"""""""""

In the ACTIVATED Lifecycle State, system power and clock have been
applied to the Interface Block, and an attempt to establish a |unipro|
link between Frame and Module has been made.

As a consequence, it is known whether the module supports |unipro|, so
UNIPRO is either UPRO_DOWN or UPRO_UP. If UNIPRO is UPRO_UP, then the
Module may signal readiness for communication via Greybus
:ref:`Protocols <glossary-protocol>` by setting MAILBOX. Thus, MAILBOX
either remains its initial value, MAILBOX_NONE, or is set by the
Module to MAILBOX_GREYBUS.

The SVC also sets INTF_TYPE when the Interface is ACTIVATED, based on
a combination of the UNIPRO and MAILBOX sub-states. The correspondence
between UNIPRO, MAILBOX, and INTF_TYPE is given in Table
:num:`table-lifecycle-state-intf-type`.

.. figtable::
   :nofig:
   :label: table-lifecycle-state-intf-type
   :caption: INTF_TYPE relationship to UNIPRO and MAILBOX in ACTIVATED
   :spec: l l l

    ===============  ===============  ===============
    INTF_TYPE        UNIPRO           MAILBOX
    ===============  ===============  ===============
    IFT_DUMMY        UPRO_DOWN        MAILBOX_NONE
    IFT_UNIPRO       UPRO_UP          MAILBOX_NONE
    IFT_GREYBUS      UPRO_UP          MAILBOX_GREYBUS
    ===============  ===============  ===============

..

In the ACTIVATED Lifecycle State, the following Interface States are
allowed as described in later sections:

.. include:: lifecycle-states/activated.txt

.. _hardware-model-lifecycle-enumerated:

ENUMERATED
""""""""""

The ENUMERATED Lifecycle State can only be reached when an Interface
signals readiness for Greybus :ref:`Protocol <glossary-protocol>`
communication during the transition to ACTIVATED. Thus,
INTF_TYPE is IFT_GREYBUS, and MAILBOX is MAILBOX_GREYBUS.

When an Interface is ENUMERATED, a Greybus :ref:`control-protocol`
Connection has been established to that Interface, and its
:ref:`manifest-description` has been read by the AP and successfully
parsed. (This process is referred to as *enumeration*).

While an Interface is ENUMERATED, the AP may determine through
application- or Protocol-specific means that the Frame's reference
clock is not required for the Interface to function correctly. Thus,
REFCLK may be set to REFCLK_OFF.

Similarly, when the Interface is ENUMERATED, the AP may determine
through application- or Protocol-specific means that the Interface can
supply power to the Frame via the Interface Block. Thus, V_CHG may be
set to V_CHG_ON.

In the ENUMERATED Lifecycle State, the following Interface States are
allowed as described in later sections:

.. include:: lifecycle-states/enumerated.txt

.. _hardware-model-lifecycle-mode-switching:

MODE_SWITCHING
""""""""""""""

The MODE_SWITCHING Lifecycle State is a special case which is used to
allow for re-enumeration of an Interface without physically removing
it from, and attaching it to, a Greybus System.

As part of entering the MODE_SWITCHING Lifecycle State, all Greybus
:ref:`Connections <glossary-connection>` involving the Interface are
closed. The Interface may then perform internal re-initialization, and
subsequently signal to the Frame when this is complete by setting
MAILBOX. The Frame can then attempt to re-enumerate the Interface,
including retrieving its (possibly different)
:ref:`manifest-description` again.

Before an Interface enters the MODE_SWITCHING Lifecycle State, REFCLK
shall be set to REFCLK_ON if it is REFCLK_OFF, and V_CHG shall be set
to V_CHG_OFF if it is V_CHG_ON.

An Interface may enter and exit the MODE_SWITCHING Lifecycle State an
arbitrary number of times.

In the MODE_SWITCHING Lifecycle State, the following Interface States
are allowed as described in later sections:

.. include:: lifecycle-states/mode-switching.txt

.. _hardware-model-lifecycle-suspended:

SUSPENDED
"""""""""

The SUSPENDED Lifecycle State is a low-power state during which some
internal state within the Interface is maintained, and system power is
still applied. No Greybus Protocol communication with the Interface is
possible when the Interface is in the SUSPENDED state.

An Interface shall not alter its :ref:`manifest-description` while it
is entering, in, or exiting the SUSPENDED state.

In the SUSPENDED Lifecycle State, the following Interface States are
allowed as described in later sections:

.. include:: lifecycle-states/suspended.txt

.. _hardware-model-lifecycle-off:

OFF
"""

The OFF Lifecycle State denotes an Interface which has power and
communication signals disabled, but whose INTF_TYPE and ORDER are
still known, having been determined during previous Lifecycle States
in the Interface Lifecycle.

In the OFF Lifecycle State, the following Interface States are allowed
as described in later sections:

.. include:: lifecycle-states/off.txt

.. _hardware-model-lifecycle-detached:

DETACHED
""""""""

The DETACHED Lifecycle State is a special case. In this Lifecycle
State, no Module is attached to the Interface Block.

The SVC and AP have otherwise coordinated to disable power and other
signaling to the Interface Block, as in the OFF Lifecycle State.

The unique Interface State possible in the DETACHED Lifecycle State
is:

.. include:: lifecycle-states/detached.txt

.. _hardware-model-ap-module-requirements:

Special AP Module Requirements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As stated above, a Greybus System contains an AP Module and an SVC.
This section defines special requirements related to these components.

- The AP Module shall be connected to the Frame via Interface Blocks
  whose Interface IDs are known to the SVC. The AP Module shall
  contain Interfaces as other Modules do, but these Interfaces shall
  not provide :ref:`Control CPorts <glossary-control-cport>`.

  For convenience, the Interface States with these Interface IDs are
  the *AP Interface States*, the corresponding Interface Blocks are
  *AP Interface Blocks*, and the corresponding Interfaces are *AP
  Interfaces*.

  Each AP Interface shall provide a CPort whose user can be configured
  to communicate with the SVC over a :ref:`Greybus Connection
  <glossary-connection>` implementing the :ref:`svc-protocol`.

- The Interface Blocks by which the AP Module connects to the Frame
  may differ from those by which other Modules attach to the Frame,
  but AP Interface Blocks nonetheless have an associated Interface
  State as specified above.

- The following sub-states for all AP Interface States may, according
  to the implementation, be set by the AP, not the SVC:

  - REFCLK

- The following sub-states for all AP Interface States are defined as
  these constant values:

  - DETECT is DETECT_ACTIVE
  - V_SYS is V_SYS_ON
  - V_CHG is V_CHG_OFF
  - RELEASE is RELEASE_DEASSERTED
  - INTF_TYPE is IFT_GREYBUS
  - ORDER is ORDER_UNKNOWN

- The AP Module shall be able to restore the SVC to its reset state,
  and to release it from reset.
