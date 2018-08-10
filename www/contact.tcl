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

if { $read_p } {

    # Form field definitions
    set f_lol [list \
		   [list name x datatype string label "x"] \
		  ]
	       

    # Get input_array.
    # Check to see if edit/add button pressed.
    ## NO. this should be an available default feature in qfo_2g
    ## when specifying -edit_button_p which sets var qf_edit_p 1 to edit.
    ## qf_edit_p is logical && with $write_p: no write, no edit
    
    set write_p [qc_permission_p $user_id "" $property_label write $instance_id]
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
			 -write_p $write_p ]		   
    
} else {
    set title "#q-control.You_don_t_have_permission#"
    ad_return_exception_page 404 $title $title
    ad_script_abort
}

