.. include:: defines.rst

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
components. Familiarity with this document is assumed throughout this
document; its definitions are incorporated here by reference.

The Greybus Specification is included within the MDK; its purpose is
to define software interfaces whose data and control flow crosses
module boundaries. This is required to ensure software compatibility
and interoperability between modules and the endoskeleton.

Project Ara utilizes the |unipro| protocol for inter-module
communication. The |unipro| specification is defined by the |mipi|
Alliance. |unipro|\ 's design follows a layered architecture, and
specifies how communication shall occur up to the Application layer in
the `OSI model
<http://www.ecma-international.org/activities/Communications/TG11/s020269e.pdf>`_.
Project Ara's architecture requires an application layer specification
which can handle dynamic device insertion and removal from the system
at any time and at variable locations. It also requires that existing
modules interoperate with modules introduced at later dates. This
document aims to define a suite of application layer protocols which
meet these needs.

In addition to |unipro|, Project Ara also specifies a small number of
other interfaces between modules and the endoskeleton. These include a
power bus, signals which enable hotplug and power management
functions, and interface pins for modules which emit radio
signals. The Greybus Specification also defines the behavior of the
system's software with respect to these interfaces.

A Project Ara “module” is a device that slides into a physical slot on
a Project Ara endoskeleton.  Each module communicates with other
modules on the network via one or more |unipro| CPorts. A CPort is a
bidirectional pipe through which |unipro| traffic is
exchanged. Modules send “messages” via CPorts; messages are datagrams
with ancillary metadata. All CPort traffic is peer-to-peer; multicast
communication is not supported.

Project Ara presently requires that exactly one application processor
(AP) is present on the system for storing user data and executing
applications. The module which contains the AP is the *AP module*; the
Greybus specification defines a :ref:`control-protocol` to allow the
AP module to accomplish its tasks.

In order to ensure interoperability between the wide array of
application processors and hardware peripherals commonly available on
mobile handsets, the Greybus Specification defines a suite of
:ref:`device-class-protocols`, which allow for communication between
the various modules on the system, regardless of the particulars of
the chipsets involved.

The main functional chipsets on modules may communicate via a native
|unipro| interface or via “bridges,” special-purpose ASICs which
intermediate between these chipsets and the |unipro| network. In order
to provide a transition path for chipsets without native UniPro
interfaces, the Greybus Specification defines a variety of
:ref`bridged-phy-protocols`, which allow module developers to expose
these existing protocols to the network. In addition to providing a
"on-ramp" to the platform, this also allows the implementation of
modules which require communication that does not comply with a device
class protocol.

