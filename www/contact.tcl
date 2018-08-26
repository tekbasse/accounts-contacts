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
set input_array(qf_counter) 0


# Get input_array.
set form_submitted_p [qf_get_inputs_as_array input_array]
if { $input_array(qf_write_p) ne 0 } {
    # Compensate for internationalization of value, convert to 1
    # Edit mode
    set qf_write_p 1
} else {
    set qf_write_p 0
    # maybe trash or archive, but not both
    if { $input_array(qf_archive_p) ne 0 } {
	set input_array(qf_archive_p) 1

    } elseif { $input_array(qf_trash_p) ne 0 } {
	set input_array(qf_trash_p) 1
    }	      
}
set qf_archive_p $input_array(qf_archive_p)
set qf_trash_p $input_array(qf_trash_p)

if { [qf_is_natural_number $input_array(id) ] } {
    set contact_id $input_array(id)
} elseif { [qf_is_natural_number $input_array(contact_id) ] } {
    set contact_id $input_array(contact_id)
}
ns_log Notice "accounts-contacts/www/contact.tcl.91 contact_id '${contact_id}'"
if {[catch { set qf_counter [expr { $input_array(qf_counter) + 1 } ] } ] } {
    ns_log Warning "accounts-contacts/www/contact.tcl qf_counter + 1 error, qf_counter '${qf_counter}'. Reset to 0"
    set qf_counter 0
}
array unset input_array qf_archive_p
array unset input_array qf_trash_p
array unset input_array contact_id
array unset input_array qf_write_p
# Scope qf_write_p to permissions of write_p
set qf_write_p [expr { $write_p && $qf_write_p } ]


# Form field definitions
set disabled_p [expr { !$qf_write_p } ]

ns_log Notice "contact.tcl.71 contact_id '${contact_id}' "

ns_log Notice "contact.tcl.73 qf_write_p '${qf_write_p}' disabled_p '${disabled_p}' qf_counter '${qf_counter}' form_submitted_p '${form_submitted_p}' instance_id '${instance_id}'"
if { $qf_counter < 2 } {

    if { $form_submitted_p eq 1 && $qf_counter < 2 && $contact_id ne "" } {
	set form_submitted_p 0	
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
    } elseif { $form_submitted_p eq 0 && $contact_id eq "" && $write_p } {
	# Force to show a new record form
	set qf_write_p 1
    }
}



set f_lol [list \
	       [list name qf_write_p form_tag_type input type hidden value 1 ] \
	       [list name qf_counter form_tag_type input type hidden value $qf_counter ] \
	       [list name id form_tag_type input type hidden value $contact_id ] \
	       [list name rev_id form_tag_type input type hidden value $rev_id ] \
	       [list name instance_id form_tag_type input type hidden value $instance_id ] \
	       [list name parent_id form_tag_type input type hidden value $parent_id ] \
	       [list name street_addrs_id form_tag_type input type hidden value $street_addrs_id ] \
	       [list name mailing_addrs_id form_tag_type input type hidden value $mailing_addrs_id ] \
	       [list name billing_addrs_id form_tag_type input type hidden value $billing_addrs_id ] \
	       [list name vendor_id form_tag_type input type hidden value $vendor_id ] \
	       [list name customer_id form_tag_type input type hidden value $customer_id ] \
	       [list name label datatype text_nonempty maxlength 40 label "Label" value $label] \
	       [list name taxnumber datatype text maxlength 32 label "taxnumber" value $taxnumber ] \
	       [list name sic_code datatype text maxlength 15 label "SIC Code" value $sic_code] \
	       [list name iban datatype text maxlength 34 label "IBAN" value $iban] \
	       [list name bic datatype text maxlength 34 label "BIC" value $bic] \
	       [list name language_code datatype text maxlength 6 label "Language Code" value $language_code] \
	       [list name currency datatype text maxlength 3 label "Currency Code" value $currency] \
	       [list name timezone datatype text size 40 maxlength 100 label "Timezone" value $timezone ] \
	       [list name time_start datatype timestamp label "Time Start" value $time_start ] \
	       [list name time_end datatype timestamp label "Time End" value $time_end ] \
	       [list name url datatype url size 40 maxlength 200 label "URL" value $url] \
	       [list name notes datatype html_text cols 40 rows 5 label "Notes" value $notes] \
	       [list type submit name submit value "#acs-kernel.common_Save#" datatype text_nonempty label "" disabled $disabled_p] \
	      ]

::qfo::form_list_def_to_array \
    -list_of_lists_name f_lol \
    -fields_ordered_list_name qf_fields_ordered_list \
    -array_name f_arr \
    -ignore_parse_issues_p 0


set validated_p [qfo_2g \
		     -form_id 20180809 \
		     -fields_ordered_list $qf_fields_ordered_list \
		     -fields_array f_arr \
		     -inputs_as_array input_array \
		     -form_submitted_p $form_submitted_p \
		     -form_varname content_html \
		     -multiple_key_as_list 1 \
		     -write_p $qf_write_p ]		   


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

ns_log Notice "accounts-contacts/www/contact.tcl array get input_array '[array get input_array]'"
ns_log Notice "accounts-contacts/www/contact.tcl validated_p '${validated_p}'"
ns_log Notice "accounts-contacts/www/contact.tcl f_lol '${f_lol}'"

if { $validated_p } {
    if { $contact_id eq "" } {
	qal_contact_create input_array
	ns_log Notice "accounts-contacts/www/contact.tcl creating contact: array get input_array '[array get input_array]'"
    } else {
	set contact_id [qal_contact_write input_array]
	ns_log Notice "accounts-contacts/www/contact.tcl writing contact_id '${contact_id}': array get input_array '[array get input_array]'"
    }
    rp_form_put contact_id $contact_id
    rp_form_put qf_counter 0
    rp_form_put qf_write_p 0
    rp_internal_redirect contact
    
}
