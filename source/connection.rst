.. include:: defines.rst

Connection Protocols
====================

The following sections define the request and response message formats
for all operations for specific connection protocols. Requests are
most often (but not always) initiated by the AP. Each request has a
unique identifier, supplied by the requestor, and each response will
include the identifier of the request with which it is associated.
This allows operations to complete asynchronously, so multiple
operations can be “in flight” between the AP and a |unipro|-attached
adapter at once.

Each response begins with a status byte, which communicates whether
any error occurred in delivering or processing a requested operation.
If the operation completed successfully the status value is 0.
Otherwise the reason it was not successful will be conveyed by one of
the positive values defined in the following table.

A protocol can define its own status values if needed [#ay]_ [#az]_
[#ba]_ [#bb]_ [#bc]_; every status byte with a MSB set to one beside
0xff will be considered as a protocol status value.

.. list-table::
   :header-rows: 1

   * - Status
     - Value
     - Meaning
   * - Success
     - 0x00
     - Operation completed successfully
   * - Invalid
     - 0x01
     - Invalid argument supplied
   * - No memory
     - 0x02
     - Memory exhaustion prevented completion
   * - Busy
     - 0x03
     - Device or needed resource was in use
   * - Retry
     - 0x04
     - Request should be retried
   * - Reserved
     - 0x05 to 0x7f
     - Reserved for future use
   * -
     - 0x80 to 0xfe
     - Status defined by the protocol (see protocol definitions in
       following sections)
   * - Bad
     - 0xff
     - Initial value; never set by response

All protocols defined herein are subject to the
:ref:`general-requirements` listed above.

Protocol Versions
-----------------

Every protocol has a version, which comprises two one-byte values,
major and minor. A protocol definition can evolve to add new
capabilities, and as it does so, its version changes. If existing (or
old) protocol handling code which complies with this specification can
function properly with the new feature in place, only the minor
version of the protocol will change. Any time a protocol changes in a
way that requires the handling code be updated to function properly,
the protocol’s major version will change.

Two modules may implement different versions of a protocol, and as a
result they shall negotiate a common version of the protocol to
use. This is done by each side exchanging information about the
version of the protocol it supports at the time an initial handshake
between module interfaces is performed (for the control protocol), or
when a connection between CPorts is established (for all other
protocols).  The version of a particular protocol advertised by a
module is the same as the version of the document that defines the
protocol (so for protocols defined herein, the version is |gb-major|.\
|gb-minor|). [#bd]_ [#be]_

To agree on a protocol, an operation request supplies the (greatest)
major and minor version of the protocol supported by the source of a
request. The request destination compares that version with the
(greatest) version of the protocol it supports.  If the destination
supports a protocol version with major number equal to that supplied
by the source, and a minor number greater than or equal to that
supplied by the source, it shall communicate using the protocol
version equal to that supplied by the source. Otherwise, it decides
that its own version of the protocol will be the one to be used [#bf]_
[#bg]_. In either case, the chosen version is sent back in the
response, and the source interface will honor that decision and use
the selected version of the protocol. As a consequence of this,
protocol handlers must be capable of handling all prior versions of
the protocol.


.. Footnotes
.. =========

.. rubric:: Footnotes

.. [#ay] Is it worth adding symbolic constants for these (e.g. reuse
         the equivalent errno defines)? So Invalid=EINVAL, etc.

         CC: +elder_alex@projectara.com

.. [#az] Marked as resolved

.. [#ba] Re-opened

.. [#bb] Whoops.

.. [#bc] There are some symbolic constants we've been using in the
         code, and I think it would be a good idea to duplicate them here.

         As far as matching existing symbols like EINVAL, etc., I don't
         like that idea.  If our meaning exactly matches the POSIX
         EINVAL meaning, then that would be fine, but I wouldn't want
         to assume that.  I think we need to define our own name space
         with our own precise meaning attached to each symbol.

.. [#bd] I believe this is no longer correct, since we allow protocols
         to change versions independently from one another.

         Is that correct? If so, I will update the text.

         CC +elder_alex@projectara.com

.. [#be] It is technically correct at the moment.  If these sections
         split into separate (and separately-versioned) documents, then
         it would be correct for those as well.

         It doesn't matter to me.  We could state what version is
         documented for each protocol.

.. [#bf] This is kind of vague.

         Since the backwards compatibility requirement implies that
         protocol versions form a total order (X.Y is less than X.(Y+n)
         and X.Y is less than (X+n).Z for nonnegative integers X,Y,Z,
         and positive integers n), perhaps we can introduce formal
         language that more clearly defines the "greater" and "greater
         than or equal to" relations between protocol versions, and
         rely on that with more precision here?

.. [#bg] That would be great.

         I found it very cumbersome to try to explain this, and in the
         end it is fairly simple logic.  I would love to have it
         improved but at the moment won't try myself.


         Similarly we should probably explain that "X.Y" is a notation
         we use for major version X, minor version Y (if, in fact,
         that's what we're doing...).


