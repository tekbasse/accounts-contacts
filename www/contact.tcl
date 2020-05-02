set title "Contact"
set context [list $title]

# This is the page for modifying and displaying a single contact.



# defaults

set user_id [ad_conn user_id]
# unset instance_id for qc_set_instance_id
qc_set_instance_id
ns_log Notice "contact.tcl.11 instance_id '${instance_id}'"


# in accounts-contacts, differentiate org_contact_id from contact_id
# org_contact_id  is the contact_id of the user
# contact_id is the contact_id of editable data in focus
set org_contact_id [qc_set_contact_id ]
# contact_id is upvar'd by qc_set_contact_id. Here, it creates name conflict.
#unset contact_id, set it to "" for logging.
set contact_id ""



set property_label [qc_parameter_get propertyLabel $instance_id "org_accounts"]

set user_read_p [qc_permission_p $user_id $org_contact_id $property_label read $instance_id]
set content_html ""

if { !$read_p } {
    set title "#q-control.You_don_t_have_permission#"
    ad_return_exception_page 404 $title $title
    ad_script_abort
}



set user_create_p [qc_permission_p $user_id $org_contact_id $property_label create $instance_id]
set user_write_p [qc_permission_p $user_id $org_contact_id $property_label write $instance_id]

if { $user_write_p || $user_create_p } {
    
    set user_delete_p [qc_permission_p $user_id $org_contact_id $property_label delete $instance_id]

    if { $user_write_p } {
        set input_array(id) ""
        set input_array(contact_id) ""
        # Get input_array, so we can set the state of the buttons
        # and maybe perform some action before displaying another form.
        set form_submitted_p [qf_get_inputs_as_array input_array]
        # no contact_id from form input implies new contact
        set contact_id_exists_p 0
        if { [qf_is_natural_number $input_array(id) ] } {
            set contact_id $input_array(id)
            set contact_id_exists_p 1
        } elseif { [qf_is_natural_number $input_array(contact_id) ] } {
            set contact_id $input_array(contact_id)
            set contact_id_exists_p 1
        }
        ns_log Notice "contact.tcl.71 contact_id '${contact_id}' "

        #
        # Actions
        #
        
        # maybe trash or archive, but not both
        # Put actions in a switch
        append a $qf_trash_p $qf_archive_p $contact_id_exists_p

        switch -exact $a {
            101  {
                set success_p [qal_contact_trash $contact_id]
                if { $contact_id eq "" } {
                    set message "<p>#acs-tcl.lt_We_had_a_problem_proc# #acs-tcl.Succes_error_submitted#</p>"
                    ns_log Warning "accounts-contacts/www/contact.tcl.157 unable to archive contact_id '${contact_id}"
                    ad_returnredirect -message $message contacts
                } else {
                    ad_returnredirect contacts
                }
                ad_script_abort
            }
            011 {
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
            }
            001 {
                # If contact_id exists, update data, then
                # check if an action needs to be done and pass
                # the contact_id instead of displaying form again.
                
                # Are there ny actions that should be taken before
                # or instead of rendering form ?
                
                qac_extended_package_urls_get \
                    -accounts_receivables_vname ar_pkg_url \
                    -accounts_payables_vname ap_pkg_url \
                    -accounts_ledger_vname al_pkg_url
        
                set qf_archive_p [info exists input_array(qf_archive_p)]
                set qf_trash_p [info exists input_array(qf_trash_p)]    
                set redirect_url [qac_ar_buttons_transform \
                                      -input_array_name input_array \
                                      -accounts_receivables_url $ar_pkg_url]
                set redirect_url [qac_ap_buttons_transform \
                                      -input_array_name input_array \
                                      -accounts_payables_url $ap_pkg_url]
                set redirect_url [qac_al_buttons_transform \
                                      -input_array_name input_array \
                                      -accounts_ledger_url $al_pkg_url]
                
                set record_nvl [qal_contact_read $contact_id $org_contact_id]
                ns_log Notice "contact.tcl.87 record_nvl '${record_nvl}'"
                foreach {n v} $record_nvl {
                    set $n $v
                }
            }

        }
        

    }

    qal_contact_form_def -field_values_arr_name f_lol

    # add appropriate buttons to form defintion
    set f_buttons_lol [list \
                           [list type submit name save context content_c5 \
                                value "\#acs-kernel.common_save\#" datatype text html_before $html_before3 html_after $html_after label "" class "btn-big" action contact ] ]
    
    if { $contact_id ne "" } {
        set btn_update [list type submit name update context content_c5 \
                            value "\#acs-kernel.common_update\#" datatype text html_before $html_before3 html_after $html_after label "" class "btn-big" action contact ]
        lappend f_buttons_lol $btn_update
        if { $delete_p } {
            # todo
            # Show button to archive contact record
            #  (by posting an end-date, default to today as end-date)
            # Show button to trash contact record
            set f_btns_trash_archive_lol [list \
                                         [list name qf_archive_p value "#accounts-contacts.Archive#" id contact-20180826a action contact ] \
                                         [list name qf_trash_p value "#accounts-contacts.Trash#" id contact-20180826b action contact ] ]
        }


    }

    # Show button to edit contact record. No.
    # Assume one wants to edit here.

    # Todo
    # Make a contact-view page to just see (with no edit button)
    # for printouts and the like. Have the logo or something an anchor
    # to click back out..
        
        # Show links to view/edit other addresses (separate from buttons)
        #
        # Sql-Ledger has other buttons:
        # AR Transaction, Sales Invoice, Credit Invoice, POS, Sales Order,
        # Quotation, Pricelist, New Number(copy to a new contact_id)
        # We're using "save as new"
    qac_ar_button_defs_lol -accounts_receivables_url $ar_pkg_url
    qac_ap_button_defs_lol -accounts_paybables_url $ap_pkg_url
    qac_al_button_defs_lol -accounts_ledger_url $al_pkg_url
        

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


