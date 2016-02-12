.. highlight:: text

Hotplug Implementation (Informative)
====================================

.. warning::

   **Work in progress**. This section assumes:

   1. No spontaneous errors on the UniPro link once it's established

   2. ES2 modules only (no ES3). (There are changes to the UniPro
      linkup sequence in ES3 that will be detailed in future patches.)

   3. 1x2 modules with Toshiba bridge ASICs only (no 2x2 modules, no
      "dummy" modules, etc.)

   4. No power management (e.g. it's assumed OK to power on all
      modules at the same time)

   5. Modules only drain power (no battery modules)

   6. SVC and AP are booted and operational

   7. Potential changes to wake/detect are ignored (still under
      discussion; details are not yet available)

This appendix describes how one implementation of a Greybus system
physically supports dynamic insertion and removal of modules. In
particular, it defines the state machines which manage module hotplug.

It is purely informative from the perspective of the Greybus
specification itself. Other implementations of Greybus may choose to
support hotplug differently.

Interface States
----------------

This section describes the instantaneous sub-states associated with an
interface on a module at any given time.

An *interface state* is a tuple containing the sub-state values for an
interface at a particular time.

An interface state is written as follows::

  (WD=<wd>, V_SYS=<v_sys>, V_CHG=<v_chg>, REFCLK=<ref_clk>, UNIPRO=<unipro>,
   MBOX=<mbox>, DEVID=<devid>, CPORT=[<cports>], ORD=<ord>)

Where each of the values in angle brackets (<>) are one of the legal
values for the sub-states as defined below.

Wake/Detect (WD)
~~~~~~~~~~~~~~~~

*WD* is the wake/detect sub-state. It is the instantaneous state of
the wake/detect pin, and is one of:

- UNK: unknown
- INA_S: inactive stable
- INA_U: inactive unstable (only occurs while debouncing during state
  transitions)
- ACT_S: active stable
- ACT_U: active unstable (only occurs while debouncing during state
  transitions)

Physically speaking, the WD sub-state is what the SVC has measured
most recently.

System Power Bus (V_SYS)
~~~~~~~~~~~~~~~~~~~~~~~~

*V_SYS* is the system power sub-state. It describes whether power is
supplied to an interface by the system, and is one of:

- OFF: power is not supplied
- ON: power is supplied

Battery Power Bus (V_CHG)
~~~~~~~~~~~~~~~~~~~~~~~~~

TBD. For now, the *V_CHG* sub-state is simply the value "0".

Reference Clock (REFCLK)
~~~~~~~~~~~~~~~~~~~~~~~~

The *REFCLK* sub-state defines whether an interface's reference clock
is enabled, and is one of:

- OFF: reference clock is not supplied
- ON: reference clock is supplied

.. note::

   The state machines below ensure that REFCLK is always OFF when
   V_SYS is OFF.

UniPro Link (UNIPRO)
~~~~~~~~~~~~~~~~~~~~

The *UNIPRO* sub-state is a simplification of the state of an
interface's UniPro link. It is one of:

- DOWN: link is down
- LSS: link startup sequence is ongoing
- UP: link is established

Switch Mailbox (MBOX)
~~~~~~~~~~~~~~~~~~~~~

The *MBOX* sub-state is the value of the mailbox attribute for the
UniPort associated with the interface's switch port.

It is one of:

- NONE: zero
- READY: interface signals readiness for Greybus operation

Other values are possible, but are treated as errors.

Device ID (DEVID)
~~~~~~~~~~~~~~~~~

The *DEVID* sub-state contains UniPro device ID associated with the
UniPort contained within a module's interface. It is one of:

- INV: special state signaling the device ID is invalid
- *N*: a positive integer *N*.

CPort Connections (CPORT)
~~~~~~~~~~~~~~~~~~~~~~~~~

The *CPORT* sub-state is a list containing the CPort numbers on an
interface which are connected to a peer on the UniPro network. A list
is given between square brackets, ([]). The empty list is [].

Note that the CPort associated with the Greybus Control Protocol is
zero. Therefore, a CPORT sub-state when only the Control Protocol
connection is established is written as [0]. A CPORT sub-state with
the Control Protocol connection on CPort zero and another connection
on CPort one is written as [0, 1].

Order (ORD)
~~~~~~~~~~~

The *ORD* sub-state defines whether an interface has been detected as
the "primary" or one of the "secondary" interfaces on a module. It is
one of:

- UNK: interface is not associated with any module
- PRI: interface is the unique primary interface associated with a module
- SEC: interface is one of zero or more secondary interfaces
  associated with a module

Module Boot
-----------

.. warning:: This section currently assumes a 1x2 module with ES2 bridge ASIC.

This section describes the state machine which boots an interface. It
starts from an ABSENT state, and describes how the interface
transitions to a BOOTED state.

The ABSENT state is defined as the initial state of an interface
regardless of whether a module is inserted into it after the entire
Greybus system boots, or if it was physically present before the
system's power-on reset.

The BOOTED state describes an interface which is powered on and
initialized, but does not yet have any Greybus connections
established.

Boot State Machine
~~~~~~~~~~~~~~~~~~

.. image:: /img/dot/hotplug-absent2boot.png
   :align: center

Boot States
~~~~~~~~~~~

The corresponding interface states for the above states are given in
this section. For each state, a brief description is accompanied by a
tuple indicating the associated interface state.

- **ABSENT**: The SVC has detected the absence of a module on the interface,
  or has yet to start detection. Power and clock are disabled; UniPro
  is down. ::

    (WD=UNK, V_SYS=OFF, V_CHG=0, REFCLK=OFF, UNIPRO=DOWN, MBOX=NONE, DEVID=INV,
     CPORT=[], ORD=UNK)

- **DEBOUNCING**: The interface WD has been asserted, and is being debounced. ::

    (WD=INA_U or ACT_U, V_SYS=OFF, V_CHG=0, REFCLK=OFF, UNIPRO=DOWN, MBOX=NONE,
    DEVID=INV, CPORT=[], ORD=UNK)

  Note that, as explained in the *iface_detect_assert* transition below,
  the transition from ABSENT to DEBOUNCING occurs when WD changes from
  UNK to ACT_U. However, the *svc_db_cont* transition may cause WD to
  transition from ACT_U to INA_U or from INA_U back to ACT_U while the
  interface state remains DEBOUNCING.

  The precise algorithm used to debounce the WD state is not specified
  in this document.

- **DETECTED**: The interface WD has been asserted through the entire
  debounce period. The SVC has determined that the interface is now
  occupied.

  .. warning:: This assumes a 1x2 module only. 2x2 modules may result in
               the interface ORD sub-state being SEC instead of PRI.

  The ORD sub-state of the interface has been determined. ::

    (WD=ACT_S, V_SYS=OFF, V_CHG=0, REFCLK=OFF, UNIPRO=DOWN, MBOX=NONE, DEVID=INV,
     CPORT=[], ORD=PRI)

  .. TODO (fix for SW-2608) specify how to determine ORD, generalize to
     1x2 versus 2x2 (this may require another sub-state or more global
     module-level state definitions), etc.

- **COLD_BOOT**: The SVC has enabled power and clock to the interface. An
  attempt to establish the UniPro link is ongoing. ::

    (WD=ACT_S, V_SYS=ON, V_CHG=0, REFCLK=ON, UNIPRO=LSS, MBOX=NONE, DEVID=INV,
    CPORT=[], ORD=PRI)

  .. FIXME: This language is deliberately vague about who initiates link
     startup. There is a difference in ES3 -- the switch initiates (fix
     for SW-2609) -- while in ES2, the bridge initiates. (Also see SW-2259.)

- **LINK_UP**: The UniPro link has been established. The SVC is
  waiting for a change to the MBOX state to determine that a Greybus
  interface has finished booting. ::

    (WD=ACT_S, V_SYS=ON, V_CHG=0, REFCLK=ON, UNIPRO=UP, MBOX=NONE, DEVID=N,
     CPORT=[], ORD=PRI)

- **BOOTED**: The interface has written to the switch port mailbox, and
  MBOX is valid (i.e. is the READY value). ::

    (WD=ACT_S, V_SYS=ON, V_CHG=0, REFCLK=ON, UNIPRO=UP, MBOX=READY, DEVID=N,
     CPORT=[], ORD=PRI)

- **DEAD_DUMMY**: The interface is detected, and ORD is known, but is
  otherwise powered off. No Greybus communication can be performed. ::

    (WD=ACT_S, V_SYS=OFF, V_CHG=0, REFCLK=OFF, UNIPRO=DOWN, MBOX=NONE, DEVID=INV,
     CPORT=[], ORD=PRI)

Boot State Transitions
~~~~~~~~~~~~~~~~~~~~~~

The events which cause the labeled transitions between these states,
and the actions taken by the SVC, AP, and interface during these
transitions, are as follows.

- *iface_detect_assert* (ABSENT → DEBOUNCING)

  Either due to the SVC measuring the WD state at power-on reset, or due
  to the module being inserted afterwards, the WD state is observed to
  be ACT_U. This triggers WD debouncing through transition to the
  DEBOUNCING state.

- *svc_db_inact* (DEBOUNCING → ABSENT)

  If during the SVC debounce period, the WD state transitions to INA_S
  for sufficient time, the SVC determines the WD line signals the
  interface is ABSENT and returns to that state. No notifications to the
  AP are made.

- *svc_db_cont* (DEBOUNCING → DEBOUNCING)

  The SVC debounce period continues for a predefined duration, during
  which the SVC detects transitions of the WD line.

- *svc_db_act* (DEBOUNCING → DETECTED)

  The WD line remains at ACT_U for the entire debounce period, and the
  SVC determines the module is DETECTED. The WD state is redefined to
  ACT_S.

- *svc_iface_cold_boot* (DETECTED → COLD_BOOT)

  The SVC enables V_SYS and REFCLK to the interface.

  It then sends a cold boot "wake out" pulse by changing the WD state
  from ACT_S to INA_S for a predetermined duration, then changing it
  back to ACT_S.

  This "wake out" pulse a signal to the interface to perform a cold or
  power-on reset and prepare for Greybus communication.

  The duration of this pulse is not currently specified in this
  document.

- *unipro_lss_cont* (COLD_BOOT → COLD_BOOT)

  .. warning::

     This is an ES2 bridge-specific description: the ES3 and dummy cases
     differ.

  Once the module has been cold booted, it will initiate the UniPro link
  startup sequence.

  The interface remains in the COLD_BOOT state while the UniPro link
  startup sequence is ongoing.

- *unipro_lss_success* (COLD_BOOT → LINK_UP)

  When the UniPro link startup sequence completes successfully, the
  unipro_lss_success transition occurs, taking the interface to the
  LINK_UP state, in which the UNIPRO sub-state is UP.

  When the link is established, the SVC proceeds to assign a device ID
  for the UniPro peer linked up to the interface, making the DEVID
  sub-state take some integral value *N*.

- *svc_wait_boot* (LINK_UP → LINK_UP)

  The SVC starts a timeout, waiting for a change in the MBOX state. If
  the interface is part of a module and contains a Greybus
  implementation, it is initializing itself for the initial Greybus
  Control Protocol connection.

- *iface_mbox_write* (LINK_UP → BOOTED)

  The interface is ready for Greybus Connection establishment. It has
  written a boot status into DME following link establishment, and
  notifies the SVC of its readiness by writing to the mailbox attribute
  on its switch port.

- *svc_boot_err* (LINK_UP → DEAD_DUMMY)

  The interface either writes an invalid value into the mailbox
  attribute, or an SVC timeout expires during the LINK_UP period.

- *unipro_lss_fail* (COLD_BOOT → DEAD_DUMMY)

  The attempt to establish the UniPro link fails for whatever
  reason. The SVC disables power and clock to the interface. At this
  point, the interface is considered to contain either a damaged Greybus
  implementation, or it is simply a "blank" or "spacer" interface.

Module Enumeration
------------------

Once an interface is in the BOOTED state, the system attempts to
establish sufficient Greybus connections to be usable by
applications. When this succeeds, the interface is in the ENUMERATED
state.

Enumeration State Machine
~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   This is just a transcription of the whiteboard image -- more
   thought is needed to flesh out any needed inner transitions /
   back-edges.

.. image:: /img/dot/hotplug-boot2enum.png
   :align: center

Enumeration States
~~~~~~~~~~~~~~~~~~

TODO.

Enumeration State Transitions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO.

Module Unplug
-------------

Unplug State Machine
~~~~~~~~~~~~~~~~~~~~

.. image:: /img/dot/hotplug-unplug.png
   :align: center

Unplug States
~~~~~~~~~~~~~

TODO.

Unplug State Transitions
~~~~~~~~~~~~~~~~~~~~~~~~

TODO.

Module Forcible Removal
-----------------------

Forcible Removal State Machine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. image:: /img/dot/hotplug-forcibleremoval.png
   :align: center

Forcible Removal State Machine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO.

Forcible Removal State Transitions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO.
