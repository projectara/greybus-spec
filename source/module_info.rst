.. include:: defines.rst

Module Information
==================

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

A Greybus module shall provide self-descriptive information in order to
establish communications with other modules on the |unipro| network.
This information is provided via a Manifest, which describes
components present within the module that are accessible via |unipro|.
The Manifest is a data structure, which includes a set of
Descriptors, that presents a functional description of the module.
Together, these Descriptors define the module's capabilities and means of
communication via |unipro| from the perspective of the application layer
and above.

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
  protocols (like that between the AP and SVC) shall be versioned, to
  allow future extensions (or fixes) to be added and recognized.

Manifest
--------

The Manifest is a contiguous block of data that includes a
Manifest Header and a set of Descriptors.  When read, a
Manifest is transferred in its entirety.  This allows the module to be
described to the AP all at once, alleviating the need for multiple
communication messages during the enumeration phase of the module.

Manifest Header
^^^^^^^^^^^^^^^

The Manifest Header is present at the beginning of the Manifest
and defines the size of the manifest and the version of the Greybus protocol
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
definition, in such a way that any protocol handler that supports
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

Following the Manifest Header is one or more Descriptors.  Each
Descriptor is composed of a Descriptor Header followed by Descriptor
Data. The format of the Descriptor Header can be seen in Table
:num:`table-descriptor-header`.

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
    Module                          0x01
    String                          0x02
    Interface                       0x03
    CPort                           0x04
    Class                           0x05
    (All other values reserved)     0x06..0xff
    ============================    ==========

Module Descriptor
^^^^^^^^^^^^^^^^^

This descriptor describes module-specific values as set by the vendor
who created the module. Every Manifest shall have exactly one
module descriptor as described in Table :num:`table-module-descriptor`.

.. figtable::
    :nofig:
    :label: table-module-descriptor
    :caption: Module Descriptor
    :alt: Module Descriptor
    :spec: l l c c l

    =======  =================  ======  ==========  ==============================
    Offset   Field              Size    Value       Description
    =======  =================  ======  ==========  ==============================
    0        size               2       0x0014      Size of this descriptor
    2        type               1       0x01        Type of the descriptor (Module)
    3        (pad)              1       0           Reserved (pad to 4 byte boundary)
    4        vendor             2       ID          Module vendor id
    6        product            2       ID          Module product id
    8        vendor_string_id   1       ID          String id for the vendor name
    9        product_string_id  1       ID          String id for the product name
    10       unique_id          8       ID          Unique ID of the module
    18       (pad)              2       0           Reserved (pad to 20 bytes)
    =======  =================  ======  ==========  ==============================

The *vendor* field is a value assigned by Google.  All vendors should
apply for a Project Ara vendor ID in order to properly mark their
modules. Contact ara-dev@google.com for more information regarding the
vendor ID application process.

The *product* field is controlled by the vendor, and should be unique
per type of module that is created.

*vendor_string_id* is a reference to a specific string descriptor id
that provides a description of the vendor who created the module.  If
there is no string present for this value in the Manifest, this
value shall be 0x00.  See the :ref:`string-descriptor` section below for
more details.

*product_string_id* is a reference to a specific string descriptor id
that provides a description of the product.  If there is no string
present for this value in the Manifest, this value shall be 0x00.
See the :ref:`string-descriptor` section below for more details.

The *unique_id* field is an 8 byte Unique ID that is written into each
Greybus compliant chip during manufacturing. Google manages the Unique
IDs, providing each manufacturer with the means to generate compliant
Unique IDs for their products. In a module that contains multiple
interfaces, there is more than one hardware Unique ID
available. It is the responsibility of the module designer to
designate one primary interface and expose that primary Unique ID in
this field.

.. _string-descriptor:

String Descriptor
^^^^^^^^^^^^^^^^^

A string descriptor provides a human-readable string for a
specific value, such as a vendor or product string.  Any string that is
not an even multiple of 4 bytes in length shall be padded out to a
4-byte boundary with 0x00 values.  Strings consist of UTF-8 characters
and are not required to be zero terminated. A string descriptor shall
be referenced only once within the Manifest, e.g. only one product (or
vendor) string field may refer to string id 2.  The format of the string
descriptor can be found in Table :num:`table-string-descriptor`.

.. figtable::
    :nofig:
    :label: table-string-descriptor
    :caption: String Descriptor
    :alt: String Descriptor
    :spec: l l c c l

    ========  ==============  ========  ==========  ===========================
    Offset    Field           Size      Value       Description
    ========  ==============  ========  ==========  ===========================
    0         size            2         Number      Size of this descriptor
    2         type            1         0x02        Type of the descriptor (String)
    3         (pad)           1         0           Reserved (pad to 4 byte boundary)
    4         length          1         Number      Length of the string in bytes
    5         id              1         ID          String id for this descriptor
    6         string          length    UTF-8       Characters for the string
    6+length  (pad)           0-3       0           Reserved (pad to 4 byte boundary)
    ========  ==============  ========  ==========  ===========================

The *id* field shall not be 0x00, as that is an invalid String ID value.

The *length* field excludes any trailing padding bytes in the descriptor.

Interface Descriptor
^^^^^^^^^^^^^^^^^^^^

An interface descriptor describes an access point for a module to the
|unipro| network. Each interface represents a single physical port
through which |unipro| packets are transferred. Every module shall have
at least one interface. Each interface has an id whose value is unique
within the module.  The first interface shall have id 0, the second
(if present) shall have value 1, and so on. The purpose of these Ids
is to allow CPort descriptors to define which interface they are
associated with.  The interface descriptor is defined in Table
:num:`table-interface-descriptor`.

.. figtable::
    :nofig:
    :label: table-interface-descriptor
    :caption: Interface Descriptor
    :alt: Interface Descriptor
    :spec: l l c c l

    =======  ==============  ======  ==========      ===========================
    Offset   Field           Size    Value           Description
    =======  ==============  ======  ==========      ===========================
    0        size            2       0x0004          Size of this descriptor
    2        type            1       0x03            Type of the descriptor (Interface)
    3        (pad)           1       0               Reserved (pad to 4 byte boundary)
    4        id              1       ID              Module-unique ID for this interface
    5        (pad)           3       0               Reserved (pad to 8 bytes)
    =======  ==============  ======  ==========      ===========================

CPort Descriptor
^^^^^^^^^^^^^^^^

This descriptor describes a CPort implemented within the module. Each
CPort is associated with one of the module's interfaces, and has an id
unique for that interface.  Every CPort defines the protocol used by
the AP to interact with the CPort. A special control CPort shall be
defined for every interface, and shall be defined to use the *Control
Protocol*. The Cport Descriptor is defined in Table
:num:`table-cport-descriptor`. The details of these protocols are
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
    4         interface       1       ID          Interface ID this CPort is associated with
    5         id              2       ID          Id (destination address) of the CPort
    7         protocol        1       Number      protocol is defined in Table :num:`table-cport-protocol`
    ========  ==============  ======  ==========  ===========================

.. todo::
    The details of how the CPort identifier is determined will be
    specified in a later version of this document.

The *id* field is the CPort identifier used by other modules to direct
traffic to this CPort. The IDs for CPorts using the same interface
shall be unique. Certain low-numbered CPort identifiers (such as the
control CPort) are reserved. Implementors shall assign CPorts
low-numbered id values, generally no higher than 31. (Higher-numbered
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
    Battery                         0x08
    PWM                             0x09
    I2S                             0x0a
    SPI                             0x0b
    Display                         0x0c
    Camera                          0x0d
    Sensor                          0x0e
    LED                             0x0f
    Vibrator                        0x10
    (All other values reserved)     0x11..0xfe
    Vendor Specific                 0xff
    ============================    ==========

