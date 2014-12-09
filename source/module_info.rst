.. include:: defines.rst

Module Information
==================

                    | Imitation is the sincerest form of flattery.
                    | — Charles Caleb Colton

A Greybus module must contain self-descriptive information in order to
identify itself to the |unipro| network. This information is found in
the Module Manifest, which describes components present within the
module that are accessible via |unipro|. The Module Manifest includes a
set of Descriptors which present a functional description of the
module.  Together, these define what the module is from an application
protocol layer, including its capabilities, and how it should be
communicated with.

.. _general-requirements:

General Requirements
--------------------

All data found in message structures defined below shall adhere to the
following general requirements:

* All numeric values shall be unsigned unless explicitly stated otherwise.
* Numeric values prefixed with 0x are hexadecimal; they are decimal otherwise.
* All headers and descriptor data within a Module Manifest shall be
  implicitly followed by pad bytes as necessary to bring the
  structure's total size to a multiple of 4 bytes.
* Accordingly, the low-order two bits of all header “size” field values shall be 00.
* Any reserved or unused space (including implicit padding) in a
  header or descriptor shall be ignored when read, and zero-filled
  when written.
* All descriptor field values shall have little endian format.
* All offset and size values are expressed in units of bytes unless
  explicitly stated otherwise.
* All string descriptors shall consist of UTF-8 encoded characters.
* All major structures (like the module manifest header) and interface
  protocols (like that between the AP and SVC) shall be versioned, to
  allow future extensions (or fixes) to be added and recognized.

Module Manifest
---------------

The Module Manifest is a contiguous buffer that includes a
Manifest Header and a set of Descriptors.  When read, a Module
Manifest is transferred in its entirety.  This allows the module to be
described to the host all at once, alleviating the need for multiple
communication messages during the enumeration phase of the module.

Manifest Header
^^^^^^^^^^^^^^^

The Manifest Header is present at the beginning of the Module Manifest
and defines its size in bytes and the version of the Greybus protocol
with which the Manifest complies.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description

   * - 0
     - size
     - 2
     -
     - Size of the entire manifest

   * - 2
     - version_major
     - 1
     - |gb-major|
     - Greybus major version

   * - 3
     - version_minor
     - 1
     - |gb-minor|
     - Greybus minor version

The values of version_major and version_minor values shall refer to
the highest version of this document (currently |gb-major|.\
|gb-minor|) with which the format complies.

Minor versions increment with additions to the existing descriptor
definition, in such a way that reading of the Module Manifest by any
protocol handler that understands the version_major should not fail. A
changed version_major indicates major differences in the Module
Manifest format, and it is not expected that parsers of older major
versions would be able to understand newer ones.

All Module Manifest parsers shall be able to interpret manifests
formatted using older Greybus versions, such that they will still work
properly (i.e. backwards compatibility is required).

Descriptors
^^^^^^^^^^^

Following the Manifest Header is one or more Descriptors.  Each
Descriptor is composed of a Descriptor Header followed by Descriptor
Data. The format of the Descriptor Data depends on the type of the
descriptor, which is specified in the header. These Descriptor formats
are laid out below.

Descriptor Header
"""""""""""""""""

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Description

   * - 0
     - size
     - 2
     - Size of this descriptor record, in bytes

   * - 2
     - type
     - 1
     - Type of the descriptor, see below for values.

Descriptor types
""""""""""""""""

This table describes the known descriptor types and their values:

.. list-table::
   :header-rows: 1

   * - Descriptor Type
     - Value

   * - Invalid
     - 0x00

   * - Module
     - 0x01

   * - String
     - 0x02

   * - Interface
     - 0x03

   * - CPort
     - 0x04

   * - Class
     - 0x05

   * - (All other values reserved)
     - 0x06..0xff


Module Descriptor
^^^^^^^^^^^^^^^^^

This descriptor describes module-specific values as set by the vendor
who created the module. Every module manifest shall have exactly one
module descriptor.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description

   * - 0
     - size
     - 2
     - 0x0013
     - Size of this descriptor record

   * - 2
     - type
     - 1
     - 0x01
     - Type of the descriptor (Module)

   * - 3
     - vendor
     - 2
     -
     - Module vendor id

   * - 5
     - product
     - 2
     -
     - Module product Id

   * - 7
     - version
     - 2
     -
     - Module version

   * - 9
     - vendor_string_id
     - 1
     -
     - String id for descriptor containing the vendor name

   * - 10
     - product_string_id
     - 1
     -
     - String id for descriptor containing the product name

   * - 11
     - unique_id
     - 8
     -
     - Unique ID of the module

The *vendor* field is a value assigned by Google.  All vendors should
apply for a Project Ara vendor ID in order to properly mark their
modules. Contact ara-dev@google.com for more information regarding the
vendor ID application process.

The *product* field is controlled by the vendor, and should be unique
per type of module that is created.

The *version* field is the version of the module that is present. This
number shall be changed if the module firmware functionality changes
in such a way that the operating system needs to know about it. [#h]_
[#i]_ [#j]_ [#k]_

*vendor_string_id* is a reference to a specific string descriptor id
that provides a description of the vendor who created the module.  If
there is no string present for this value in the Module Manifest, this
value shall be 0x00.  See the :ref:`string-descriptor` section below for
more details.

*product_string_id* is a reference to a specific string descriptor id
that provides a description of the product.  If there is no string
present for this value in the Module Manifest, this value shall be 0x00.
See the :ref:`string-descriptor` section below for more details.

The *unique_id* field is an 8 byte Unique ID that is written into each
Greybus compliant chip during manufacturing. Google manages the Unique
IDs, providing each manufacturer with the means to generate compliant
Unique IDs for their products. In a module that contains multiple
interfaces, there will be more than one hardware Unique ID
available. It is the responsibility of the module designer to
designate one primary interface and expose that primary Unique ID in
this field.

.. _string-descriptor:

String Descriptor
^^^^^^^^^^^^^^^^^

A string descriptor provides a human-readable form of a string for a
specific value, like a vendor or product string.  Any string that is
not an even multiple of 4 bytes in length shall be padded out to a
4-byte boundary with 0x00 values.  Strings consist of UTF-8 characters
and are not required to be zero terminated. A string descriptor shall
be referenced only once within the manifest, e.g. only one product (or
vendor) string field may refer to string id 2.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description

   * - 0
     - size
     - 2
     - 0x0005+X
     - Size of this descriptor record

   * - 2
     - type
     - 1
     - 0x02
     - Type of the descriptor (String)

   * - 3
     - length
     - 1
     - X
     - Length of the string in bytes (excluding trailing pad bytes)

   * - 4
     - id
     - 1
     - cannot be 0x00
     - String id for this descriptor

   * - 5
     - string
     - X
     -
     - UTF-8 characters for the string (padded if necessary)

Interface Descriptor
^^^^^^^^^^^^^^^^^^^^

An interface descriptor describes an access point for a module to the
|unipro| network. Each interface represents a single physical port
through which |unipro| packets are transferred. Every module shall have
at least one interface. Each interface has an id whose value is unique
within the module.  The first interface shall have id 0, the second
(if present) shall have value 1, and so on. The purpose of these Ids
is to allow CPort descriptors to define which interface they are
associated with.

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description

   * - 0
     - size
     - 2
     - 0x0004
     - Size of this descriptor record

   * - 2
     - type
     - 1
     - 0x03
     - Type of the descriptor (Interface)

   * - 3
     - id
     - 1
     -
     - Module-unique Id for this interface

CPort Descriptor
^^^^^^^^^^^^^^^^

This descriptor describes a CPort implemented within the module. Each
CPort is associated with one of the module’s interfaces, and has an id
unique for that interface.  Every CPort defines the protocol used by
the AP to interact with the CPort. A special control CPort [#p]_
[#q]_shall be defined for every interface, and shall be defined to use
the “control” protocol. The details of these protocols are defined in
the section Function Class Protocols below.

**FIXME** "Function class protocols" is an invalid link

.. list-table::
   :header-rows: 1

   * - Offset
     - Field
     - Size
     - Value
     - Description

   * - 0
     - size
     - 2
     - 0x0007
     - Size of this descriptor record

   * - 2
     - type
     - 1
     - 0x04
     - Type of the descriptor (CPort)

   * - 3
     - interface
     - 1
     -
     - Interface Id this CPort is associated with

   * - 4
     - id
     - 2
     -
     - Id (destination address) of the CPort

   * - 6
     - protocol
     - 1
     -
     - Protocol used for this CPort

The *id* field is the CPort identifier used by other modules to direct
traffic to this CPort. The IDs for CPorts using the same interface
must be unique. Certain low-numbered CPort identifiers (such as the
control CPort) are reserved. Implementors shall assign CPorts
low-numbered id values, generally no higher than 31. (Higher-numbered
CPort ids impact on the total usable number of |unipro| devices and
typically should not be used.)

Protocol
""""""""

.. XXX cross-reference these with the below protocols.

   (It's probably worth allocating all of the protocols we ever plan
   on implementing once, adding protocol version operations for each
   of them, and numbering them with substitution definitions.)

.. list-table::
   :header-rows: 1

   * - Protocol
     - Value

   * - Control
     - 0x00

   * - AP [#r]_ [#s]_
     - 0x01

   * - GPIO
     - 0x02

   * - I2C
     - 0x03

   * - UART
     - 0x04

   * - HID
     - 0x05

   * - USB
     - 0x06

   * - SDIO
     - 0x07

   * - Battery
     - 0x08

   * - PWM
     - 0x09

   * - I2S
     - 0x0a

   * - SPI
     - 0x0b

   * - Display
     - 0x0c

   * - Camera
     - 0x0d

   * - Sensor
     - 0x0e

   * - LED
     - 0x0f

   * - Vibrator
     - 0x10

   * - (All other values reserved)
     - 0x11..0xfe

   * - Vendor Specific
     - 0xff

.. Footnotes
.. =========

.. rubric:: Footnotes

.. [#h] This is a pretty vague statement. Any idea how to make it
        sharper? Why not have major/minor versions for this as well, so
        m odule vendors can handle compatibility breaks vs. bugfixes
        the same way we do?

.. [#i] Given later Greybus changes (we version protocols
        independently), does the operating system even need to
        interpret this value at all? Does it make sense to instead
        specify that it's for the vendor's use, and is not given
        special interpretation by the operating system?
        +elder_alex@projectara.com

.. [#j] The purpose for this version field is to version the module *as
        a whole*.  In my mind, yes, it's an attribute fully under
        control of the vendor.  I could envision a class driver of some
        kind making use of this information, but to date we don't use
        it. Your questions highlight that we should clarify how we
        expect each of these fields are to be used.  If they don't
        serve a particular purpose we should just remove them.

.. [#k] So shouldn't we just remove this one, if we don't have a use
        for it yet?

.. [#p] This will be CPort 0 if possible.  If we can't reserve it for
        our exclusive use it will be CPort 1.

.. [#q] ...or whatever we can get.

.. [#r] I think there will be no "AP" protocol. This table is currently
        tentative.  To date, only GPIO, I2C, and PWM protocols are
        well-defined.

.. [#s] On the other hand, I believe there will be an "SVC" protocol
        that will implement certain requests between the AP and the SVC
        (such as setting routes, or the SVC notifying the AP about
        battery status and module events).



