set title "Contact'"
set context [list $title]

# This is the page for modifying and displaying a single contact.

# no contact_id implies new contact

set user_id [ad_conn user_id]
qc_set_instance_id
set property_label [qc_parameter_get propertyLabel $instance_id "org_accounts"]

set write_p 0
set read_p [qc_permission_p $user_id "" $property_label read $instance_id]
set content_html ""

if { !$read_p } {
        set title "#q-control.You_don_t_have_permission#"
    ad_return_exception_page 404 $title $title
    ad_script_abort
}

set write_p [qc_permission_p $user_id "" $property_label write $instance_id]

# defaults
set input_array(qf_write_p) 0
set input_array(contact_id) ""
# Get input_array.
qf_get_inputs_as_array input_array
if { $input_array(qf_write_p) ne 0 } {
    # Compensate for internationalization of value, convert to 1
    set qf_write_p 1
} else {
    set qf_write_p 0
}

set contact_id $input_array(contact_id)
if { $contact_id ne "" } {
    set contact_list [qal_contact_read $contact_id]
}

# If contact_id exists, show the contact if qf_write_p is 0
# If qf_write_p is 1 and contact_id exists, then edit
# If contact_id doesn't exist, show form if write_p is 1

# Scope qf_write_p to permissions of write_p
set qf_write_p [expr { $write_p && $qf_write_p } ]

# Form field definitions
set f_lol [list \
	       [list name id $contact_id datatype text] \
	       [list name label datatype text_nonempty] \
	       [list name name datatype text_nonempty] \
	       [list name 
	      ]
##code



::qfo::form_list_def_to_array \
    -list_of_lists_name f_lol \
    -fields_ordered_list_name qf_fields_ordered_list \
    -array_name input_array \
    -ignore_parse_issues_p 0

set validated_p [qfo_2g \
		     -form_id 20180809 \
		     -fields_ordered_list $qf_fields_ordered_list \
		     -fields_array input_array \
		     -form_varname content_html \
		     -multiple_key_as_list 1 \
		     -write_p $qf_write_p ]		   


if { !$qf_write_p && $contact_id ne "" && $write_p } {
    # Show button to edit contact record
    set b1_ol [list \
		   name qf_write_p \
		   value "#accounts-contact.edit_contact#" \
		   form_id contact-20180810c \
		   action contact \
		   name contact_id \
		   value $contact_id ]
    append content_html [qf_one_button_form $b1_ol ]

    # Show buttons to manage addresses
    #
    set b2_ol [list \
		   name submit \
		   value  "#accounts-contact.manage_street_addresses#" \
		   form_id contact-20180810a \
		   action contact-addresses \
		   name contact_id \
		   value $contact_id ]
    append content_html [qf_one_button_form $b2_ol ]
    set b3_ol [list \
		   form_id contact-20180810b \
		   action contact-other-addresses \
		   name submit \
		   value "#accounts-contact.manage_other_addresses#" \
		   name contact_id \
		   value $contact_id ]
    append content_html [qf_one_button_form $b3_ol]
    
}


