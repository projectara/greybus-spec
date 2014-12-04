.. ----------------------------------------------------------------------
.. Notes for Project Ara Internal Team Use

.. Go look at README FIRST before doing anything else:
   https://docs.google.com/a/projectara.com/document/d/1-g9uymGyxUrVKOfuJrYCMkl2kqoMvu-GGvqIw3extPE/edit

.. Before reading this document, try to get a basic working knowledge
   of the MIPI UniPro v1.6 specification:
   https://docs.google.com/a/projectara.com/file/d/0BxTh4XIogG2qbm1PaEo5M1ZES1U/edit>`_.

   At a bare minimum, read chapter 4 for an architecture overview.
.. ----------------------------------------------------------------------

.. highlight:: none

.. include:: defines.rst

.. Headers and footers

.. footer::

   Google Confidential/Restricted. ###Page###/###Total###

.. header::

   Greybus Specification Version: |gb-major|.\ |gb-minor|


.. warning::

   This document contains a preliminary specification for various
   aspects of a Greybus system's communication. It is important to
   note that the information contained within is in a draft stage, and
   has not yet been fully implemented. The specifications defined
   herein are **unstable**, and may change incompatibly in future
   versions of this document.

.. toctree::
   :maxdepth: 2

   terminology
   glossary
   introduction
   hardware_model
   module_info
   operations
   connection
   device_class
   bridged_phy
   control


.. Footnotes
.. =========

.. rubric:: Footnotes

.. [#a] TODO: remove these links when we are ready to incorporate this doc
        into the MDK.

.. [#t] Class Device descriptor?  I'd like to distinguish between a
        "class" of device and an instance of a device of a certain
        class.

.. [#u] I'm just going to state for the record that the notion of a
        "class" is still not very well defined.  We have a pretty clear
        idea of protocols and CPorts now, and how certain simple device
        functionality (like GPIO) can be implemented using them. But a
        class will offer a higher level of functionality, and it might
        span the use of multiple CPorts.  This is still a bit fuzzy and
        how exactly this will look is still under discussion.

.. [#v] I mention in an e-mail the possibility of implementing SVC
        communication by defining it as a distinct function type.

.. [#w] In addition, we could define a "multiplexor" function type.
        This would have a one-byte payload which defines which of up to
        256 "actual" functions within a device a message should be
        directed to.  I.e., it would provide a natural way of
        multiplexing communication with more than one function using a
        single CPort.

.. [#x] Supporting a multiplexor function would be pretty easy.  The
        MUX function would claim the CPort; then each of the
        multiplexed functions would point also use the same CPort,
        indicating also a unique "which function" number to be used to
        address messages to the function.  I suspect that might mean we
        reserve function 0 to communicate with the MUX function itself.

.. [#y] More specific?  I suspect this is unnecessarily copied from
        USB.  DME access and |unipro| configuration, which covers much of
        the same purpose, has a dedicated protocol. While some devices
        also use the control pipe for part of the application protocol,
        others do not, and there's no need to special case it anyway.
        (It's special cased precisely because it also handles USB
        configuration—see above.)  Given our constraints, requiring
        extra cports that devices don't need seems like a poor choice.

.. [#z] DME does not cover the |unipro| application layer, which is
        explicitly the layer for which Greybus is defined.

        Perhaps, rather than dedicating one of the CPorts to the
        Control "function," we could assert that CPort 0 shall support
        (in addition to any other functionality it offers) the
        control-related features.  This would require all control
        operations to be distinct from all other operations defined
        over the connection.

.. [#aa] This won't be a class, it'll be a "control CPort" that runs
         the "control" protocol.  I have defined some control protocol
         functionality and will be adding it to this document soon.

.. [#ab] I had a lot of questions about how everything is wired
         together as I looked through this, and they are probably
         covered in other documentation.

         For example:

         - Is the AP module distinguished from others in any way other
           than how it responds to power-up events?  E.g., is there a
           special physical connection to tell the SVC *this* module is
           the AP?

         - Is the AP module limited in which physical Ara "slots" it can reside in?

         - Is it possible to have more than one AP module on an Ara "handset" (or Endo?)?

         - The SVC must manage the |unipro| network using its own
           out-of-band communication medium. Does all the AP <-> SVC
           communication require any connection in addition to the
           |unipro| channel?  (It seems like it shouldn't.)

.. [#ac] We are in the process of redefining the SVC <--> AP
         interactions in terms of the "operations" protocol currently
         defined later in this document.

.. [#ad] Based on the diagram below, it appears the AP *sets/defines*
         routes, while the SVC implements them (that is, configures the
         switch hardware). Is there any reason the SVC should somehow
         verify the sanity of what gets set by an authenticated AP?  (I
         presume not.)

.. [#ae] The "Bootup sequence" mostly clarifies this as SVC
         independently setting up the initial state so communication
         can occur between it and the AP. The use cases in the Ara
         |unipro| Network functional spec also confirm this in more
         detail as to how the SVC sets up initial state after power on
         reset. In that document it's unclear who owns the post setup
         route configuration, but step 6 below confirms that the AP
         owns route configuration requests with the SVC merely
         implementing those requests as you say.

.. [#af] Is the model for when modules can be plugged in and unplugged
         defined somewhere?  Can a module be unplugged without AP
         knowledge/involvement when the OS is booted?

.. [#ag] Yes. There's now an RFC sequence diagram for what happens in
         this case in the SVC section of the software architecture doc.

.. [#ah] I was going to suggest this term.

         Do you prefer something else, to avoid confusion because this
         is *not* using |unipro| protocol?  If that is the case, perhaps
         using a completely different set of terms would make
         distinguishing them clearer.

.. [#ai] Is it your intention to impose the same sort of restrictions
         on these structures as were made for the descriptors,
         earlier?  Sizes rounded up to 4 byte multiples, etc.?

.. [#aj] Is a reply message expected?

.. [#ak] Once we switch over to the operations model, yes, there will
         be a reply.

.. [#al] I have now defined operations for all of these in a "control
         protocol" found at the end of this document.

.. [#am] The module Id needs to convey the physical location of the
         module within the Endo. Application software may need to know
         this in order to function properly.

.. [#an] Furthermore the SVC need to be able to communicate what model
         of Endo is in use, to allow correct interpretation of this
         position information.

.. [#ao] The "October 8th" proposal I just sent out will address these
         issues.

.. [#ap] (Referencing the comment above.)

         In this case, we *are* talking about a module id.  I think an
         interface block would be tightly coupled with the notion of a
         |unipro| device, and looking ahead we are not limited to one
         interface block per module.  I expect an endo would define a
         mapping between the interface blocks in each module and their
         device numbers (along with the physical position of each
         module).

.. [#aq] MDK 0.2 Draft Figure 5.5 defines unique IDs for each IB in the
         mini and medium endos (large is not yet defined). As mentioned
         in my proposal, we can define a unique Module ID using the
         unique IB IDs that have that physical positioning attribute
         defined in the MDK.

.. [#ar] Given the above comments, I would like to rename this field
         "position" or something along those lines, to emphasize that
         it is more than simply a unique identifier within the Endo.

.. [#as] Is there any need (or ability) to determine the current state
         of an EPM?

.. [#at] Don't we also need resume commands to be passed from modules
         to the AP (via the SVC)?

.. [#au] No suspend message types yet...

.. [#av] +elder_alex@projectara.com Presumably, protocols are defined
         also in terms of state changes due to e.g. error handling for
         failed operations as well, no?

.. [#aw] I'm not completely sure what you mean.  Are you just
         questioning the word "successfully" in this sentence?  If so,
         you're right--error behavior should be well-defined for every
         operation too.

.. [#ax] Yes, just questioning the word "successfully"


.. [#bh] Can we add -

         "get_shutdowntemperature" - shutdown temperature at which
         device should get turned off..(60 or 80 or 70 Celsius etc..)

         "get_totalcapacity" - Total (design) battery capacity in mAh.

         "get_lowwarning" - when system should raise low warning level

         This is to update few parameters in android framework. I see
         these parameters vary from battery to battery.

.. [#bi] for shutdown temp, would that be the
         POWER_SUPPLY_PROP_TEMP_ALERT_MAX value in the kernel?

         For total capacity, is that POWER_SUPPLY_PROP_CURRENT_MAX ?

         As for "low warning", I don't understand how that works from
         the kernel side, is there a value you read from the kernel for
         this?  Or does Android take the existing capacity % and just
         use it (less than 10% is an issue)?

.. [#bj] yes, we use "POWER_SUPPLY_PROP_TEMP_ALERT_MAX" - get the alert
         value for shutdown temp

         At present, no idea if we can calculate total capacity in mAh
         from "POWER_SUPPLY_PROP_CURRENT_MAX" ? Do you have any ?  Need
         to look further for this.

         "low warning" level is statically defined in user space config
         file for each vendor. But you are right We can use static
         value for all - 10/15% to indicate low warning level.. - I am
         ok with that

.. [#bk] typo: voltage instead of current

.. [#bl] Can we add -

         "get_shutdowntemperature" - shutdown temperature at which
         device should get turned off..(60 or 80 or 70 Celsius etc..)

         "get_totalcapacity" - Total (design) battery capacity in mAh.

         "get_lowwarning" - when system should raise low warning level

         This is to update few parameters in android framework. I see
         these parameters vary from battery to battery.

.. [#bm] for shutdown temp, would that be the
         POWER_SUPPLY_PROP_TEMP_ALERT_MAX value in the kernel?

         For total capacity, is that POWER_SUPPLY_PROP_CURRENT_MAX ?

         As for "low warning", I don't understand how that works from
         the kernel side, is there a value you read from the kernel for
         this?  Or does Android take the existing capacity % and just
         use it (less than 10% is an issue)?

.. [#bn] yes, we use "POWER_SUPPLY_PROP_TEMP_ALERT_MAX" - get the alert
         value for shutdown temp

         At present, no idea if we can calculate total capacity in mAh
         from "POWER_SUPPLY_PROP_CURRENT_MAX" ? Do you have any ?  Need
         to look further for this.

         "low warning" level is statically defined in user space config
         file for each vendor. But you are right We can use static
         value for all - 10/15% to indicate low warning level.. - I am
         ok with that

.. [#bo] in the case of a weak USB charger (like a regular USB port),
         there is actually a possibility that the battery is "charging
         but discharging", i.e. the charging current is less that the
         current consumed by the phone. Would should be the status
         reported then? also note the get_current() function returns
         unsigned value, so cannot be used to handle it.

