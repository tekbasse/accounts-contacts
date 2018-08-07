#accounts-contacts/tcl/cs-util-procs.tcl
ad_library {

    misc API for accounts-contacts
    @creation-date 7 Aug 2018
    @Copyright (c) 2018 Benjamin Brink
    @license GNU General Public License 2
    @project home: http://github.com/tekbasse/accounts-contacts
    
}

# qc_properties  returns list of properties (defined in accounts-ledger)

# accounts-contacts.contact_id references refer to accounts-ledeger.contact_id
# so that package can be used  with contacts, contacts, or vendors.

ad_proc -private cs_contact_ids_of_user_id { 
    {user_id ""}
} {
    Returns list of contact_id available to user_id in a contact's role position.
} {
    upvar 1 instance_id instance_id
    if { ![info exists instance_id] } {
        # set instance_id package_id
        set instance_id [qc_set_instance_id]
    }
    if { $user_id eq "" } {
        set user_id [ad_conn user_id]
    }
    set package_id [ad_conn package_id]

    #set cs_type qc_parameter_get $instance_id ""
    set cs_type [parameter::get -parameter contactTypesRef -package_id $package_id]

    # Change this SWITCH to whatever other package reference provides a list of contact_ids for user_id
    # Use accounts-ledger api for default, consider a package parameter for other cases
    # qal_contact_ids_of_usr_id  (this handles for vendors, contacts, as well as other cases)
    set contact_id_list [list ]
    switch $cs_type -- {
        1 {
            set customer_id_list [qal_customer_ids_of_user_id $user_id ]
            set contact_id_list [qal_contact_id_of_customer_id $customer_id_list]
        }
        2 {
            set vendor_id_list [qal_vendor_ids_of_user_id $user_id ]
            set contact_id_list [qal_contact_id_of_vendor_id $vendor_id_list]
        }
        3 {
            set customer_id_list [qal_customer_ids_of_user_id $user_id ]
            set c_contact_id_list [qal_contact_id_of_customer_id $customer_id_list]

            set vendor_id_list [qal_vendor_ids_of_user_id $user_id ]
            set v_contact_id_list [qal_contact_id_of_vendor_id $vendor_id_list]

            set contact_id_list [set_union $c_contact_id_list $v_contact_id_list]
        } 
        4 {
            # all contacts user has access to
            set contact_id_list [qal_contact_ids_of_user_id $user_id ]
        }
   }
    return $contact_id_list
}

