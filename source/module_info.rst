Interface Information
=====================

.. raw:: latex

  \epigraph{Imitation is the sincerest form of flattery.}
  {--- Charles Caleb Colton}

.. raw:: html

  <blockquote>
  <div><div class="line-block">
  <div class="line">Imitation is the sincerest form of flattery.</div>
  <div class="line">— Charles Caleb Colton</div>
  </div></div>
  </blockquote>

A Greybus Interface shall provide self-descriptive information in
order to establish communications with other Interfaces on the
|unipro| network.  This information is provided via a Manifest, which
describes components present within the Interface that are accessible
via |unipro|.  The Manifest is a data structure, which includes a set
of Descriptors, that presents a functional description of the
Interface.  Together, these Descriptors define the Interface's
capabilities and means of communication via |unipro| from the
perspective of the application layer and above.

.. _manifest-data-requirements:

Data Requirements
-----------------

All data found in Manifest structures defined below shall adhere to
the following general requirements:

* All numeric values shall be unsigned unless explicitly stated otherwise.
* All descriptor field values shall have little endian format.
* Numeric values prefixed with 0x are hexadecimal; they are decimal otherwise.
* All offset and size values are expressed in units of bytes unless
  explicitly stated otherwise.
* All string descriptors shall consist of UTF-8 encoded characters.
* All headers and descriptor data within a Manifest shall be
  implicitly followed by pad bytes as necessary to bring the
  structure's total size to a multiple of 4 bytes.
* Accordingly, the low-order two bits of all header *size* field values shall
  be 00.
* Any reserved or unused space (including implicit padding) in a
  header or descriptor shall be ignored when read, and zero-filled
  when written.
* All major structures (like the Manifest header) and interface
  Protocols (like that between the AP Module and SVC) shall be
  versioned, to allow future extensions (or fixes) to be added and
  recognized.

.. _manifest-description:

Manifest
--------

The Manifest is a contiguous block of data that includes a Manifest
Header and a set of Descriptors.  When read, a Manifest is transferred
in its entirety.  This allows the Interface to be described to the AP
Module all at once, alleviating the need for multiple communication
messages during the enumeration phase of the Interface.

Manifest Header
^^^^^^^^^^^^^^^

The Manifest Header is present at the beginning of the Manifest
and defines the size of the manifest and the version of the Greybus Protocol
with which the Manifest complies.

.. figtable::
    :nofig:
    :label: table-manifest-header
    :caption: Manifest Header
    :alt: Manifest Header
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        size            2       Number          Size of the entire manifest
    2        version_major   1       |gb-major|      Greybus major version
    3        version_minor   1       |gb-minor|      Greybus minor version
    =======  ==============  ======  ==========      ===========================

The values of version_major and version_minor values shall refer to
the highest version of this document (currently |gb-major|.\
|gb-minor|) with which the format complies.

Minor versions increment with modifications to the Greybus
definition, in such a way that any Protocol handler that supports
the version_major can correctly interpret a Manifest in the
modified format.
A changed version_major indicates major differences in the
Manifest format. It is not expected that a parser can properly
interpret a Manifest whose version_major is greater than
the version_major supported by the parser.

All Manifest parsers shall be able to interpret manifests formatted
using older (lower numbered) Greybus versions, such that they still
work properly (i.e. backwards compatibility is required).

The layout for the Manifest Header can be seen in Table
:num:`table-manifest-header`.

Descriptors
^^^^^^^^^^^

.. figtable::
    :nofig:
    :label: table-descriptor-header
    :caption: Descriptor Header
    :alt: Descriptor Header
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        size            2       Number          Size of this descriptor
    2        type            1       Number          :ref:`descriptor-type`
    3        (pad)           1       0               Reserved (pad to 4 bytes)
    =======  ==============  ======  ==========      ===========================

Following the Manifest Header is one or more Descriptors.  Each
Descriptor is composed of a Descriptor Header followed by Descriptor
Data. The format of the Descriptor Header can be seen in Table
:num:`table-descriptor-header`.

.. _descriptor-type:

Descriptor type
"""""""""""""""

The format of the Descriptor Data depends on the type of the descriptor,
which is specified in the header.  The known descriptor types and their
values are described in Table :num:`table-descriptor-type`.

.. figtable::
    :nofig:
    :label: table-descriptor-type
    :caption: Descriptor Type
    :alt: Descriptor Type
    :spec: l l

    ============================    ==========
    Descriptor Type                 Value
    ============================    ==========
    Invalid                         0x00
    Interface                       0x01
    String                          0x02
    Bundle                          0x03
    CPort                           0x04
    (All other values reserved)     0x05..0xff
    ============================    ==========

..

Interface Descriptor
^^^^^^^^^^^^^^^^^^^^

Interface descriptor describes an access point for a Module to the
|unipro| network. Each interface represents a single physical port
through which |unipro| packets are transferred. Every Module shall have
at least one interface. Each interface has a unique ID within the Endo.

This descriptor describes Interface-specific values as set by the vendor who
created the Interface. Every Manifest shall have exactly one Interface
descriptor as described in Table :num:`table-interface-descriptor`.

.. figtable::
    :nofig:
    :label: table-interface-descriptor
    :caption: Interface Descriptor
    :alt: Interface Descriptor
    :spec: l l c c l

    =======  =================  ======  ==========  ==================================
    Offset   Field              Size    Value       Description
    =======  =================  ======  ==========  ==================================
    0        size               2       0x0008      Size of this descriptor
    2        type               1       0x01        Type of the descriptor (Interface)
    3        features           1       Bit Mask    :ref:`interface-feature-bits`
    4        vendor_string_id   1       ID          String ID for the vendor name
    5        product_string_id  1       ID          String ID for the product name
    6        (pad)              2       0           Reserved (pad to 4 byte boundlary)
    =======  =================  ======  ==========  ==================================

*vendor_string_id* is a reference to a specific string descriptor ID
that provides a description of the vendor who created the Module.  If
there is no string present for this value in the Manifest, this
value shall be 0x00.  See the :ref:`string-descriptor` section below for
more details.

*product_string_id* is a reference to a specific string descriptor ID
that provides a description of the product.  If there is no string
present for this value in the Manifest, this value shall be 0x00.
See the :ref:`string-descriptor` section below for more details.

.. _interface-feature-bits:

Greybus Interface Descriptor Feature Bits
"""""""""""""""""""""""""""""""""""""""""

Table :num:`table-interface-feature-bits` defines the bits which specify the
set of features supported by an Interface.

.. figtable::
    :nofig:
    :label: table-interface-feature-bits
    :caption: Interface Descriptor Feature Bits
    :spec: l l l

    ====================== ================================================== ==========
    Symbol                 Descirption                                        Value
    ====================== ================================================== ==========
    GB_INTERFACE_TIME_SYNC The Interface supports Greybus TimeSync Operations 0x01
    |_|                    (All other values are reserved)                    0x02..0x80
    ====================== ================================================== ==========

.. _string-descriptor:

String Descriptor
^^^^^^^^^^^^^^^^^

A string descriptor provides a human-readable string for a
specific value, such as a vendor or product string. Strings consist of UTF-8
characters and are not required to be zero terminated. A string descriptor
shall be referenced only once within the Manifest, e.g. only one product (or
vendor) string field may refer to string ID 2.  The format of the string
descriptor can be found in Table :num:`table-string-descriptor`.

.. figtable::
    :nofig:
    :label: table-string-descriptor
    :caption: String Descriptor
    :alt: String Descriptor
    :spec: l l c c l

    ============  ==============  ========  ==========  ===========================
    Offset        Field           Size      Value       Description
    ============  ==============  ========  ==========  ===========================
    0             size            2         Number      Size of this descriptor
    2             type            1         0x02        Type of the descriptor (String)
    3             (pad)           1         0           Reserved (pad to 4 byte boundary)
    4             length          1         Number      Length of the string in bytes
    5             id              1         ID          String ID for this descriptor
    6             string          *length*  UTF-8       Characters for the string
    6+\ *length*  (pad)           0-3       0           Reserved (pad to 4 byte boundary)
    ============  ==============  ========  ==========  ===========================

The *id* field shall not be 0x00, as that is an invalid String ID value.

The *length* field excludes any trailing padding bytes in the descriptor.

Bundle Descriptor
^^^^^^^^^^^^^^^^^

A Bundle represents a device in Greybus.  Bundles communicate with each other on
the network via one or more |unipro| CPorts.

.. figtable::
    :nofig:
    :label: table-bundle-descriptor
    :caption: Bundle Descriptor
    :alt: Bundle Descriptor
    :spec: l l c c l

    ============  ==============  ========  ==========  ===========================
    Offset        Field           Size      Value       Description
    ============  ==============  ========  ==========  ===========================
    0             size            2         0x0008      Size of this descriptor
    2             type            1         0x03        Type of the descriptor (Bundle)
    3             (pad)           1         0           Reserved (pad to 4 byte boundary)
    4             id              1         ID          Interface-unique ID for this Bundle
    5             class           1         Number      See Table :num:`table-bundle-class`
    6             (pad)           2         0           Reserved (pad to 8 bytes)
    ============  ==============  ========  ==========  ===========================

The *id* field uniquely identifies a Bundle within the Interface.  The first
Bundle shall have ID 0, the second (if present) shall have value 1, and so on.
The purpose of these Ids is to allow CPort descriptors to define which Bundle
they are associated with.  The Bundle descriptor is defined in Table
:num:`table-bundle-descriptor`.

The *class* field defines the class of the bundle. This shall be used by
the AP to find what to expect from the bundle and how to configure/use
it. Class types are defined in Table :num:`table-bundle-class`.

.. figtable::
    :nofig:
    :label: table-bundle-class
    :caption: Bundle Class Types
    :alt: Bundle Class Types
    :spec: l c

    ============================    ==========
    Class type                      Value
    ============================    ==========
    Control                         0x00
    AP                              0x01
    Reserved                        0x02
    Reserved                        0x03
    Reserved                        0x04
    HID                             0x05
    Reserved                        0x06
    Reserved                        0x07
    Power Supply                    0x08
    Reserved                        0x09
    Bridged PHY                     0x0a
    SPI                             0x0b
    Display                         0x0c
    Camera                          0x0d
    Sensor                          0x0e
    Lights                          0x0f
    Vibrator                        0x10
    Loopback                        0x11
    Audio                           0x12
    Reserved                        0x13
    SVC                             0x14
    Firmware                        0x15
    (All other values reserved)     0x16..0xfd
    Raw                             0xfe
    Vendor Specific                 0xff
    ============================    ==========

..

CPort Descriptor
^^^^^^^^^^^^^^^^

A CPort descriptor describes a CPort implemented within the Module. Each
CPort is associated with one of the Interface's Bundle, and has an ID
unique for that Interface.  Every CPort defines the Protocol used by
the AP Module to interact with the CPort. A special control CPort shall be
defined for every Interface, and shall be defined to use the *Control
Protocol*. The Cport Descriptor is defined in Table
:num:`table-cport-descriptor`. The details of these Protocols are
defined in the sections :ref:`device-class-protocols` and
:ref:`bridged-phy-protocols` below.

.. figtable::
    :nofig:
    :label: table-cport-descriptor
    :caption: CPort Descriptor
    :alt: CPort Descriptor
    :spec: l l c c l

    ========  ==============  ======  ==========  ===========================
    Offset    Field           Size    Value       Description
    ========  ==============  ======  ==========  ===========================
    0         size            2       0x0008      Size of this descriptor
    2         type            1       0x04        Type of the descriptor (CPort)
    3         (pad)           1       0           Reserved (pad to 4 byte boundary)
    4         id              2       ID          ID (destination address) of the CPort
    6         bundle          1       ID          Bundle ID this CPort is associated with
    7         protocol        1       Number      See Table :num:`table-cport-protocol`
    ========  ==============  ======  ==========  ===========================

.. todo::
    The details of how the CPort identifier is determined will be
    specified in a later version of this document.

The *id* field is the CPort identifier used by other Modules to direct
traffic to this CPort. The IDs for CPorts using the same Interface
shall be unique. Certain low-numbered CPort identifiers (such as the
control CPort) are reserved. Implementors shall assign CPorts
low-numbered ID values, generally no higher than 31. (Higher-numbered
CPort ids impact on the total usable number of |unipro| devices and
typically should not be used.)

.. XXX cross-reference these with the below protocols.

   (It's probably worth allocating all of the protocols we ever plan
   on implementing once, adding protocol version operations for each
   of them, and numbering them with substitution definitions.)

.. figtable::
    :nofig:
    :label: table-cport-protocol
    :caption: CPort Protocol Numbers
    :alt: CPort Protocol Numbers
    :spec: l c

    ============================    ==========
    Protocol                        Value
    ============================    ==========
    Control                         0x00
    AP                              0x01
    GPIO                            0x02
    I2C                             0x03
    UART                            0x04
    HID                             0x05
    USB                             0x06
    SDIO                            0x07
    Power Supply                    0x08
    PWM                             0x09
    I2S Management                  0x0a
    SPI                             0x0b
    Display                         0x0c
    Camera Management               0x0d
    Sensor                          0x0e
    Lights                          0x0f
    Vibrator                        0x10
    Loopback                        0x11
    Audio Managemnt                 0x12
    Audio Data                      0x13
    SVC                             0x14
    Firmware                        0x15
    Camera Data                     0x16
    (All other values reserved)     0x17..0xfd
    Raw                             0xfe
    Vendor Specific                 0xff
    ============================    ==========

