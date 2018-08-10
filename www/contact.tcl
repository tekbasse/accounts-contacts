set title "Contact'"
set context [list $title]

# This is the page for modifying and displaying a single contact.

# no contact_id implies new contact

set user_id [add_conn user_id]
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

# Form field definitions
set f_lol [list \
	       [list name x datatype string label "x"] \
	      ]



set write_p [qc_permission_p $user_id "" $property_label write $instance_id]


# default set qf_write_p 0
# Get input_array.
# If contact_id exists, show the contact if qf_write_p is 0
# If qf_write_p is 1 and contact_id exists, then edit
# If contact_id doesn't exist, show form if write_p is 1

# Scope qf_write_p to permissions of write_p
set qf_write_p [expr { $write_p && $qf_write_p } ]




# Grab contact_id from form_input
# If contact_id exists, read record




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
    qf_form form_id contact-20180810c action contact
    qf_input type hidden name contact_id value $contact_id
    qf_input type submit name submit value "#accounts-contact.edit_contact#"
    # Show buttons to manage addresses
    #
    qf_form form_id contact-20180810a action contact-addresses
    qf_input type hidden name contact_id value $contact_id
    qf_input type submit name submit value  "#accounts-contact.manage_street_addresses#"
    qf_form form_id contact-20180810b action contact-other-addresses
    qf_input type hidden name contact_id value $contact_id
    qf_input type submit name submit "#accounts-contact.manage_other_addresses#"
    qf_close
    append content_html [concat [qf_read ] "\n"]
}


