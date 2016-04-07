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

- Certain groups of Interface States have special meaning within the
  Greybus Specification. These groups of Interface States, named
  *Lifecycle States*, along with transitions between them managed by
  the Greybus System, are given in
  :ref:`hardware-model-lifecycle-states`.

Subsequent definitions within the Greybus Specification define how
certain Greybus :ref:`Operations <glossary-operation>` affect
Interface States and Lifecycle States in a Greybus System.

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

- DETECT: whether the SVC has sensed that a Module is attached to the
  Interface Block.
- V_SYS: whether system power is supplied from the Frame to the
  Interface Block.
- V_CHG: whether the Interface Block can supply power to the Frame.
- WAKE: whether the Frame is "activating" the Interface Block for
  communication via Greybus.
- UNIPRO: a simplified representation of the state of the |unipro|
  port within the Frame connected to the Interface Block.
- REFCLK: whether the Frame is providing a reference clock signal to
  the Interface Block.
- RELEASE: indicates whether the Frame is attempting to physically
  eject a Module attached to the Interface Block.
- INTF_TYPE: an indicator of what communication is supported by a
  Module connected to the Interface Block, if any.
- ORDER: If the Interface Block is attached to a Module, an indicator
  of whether this is the ":ref:`Primary Interface
  <glossary-primary-interface>`" or a ":ref:`Secondary Interface
  <glossary-secondary-interface>`" to the Module.
- MAILBOX: the value of a special-purpose and Greybus
  implementation-specific |unipro| DME attribute used by Modules as a
  non-CPort based means of communication with the Frame.

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

The V_CHG sub-state of an Interface State represents whether power is
supplied by an Interface Block to the Frame, via the Interface Block's
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
signal used to initialize and manage power consumed by an attached
Module. The value of the WAKE sub-state is controlled by the SVC and
any Module attached to the Interface Block.

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

This is called a "WAKE pulse". When the duration of the WAKE pulse
exceeds an implementation-defined threshold, this is a signal to any
attached Module to initiate (or reinitiate) Greybus communication, as
described in later sections.

.. XXX this "as described" descriptions are currently not described
   anywhere; later updates will need to fix that once Interface States
   are in the spec as mechanism to do so.

Note that the WAKE sub-state only indicates whether the wake signal is
asserted, deasserted, or neither to corresponding Interface Block; it
does *not* imply that a Module is attached to the Interface Block.

The SVC shall set the WAKE sub-state of any Interface States
associated with a :ref:`forcibly removed <hardware-model-detect>`
Module to WAKE_UNSET after an implementation-defined delay.

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

A Module must be attached to an Interface Block for its UNIPRO state
to become UPRO_LSS, UPRO_UP, or UPRO_RELINK. Before a Module is first
attached to an Interface Block, UNIPRO is either UPRO_OFF or
UPRO_DOWN. The SVC can set the UNIPRO sub-state to either UPRO_OFF or
UPRO_DOWN at any time.

.. XXX those later sections don't have those descriptions yet. But
   they will need these definitions to exist in order to be written.

Note that the UNIPRO sub-state is a Frame-centric view of the state of
the corresponding |unipro| link. Following a :ref:`forcible removal
<hardware-model-detect>` of a Module which had established a |unipro|
link to the Frame via the corresponding Interface Block, the UNIPRO
sub-state may retain its previous value or change values. This may
depend upon its current value and any ongoing activity on the link.

The SVC may set the UNIPRO sub-state of any Interface States
associated with a :ref:`forcibly removed <hardware-model-detect>`
Module to UPRO_OFF.

.. NOTE: "may set the UNIPRO [...]" is on purpose. We want to allow
   current and future implementations some latitude to perform
   AP-driven cleanup of the network at their leisure.

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
module from the Frame.

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

INTF_TYPE
"""""""""

The values of the INTF_TYPE sub-state are given in Table
:num:`table-interface-state-type`.

.. figtable::
   :nofig:
   :label: table-interface-state-type
   :caption: INTF_TYPE sub-state values
   :spec: l l

   =============  ================================================
   Value          Description
   =============  ================================================
   IFT_UNKNOWN    Module not attached, type is undetermined, or error occurred
   IFT_DUMMY      Module attached which does not support |unipro| communication
   IFT_UNIPRO     Module attached which supports |unipro|, but not Greybus Protocols
   IFT_GREYBUS    Module attached which supports Greybus Protocols
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
is the "Primary Interface" to the Module; signaling on this interface
may be used to physically eject the Module from the Frame. All other
Interface Blocks attached to the Module, if any, are "Secondary
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

MAILBOX
"""""""

The MAILBOX sub-state is either the value MAILBOX_NULL or a
non-negative integer.

The MAILBOX sub-state represents the value of an
implementation-defined DME attribute, named the "mailbox", which is
present on each port in the |unipro| switch inside the Frame.

When an Interface State's UNIPRO sub-state is UPRO_OFF, its MAILBOX
sub-state is NULL. Otherwise, it is a positive integer.

When an Interface State's UNIPRO sub-state is UPRO_UP, a Module may
write to this DME attribute using a |unipro| peer write. In a Greybus
System, the SVC is able to detect this write and subsequently read the
value of the mailbox attribute.

The values that a Module may write to the mailbox attribute are given
in Table :num:`table-interface-state-mailbox`.

.. figtable::
   :nofig:
   :label: table-interface-state-mailbox
   :caption: MAILBOX sub-state values
   :spec: l l l

   =======================    ======  =========================
   MAILBOX sub-state          Value   Description
   =======================    ======  =========================
   MAILBOX_NULL               (none)  UNIPRO is UPRO_OFF; DME attribute access is not possible
   MAILBOX_NONE (Reserved)    0       Initial DME attribute value; reserved for internal use
   (Reserved)                 1       Reserved for internal use
   MAILBOX_GREYBUS            2       Module is ready for :ref:`control-protocol` Connection
   =======================    ======  =========================

..

.. _hardware-model-initial-states:

Initial States
^^^^^^^^^^^^^^

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

.. _hardware-model-lifecycle-states:

Interface Lifecycle States
^^^^^^^^^^^^^^^^^^^^^^^^^^

The following state machine diagram is the *Interface Lifecycle*. Each
of the states is a *Lifecycle State*. Lifecycle States are groups of
Interface States with a special meaning within the Greybus
Specification.

.. image:: /img/dot/interface-lifecycle.png
   :align: center

For example, the ATTACHED Lifecycle State is the Interface State for
an Interface Block which the SVC has determined a Module is attached
to, but no other action has been taken by the Greybus System to
communicate with it. Similarly, the DETACHED Lifecycle State is the
Interface State for an Interface Block with no module attached.

Certain Lifecycle States refer to multiple possible Interface
States. For example, the ACTIVATED Lifecycle State refers to a group
of related Interface States, all of which have an INTF_TYPE other than
IFT_UNKNOWN. Multiple permitted values for the sub-states of the
Interface States within each Lifecycle State are shown between angle
brackets (<>).

The square node labeled "Any State" denotes that the transition is
allowed from any Interface State whatsoever, and models the
consequences of a :ref:`forcible removal <hardware-model-detect>`.

For brevity, the phrase "an Interface is in the ATTACHED Lifecycle
State" or "an Interface is ATTACHED" is used to mean "the Interface
State corresponding to the Interface Block is in the ATTACHED
Lifecycle State", and similarly for the other Lifecycle States.

Using the above notation, the Lifecycle States are defined in the
following sections.

Subsequent chapters define Greybus :ref:`Protocols
<glossary-protocol>`, of which the :ref:`control-protocol` and
:ref:`svc-protocol` are especially significant in terms of their
impact on an Interface's Lifecycle State. Following those chapters, a
detailed description of the actions taken by the AP, SVC, and each
Interface is given describing how transitions between Lifecycle States
are managed.

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
|unipro|, etc. That is, ATTACHED is otherwise identical to the
:ref:`initial state <hardware-model-initial-states>` of each Interface
State.

ATTACHED is the following group of Interface States::

  (DETECT=DETECT_ACTIVE, V_SYS=V_SYS_OFF, V_CHG=V_CHG_OFF,
   WAKE=WAKE_UNSET, UNIPRO=UPRO_OFF, REFCLK=REFCLK_OFF,
   RELEASE=RELEASE_DEASSERTED, INTF_TYPE=IFT_UNKNOWN,
   ORDER=<ORDER_PRIMARY or ORDER_SECONDARY>,
   MAILBOX=MAILBOX_NULL)

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

The SVC also sets INTF_TYPE then the Interface is ACTIVATED, based on
a combination of the UNIPRO and MAILBOX sub-states. The correspondence
between UNIPRO, MAILBOX, and INTF_TYPE is given in Table
:num:`table-lifecycle-state-intf-type`.

.. figtable::
   :nofig:
   :label: table-lifecycle-state-intf-type
   :caption: INTF_TYPE relationship to UNIPRO and MAILBOX in ACTIVATED
   :spec: l l l

   ===============  ===============  ===============
   UNIPRO           MAILBOX          INTF_TYPE
   ===============  ===============  ===============
   UPRO_DOWN        MAILBOX_NONE     IFT_DUMMY
   UPRO_UP          MAILBOX_NONE     IFT_UNIPRO
   UPRO_UP          MAILBOX_GREYBUS  IFT_GREYBUS
   ===============  ===============  ===============

..

ACTIVATED is the following group of Interface States::

  (DETECT=DETECT_ACTIVE, V_SYS=V_SYS_ON, V_CHG=V_CHG_OFF,
   WAKE=WAKE_UNSET,
   UNIPRO=<UPRO_DOWN or UPRO_UP>,
   REFCLK=REFCLK_ON,
   RELEASE=RELEASE_DEASSERTED,
   INTF_TYPE=<IFT_DUMMY, IFT_UNIPRO, or IFT_GREYBUS>,
   ORDER=<ORDER_PRIMARY or ORDER_SECONDARY>,
   MAILBOX=<MAILBOX_NONE or MAILBOX_GREYBUS>)

.. _hardware-model-lifecycle-enumerated:

ENUMERATED
""""""""""

The ENUMERATED Lifecycle State can only be reached when readiness for
Greybus :ref:`Protocol <glossary-protocol>` communication was
signaled during the transition to ACTIVATED. Thus, INTF_TYPE is
IFT_GREYBUS, and MAILBOX is MAILBOX_GREYBUS.

When an Interface is ENUMERATED, a Greybus :ref:`control-protocol`
Connection has been established to the Module via that Interface
Block, and its :ref:`manifest-description` has been read by the AP and
successfully parsed. (This process is referred to as *enumeration*).

While an Interface is ENUMERATED, the AP may determine through
application- or Protocol-specific means that the Frame's reference
clock is not required for the Module attached to the Interface Block
to function correctly. Thus, REFCLK may be set to REFCLK_OFF.

Similarly, when the Interface is ENUMERATED, the AP may determine
through application- or Protocol-specific means that the Module can
supply power to the Frame via the Interface Block. Thus, V_CHG may be
set to V_CHG_ON.

ENUMERATED is the following group of Interface States::

  (DETECT=DETECT_ACTIVE, V_SYS=V_SYS_ON,
   V_CHG=<V_CHG_OFF or V_CHG_ON>,
   WAKE=WAKE_UNSET, UNIPRO=UPRO_UP,
   REFCLK=<REFCLK_ON or REFCLK_OFF>,
   RELEASE=RELEASE_DEASSERTED,
   INTF_TYPE=IFT_GREYBUS,
   ORDER=<ORDER_PRIMARY or ORDER_SECONDARY>,
   MAILBOX=MAILBOX_GREYBUS)

.. _hardware-model-lifecycle-mode-switching:

MODE_SWITCHING
""""""""""""""

The MODE_SWITCHING Lifecycle State is a special case which is used to
allow for re-enumeration of an Interface without physically removing
it from, and attaching it to, a Greybus System.

As part of entering the MODE_SWITCHING Lifecycle State, all Greybus
:ref:`Connections <glossary-connection>` involving the Interface are
closed. The Module attached to the Interface Block may then perform
internal re-initialization, and subsequently signal to the Frame by
setting MAILBOX when this is completed. The Frame will then attempt to
re-enumerate the Interface, including retrieving its (possibly
different) :ref:`manifest-description` again.

Before an Interface enters the MODE_SWITCHING Lifecycle State, REFCLK
shall be set to REFCLK_ON if it is REFCLK_OFF, and V_CHG shall be set
to V_CHG_OFF if it is V_CHG_ON.

An Interface State may enter and exit the MODE_SWITCHING Lifecycle
State an arbitrary number of times.

MODE_SWITCHING is the following group of Interface States::

  (DETECT=DETECT_ACTIVE, V_SYS=V_SYS_ON, V_CHG=V_CHG_OFF,
   WAKE=WAKE_UNSET, UNIPRO=UPRO_UP,
   REFCLK=REFCLK_ON, RELEASE=RELEASE_DEASSERTED, INTF_TYPE=IFT_GREYBUS,
   ORDER=<ORDER_PRIMARY or ORDER_SECONDARY>,
   MAILBOX=MAILBOX_GREYBUS)

.. _hardware-model-lifecycle-suspended:

SUSPENDED
"""""""""

The SUSPENDED Lifecycle State is a low-power state during which some
internal state within the Module is maintained, and system power is
still applied. No Greybus Protocol communication with the Module via
that Interface Block is possible when the Interface is in the
SUSPENDED state.

An Interface shall not alter its :ref:`manifest-description` while it
is entering, in, or exiting the SUSPENDED state.

SUSPENDED is the following group of Interface States::

  (DETECT=DETECT_ACTIVE, V_SYS=V_SYS_ON,
   V_CHG=<V_CHG_OFF or V_CHG_ON>,
   WAKE=WAKE_UNSET, UNIPRO=UPRO_HIBERNATE,
   REFCLK=REFCLK_OFF, RELEASE=RELEASE_DEASSERTED, INTF_TYPE=IFT_GREYBUS,
   ORDER=<ORDER_PRIMARY or ORDER_SECONDARY>,
   MAILBOX=MAILBOX_GREYBUS)

.. _hardware-model-lifecycle-off:

OFF
"""

The OFF Lifecycle State denotes an Interface Block which has power and
communication signals disabled, but whose INTF_TYPE and ORDER are
still known, having been determined during previous Lifecycle States
in the Interface Lifecycle.

OFF is the following group of Interface States::

  (DETECT=DETECT_ACTIVE, V_SYS=V_SYS_OFF, V_CHG=V_CHG_OFF,
   WAKE=WAKE_UNSET, UNIPRO=UPRO_OFF, REFCLK=REFCLK_OFF,
   RELEASE=RELEASE_DEASSERTED,
   INTF_TYPE=<IFT_DUMMY, IFT_UNIPRO, or IFT_GREYBUS>,
   ORDER=<ORDER_PRIMARY or ORDER_SECONDARY>,
   MAILBOX=MAILBOX_NULL)

.. _hardware-model-lifecycle-detached:

DETACHED
""""""""

In the DETACHED Lifecycle State, no Module is attached to the
Interface Block.

The SVC and AP have otherwise coordinated to disable power and other
signaling to the Interface Block, as in the OFF Lifecycle State.

DETACHED is the following group of Interface States::

  (DETECT=DETECT_INACTIVE, V_SYS=V_SYS_OFF, V_CHG=V_CHG_OFF,
   WAKE=WAKE_UNSET, UNIPRO=UPRO_OFF, REFCLK=REFCLK_OFF,
   RELEASE=RELEASE_DEASSERTED, INTF_TYPE=IFT_UNKNOWN,
   ORDER=ORDER_UNKNOWN, MAILBOX=MAILBOX_NULL)

Subsequent chapters in the Greybus Specification will define the
mechanisms which cause Interfaces States to transition between
Lifecycle States.
