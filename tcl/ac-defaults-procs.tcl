ad_library {
    Library that provides defaults for accounts-contacts
    @creation-date 2016-06-28

}

ad_proc -private qal_contact_defaults {
    arr_name
} {
    Sets defaults for a contact record into array_name 
    if element does not yet exist in array.

    @see qal_contact_keys
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name c_arr

    set c_list [list \
                    id "" \
                    rev_id "" \
                    instance_id $instance_id \
                    parent_id "" \
                    label "" \
                    name "" \
                    street_addrs_id "" \
                    mailing_addrs_id "" \
                    billing_addrs_id "" \
                    vendor_id "" \
                    customer_id "" \
                    taxnumber "" \
                    sic_code "" \
                    iban "" \
                    bic "" \
                    language_code "" \
                    currency "" \
                    timezone "" \
                    time_start "" \
                    time_end "" \
                    url "" \
                    user_id "" \
                    created [qf_clock_format [clock seconds]] \
                    created_by "" \
                    trashed_p "0" \
                    trashed_by "" \
                    trashed_ts "" \
                    notes "" ]
    set c2_list [list ]
    foreach {key value} $c_list {
        lappend c2_list $key
        if { ![exists_and_not_null c_arr(${key}) ] } {
            set c_arr(${key}) $value
        }
    }
    if { [llength [set_difference_named_v c2_list [qal_contact_keys]]] > 0 } {
        ns_log Warning "qal_contact_defaults: Update this proc. \
 It is out of sync with qal_contact_keys"
    }
    return 1
}

ad_proc -private qal_contact_user_map_defaults {
    arr_name
} {
    Sets defaults for a contact record into array_name 
    if element does not yet exist in array.

    @see qal_contact_user_map_keys
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name c_arr

    set c_list [list \
                    instance_id $instance_id \
                    contact_id "" \
                    user_id "" \
                    created [qf_clock_format [clock seconds]] \
                    created_by "" \
                    trashed_p "0" \
                    trashed_by "" \
                    trashed_ts "" ]
    set c2_list [list ]
    foreach {key value} $c_list {
        lappend c2_list $key
        if { ![exists_and_not_null c_arr(${key}) ] } {
            set c_arr(${key}) $value
        }
    }
    if { [llength [set_difference_named_v c2_list [qal_contact_user_map_keys]]] > 0 } {
        ns_log Warning "qal_contact_user_map_defaults: Update this proc. \
 It is out of sync with qal_contact_user_map_keys"
    }
    return 1
}


ad_proc -private qal_other_address_map_defaults {
    arr_name
} {
    Sets defaults for a other_address_map record into array_name 
    if element does not yet exist in array.

    @see qal_other_address_map_keys
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name v_arr

    set v_list [list \
                    contact_id "" \
                    instance_id $instance_id \
                    addrs_id "" \
                    record_type "" \
                    address_id "" \
                    sort_order "" \
                    created "" \
                    created_by "" \
                    trashed_p "" \
                    trashed_by "" \
                    trashed_ts "" \
                    account_name "" \
                    notes ""]
    set v2_list [list ]
    foreach {key value} $v_list {
        lappend v2_list $key
        if { ![exists_and_not_null v_arr(${key}) ] } {
            set v_arr(${key}) $value
        }
    }
    if { [llength [set_difference_named_v v2_list [qal_other_address_map_keys]]] > 0 } {
        ns_log Warning "qal_other_address_map_defaults: Update this proc. \
 It is out of sync with qal_other_address_map_keys"
    }
    return 1
}

ad_proc -private qal_address_defaults {
    arr_name
} {
    Sets defaults for a address record into array_name 
    if element does not yet exist in array.

    @see qal_address_keys
} {
    upvar 1 instance_id instance_id
    upvar 1 $arr_name v_arr

    set v_list [list \
                    id "" \
                    instance_id $instance_id \
                    address_type "" \
                    address0 "" \
                    address1 "" \
                    address2 "" \
                    city "" \
                    state "" \
                    postal_code "" \
                    country_code "" \
                    attn "" \
                    phone "" \
                    phone_time "" \
                    fax "" \
                    email "" \
                    cc "" \
                    bcc ""]
    set v2_list [list ]
    foreach {key value} $v_list {
        lappend v2_list $key
        if { ![exists_and_not_null v_arr(${key}) ] } {
            set v_arr(${key}) $value
        }
    }
    if { [llength [set_difference_named_v v2_list [qal_address_keys]]] > 0 } {
        ns_log Warning "qal_address_defaults: Update this proc. \
 It is out of sync with qal_address_keys"
    }
    return 1
}