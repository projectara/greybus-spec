Introduction (Informative)
==========================


.. raw:: latex

  \epigraph{Good artists copy, great artists steal.}
  {--- Pablo Picasso}

.. raw:: html

  <blockquote>
  <div><div class="line-block">
  <div class="line">Good artists copy, great artists steal.</div>
  <div class="line">— Pablo Picasso</div>
  </div></div>
  </blockquote>

The Greybus Specification describes a suite of communications
protocols required to support the Project Ara modular cell phone
platform.

The Project Ara Module Developer's Kit (MDK) is the official Project
Ara platform definition; it comprises various documents which
collectively define the Ara platform, including its industrial,
mechanical, electrical, and software design and requirements. Refer to
the main MDK document for an introduction to the platform and its
components. Familiarity with this document is assumed throughout the
Greybus Specification; its definitions are incorporated here by
reference.

The Greybus Specification is included within the MDK; its purpose is
to define software interfaces whose data and control flow cross
Module boundaries. This is required to ensure software compatibility
and interoperability between Modules and the :ref:`Frame
<glossary-frame>`.

Project Ara utilizes the |unipro| protocol for inter-Module
communication. The |unipro| specification is defined by the |mipi|
Alliance. |unipro|\ 's design follows a layered architecture, and
specifies how communication shall occur up to the Application layer in
the `OSI model
<http://www.ecma-international.org/activities/Communications/TG11/s020269e.pdf>`_.
Project Ara's architecture requires an application layer specification
which can handle dynamic device insertion and removal from the system
at any time and at variable locations. It also requires that existing
Modules interoperate with Modules introduced at later dates. This
document aims to define a suite of application layer protocols which
meet these needs.

In addition to |unipro|, Project Ara also specifies a small number of
other interfaces between Modules and the Frame. These include a
power bus, signals which enable hotplug and power management
functions, and interface pins for Modules which emit and receive radio
signals. The Greybus Specification also defines the behavior of the
system's software with respect to these interfaces.

A Project Ara "Module" is a device that slides into a physical slot on
a Project Ara Frame.  The Frame has one or more "Interface Blocks."
Each Interface Block is a single physical port through which |unipro|
packets are transferred.  Modules connect one or more Interface Blocks
on the Frame.  Greybus represents each Interface Block with an
"Interface" abstraction.  A Greybus Interface can support one or more
"Bundles". A Bundle represents a logical "device" in Greybus that does
one logical "thing" as far as the host operating system works.
Bundles communicate with each other on the network via one or more
|unipro| CPorts.  A CPort is a bidirectional pipe through which
|unipro| traffic is exchanged.  Bundles send "messages" via CPorts;
messages are datagrams with ancillary metadata.  All CPort traffic is
peer-to-peer; multicast communication is not supported.

Project Ara presently requires that exactly one application processor
(AP) is present on the system for storing user data and executing
applications. The Module that contains the AP is the *AP Module*; the
Greybus specification defines a :ref:`control-protocol` to allow the
AP Module to accomplish its tasks.

In order to ensure interoperability between the wide array of
application processors and hardware peripherals commonly available on
mobile handsets, the Greybus Specification defines a suite of
:ref:`device-class-protocols`, which allow for communication between
the various Modules on the system, regardless of the particulars of
the chipsets involved.

The main functional chipsets on Modules may communicate via a native
|unipro| interface or via "bridges," special-purpose ASICs which
intermediate between these chipsets and the |unipro| network. In order
to provide a transition path for chipsets without native |unipro|
interfaces, the Greybus Specification defines a variety of
:ref:`bridged-phy-protocols`, which allow Module developers to expose
these existing protocols to the network. In addition to providing an
"on-ramp" to the platform, this also allows the implementation of
Modules which require communication that does not comply with a device
class Protocol.

