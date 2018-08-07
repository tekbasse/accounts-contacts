#accounts-contacts/tcl/cs-view-procs.tcl
ad_library {

    views for accounts-contacts
    @creation-date 7 Aug 2018
    @Copyright (c) 2018 Benjamin Brink
    @license GNU General Public License 2
    @project home: http://github.com/tekbasse/accounts-contacts
    
}

# a contact is of q-control property type org_properties

# qac_contact_create/write
# qac_contact_read
# qac_contact_trash
# qac_contact_delete

ad_proc -private qac_contact_keys {
    {separator ""}
} {
    Returns an ordered list of keys that is parallel to the ordered list returned by qac_contact_read.

    If separator is not "", returns a string joined with separator.
    @see qal_keys_by
} {
    set keys_list [list \
		       id \
		       rev_id \
		       instance_id \
		       parent_id \
		       label \
		       name \
		       street_addrs_id \
		       mailing_addrs_id \
		       billing_addrs_id \
		       vendor_id \
		       customer_id \
		       taxnumber \
		       sic_code \
		       iban \
		       bic \
		       language_code \
		       currency \
		       timezone \
		       time_start \
		       time_end \
		       url \
		       user_id \
		       created \
		       created_by \
		       trashed_p \
		       trashed_by \
		       trashed_ts \
		       notes ]
    set keys [qal_keys_by $keys_list $separator]
    return $keys
}

ad_proc -public qac_contact_read {
    args
} {
    Returns a name value list of contact attributes.
    If no contact_id supplied, returns an empty list.
    <br/>
    Default q-control.property_label is org_properties.
    <br/>
    contact_id is contact's contact_id from qal_contacts.
    <br/>
    <code>args</code> can be passed as name value list.
    <br/>
    If there is an error, an empty contact_id is returned.
} {
    upvar 1 instance_id instance_id
    set property_label "org_properties"
    # contact may be of type:
    # org_properties
    # org_accounts
    # project_accounts
    # project_properties
    set keys_list [qac_contact_keys ]
    qf_nv_list_to_vars $args $keys_list

    set allowed_p [qc_permission_p \
		       $user_id \
		       $contact_id \
		       $property_label \
		       "read" \
		       $instance_id ]
    return $contact_id
}

