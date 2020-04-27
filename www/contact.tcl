set title "Contact"
set context [list $title]

# This is the page for modifying and displaying a single contact.

# unset instance_id for qc_set_instance_id
#unset instance_id
# defaults
foreach k [qal_contact_keys ] {
    set input_array(${k}) ""
    set $k ""
}

set user_id [ad_conn user_id]
unset instance_id
qc_set_instance_id
ns_log Notice "contact.tcl.11 instance_id '${instance_id}'"
# in accounts-contacts, differentiate org_contact_id from contact_id
set org_contact_id [qc_set_contact_id ]
ns_log Notice "contact.tcl.14 instance_id '${instance_id}'"
# contact_id is upvar'd by qc_set_contact_id. Here, it creates name conflict.
#unset contact_id, set it to "" for logging.
set contact_id ""



set input_array(contact_id) ""


# no contact_id implies new contact

ns_log Notice "contact.tcl.30 instance_id '${instance_id}'"
set property_label [qc_parameter_get propertyLabel $instance_id "org_accounts"]


set read_p [qc_permission_p $user_id $org_contact_id $property_label read $instance_id]
set content_html ""

if { !$read_p } {
    set title "#q-control.You_don_t_have_permission#"
    ad_return_exception_page 404 $title $title
    ad_script_abort
}

set write_p [qc_permission_p $user_id $org_contact_id $property_label write $instance_id]

#
# If contact_id exists, and if qf_write_p is 0 , then show contact
# If contact_id exists, and if qf_write_p is 1 , then edit contact
# If contact_id doesn't exist, show form if write_p is 1
set input_array(qf_write_p) 0
# If qf_trash_p is not 0 , trash contact_id
set input_array(qf_trash_p) 0
# If qf_archive_p is not 0, archive contact_id
set input_array(qf_archive_p) 0

#
# How to force qfo_g2 to present the form,
# even if validated due to form_submitted_p?
# One way is to have a form_submission counter.
# This preserves the option to use hash_check with the form at some point.
# On first form submit, validation is always 0, when write_p is used.
# Which means we need to know if the variable write_p is referred to exists.
# set input_array(qf_counter) 0
# qal_3g offers this by default. 

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

if { $qf_trash_p } {
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
        set form_submitted_p 1
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
# add appropriate buttons to form defintion
if { !$qf_write_p && $write_p } {
    if { $contact_id ne "" } {

        # Show button to edit contact record
        append content_html [qf_button_form \
                                 name qf_write_p \
                                 value "#accounts-contacts.Edit#" \
                                 id contact-20180810c \
                                 id contact-20180810c \
                                 action contact \
                                 name contact_id \
                                 value $contact_id ]
        
        # Show button to archive contact record
        append content_html [qf_button_form \
                                 name qf_archive_p \
                                 value "#accounts-contacts.Archive#" \
                                 id contact-20180826a \
                                 id contact-20180826a \
                                 action contact \
                                 name contact_id \
                                 value $contact_id ]
        
        # Show button to trash contact record
        append content_html [qf_button_form \
                                 name qf_trash_p \
                                 value "#accounts-contacts.Trash#" \
                                 id contact-20180826b \
                                 id contact-20180826b \
                                 action contact \
                                 name contact_id \
                                 value $contact_id ]
        
        # Show buttons to manage addresses
        #
        append content_html "<h2>#accounts-contacts.Street_addresses#</h2>"
        append content_html [qf_button_form \
                                 name submit \
                                 value "#acs-kernel.common_View#" \
                                 id contact-20180810a \
                                 action contact-addresses \
                                 name contact_id \
                                 value $contact_id ]
        append content_html "<h2>#accounts-contacts.Other_addresses#</h2>"
        append content_html [qf_button_form \
                                 id contact-20180810b \
                                 action contact-other-addresses \
                                 name submit \
                                 value "#acs-kernel.common_View#" \
                                 name contact_id \
                                 value $contact_id ]
    }
}

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
