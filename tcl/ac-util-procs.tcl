ad_library {
    Library for accounts-contacts
    @creation-date 2016-06-28

}

ad_proc -public qal_contact_id_exists_q {
    contact_id
} {
    Returns 1 if contact_id exists, otherwise returns 0
} {
    upvar 1 instance_id instance_id
    db_0or1row qal_contact_exists_q {select id from qal_contact where instance_id=:instance_id and id=:contact_id and trashed_p!='1'}
    return [info exists id]
}


ad_proc -public qal_contact_label_from_id {
    contact_id
} {
    Returns contact label if it exists, otherwise returns ""
} {
    upvar 1 instance_id instance_id
    set label ""
    db_0or1row qal_contact_label_exists_q {select label from qal_contact where instance_id=:instance_id and id=:contact_id and trashed_p!='1'}
    return $label
}

ad_proc -public qal_contact_id_from_label {
    contact_label
} {
    Returns id if contact_label exists, otherwise returns ""
} {
    upvar 1 instance_id instance_id
    set id ""
    db_0or1row qal_contact_label_exists_q {select id from qal_contact where instance_id=:instance_id and label=:contact_label and trashed_p!='1'}
    return $id
}

ad_proc -public qal_contact_id_from_customer_id {
    customer_id
} {
    Returns contact_id(s) of customer_id(s). If supplied 1, returns a scalar, otherwise returns a list.
    Returns an empty string if customer_id not found.
} {
    upvar 1 instance_id instance_id
    if { [llength $customer_id] > 1 } {
        set contact_ids [db_list qal_customer_read_c_id_n "select contact_id from qal_customer \
 where customer_id in ([template::util::tcl_to_sql_list $customer_id]) and trashed_p!='1' and instance_id=:instance_id"]
    } else {
        set contact_ids ""
        db_0or1row qal_customer_read_customer_id_1 {select contact_id as contact_ids from qal_customer
            where id=:customer_id
            and instance_id=:instance_id
            and trashed_p!='1'}
    }
    return $contact_ids
}

ad_proc -public qal_contact_id_from_vendor_id {
    vendor_id
} {
    Returns contact_id(s) of vendor_id(s). If supplied 1, returns a scalar, otherwise returns a list.
    Returns an empty string if vendor_id not found.
} {
    upvar 1 instance_id instance_id
    if { [llength $vendor_id] > 1 } {
        set contact_ids [db_list qal_vendor_read_c_id_n "select contact_id from qal_vendor \
 where vendor_id in ([template::util::tcl_to_sql_list $vendor_id]) and trashed_p!='1' and instance_id=:instance_id"]
    } else {
        set contact_ids ""
        db_0or1row qal_vendor_read_vendor_id_1 {select contact_id as contact_ids from qal_vendor
            where id=:vendor_id
            and instance_id=:instance_id
            and trashed_p!='1'}
    }
    return $vendor_ids
}


ad_proc -public qal_customer_id_exists_q {
    customer_id
} {
    Returns 1 if customer_id exists, otherwise returns 0
} {
    upvar 1 instance_id instance_id
    db_0or1row qal_customer_exists_q {select id from qal_customer where instance_id=:instance_id and id=:customer_id and trashed_p!='1'}
    return [info exists id]
}


ad_proc -public qal_customer_id_from_code {
    customer_code
} {
    Returns id if customer_code exists, otherwise returns ""
} {
    upvar 1 instance_id instance_id
    set id ""
    db_0or1row qal_customer_code_exists_q {select id from qal_customer where instance_id=:instance_id and customer_code=:customer_code and trashed_p!='1'}
    return $id
}

ad_proc -public qal_vendor_id_exists_q {
    vendor_id
} {
    Returns 1 if vendor_id exists, otherwise returns 0
} {
    upvar 1 instance_id instance_id
    db_0or1row qal_vendor_exists_q {select id from qal_vendor where instance_id=:instance_id and id=:vendor_id and trashed_p!='1'}
    return [info exists id]
}


ad_proc -public qal_vendor_id_from_code {
    vendor_code
} {
    Returns id if vendor_code exists, otherwise returns ""
} {
    upvar 1 instance_id instance_id
    set id ""
    db_0or1row qal_vendor_code_exists_q {select id from qal_vendor where instance_id=:instance_id and vendor_code=:vendor_code and trashed_p!='1'}
    return $id
}


ad_proc -public qal_contact_ids {
} {
    Returns contact_id(s) for contact_id, or empty string if none found.
} {
    upvar 1 instance_id instance_id
    # Was: qal_contact_ids_of_user_id
    # but that function has been deligated to qc_contact_ids_of_user_id
    # qal_contact_ids returns all contact_ids for org_contact_id
    set contact_id_list [db_list qal_contact_ids_rn {
        select id from qal_contact
        where instance_id=:instance_id
        and trashed_p!='1' } ]
    return $contact_id_list
}


ad_proc -public qal_customer_ids_of_user_id {
    user_id
} {
    Returns customer_id(s) of user_id, or empty string if none found.
} {
    upvar 1 instance_id instance_id
    # Every customer_id has one contact_id
    set contact_id_list [qal_contact_ids_of_user_id $user_id]
    set customer_id_list [list ]
    if { [llength $contact_id_list] > 0 } {
        set customer_id_list [db_list qal_customer_contact_ids_r " select id from qal_customer
        where contact_id in ([template::util::tcl_to_sql_list $contact_id_list])
        and instance_id=:instance_id"]
    }
    return $customer_id_list
}

ad_proc -public qal_vendor_ids_of_user_id {
    user_id
} {
    Returns vendor_id(s) of user_id, or empty string if none found.
} {
    upvar 1 instance_id instance_id
    # Every vendor_id has one contact_id
    set contact_id_list [qal_contact_ids_of_user_id $user_id]
    set vendor_id_list [list ]
    if { [llength $contact_id_list] > 0 } {
        set vendor_id_list [db_list qal_vendor_contact_ids_r " select id from qal_vendor
        where contact_id in ([template::util::tcl_to_sql_list $contact_id_list])
        and instance_id=:instance_id"]
    }
    return $vendor_id_list
}


ad_proc -public qal_contact_keys {
    {separator ""}
} {
    Returns an ordered list of keys for qal_contact: 

    id 
    rev_id 
    instance_id 
    parent_id 
    label 
    name 
    street_addrs_id 
    mailing_addrs_id 
    billing_addrs_id 
    vendor_id 
    customer_id 
    taxnumber 
    sic_code 
    iban 
    bic 
    language_code 
    currency 
    timezone 
    time_start 
    time_end 
    url 
    user_id 
    created 
    created_by 
    trashed_p 
    trashed_by 
    trashed_ts 
    notes 

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

ad_proc -public qal_customer_keys {
    {separator ""}
} {
    Returns an ordered list of keys for qal_customer:
    id 
    instance_id 
    rev_id 
    contact_id 
    discount 
    tax_included 
    credit_limit 
    terms 
    terms_unit 
    annual_value 
    customer_code 
    pricegroup_id 
    created 
    created_by 
    trashed_p 
    trashed_by 
    trashed_ts
} {
    set keys_list [list \
                       id \
                       instance_id \
                       rev_id \
                       contact_id \
                       discount \
                       tax_included \
                       credit_limit \
                       terms \
                       terms_unit \
                       annual_value \
                       customer_code \
                       pricegroup_id \
                       created \
                       created_by \
                       trashed_p \
                       trashed_by \
                       trashed_ts ]
    set keys [qal_keys_by $keys_list $separator]
    return $keys
}

ad_proc -public qal_vendor_keys {
    {separator ""}
} {
    Returns an ordered list of keys for qal_vendor:
    id 
    instance_id 
    rev_id 
    contact_id 
    terms 
    terms_unit 
    tax_included 
    vendor_code 
    gifi_accno 
    discount 
    credit_limit 
    pricegroup_id 
    created 
    created_by 
    trashed_p 
    trashed_by 
    trashed_ts 
    area_market 
    purchase_policy 
    return_policy 
    price_guar_policy 
    installation_policy 
} {
    set keys_list [list \
                       id \
                       instance_id \
                       rev_id \
                       contact_id \
                       terms \
                       terms_unit \
                       tax_included \
                       vendor_code \
                       gifi_accno \
                       discount \
                       credit_limit \
                       pricegroup_id \
                       created \
                       created_by \
                       trashed_p \
                       trashed_by \
                       trashed_ts \
                       area_market \
                       purchase_policy \
                       return_policy \
                       price_guar_policy \
                       installation_policy ]
    set keys [qal_keys_by $keys_list $separator]
    return $keys
}

ad_proc -public qal_address_keys {
    {separator ""}
} {
    Returns an ordered list of keys for qal_address:
    id 
    instance_id 
    address_type 
    address0 
    address1 
    address2 
    city 
    state 
    postal_code 
    country_code 
    attn 
    phone 
    phone_time 
    fax 
    email 
    cc 
    bcc
} {
    # removed rev_id. see table definition.
    set keys_list [list \
                       id \
                       instance_id \
                       address_type \
                       address0 \
                       address1 \
                       address2 \
                       city \
                       state \
                       postal_code \
                       country_code \
                       attn \
                       phone \
                       phone_time \
                       fax \
                       email \
                       cc \
                       bcc ]
    set keys [qal_keys_by $keys_list $separator]
    return $keys
}


ad_proc -public qal_other_address_map_keys {
    {separator ""}
} {
    Returns an ordered list of keys for qal_other_address_map:
    contact_id 
    instance_id 
    addrs_id 
    record_type 
    address_id 
    sort_order 
    created 
    created_by 
    trashed_p 
    trashed_by 
    trashed_ts 
    account_name 
    notes 

    @see qal_address_keys
} {
    set keys_list [list \
                       contact_id \
                       instance_id \
                       addrs_id \
                       record_type \
                       address_id \
                       sort_order \
                       created \
                       created_by \
                       trashed_p \
                       trashed_by \
                       trashed_ts \
                       account_name \
                       notes ]
    set keys [qal_keys_by $keys_list $separator]
    return $keys
}


ad_proc -public qal_addresses_keys {
    {separator ""}
} {
    Special case of *_keys api for use with db api. Returns an ordered list of keys for the combined tables of qal_address and qal_other_address_map as qal_addresses_read: \
        contact_id \
        instance_id \
        addrs_id \
        record_type \
        address_id \
        sort_order \
        created \
        created_by \
        trashed_p \
        trashed_by \
        trashed_ts \
        account_name \
        notes \
        address_type \
        address0 \
        address1 \
        address2 \
        city \
        state \
        postal_code \
        country_coude \
        attn \
        phone \
        phone_time \
        fax \
        email \
        cc \
        bcc
    @see qal_address_keys
    @see qal_other_address_map_keys
} {
    # This only works to read from the database and a extract data from an ordered list.
    # To write to database, use qal_address_keys and qal_other_address_map_keys.
    set k_list [list \
                    om.contact_id \
                    om.instance_id \
                    om.addrs_id \
                    om.record_type \
                    om.address_id \
                    om.sort_order \
                    om.created \
                    om.created_by \
                    om.trashed_p \
                    om.trashed_by \
                    om.trashed_ts \
                    om.account_name \
                    om.notes \
                    ad.address_type \
                    ad.address0 \
                    ad.address1 \
                    ad.address2 \
                    ad.city \
                    ad.state \
                    ad.postal_code \
                    ad.country_code \
                    ad.attn \
                    ad.phone \
                    ad.phone_time \
                    ad.fax \
                    ad.email \
                    ad.cc \
                    ad.bcc ]
    if { $separator eq "," } {
        set keys_list $k_list
    } else {
        set keys_list [list ]
        foreach key $k_list {
            lappend keys_list [string range $key 3 end]
        }
    }
    set keys [qal_keys_by $keys_list $separator]
    return $keys
}

ad_proc -public qal_address_type {
    addrs_id
    {contact_id ""}
} {
    Returns address type (ie qal_other_address_map.record_type ) or empty string if not found.
    If contact_id is nonempty, constrains query to contact_id.
    <br/>
    @see qal_other_address_map_keys
} {
    upvar 1 instance_id instance_id
    set record_type ""
    if { [qf_is_natural_number $contact_id ] } {
        db_0or1row qal_other_address_map_address_type_r {
            select record_type from qal_other_address_map
            where contact_id=:contact_id
            and addrs_id=:addrs_id
            and instance_id=:instance_id
            and trashed_p!='1' }
    } else {
        db_0or1row qal_other_address_map_address_type_r2 {
            select record_type from qal_other_address_map
            where addrs_id=:addrs_id
            and instance_id=:instance_id
            and trashed_p!='1' }
    }
    return $record_type
}

ad_proc -public qal_address_type_keys {
} {
    Returns postal address_type keys in a list: mailing_address billing_address street_address
    <br/>
    Other address_type can be most anything: twitter, phone, etc.
    <br/>
    For other address_type keys, see qal_demo_address_write

    @see qal_demo_address_write
} {
    return [list mailing_address billing_address street_address]
}

ad_proc -private qal_address_type_fields {
} {
    Returns postal address_type fields that correspond to address_type keys

    @see qal_address_type_keys
} {
    return [list mailing_addrs_id billing_addrs_id street_addrs_id]
}

ad_proc -public qal_address_type_is_postal_q {
    address_type
} {
    Returns 1 if address type is a postal address, otherwise returns 0.
} {
    set is_postal_p 1
    set address_type_list [qal_address_type_keys]
    if { $address_type ni $address_type_list } {
        set is_postal_p 0
    }
    return $is_postal_p
}

ad_proc -public qal_field_name_of_address_type {
    address_type
} {
    Returns field name in table qal_other_address_map of record_type,
    or empty string if address_type not in table.
    <br/>
    Field names are: mailing_addrs_id billing_addrs_id street_addrs_id (in table qal_contact)
    @see qal_other_address_map_keys
} {
    set type_list [qal_address_type_keys]
    set name_list [qal_address_type_fields]
    set type_idx [lsearch -exact $type_list $address_type]
    set field_name [lindex $name_list $type_idx]
    return $field_name
}


ad_proc -private qal_customer_id_from_contact_id {
    contact_id
} {
    Returns customer_id of contact_id
    Returns an empty string if customer_id not found.
} {
    upvar 1 instance_id instance_id
    set id ""
    db_0or1row qal_customer_read_contact_id_1 {select id from qal_customer
        where contact_id=:contact_id
        and instance_id=:instance_id
        and trashed_p!='1'}
    return $id
}

ad_proc -private qal_vendor_id_from_contact_id {
    contact_id
} {
    Returns vendor_id of customer_id. 
    Returns an empty string if vendor_id not found.
} {
    upvar 1 instance_id instance_id
    set id ""
    db_0or1row qal_vendor_read_contact_id_1 {select id from qal_vendor
        where contact_id=:contact_id
        and instance_id=:instance_id
        and trashed_p!='1'}
return $id
}

ad_proc -private qac_extended_package_urls_get {
    {-accounts_receivables_vname ""}
    {-accounts_payables_vname ""}
    {-accounts_ledger_vname ""}
} {
    Assigns the variables with the url of package, if the package
    is installed and a package instance in the same subsite
    as accounts-contacts' instance. Otherwise sets the variables to empty
    string.
    <br><br>
    Returns 1 if any found, otherwise 0
} {
    # accounts-ledger is a common requirement of all three.
    # Don't need to check if it isn't installed.
    set found_p 0
    upvar 1 $accounts_receivables_vname ar_url
    upvar 1 $accounts_payables_vname ap_url
    upvar 1 $accounts_ledger_vname gl_url
    set ar_url ""
    set ap_url ""
    set gl_url ""
    if { [apm_package_installed_p accounts-ledger] } {
        set subsite_node_ids_list [subsite::util::packages -node_id [ad_conn node_id]]
        foreach n_id $subsite_node_ids_list {
            set pkg_key [apm_package_key_from_id $n_id]
            switch -exact -- $pkg_key {
                accounts-receivables {
                    set ar_p 1
                    set ar_url [apm_package_url_from_id $n_id]
                    set found_p 1
                }
                accounts-payables {
                    set ap_p 1
                    set ap_url [apm_package_url_from_id $n_id]
                    set found_p 1
                }
                accounts-ledger {
                    set gl_p 1
                    set gl_url [apm_package_url_from_id $n_id]
                    set found_p 1
                }
            }
        }
    }
    return $found_p
}

ad_proc -private qac_ar_button_defs_lol {
    {-accounts_receivables_url ""}
} {
    Returns button definitions for beginning actions
    in accounts-receivables package in same subsite
    from another package,
    where definitions work with qal_3g or qfo_2g procs.
    Button definitions return as a list of lists, or an empty list
    if url is empty string.
    
    @see qac_extended_package_urls_get
    @see qal_3g
    @see qfo_2g
} {
    if { $accounts_receivables_url ne "" } {
        # add buttons:
        # AR Transaction
        # Sales Invoice
        # Credit Invoice
        # POS invoice
        # Sales Order
        # Sales Quotation
        # Customer Pricelist
        set ar_btn_defs_lol [list \
                                 [list type submit name qf_ar_trans value "#accounts-ledger.AR_Transaction#" id qac-20200428a] \
                                 [list type submit name qf_inv_sales value "#accounts-ledger.Add_Sales_Invoice#" id qac-20200428b] \
                                 [list type submit name qf_inv_credit value "#accounts-ledger.Add_Credit_Invoice#" id qac-20200428c] \
                                 [list type submit name qf_inv_pos value "#accounts-ledger.Add_POS_Invoice#" id qac-20200428d] \
                                 [list type submit name qf_ord_sales value "#accounts-ledger.Add_Add_Sales_Order" id qac-20200428e] \
                                 [list type submit name qf_quote_sales value "#accounts-ledger.Add_Quotation#" id qac-20200428f] \
                                 [list type submit name qf_pricelist_c value "(#accounts-ledger.Customer#) #accounts-ledger.Pricelist#" id qac-20200428g] ]
    } else {
        set ar_btn_defs_lol [list ]
    }
    return $ar_btn_defs_lol
}

ad_proc -private qac_ar_buttons_transform {
    {-input_array_name ""}
    {-accounts_receivables_url ""}
} {
    Transforms, validates form inputs for buttons to boolean
    values and returns the relevant url for redirecting page.
} {
    set redirect_url ""
    if { $accounts_receivables_url ne "" } {
        upvar 1 $input_array_name f_arr
        set ar_trans_p [info exists f_arr(qf_ar_trans) ]
        set inv_sales_p [info exists f_arr(qf_inv_sales) ]
        set inv_credit_p [info exists f_arr(qf_inv_credit) ]
        set inv_pos_p [info exists f_arr(qf_inv_pos) ]
        set ord_sales_p [info exists f_arr(qf_ord_sales) ]
        set quote_sales_p [info exists f_arr(qf_quote_sales) ]
        set pricelist_c_p [info exists f_arr(qf_pricelist_c) ]

        append b $ar_trans_p $inv_sales_p $inv_credit_p
        append b $inv_pos_p $ord_sales_p $quote_sales_p $pricelist_c_p

        set redirect_url $accounts_receivables_url
        switch -exact -- $b {
            1000000 {
                append redirect_url "/transaction"
            }
            0100000 {
                append redirect_url "/invoice-sales"
            }
            0010000 {
                append redirect_url "/invoice-credit"
            }
            0001000 {
                append redirect_url "/invoice-pos"
            }
            0000100 {
                append redirect_url "/order-sales"
            }
            0000010 {
                append redirect_url "/quote-sales"
            }
            0000001 {
                append redirect_url "/pricelist-customer"
            }
            default {
                set redirect_url ""
            }
        }
    }
    return $redirect_url
}

ad_proc -private qac_ap_button_defs_lol {
    {-accounts_payables_url ""}
} {
    Returns button definitions for beginning actions
    in accounts-payables package in same subsite
    from another package,
    where definitions work with qal_3g or qfo_2g procs.
    Button definitions return as a list of lists, or an empty list
    if url is empty string.
    
    @see qac_extended_package_urls_get
    @see qal_3g
    @see qfo_2g
} {
    if { $accounts_payables_url ne "" } {
        # add buttons:
        # AP Transaction
        # Vendor Invoice
        # Purchase Order
        # Vendor Quotation
        # RFQ
        # Vendor Pricelist
        set ap_btn_defs_lol [list \
                                 [list type submit name qf_ap_trans value "#accounts-ledger.AP_Transaction\#" id qac-20200428n class "btn-big"] \
                                 [list type submit name qf_inv_vendor value "#accounts-ledger.Add_Vendor_Invoice\#" id qac-20200428o class "btn-big"] \
                                 [list type submit name qf_ord_purchase value "#accounts-ledger.Add_Purchase_Order\#" id qac-20200428p class "btn-big"] \
                                 [list type submit name qf_quote_vendor value "#accounts-ledger.Add_Vendor_Quote\#" id qac-20200428r class "btn-big"] \
                                 [list type submit name qf_quote_request value "#accounts-ledger.Add_Request_for_Quotation\#" id qac-20200428s class "btn-big"] \
                                 [list type submit name qf_pricelist_v value "(#accounts-ledger.Vendor#) #accounts-ledger.Pricelist\#" id qac-20200428t class "btn-big"] ]
    } else {
        set ap_btn_defs_lol [list ]
    }
    return $ap_btn_defs_lol
}

ad_proc -private qac_ap_buttons_transform {
    {-input_array_name ""}
    {-accounts_payables_url ""}
} {
    Transforms, validates form inputs for buttons to boolean
    values and returns the relevant url for redirecting page.
} {
    set redirect_url ""
    if { $accounts_payables_url ne "" } {
        upvar 1 $input_array_name f_arr
        set ap_trans_p [info exists f_arr(qf_ap_trans) ]
        set inv_vendor_p [info exists f_arr(qf_inv_vendor) ]
        set ord_purchase_p [info exists f_arr(qf_order_purchase) ]
        set quote_vendor_p [info exists f_arr(qf_quote_vendor) ]
        set quote_request_p [info exists f_arr(qf_quote_request) ]
        set pricelist_v_p [info exists f_arr(qf_pricelist_v) ]

        append b $ap_trans_p $inv_vendor_p $ord_purchase_p
        append b $quote_vendor_p $quote_request_p $pricelist_v_p

        set redirect_url $accounts_payables_url
        switch -exact -- $b {
            10000 {
                append redirect_url "/transaction"
            }
            01000 {
                append redirect_url "/invoice-vendor"
            }
            01000 {
                append redirect_url "/order-purchase"
            }
            00100 {
                append redirect_url "/quote-vendor"
            }
            00010 {
                append redirect_url "/quote-request"
            }
            00001 {
                append redirect_url "/pricelist-customer"
            }
            default {
                set redirect_url ""
            }
        }
    }
    return $redirect_url
}

ad_proc -private qac_al_button_defs_lol {
    {-accounts_ledger_url ""}
} {
    Returns button definitions for beginning actions
    in accounts-ledger package in same subsite
    from another package,
    where definitions work with qal_3g or qfo_2g procs.
    Button definitions return as a list of lists, or an empty list
    if url is empty string.
    
    @see qac_extended_package_urls_get
    @see qal_3g
    @see qfo_2g
} {
    if { $accounts_ledger_url ne "" } {
        # Vendor - to see contact's vendor record or make one
        # Customer - to see contact's customer record or make one
        set al_btn_defs_lol [list \
                                 [list type submit name qf_vendor value "#accounts-ledger.Vendor#" id qac-20200428x class "btn-big"] \
                                 [list type submit name qf_customer value "#accounts-ledger.Customer#" id qac-20200428y class "btn-big"] ]
    } else {
        set al_btn_defs_lol [list ]
    }
    return $al_btn_defs_lol
}

ad_proc -private qac_al_buttons_transform {
    {-input_array_name ""}
    {-accounts_ledger_url ""}
} {
    Transforms, validates form inputs for buttons to boolean
    values and returns the relevant url for redirecting page.
} {
    set redirect_url ""
    if { $accounts_ledger_url ne "" } {
        upvar 1 $input_array_name f_arr
        set vendor_p [info exists f_arr(qf_vendor) ]
        set customer_p [info exists f_arr(qf_customer) ]
        append b $vendor_p $customer_p

        set redirect_url $accounts_ledger_url
        switch -exact -- $b {
            10 {
                append redirect_url "/vendor"
            }
            01 {
                append redirect_url "/customer"
            }
            default {
                set redirect_url ""
            }
        }
    }
    return $redirect_url
}
