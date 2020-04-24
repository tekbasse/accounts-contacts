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

ad_proc -private qal_contact_form_def {
    {-field_values_arr_name ""}
} {
    Creates a form definiton for qal_contact table to feed to qal_3g via qfo::form_list_def_to_array.

    field_values_arr_name is the name of an array that contains
    names of fields, where the returned values replace defaults.

    @see qal_contact_keys
    @see qal_contact_defaults
    @see qfo::form_list_def_to_array
    @see qal_3g
} {
    upvar 1 instance_id instance_id
    if { $field_values_arr_name ne "" } {
        upvar 1 field_values_arr_name fv_arr
    }
    set html_before1 {<div class="grid-2 m-grid-6 s-grid-12"><div class="content-box">}

    set html_before2 {<div class="grid-2 m-grid-3 s-grid-6"><div class="content-box">}
    set html_after {</div></div>}

    qal_contact_defaults fv_arr

    set f_lol [list \
                   [list name label value $fv_arr(label) datatype text_word label "#accounts-contacts.label#" title "#q-data-types.alphanum_word_hint#"] \
                   [list name name value $fv_arr(name) datatype text_nonempty label "#accounts-contacts.name#"] ]

    #
    # Make a subset of fields into a row, expandable to multiple rows.
    #
    
    # Make a list of choices for address_type
    set at_lol [list \
                    [list value street_address label "#accounts-contacts.Address#"] \
                    [list value billing_address label "#accounts-contacts.Billing_Address"] \
                    [list value shipping_address label "#accounts-contacts.Shipping_Address"] \
                    [list value other_address label "#accounts-contacts.Other_addresses#" ]]
    # set the value to existing one 
    set addrs_type_lol [list ]
    foreach at_list $at_lol {
        if { $fv_arr(address_type) eq [lindex $at_list 1] } {
            lappend at_list selected 1
        }
        lappend addrs_type_lol $at_list
    }
    
    set addrs_lol  [list \
                         [list name address_type datatype qf_choice $addrs_type_lol ] \
                         [list name address0 datatype text label "#accounts-contacts.street_address# 1/3" title "#q-data-types.street_address_hint#"] \
                         [list name address1 datatype text label "#accounts-contacts.street_address# 2/3" title "#q-data-types.street_address_hint#"] \
                         [list name address2 datatype text label "#accounts-contacts.street_address# 3/3" title "#q-data-types.street_address_hint#"] \
                         [list name city datatype text label "#accounts-contacts.City#"] \
                         [list name state datatype region label "#q-data-types.region#" title "#q-data-types.region_hint#"] \
                         [list name postal_code datatype postal_code label "#q-data-types.postal_code#" title "#q-data-types.postal_code_hint#"] \
                         [list name country_code datatype country_code label "#q-data-types.country_code#" title "#q-data-types.country_code_hint#"] \
                         [list name attn datatype text label "#q-data-types.attn#" title "#q-data-types.attn_hint#"] \
                         [list name phone datatype phone_number label "#q-data-types.phone_number#" title "#q-data-types.phone_number_hint#"] \
                         [list name phone_time datatype text label #accounts-contacts.phone_time# title #accounts-contacts.phone_time_hint# ] \
                         [list name fax datatype phone_number label "#accounts-contacts.Fax#"] \
                         [list name email datatype email label "#accounts-contacts.Email#" title "#q-data-types.email_hint#"] \
                         [list name cc datatype email label "#accounts-contacts.Cc#" title "#q-data-types.email_hint#"] \
                         [list name bcc datatype email label "#accounts-contacts.Bcc#" title "#q-data-types.email_hint#"] ]
              
set f2_lol [qfo::form_list_def_to_css_table_rows -list_of_lists_name f_lol -form_field_defs_to_multiply addrs_lol -rows_count 3]

# Add the rest of the form elements.
set f3_lol [list \
                [list type submit name save context content_c6 \
                     value "\#acs-kernel.common_save\#" datatype text label "" class "btn-big"] \
                [list type submit name update context content_c7 \
                     value "\#acs-kernel.common_update\#" datatype text label "" class "btn-big" ] \
               ]
qf_append_lol2_to_lol1 f2_lol f3_lol


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
