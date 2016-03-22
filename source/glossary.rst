Glossary
========

.. _glossary-ap-module:

AP Module
    Application Processor Module.

Application Processor Module
    A specially designated :ref:`Module <glossary-module>` within a
    :ref:`Greybus System <glossary-greybus-system>`.

    An AP Module administers a Greybus System by exchanging :ref:`SVC
    Protocol <svc-protocol>` :ref:`Operations <glossary-operation>`
    with the :ref:`SVC <glossary-svc>`, and :ref:`Control Protocol
    <control-protocol>` Operations with Modules connected to
    :ref:`Interfaces <glossary-interface>` on the :ref:`Frame
    <glossary-frame>`.

.. _glossary-bridged-phy-protocol:

Bridged PHY Protocol
    One of the designated set of :ref:`Protocols <glossary-protocol>`
    which allow Modules to expose functionality to the Greybus System
    which is provided by chipsets using alternative physical
    interfaces than |unipro|\ , or which do not comply with an
    existing :ref:`Device Class Protocol
    <glossary-device-class-protocol>`.

.. _glossary-connection:

Connection
    A bidirectional communication path between exactly two
    :ref:`Modules <glossary-module>`, or between the AP Module and the
    :ref:`SVC <glossary-svc>`.

    There is a |unipro| CPort at each end of a Connection; each such
    CPort is part of a Module or is associated with the SVC. Modules
    may exchange data on a Connection through transmission and
    reception of |unipro| Messages, according to one of the
    :ref:`Protocols <glossary-protocol>` defined by the Greybus
    Specification. The AP Module also exchanges data on a Connection
    to the SVC.

.. _glossary-connection-protocol:

Connection Protocol
    See :ref:`Protocol <glossary-protocol>`.

.. _glossary-device-class-protocol:

Device Class Protocol
    One of the designated set of :ref:`Protocol <glossary-protocol>`
    which allow Modules to expose functionality commonly found on
    mobile handsets to the Greybus System, in a manner that abstracts
    various hardware-specific aspects by which that functionality is
    implemented.

.. _glossary-frame:

Frame
    A physical entity within a :ref:`Greybus System
    <glossary-greybus-system>`, containing a |unipro|
    switch, exactly one :ref:`SVC <glossary-svc>`, and a collection
    of :ref:`Interfaces <glossary-interface>`. Each Interface may be
    occupied by a :ref:`Module <glossary-module>`. A Module may occupy
    multiple Interfaces. Every Module exchanges |unipro| Messages with
    other elements of a Greybus System by physical connection to one
    or more Interfaces.

.. _glossary-greybus-system:

Greybus System
    An implementation of the Project Ara platform which complies with
    the Greybus Specification.

.. _glossary-interface:

Interface
    An abstract representation of the services provided by the
    :ref:`Frame <glossary-module>` at one of its :ref:`Interface
    Blocks <glossary-interface-block>`.

.. _glossary-interface-block:

Interface Block
    The physical connectors exposed by the :ref:`Frame
    <glossary-frame>` for connection to :ref:`Modules
    <glossary-module>` as defined by the Project Ara :ref:`MDK
    <glossary-mdk>`.

.. _glossary-message-header:

Message Header
    The Message Header is a common data structure which occurs at
    offset zero of each |unipro| Message containing an individual
    Greybus :ref:`Operation's <glossary-operation>` :ref:`Request
    <glossary-request>` or :ref:`Response <glossary-response>`. Within
    the Message, the Message Header is followed by an optional
    payload, as defined by the Operation's :ref:`Protocol
    <glossary-protocol>`.

.. _glossary-module:

Module
    A physical entity within a Greybus System, which is inserted into
    exactly one :ref:`Slot <glossary-slot>` in a :ref:`Frame
    <glossary-frame>`.  Modules exchange information with one another
    and with the :ref:`SVC <glossary-svc>` via |unipro| Messages as
    defined by [MIPI01]_ and in accordance with the Greybus
    Specification.

.. _glossary-mdk:

MDK
    Module Developers' Kit.

Module Developers' Kit
    Project Ara Module Developer's Kit. This comprises various
    documents which collectively define the Ara platform.

.. _glossary-operation:

Operation
    An abstraction defined as part of a :ref:`Protocol
    <glossary-protocol>`. An Operation comprises an :ref:`Operation
    Type <glossary-operation-type>`, an Operation :ref:`Request
    <glossary-request>` (or simply "Request"), and an Operation
    :ref:`Response <glossary-response>` (or simply "Response").

    Requests and Responses are |unipro| Messages as defined in
    [MIPI01]_; the |unipro| L4 payload and semantics of each Request
    and Response are defined by the Greybus Specification.

.. _glossary-operation-type:

Operation Type
    Each :ref:`Protocol <glossary-protocol>` defines a set of
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

.. _glossary-protocol:

Protocol
    A Greybus Protocol defines the layout and semantics of the
    :ref:`Operations <glossary-operation>` which may be exchanged on a
    :ref:`Connection <glossary-connection>`.

    Protocols are grouped according to their function:

        - :ref:`Special Protocols <glossary-special-protocol>`
        - :ref:`Device Class Protocols <glossary-device-class-protocol>`
        - :ref:`Bridged PHY Protocols <glossary-bridged-phy-protocol>`

.. _glossary-request:

Request
    A |unipro| Message sent by a :ref:`Module <glossary-module>` which
    initiates an :ref:`Operation <glossary-operation>`.

    The |unipro| L4 payload and semantics of each Request are
    specified by the :ref:`Protocol <glossary-protocol>` definition of
    the Request's associated Operation.

.. _glossary-requestor:

Requestor
   Within the context of an :ref:`Operation <glossary-operation>`, the
   :ref:`Module <glossary-module>` which sends or sent the Operation's
   :ref:`Request <glossary-request>`.

.. _glossary-response:

Response
    A |unipro| Message which is  an :ref:`Operation
    <glossary-operation>`.

    The |unipro| L4 payload and semantics of each Response are
    specified by the :ref:`Protocol <glossary-protocol>` definition of
    the Response's associated Operation.

.. _glossary-respondent:

Respondent
   Within the context of an :ref:`Operation <glossary-operation>`, the
   :ref:`Module <glossary-module>` which sends or sent the Operation's
   :ref:`Response <glossary-request>`.

.. _glossary-special-protocol:

Special Protocol
    One of the designated set of Greybus :ref:`Protocols
    <glossary-protocol>` which permits discovery and enumeration of
    :ref:`Modules <glossary-module>` by the :ref:`SVC <glossary-svc>`,
    and for other special-purpose tasks, such as network and power bus
    management.

.. _glossary-svc:

Supervisory Controller (SVC)
    An entity within the :ref:`Frame <glossary-frame>` that configures
    and controls the |unipro| network, and controls other elements of
    each :ref:`Interface <glossary-interface>`.

.. _glossary-slot:

Slot
    The :ref:`Interfaces <glossary-interface>` in a :ref:`Frame
    <glossary-frame>` are physically partitioned into groups of one or
    more Interfaces. Each such group is called a Slot.

    While each Interface in a Slot may be physically connected to at
    most one :ref:`Module <glossary-module>` at any given time, a Slot
    with multiple Interfaces may be connected to multiple
    Modules. Additionally, a Module may be connected to multiple
    Interfaces, depending upon its size.
