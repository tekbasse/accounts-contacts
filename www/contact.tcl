# Modify or display a single contact.

set title "Contact"
set context [list $title]


set user_id [ad_conn user_id]
# unset instance_id for qc_set_instance_id
qc_set_instance_id
ns_log Notice "contact.tcl.11 instance_id '${instance_id}'"

# In accounts-contacts,
# differentiate user's org_contact_id from contact_id
# org_contact_id is the contact_id of the user
# contact_id is the contact_id in focus
set org_contact_id [qc_set_contact_id ]
set contact_id ""
# contact_id is upvar'd by qc_set_contact_id. Here, it creates name conflict.
#unset contact_id, set it to "" for logging.

set property_label [qc_parameter_get propertyLabel $instance_id "org_accounts"]

set user_read_p [qc_permission_p $user_id $org_contact_id $property_label read $instance_id]
set content_html ""

if { !$user_read_p } {
    set title "#q-control.You_don_t_have_permission#"
    ad_return_exception_page 401 $title $title
    ad_script_abort
}
set user_create_p [qc_permission_p $user_id $org_contact_id $property_label create $instance_id]
set user_write_p [qc_permission_p $user_id $org_contact_id $property_label write $instance_id]
set user_delete_p [qc_permission_p $user_id $org_contact_id $property_label delete $instance_id]

    
set form_submitted_p [qf_get_inputs_as_array input_array]


set save_exists_p [info exists input_array(save)]
set update_exists_p [info exists input_array(update)]
set cancel_exists_p [info exists input_array(cancel)]
set save_as_new_exists_p [info exists input_array(save_as_new)]
set qf_id_exists_p [info exists input_array(id)]
set qf_contact_id_exists_p [info exists input_array(contact_id) ]
set qf_trash_p [info exists input_array(qf_trash_p) ]
set qf_archive_p [info exists input_array(qf_archive_p) ]
set contact_id_exists_p 0
if { $qf_id_exists_p || $qf_contact_id_exists_p } {
    if { [qf_is_natural_number $input_array(id) ] } {
        set contact_id $input_array(id)
        set contact_id_exists_p 1
    } elseif { [qf_is_natural_number $input_array(contact_id) ] } {
        set contact_id $input_array(contact_id)
        set contact_id_exists_p 1
    }
    ns_log Notice "contact.tcl.71 contact_id '${contact_id}' "
}
set contact_rec_get_p 0
if { $contact_id_exists_p \
         && !( $save_exists_p || $update_exists_p || $save_as_new_p ) } {
    set contact_rec_get_p 1
}

if { ( $qf_trash_p || $qf_archive_p ) && !$user_delete_p } {
    set title "#q-control.You_don_t_have_permission#"
    ad_return_exception_page 401 $title $title
    ad_script_abort
}

#
# Actions before validation
#
    
append a $qf_trash_p $qf_archive_p $contact_rec_get_p $contact_id_exists_p
set redirect_url ""
switch -exact -- $a {
    0011 {
        # Defer other actions until after form validates.
        set record_nvl [qal_contact_read $contact_id $org_contact_id]
        ns_log Notice "contact.tcl.87 record_nvl '${record_nvl}'"
        foreach {n v} $record_nvl {
            set input_array(${n}) ${v}
        }
    }
    0101 {
        if { $input_array(time_end) eq "" } { 
            set input_array(time_end) [qf_clock_format [clock seconds]]
        }
        set r_contact_id [qal_contact_write input_array]
        if { $r_contact_id eq "" } {
            append content_html "<p>#acs-tcl.lt_We_had_a_problem_proc# #acs-tcl.Succes_error_submitted#</p>"
            ns_log Warning "accounts-contacts/www/contact.tcl.98 unable to archive contact_id '${contact_id}"
        } else {
            set redirect_url "index"
        }
    }
    1001  {
        set success_p [qal_contact_trash $contact_id]
        if { $success_p eq "" } {
            set message "<p>#acs-tcl.lt_We_had_a_problem_proc# #acs-tcl.Succes_error_submitted#</p>"
            ns_log Warning "accounts-contacts/www/contact.tcl.85 unable to trash contact_id '${contact_id}"
            ad_returnredirect -message $message contacts
        } else {
            set redirect_url "index"
        }
        ad_script_abort
    }
}

set html_before1 { <div class="grid-2 m-grid-6 s-grid-12"><div class="content-box">}
set html_before2 { <div class="grid-2 m-grid-3 s-grid-6"><div class="content-box">}
set html_before3 { <div class="grid-6 m-grid-6 s-grid-6"><div class="content-box">}
set html_after {</div></div>}

qal_contact_form_def -field_values_lol_name f_lol

set f_buttons_lol [list \
                       [list type submit name save context content_c5 value "\#accounts-contacts.Save\#" datatype text html_before $html_before3 html_after $html_after label "" class "btn-big"] \
                       [list type submit name cancel context content_c5 value "\#acs-kernel.common_cancel\#" datatype text html_before $html_before3 html_after $html_after label "" class "btn-big" ] ]


# context_c6 displayed based on .adp logic
set btn_update_lol [list \
                        [list type submit name update context content_c6 value "\#accounts-contacts.Update\#" datatype text html_before $html_before3 html_after $html_after label "" class "btn-big" ] \
                        [list type submit name save_as_new context content_c6 value "\#accounts-contacts.Save_as_new\#" datatype text html_before $html_before3 html_after $html_after label "" class "btn-big"] \
                        [list type submit name qf_archive_p value "#accounts-contacts.Archive#" id contact-20180826a context content_c6 class "btn-big"] ]
if { $user_delete_p } {
    set f_btns_trash_archive_lol [list \
                                      [list type submit name qf_trash_p value "#accounts-contacts.Trash#" id contact-20180826b context content_c6 class "btn-big"] ]
    qf_append_lol f_buttons_lol $f_btns_trash_archive_lol
}
qac_extended_package_urls_get \
    -accounts_receivables_vname ar_pkg_url \
    -accounts_payables_vname ap_pkg_url \
    -accounts_ledger_vname al_pkg_url
qf_append_lol f_buttons_lol $btn_update_lol
qf_append_lol f_buttons_lol [qac_ar_button_defs_lol \
                                 -accounts_receivables_url $ar_pkg_url]
qf_append_lol f_buttons_lol [qac_ap_button_defs_lol \
                                 -accounts_payables_url $ap_pkg_url]
qf_append_lol f_buttons_lol [qac_al_button_defs_lol \
                                 -accounts_ledger_url $al_pkg_url]

qf_append_lol f_lol $f_buttons_lol

::qfo::array_set_form_list \
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
                     -write_p $user_write_p ]

if { $validated_p } {

    #
    #  Actions after validation
    #
    
    if { $contact_id eq "" || $save_as_new_p } {
        set contact_id [qal_contact_create input_array]
        ns_log Notice "accounts-contacts/www/contact.tcl.160 creating contact: array get input_array '[array get input_array]'"
    } else {
        set new_contact_id [qal_contact_write input_array]
        if { $new_contact_id ne $contact_id } {
            ns_log Warning "accounts-contacts/www/contact.tcl.164 contact_id '${contact_id}' new_contact_id '${new_contact_id}' are different. Should be same."
        }
    }

    if { $redirect_url eq "" } {
        set redirect_url [qac_ar_buttons_transform \
                              -input_array_name input_array \
                              -accounts_receivables_url $ar_pkg_url]
    }
    if { $redirect_url eq "" } {
        set redirect_url [qac_ap_buttons_transform \
                              -input_array_name input_array \
                              -accounts_payables_url $ap_pkg_url]
    }
    if { $redirect_url eq "" } {
        set redirect_url [qac_al_buttons_transform \
                              -input_array_name input_array \
                              -accounts_ledger_url $al_pkg_url]
    }
    if { $redirect_url ne "" } {
        rp_form_put contact_id $contact_id
        rp_internal_redirect $redirect_url
        ad_script_abort
    }
}
