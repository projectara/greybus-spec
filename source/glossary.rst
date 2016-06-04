Glossary
========

.. glossary::
   :sorted:

   AP
   AP Module
   Application Processor Module
      A specially designated :term:`Module` within a
      :term:`Greybus System`.

      An AP Module administers a :term:`Greybus System` by exchanging
      :ref:`SVC Protocol <svc-protocol>` :term:`Operation`\s with the
      :term:`SVC`, and :ref:`Control Protocol <control-protocol>`
      Operations with :term:`Module`\s connected to :term:`Interface`\s
      on the :term:`Frame`.

   Bridged PHY Protocol
      One of the designated set of :term:`Protocol`\s
      which allow :term:`Module`\s to expose functionality to the Greybus
      System which is provided by chipsets using alternative physical
      interfaces than |unipro|\ , or which do not comply with an existing
      :term:`Device Class Protocol`.

   Connection
   Greybus Connection
      A Greybus Connection, or simply Connection, is a bidirectional
      communication path between exactly two :term:`Interface`\s.

      There is a |unipro| CPort at each end of a Connection; each such
      CPort is part of a Module or is associated with the SVC.
      :term:`Module`\s may exchange data on a Connection through
      transmission and reception of |unipro| Messages.

      The :term:`AP` may establish Connections to
      Interfaces during :ref:`lifecycles_interface_lifecycle`. When a
      Connection is established, Greybus :term:`Operation`\s
      may be exchanged between the two users of
      the CPorts at either end of the Connection. The semantics for
      these Operations are defined by :term:`Protocol`\s
      in the Greybus Specification.

      The :term:`AP` may also subsequently close Connections. When a
      Connection is closed, Greybus Operations can no longer be
      exchanged between the CPort Users.

      The AP also exchanges data on a Connection with the SVC.

   Connection Protocol
      See :term:`Protocol`.

   Control Connection
      A :term:`Connection` which is used to
      exchange :term:`Operation`\s in the
      :ref:`control-protocol`.

   Control CPort
      A |unipro| CPort provided by an Interface which, under certain
      conditions, responds to Greybus :term:`Operation`\s
      in the :ref:`control-protocol`.

   CSI-2
      Camera Serial Interface 2. See :ref:`CSI 2 Specifications <CSI-2>`.

   CSI-3
      Camera Serial Interface 3. See :ref:`CSI 3 Specifications <CSI-3>`.

   Device Class Protocol
      One of the designated set of :term:`Protocol`
      which allow :term:`Module`\s to expose functionality commonly found
      on mobile handsets to the :term:`Greybus System`, in a manner that
      abstracts various hardware-specific aspects by which that
      functionality is implemented.

   Frame
      A physical entity within a :term:`Greybus System`, containing a
      |unipro| switch, exactly one :term:`SVC`, and a collection of
      :term:`Interface`\s. Each Interface may be occupied by a
      :term:`Module`. A Module may occupy multiple Interfaces. Every Module
      exchanges |unipro| Messages with other elements of a :term:`Greybus
      System` by physical connection to one or more Interfaces.

   FrameTime
      A global monotonic clock shared by all processors in the system.
      FrameTime is based off of a common reference clock and is
      synchronized using Greybus Operations and a series of
      :term:`TimeSync Pulse`\s. FrameTime
      provides a global 64 bit timestamp at a clock rate specified by
      the AP.

   Greybus System
      An implementation of the Project Ara platform which complies with
      the Greybus Specification.

   Interface
      An entity with a Greybus :term:`Module` which can
      interact with a :term:`Frame` via its physical
      connection to an :term:`Interface Block`
      if the Module is attached to the Frame.

   Interface Backend Firmware
      The Interface Backend Firmware may be required for a Module for the
      functioning of an entity other than the :ref:`Interface
      <hardware-model-interfaces>`.

   Interface Block
      The physical connectors exposed by the :term:`Frame`
      for connection to :term:`Module`\s
      as defined by the Project Ara :term:`MDK`.

   Interface Firmware
      The Interface Firmware may be required for a Module for the
      functioning of an :ref:`Interface <hardware-model-interfaces>`,
      which is responsible for exchanging Greybus Operations.

   Interface Lifecycle
      A :ref:`state machine <hardware-model-lifecycle-states>` which
      defines the changes occurring on each :term:`Interface Block`'s
      :ref:`Interface State <hardware-model-interface-states>` from
      the time a :term:`Module` is attached to the Interface Block
      until it is removed.

   Interface State
      An abstract representation of the state of each :term:`Interface
      Block` in a :term:`Greybus System`.

   Message Header
      The Message Header is a common data structure which occurs at
      offset zero of each |unipro| Message containing an individual
      Greybus :term:`Operation`'s :term:`Request` or :term:`Response`.
      Within the Message, the Message Header is followed by an optional
      payload, as defined by the :term:`Operation`'s :term:`Protocol`.

   Module
      A physical entity within a :term:`Greybus System`, which is inserted
      into exactly one :term:`Slot` in a :term:`Frame`.  :term:`Module`\s
      exchange information with one another and with the :term:`SVC` via
      |unipro| Messages as defined by [MIPI01]_ and in accordance with the
      Greybus Specification.

   MDK
   Module Developers' Kit
      Project Ara Module Developer's Kit. This comprises various
      documents which collectively define the Ara platform.

   Operation
      An abstraction defined as part of a :term:`Protocol`.
      An Operation comprises an :term:`Operation Type`, an Operation
      :term:`Request` (or simply "Request"), and an Operation
      :term:`Response` (or simply "Response").

      Requests and Responses are |unipro| Messages as defined in
      [MIPI01]_; the |unipro| L4 payload and semantics of each Request
      and Response are defined by the Greybus Specification.

   Operation Type
      Each :term:`Protocol` defines a set of
      Operation Types. Each Operation Type has a name, a Request Value,
      and a Response Value.

      An Operation Type has a name, along with a one-byte nonzero value,
      from which the Operation Type's Request Value and Response Value
      are derived.

      Each Operation Type has an associated unsigned value, which lies in
      the range 1 to 127 (the value 0 is invalid). Each Operation Type has a
      Request Value, which equals the Operation Type's value, and a Response
      Value, which equals the Operation Type's value logically ORed with
      0x80.

      For example, an Operation Type with value 0x03 has Request Value
      0x03, and Response Value 0x83.

   Primary Interface
      When a :term:`Module` is attached to one or more
      :term:`Interface Block`\s in a :term:`Slot`, exactly one such
      Interface Block is the *Primary Interface* to the Module.

      This Interface Block shall have an Interface ID which is the
      lowest in value of all of the Interface Blocks attached to the
      Module.

      An attached Module can only be ejected from a :term:`Greybus System`
      via its Primary Interface. The means of ejection are
      implementation-defined.

   Protocol
      A Greybus Protocol defines the layout and semantics of the
      :term:`Operation`\s which may be exchanged on a
      :term:`Connection`.

      Protocols are grouped according to their function:

            - :term:`Special Protocol`\s
            - :term:`Device Class Protocol`\s
            - :term:`Bridged PHY Protocol`\s

   Request
      A |unipro| Message sent by a :term:`Module` which
      initiates an :term:`Operation`.

      The |unipro| L4 payload and semantics of each Request are
      specified by the :term:`Protocol` definition of
      the Request's associated Operation.

   Requestor
      Within the context of an :term:`Operation`, the
      :term:`Module` which sends or sent the :term:`Operation`'s
      :term:`Request`.

   Response
      A |unipro| Message which is  an :term:`Operation`.

      The |unipro| L4 payload and semantics of each Response are
      specified by the :term:`Protocol` definition of
      the Response's associated Operation.

   Respondent
      Within the context of an :term:`Operation`, the
      :term:`Module` which sends or sent the Operation's
      :term:`Response`.

   Secondary Interface
      When a :term:`Module` is attached to one or more
      :term:`Interface Block`\s :term:`Slot`,only one such Interface
      Block is the :term:`Primary Interface` to the Module. All other
      such Interface Blocks are Secondary Interfaces to the Module.

      These Interface Blocks, if any, have Interface IDs which are
      consecutive integers following the Interface ID of the Primary
      Interface to the Module.

      :term:`Module`\s may communicate via Greybus via Secondary
      Interfaces, but the Module as a whole is generally identified by
      the Interface ID of its Primary Interface. Additionally, the
      Module can only be physically ejected from the :term:`Greybus
      System` via its Primary Interface, through implementation-defined
      means.

   Slot
      The :term:`Interface`\s in a :term:`Frame` are physically
      partitioned into groups of one or more Interfaces. Each such
      group is called a Slot.

      While each Interface in a Slot may be physically connected to at
      most one :term:`Module` at any given time, a Slot
      with multiple Interfaces may be connected to multiple
      :term:`Module`\s. Additionally, a Module may be connected to multiple
      Interfaces, depending upon its size.

   Special Protocol
      One of the designated set of Greybus :term:`Protocol`\s
      which permits discovery and enumeration of
      :term:`Module`\s by the :term:`SVC`, and for other
      special-purpose tasks, such as network and power bus management.

   SVC
   Supervisory Controller
      An entity within the :term:`Frame` that configures
      and controls the |unipro| network, and controls other elements of
      each :term:`Interface`.

   Switch
      An entity within the :term:`Frame` that allows
      |unipro| implementations on :term:`Module`\s to
      communicate with one another via |unipro| CPorts.

      The Switch is managed directly by the :term:`SVC`.
      Through the use of the :ref:`svc-protocol`, the
      :term:`AP` may request the SVC to configure
      the Switch in order to manage its internal state, as well as to
      establish :term:`Greybus Connection`\s between :term:`Interface`\s.

   TimeSync Pulse
      An assertion and deassertion of the WAKE pin associated with an
      Interface Block for the purposes of communicating the FrameTime to
      an Interface Block. The duration of the assertion is
      implementation-defined but must be shorter than both the
      :term:`WAKE Pulse` and the
      :term:`WAKE Pulse Cold Boot Threshold` respectively.

   WAKE Pulse
      An assertion and deassertion of the :ref:`hardware-model-wake`
      sub-state of an :term:`Interface State`.

   WAKE Pulse Cold Boot Threshold
      An implementation-defined duration in time. If a :term:`WAKE Pulse`
      occurs on an :term:`Interface State` and exceeds this duration,
      then any Module which is attached to the corresponding Interface
      Block which is capable of Greybus communications shall initialize
      or re-initialize itself.

      Additional details are described in :ref:`hardware-model-wake`.
