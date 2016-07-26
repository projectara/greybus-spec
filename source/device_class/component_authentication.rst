.. _auth-protocol:

Component Authentication Protocol
---------------------------------

The Greybus Component Authentication Protocol may be used by the AP to
determine the authenticity of an Interface.

Two forms of authentication are currently defined:

* Ecosystem Authentication, which uses an Ecosystem Authentication
  Certificate (EAC) and a secret key derived from the Internal Master
  Secret (IMS) associated with an Interface.

* Identity Authentication, which uses an Identity Authentication
  Certificate (IAC) and a secret key derived from the IMS associated
  with an Interface.

Conceptually, the Operations in the Component Authentication Protocol
are:

.. c:function:: int cport_shutdown(u8 phase);

    See :ref:`greybus-protocol-cport-shutdown-operation`.

.. c:function:: int get_endpoint_uid(u8 endpoint_uid[8]);

    This Operation may be initiated only by the AP to obtain the
    endpoint unique ID of an Interface. The Response to this Operation
    contains the endpoint unique ID value.

.. c:function:: int get_ims_certificate(u32 cert_class, u32 cert_id, u8 *result_code, u8 *certificate);

    This Operation may be initiated only by the AP to obtain a
    certificate from an Interface. The Response to this Operation
    contains the certificate data.

.. c:function:: int authenticate(u8 auth_type, u8 endpoint_uid[8], u8 challenge[32], u8 *result_code, u8 auth_response[64], u8 *auth_response_sig);

    This Operation may be initiated only by the AP to present a
    challenge to an Interface. The Response to this Operation contains
    cryptographic response to the challenge and a signature for the
    cryptographic response.

Component Authentication Operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AP Module may use the Component Authentication Protocol to evaluate
the authenticity of an Interface. The Request and Response messages for
each Component Authentication Operation are defined below.

Table :num:`table-cap-operation-type` describes the Greybus Component
Authentication Operation Types and their values.

.. figtable::
    :nofig:
    :label: table-cap-operation-type
    :caption: Component Authentication Operation Types
    :spec: l l l

    ========================================  =============  =================
    Component Authentication Operation Type   Request Value  Response Value
    ========================================  =============  =================
    CPort Shutdown                            0x00           0x80
    Get Endpoint UID                          0x01           0x81
    Get IMS Certificate                       0x02           0x82
    Authenticate                              0x03           0x83
    (all other values reserved)               0x04..0x7e     0x84..0xfe
    Invalid                                   0x7f           0xff
    ========================================  =============  =================
..

.. _component-authentication-cport-shutdown:

Greybus Component Authentication CPort Shutdown Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Component Authentication CPort Shutdown Operation is the
:ref:`greybus-protocol-cport-shutdown-operation` for the Component
Authentication Protocol.

.. _cap-get-endpoint-uid:

Greybus Component Authentication Get Endpoint UID Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Component Authentication Get Endpoint UID Operation may be
used by the AP to obtain the Endpoint Unique ID (EPUID) associated with
an Interface.

The EPUID is a constant eight-byte value guaranteed to be unique across
all UniPro endpoints (e.g., Interfaces) in any system components
supporting the Greybus Component Authentication Protocol.  The EPUID
bytes are sent in little-endian format--least significant byte first.
The EPUID is derived from a globally unique value known as the IMS,
which shall be available to each Interface that supports this Protocol.

The EPUID serves as a key for determining the names of cryptographic
certificates used in this Protocol.

Greybus Component Authentication Get Endpoint UID Request
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Component Authentication Get Endpoint UID Request has no
payload.

Greybus Component Authentication Get Endpoint UID Response
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Component Authentication Get Endpoint UID Response contains
an eight-byte field, endpoint_uid.

.. figtable::
    :nofig:
    :label: table-cap-get-endpoint-uid-response
    :caption: Component Authentication Get Endpoint UID Response
    :spec: l l c c l

    =======  ==============  ===========  ==========      ===========================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ===========================
    0        endpoint_uid    8            Byte array      Endpoint Unique ID
    =======  ==============  ===========  ==========      ===========================
..

The endpoint_uid field in the Response payload shall contain the little
endian format Endpoint Unique ID value for the Interface.

Greybus Component Get IMS Certificate Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Component Authentication Get IMS Certificate Operation may
be used by the AP to retrieve one of the cryptographic certificates held
by an Interface for use in Component Authentication.

Greybus Component Authentication Get IMS Certificate Request
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Component Authentication Get IMS Certificate Request
contains a four-byte field, cert_class and a four-byte field, cert_id.
The cert_class field specifies which of the potentially multiple
certificates held by an Interface is selected for this Operation, and
shall be set to one of the valid values in Table
:num:`table-cap-cert-classes`. The cert_id is the ID of the certificate.
It is reserved for future use, and implementations adhering to this
version of the protocol shall set its value to zero.

.. figtable::
    :nofig:
    :label: table-cap-cert-classes
    :caption: Component Authentication Certificate Classes
    :spec: l l l

    ================= =================================================== ======================
    Certificate Class Description                                         Value
    ================= =================================================== ======================
    CERT_IMS_INVALID  Invalid                                             0x00000000
    CERT_IMS_EAPC     Ecosystem Authentication Certificate, Primary Key   0x00000001
    CERT_IMS_EASC     Ecosystem Authentication Certificate, Secondary Key 0x00000002
    CERT_IMS_EARC     Ecosystem Authentication Certificate, RSA Key       0x00000003
    CERT_IMS_IAPC     Identity Authentication Certificate, Primary Key    0x00000004
    CERT_IMS_IASC     Identity Authentication Certificate, Secondary Key  0x00000005
    CERT_IMS_IARC     Identity Authentication Certificate, RSA Key        0x00000006
    |_|               (All other values are reserved)                     0x00000007..0xffffffff
    ================= =================================================== ======================
..

The Greybus Component Authentication Get IMS Certificate Request is sent
by the AP to an Interface in order to obtain the data content of a
cryptographic certificate of appropriate class.

.. figtable::
    :nofig:
    :label: table-cap-get-ims-cert-request
    :caption: Component Authentication Get IMS Certificate Size Request
    :spec: l l c c l

    =======  ==============  ===========  ==========      ====================================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ====================================
    0        cert_class      4            Number          Class of the desired certificate
                                                          as present in the Table :num:`table-cap-cert-classes`
    4        cert_id         4            Number          ID of the desired certificate
    =======  ==============  ===========  ==========      ====================================
..

Greybus Component Authentication Get IMS Certificate Response
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Component Authentication Get IMS Certificate Response
contains a one-byte field, result_code, and an arbitrary-size data
block, cert_data, that is the requested certificate. The size of the
certificate shall not exceed 1600 bytes.

.. figtable::
    :nofig:
    :label: table-cap-get-ims-cert-response
    :caption: Component Authentication Get IMS Certificate Size Response
    :spec: l l c c l

    =======  ==============  =============  ==========      ===============================
    Offset   Field           Size           Value           Description
    =======  ==============  =============  ==========      ===============================
    0        result_code     1              Number          Result code
    1        cert_data       variable data  Byte array      Content of the desired certificate
    =======  ==============  =============  ==========      ===============================
..

The result_code field shall identify one of the conditions defined in
Table :num:`table-cap-get-ims-cert-results`.

* If the result_code is not CERT_FOUND, the value of cert_data is
  undefined and shall be ignored.
* If the result_code is CERT_FOUND, the cert_data field shall contain
  the certificate. AP shall determine the size of the certificate by
  the size of the Response payload minus the size of the all other
  fields in the Response payload.

.. figtable::
    :nofig:
    :label: table-cap-get-ims-cert-results
    :caption: Component Authentication Certificate Result Codes
    :spec: l l l

    ================== =============================================== ==========
    Result Code        Description                                     Value
    ================== =============================================== ==========
    CERT_FOUND         Certificate was located as requested            0x00
    CERT_CLASS_INVALID The specified cert_class is not valid           0x01
    CERT_CORRUPT       The storage for certificates is corrupted       0x02
    CERT_NOT_FOUND     No certificate of the specified class was found 0x03
    |_|                (All other values are reserved)                 0x04..0xff
    ================== =============================================== ==========
..

Greybus Component Authentication Authenticate Operation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Greybus Component Authentication Authenticate Operation may be used
by the AP to send a Component Authentication challenge to an Interface
and retrieve a Component Authentication response from it.

To authenticate an Interface, the AP shall prepare a Greybus Component
Authentication Authenticate Request and send it to the Interface. The
receiving Interface shall compute a auth_response, perform a digital
signature calculation covering the auth_response, and send both
auth_response and signature back to the AP in a Greybus Component
Authentication Authenticate Response.

To complete an authentication decision, the AP shall validate the
digital signature in the Response using a validation key obtained from
an appropriate certificate.

The receiving Interface shall complete its digital signature calculation
and return a Response to the AP within an implementation-defined time
interval. If the AP does not receive a Response within that time, the AP
shall recognize a timeout. The AP may treat timeout as an error, or may
repeat the Authenticate Operation.

Greybus Component Authentication Authenticate Request
"""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Component Authentication Authenticate Request contains a
four-byte field, auth_type, an eight-byte field, endpoint_uid, and a
32-byte field, challenge. The auth_type field shall be set to one of
the valid values in Table :num:`table-cap-auth-types`. The endpoint_uid
field shall be set to he endpoint_uid of the Interface, which shall have
been previously determined by a :ref:`cap-get-endpoint-uid`. For
auth_type of AUTH_IMS_PRI, AUTH_IMS_SEC, and AUTH_IMS_RSA, the challenge
field shall be set to a 32-byte cryptographically random challenge value.

.. figtable::
    :nofig:
    :label: table-cap-authenticate-request
    :caption: Component Authentication Authenticate Request
    :spec: l l c c l

    =======  ==============  ===========  ==========      ======================================
    Offset   Field           Size         Value           Description
    =======  ==============  ===========  ==========      ======================================
    0        auth_type       4            Number          Type of authentication for response
    4        endpoint_uid    8            Data            Endpoint Unique ID of target Interface
    12       challenge       32           Data            Cryptographic challenge value
    =======  ==============  ===========  ==========      ======================================
..

Several types of authentication are supported, as defined in Table
:num:`table-cap-auth-types`.

.. figtable::
    :nofig:
    :label: table-cap-auth-types
    :caption: Component Authentication Protocol Authentication Types
    :spec: l l l

    ============ ======================================================================== ======================
    Type         Description                                                              Value
    ============ ======================================================================== ======================
    AUTH_INVALID Invalid                                                                  0x00000000
    AUTH_IMS_PRI Authenticate using the IMS-derived Endpoint Primary Signing Key (EPSK)   0x00000001
    AUTH_IMS_SEC Authenticate using the IMS-derived Endpoint Secondary Signing Key (ESSK) 0x00000002
    AUTH_IMS_RSA Authenticate using the IMS-derived Endpoint RSA Private Key (ERRK)       0x00000003
    |_|          (All other values are reserved)                                          0x00000004..0xffffffff
    ============ ======================================================================== ======================
..

The authentication type in the Request determines the cryptographic
algorithm and which class(es) of certificates may be used to validate
the Response, as described in table :num:`table-cap-auth-cert-classes`.

.. figtable::
    :nofig:
    :label: table-cap-auth-cert-classes
    :caption: Component Authentication Types and Certificates
    :spec: l l l

    ============== ==================== ======================================
    Auth. Type     Algorithm            Certificate Classes for Authentication
    ============== ==================== ======================================
    AUTH_IMS_PRI   ed448 [ED448]_       CERT_IMS_EAPC, CERT_IMS_IASC
    AUTH_IMS_SEC   ed25519 [ED25519]_   CERT_IMS_EASC, CERT_IMS_IASC
    AUTH_IMS_RSA   RSA 2048 [RSA]_      CERT_IMS_EARC, CERT_IMS_IARC
    ============== ==================== ======================================
..

Greybus Component Authentication Authenticate Response
""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Greybus Component Authentication Authenticate Response contains a
one-byte field, result_code, a 64-byte field, auth_response, and an
arbitrary-size data block, auth_response_sig. The size of
auth_response_sig shall not exceed 320 bytes.

.. figtable::
    :nofig:
    :label: table-cap-authenticate-response
    :caption: Component Authentication Authenticate Response
    :spec: l l c c l

    =======  =================  =============  ==========  ===============================
    Offset   Field              Size           Value       Description
    =======  =================  =============  ==========  ===============================
    0        result_code        1              Number      Result code
    1        auth_response      64             Byte array  auth_response from module
    65       auth_response_sig  variable data  Byte array  Digital signature of auth_response
    =======  =================  =============  ==========  ===============================
..

The result_code field shall identify one of the conditions defined in
Table :num:`table-cap-authenticate-results`. If the result_code is not
CR_SUCCESS, the values of auth_response and auth_response_sig
are undefined and shall be ignored.

.. figtable::
    :nofig:
    :label: table-cap-authenticate-results
    :caption: Component Authentication Challenge/Response Result Codes
    :spec: l l l

    =========== ============================================================= ==========
    Result      Description                                                   Value
    =========== ============================================================= ==========
    CR_SUCCESS  Authentication response and signature generated successfully  0x00
    CR_BAD_TYPE The specified auth_type is invalid                            0x01
    CR_WRONG_EP The supplied endpoint_uid does not match the target Interface 0x02
    CR_NO_KEY   The Interface cannot access the required signing key          0x03
    CR_SIG_FAIL The requested signature could not be calculated               0x04
    |_|         (All other values are reserved)                               0x05..0xff
    =========== ============================================================= ==========
..

The remainder of this section describes processing for auth_type values
of AUTH_IMS_PRI, AUTH_IMS_SEC, and AUTH_IMS_RSA.

Upon receiving a Component Authentication Authenticate Request, the
Interface shall perform several validation checks (the order of which is
unspecified) and calculate a signature. The Interface shall check that:

* The auth_type specifies an authentication type that it is prepared to
  perform, and shall return a Response with a result_code of CR_BAD_TYPE
  if not.
* Its own endpoint unique ID matches the endpoint_uid field in the
  Request, and shall return a Response with a result_code of CR_WRONG_EP
  if not.
* It has access to the signing key needed to perform the signature
  calculation, and shall return a Response with a result_code of
  CR_NO_KEY if not.

Following the validation steps, the Interface shall perform a digital
signature calculation using the designated key. If an error occurs
performing this calculation, the Interface shall return a Response with
a result_code of CR_SIG_FAIL.

The Interface shall calculate the digital signature by preparing a
64-byte response buffer in which the first 32 bytes are a copy of the
first 32 bytes of the challenge parameter in the Request, the next 24
bytes are a cryptographically random nonce value calculated by the
Interface, the next 8 bytes are the endpoint_uid of the Interface. The
Interface shall calculate the digital signature of the 64-byte response
buffer using the SHA-256 hash algorithm [FIPS180]_ and the digital
signature algorithm identified in Table
:num:`table-cap-auth-cert-classes`.

Having calculated the digital signature, the Interface shall send a
Response in which the result_code is CR_SUCCESS, the auth_response is a
copy of the response buffer, and the auth_response_sig contains digital
signature output.

Upon receipt of a Greybus Component Authentication Authenticate
Response, if the result_code is not CR_SUCCESS, the AP shall treat the
authentication Operation as having failed. If result_code is CR_SUCCESS,
the AP shall perform several validation checks (the order of which is
unspecified) The AP shall check that:

* The first 32 bytes of the auth_response field are equal to the the
  challenge it sent.
* Bytes 56-63 of the auth_response field are equal to the endpoint_uid
  of the request.
* The size of auth_response_sig, determined by the size of the Response
  payload minus the size of the all other fields in the Response
  payload, is non-zero and no greater than 320 bytes.

Having performed the validation checks, the AP shall then locate a
certificate containing the validation key for the signature (for
example, one obtained from a Greybus Component Authentication Get IMS
Certificate Operation, which may occur at any time before the validation
calculation, either before or after the Greybus Component Authentication
Authenticate Operation). Appropriate certificate(s) may also have been
obtained by out of band mechanisms, or found in local storage managed by
the AP, depending on system architecture. If the certificate cannot be
located or obtained, then the validation fails.

The AP shall then validate that the common name (CN) in the certificate
appropriately incorporates the hexadecimal representation of the
endpoint_uid value for the Interface and  that it otherwise matches the
certificate naming conventions (for example, to perform identity
authentication, the certificate must also incorporate the hexadecimal
representations of the Ara VID and Ara PID attributes of the Interface
in an appropriate format). If the certificate name does not meet
requirements, then the validation fails.

Finally, the AP shall use the public key from that certificate to
attempt to validate that the signature in the signature field is a valid
signature of the auth_response field.

If any errors occur in the validation checks, or the signature
validation calculation fails, the authentication has failed; otherwise,
it has succeeded.

Note that a single Response can be validated with respect to multiple
different certificates, depending on goal of the authentication (e.g.,
ecosystem authentication, identity authentication). The different
certificates will contain the same (public) validation key but will be
distinguished by the Common Name in the certificate.

