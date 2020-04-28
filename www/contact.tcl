set title "Contact"
set context [list $title]

# This is the page for modifying and displaying a single contact.

# unset instance_id for qc_set_instance_id
#unset instance_id
# defaults

set user_id [ad_conn user_id]
#unset instance_id
qc_set_instance_id
ns_log Notice "contact.tcl.11 instance_id '${instance_id}'"
# in accounts-contacts, differentiate org_contact_id from contact_id
set org_contact_id [qc_set_contact_id ]
ns_log Notice "contact.tcl.14 instance_id '${instance_id}'"
# contact_id is upvar'd by qc_set_contact_id. Here, it creates name conflict.
#unset contact_id, set it to "" for logging.
set contact_id ""






# no contact_id implies new contact

ns_log Notice "contact.tcl.30 instance_id '${instance_id}'"
set property_label [qc_parameter_get propertyLabel $instance_id "org_accounts"]


set user_read_p [qc_permission_p $user_id $org_contact_id $property_label read $instance_id]
set content_html ""

if { !$read_p } {
    set title "#q-control.You_don_t_have_permission#"
    ad_return_exception_page 404 $title $title
    ad_script_abort
}

set user_create_p [qc_permission_p $user_id $org_contact_id $property_label write $instance_id]
set user_write_p [qc_permission_p $user_id $org_contact_id $property_label write $instance_id]
set user_delete_p [qc_permission_p $user_id $org_contact_id $property_label delete $instance_id]

set input_array(qf_archive_p) ""
set input_array(qf_trash_p) ""
set input_array(contact_id) ""
set input_array(qf_write_p) ""

if { $user_write_p } {
    # Get input_array, so we can set the state of the buttons
    # and maybe perform some action before displaying another form.
    set form_submitted_p [qf_get_inputs_as_array input_array]

    # maybe trash or archive, but not both
    if { $input_array(qf_archive_p) ne 0 } {
        set input_array(qf_archive_p) 1
        
    } elseif { $input_array(qf_trash_p) ne 0 } {
        set input_array(qf_trash_p) 1
    }	      

    set qf_archive_p $input_array(qf_archive_p)
    set qf_trash_p $input_array(qf_trash_p)

    if { [qf_is_natural_number $input_array(id) ] } {
        set contact_id $input_array(id)
    } elseif { [qf_is_natural_number $input_array(contact_id) ] } {
        set contact_id $input_array(contact_id)
    }
    ns_log Notice "contact.tcl.71 contact_id '${contact_id}' "

    array unset input_array qf_archive_p
    array unset input_array qf_trash_p
    array unset input_array contact_id
    array unset input_array qf_write_p

    if { $qf_trash_p && $user_delete_p } {
        set success_p [qal_contact_trash $contact_id]
    } else {
        set record_nvl [qal_contact_read $contact_id $org_contact_id]
        ns_log Notice "contact.tcl.87 record_nvl '${record_nvl}'"
        #  id - this is contact_id
        #  rev_id *internal
        #  instance_id
        #  parent_id
        #  label
        #  name
        #  street_addrs_id
        #  mailing_addrs_id
        #  billing_addrs_id
        #  vendor_id
        #  customer_id
        #  taxnumber
        #  sic_code
        #  iban
        #  bic
        #  language_code
        #  currency
        #  timezone
        #  time_start
        #  time_end
        #  url
        #  user_id *
        #  created *
        #  created_by *
        #  trashed_p *
        #  trashed_by *
        #  trashed_ts *
        #  notes 
        foreach {n v} $record_nvl {
            set $n $v
        }
    }
    if { $qf_archive_p } {
        # update / close record
        # time is in standard date format.
        set input_array(time_end) [qf_clock_format [clock seconds]]
        set r_contact_id [qal_contact_write input_array]
        if { $contact_id eq "" } {
            append content_html "<p>#acs-tcl.lt_We_had_a_problem_proc# #acs-tcl.Succes_error_submitted#</p>"
            ns_log Warning "accounts-contacts/www/contact.tcl.157 unable to archive contact_id '${contact_id}"
        } else {
            ad_returnredirect contacts
            ad_script_abort
        }
        
    } elseif { $qf_trash_p } {
        set r_contact_id [qal_contact_trash $contact_id ]
        if { $contact_id eq "" } {
            set message "<p>#acs-tcl.lt_We_had_a_problem_proc# #acs-tcl.Succes_error_submitted#</p>"
            ns_log Warning "accounts-contacts/www/contact.tcl.157 unable to archive contact_id '${contact_id}"
            ad_returnredirect -message $message contacts
        } else {
            ad_returnredirect contacts
        }
        ad_script_abort
    }


    # set f_lol
    qal_contact_form_def -field_values_arr_name f_lol

    # add appropriate buttons to form defintion
    set f_buttons_lol [list \
                           [list type submit name save context content_c5 \
                                value "\#acs-kernel.common_save\#" datatype text html_before $html_before3 html_after $html_after label "" class "btn-big" action contact ] \
                           [list type submit name update context content_c5 \
                                value "\#acs-kernel.common_update\#" datatype text html_before $html_before3 html_after $html_after label "" class "btn-big" action contact ] \
                          ]

    if { $contact_id ne "" } {
        # Show button to edit contact record. No. Assumes one wants to edit here. Make a contact-view page to just see (with edit button)
        # Show button to archive contact record (by posting an end-date, default to today as end-date)
        # Show button to trash contact record
        # Show links to view/edit other addresses (separate from buttons)
        #
        # Sql-Ledger has other buttons:
        # AR Transaction, Sales Invoice, Credit Invoice, POS, Sales Order,
        # Quotation, Pricelist, New Number(copy to a new contact_id)
        # We're skipping New Number for now, because that's likely
        # mostly a patch for linear membership association.
        # This has built-in groups to increase managability and avoid copying.

        if { [apm_package_installed_p accounts-ledger] } {
            set subsite_node_ids_list [subsite::util::packages]
            
            foreach $n_id $subsite_node_ids_list {
                set pkg_key [apm_package_key_from_id $n_id]
                switch -exact -- $pkg_key {
                    accounts-receivables {
                        set accounts_receivables_p 1
                        set accounts_receivables_url [apm_package_url_from_id $n_id]
                        
                    }
                    accounts-payables {
                        set accounts_payables_p 1
                        set accounts_payables_url [apm_package_url_from_id $n_id]
                        
                    }
                    accounts-ledger {
                        set accounts_ledger_p 1
                        set accounts_ledger_url [apm_package_url_from_id $n_id]
                        
                    }
                    
                }
            }
        }


        if { $accounts_receivables_inst_p } {
            ### TODO
            # add buttons:
            # (Make these defs a proc, because they'll be peppered all over)
            # AR Transaction
            # Sales Invoice
            # Credit Invoice
            # POS
            # Sales Order
            # Sales Quotation
            # Customer Pricelist
        }
        set accounts_payables_inst_p [apm_package_installed_p accounts-payables]
        if { $accounts_payables_inst_p } {
            ### TODO
            # (Make these defs a proc, because they'll be peppered all over)
            # add buttons:
            # Vendor Pricelist
            # AP Transaction
            # Vendor Invoice
            # Purchase Order
            # Vendor Quotation
            # RFQ
        }

        set accounts_ledger_inst_p [apm_package_installed_p accounts-ledger]
        if { $accounts_ledger_inst_p } {
            ### TODO
            # (Make these defs a proc, because they'll be peppered all over)
            # Vendor - to see contact's vendor record or make one
            # Customer - to see contact's customer record or make one
        }
        
        set f_buttons_write_lol [list \
                                     [list name qf_archive_p value "#accounts-contacts.Archive#" id contact-20180826a action contact ] \
                                     [list name qf_trash_p value "#accounts-contacts.Trash#" id contact-20180826b action contact ] ]
    }

    qf_append_lol2_to_lol1 f_lol f2_lol

    ::qfo::form_list_def_to_array \
        -list_of_lists_name f_lol \
        -fields_ordered_list_name qf_fields_ordered_list \
        -array_name f_arr \
        -ignore_parse_issues_p 0


    set validated_p [qal_3g \
                         -form_id 20200427 \
                         -fields_ordered_list $qf_fields_ordered_list \
                         -fields_array f_arr \
                         -inputs_as_array input_array \
                         -form_submitted_p $form_submitted_p \
                         -dev_mode_p 1 \
                         -form_verify_varname "confirmed" \
                         -form_varname "content_c" \
                         -write_p $write_p ]




    if { $validated_p } {
        if { $contact_id eq "" } {
            qal_contact_create input_array
            ns_log Notice "accounts-contacts/www/contact.tcl creating contact: array get input_array '[array get input_array]'"
        } else {
            set contact_id [qal_contact_write input_array]
            ns_log Notice "accounts-contacts/www/contact.tcl writing contact_id '${contact_id}': array get input_array '[array get input_array]'"
        }
        rp_form_put contact_id $contact_id
    }
}


# notes on buttons
# if content_id & edit_p, then show form
# and update, cancel, post-as-new buttons

# if no content_id, show blank form and
# save, cancel buttons

# otherwise display data ( disabled form)
# and show edit button and other options..
# see AR/ AP buttons above.


