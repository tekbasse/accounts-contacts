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
    Returns a form definiton for qal_contact table to feed to qfo::form_list_def_to_array and subsequently to qal_3g.
    
    <code>field_values_arr_name</code> is the name of an array
    where the indexes are names of fields, and
    their values replace internal defaults.
    This is more for customizations that might occur at a single page,
    where the defaults are tweaked for one reason or another.
    
    @see qal_contact_keys
    @see qal_contact_defaults
    @see qfo::form_list_def_to_array
    @see qal_3g
} {
    upvar 1 instance_id instance_id
    if { $field_values_arr_name ne "" } {
        upvar 1 field_values_arr_name fv_arr
    }
    # 2 col
    set html_before1 {<div class="grid-6 m-grid-12 s-grid-12"><div class="content-box">}
    # 3 col
    set html_before2 {<div class="grid-4 m-grid-2 s-grid-12"><div class="content-box">}
    set html_before3 {<div class="grid-6 m-grid-6 s-grid-6"><div class="content-box">}
    set html_after {</div></div>}
    
    qal_contact_defaults fc_arr
    qal_address_defaults fa_arr
    set f_lol [list \
                   [list name label value $fc_arr(label) context content_c1 datatype text_word html_before $html_before1 html_after $html_after label "#accounts-contacts.label#" title "#q-data-types.alphanum_word_hint#"] \
                   [list name name value $fc_arr(name) context content_c1 datatype text_nonempty html_before $html_before1 html_after $html_after label "#accounts-contacts.name#"] ]
    
    #
    # Make a subset of fields into a row, expandable to multiple rows.
    #
    
    # Make a list of choices for address_type
    # Could almost use qal_address_type_keys here,
    # but language keys don't correlate
    set at_lol [list \
                    [list value street_address label "#accounts-contacts.Address#"] \
                    [list value billing_address label "#accounts-contacts.Billing_Address"] \
                    [list value shipping_address label "#accounts-contacts.Shipping_Address"] \
                    [list value other_address label "#accounts-contacts.Other_addresses#" ]]
    # set the value to existing one 
    set addrs_type_lol [list ]
    foreach at_list $at_lol {
        if { $fa_arr(address_type) eq [lindex $at_list 1] } {
            lappend at_list selected 1
        }
        lappend addrs_type_lol $at_list
    }

    
    set addrs_lol  [list \
                        [list name address_type value $fa_arr(address_type) context content_c2 datatype qf_choice $addrs_type_lol html_before $html_before1 html_after $html_after ] \
                        [list name address0 value $fa_arr(address0) context content_c2 datatype text maxlength 32 html_before $html_before1 html_after $html_after label "#accounts-contacts.street_address# 1/3" title "#q-data-types.street_address_hint#"] \
                        [list name address1 value $fa_arr(address1) context content_c2 datatype text maxlength 32 html_before $html_before1 html_after $html_after label "#accounts-contacts.street_address# 2/3" title "#q-data-types.street_address_hint#"] \
                        [list name address2 value $fa_arr(address2) context content_c2 datatype text maxlength 32 html_before $html_before1 html_after $html_after label "#accounts-contacts.street_address# 3/3" title "#q-data-types.street_address_hint#"] \
                        [list name city value $fa_arr(city) context content_c2 datatype text maxlength 32 html_before $html_before2 html_after $html_after label "#accounts-contacts.City#"] \
                        [list name state value $fa_arr(state) context content_c2 datatype region maxlength 32 html_before $html_before2 html_after $html_after label "#q-data-types.region#"] \
                        [list name postal_code value $fa_arr(postal_code) context content_c2 datatype postal_code maxlength 10 html_before $html_before2 html_after $html_after label "#q-data-types.postal_code#"] \
                        [list name country_code value $fa_arr(country_code) context content_c2 datatype country_code maxlength 32 html_before $html_before3 html_after $html_after label "#q-data-types.country_code#"] \
                        [list name attn value $fa_arr(attn) context content_c2 datatype text maxlength 32 html_before $html_before3 html_after $html_after label "#q-data-types.attn#" title "#q-data-types.attn_hint#"] \
                        [list name phone  value $fa_arr(phone) context content_c2 datatype phone_number html_before $html_before2 html_after $html_after label "#q-data-types.phone_number#"] \
                        [list name phone_time value $fa_arr(phone_time) context content_c2 datatype text html_before $html_before2 html_after $html_after label "#accounts-contacts.phone_time#" title "#accounts-contacts.phone_time_hint#" ] \
                        [list name fax value $fa_arr(fax) context content_c2 datatype phone_number html_before $html_before2 html_after $html_after label "#accounts-contacts.Fax#"] \
                        [list name email value $fa_arr(email) context content_c2 datatype email html_before $html_before2 html_after $html_after label "#accounts-contacts.Email#"] \
                        [list name cc value $fa_arr(cc) context content_c2 datatype email html_before $html_before2 html_after $html_after label "#accounts-contacts.Cc#"] \
                        [list name bcc value $fa_arr(bcc) context content_c2 datatype email html_before $html_before2 html_after $html_after label "#accounts-contacts.Bcc#"] ]
    
    set f2_lol [qfo::form_list_def_to_css_table_rows -list_of_lists_name f_lol -form_field_defs_to_multiply addrs_lol -rows_count 1]
    
    # Add the rest of the form elements. Skipping: taxnumber, iban, bic, currency
    set f3_lol [list \
                    [list name sic_code value $fc_arr(sic_code) context content_c3 datatype natural_num html_before $html_before2 html_after $html_after label "#accounts-contacts.SIC#"] \
                    [list name language_code value $fc_arr(language_code) context content_c3 datatype text maxlength 12 html_before $html_before2 html_after $html_after label "#accounts-contacts.language_code#" ] \
                    [list name timezone value $fc_arr(timezone) context content_c3 datatype text maxlength 4 html_before $html_before2 html_after $html_after label "#accounts-contacts.timezone#" ] \
                    [list name time_start value $fc_arr(time_start) context content_c3 datatype date html_before $html_before3 html_after $html_after label "#accounts-contacts.Startdate#" ] \
                    [list name time_end value $fc_arr(time_end) context content_c3 datatype date html_before $html_before3 html_after $html_after label "#accounts-contacts.Enddate#" ] \
                    [list name url value $fc_arr(url) context content_c3 datatype url html_before $html_before3 html_after $html_after label "#accounts-contacts.URL#" ] \
                    [list name notes value $fc_arr(notes) context content_c4 datatype block_text cols 34 html_before $html_before3 html_after $html_after label "#accounts-contacts.notes#"] \
                    [list type submit name save context content_c5 \
                         value "\#acs-kernel.common_save\#" datatype text html_before $html_before3 html_after $html_after label "" class "btn-big"] \
                    [list type submit name update context content_c5 \
                         value "\#acs-kernel.common_update\#" datatype text html_before $html_before3 html_after $html_after label "" class "btn-big" ] \
                   ]
    qf_append_lol2_to_lol1 f2_lol f3_lol
    
    return $f2_lol
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
