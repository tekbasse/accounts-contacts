set title "Contact'"
set context [list $title]

# This is the page for modifying and displaying addresses of a single contact.

# no contact_id should result in an error, contact not found.

# Display contact info, and a list of addresses that can be trashed/deleted



set user_id [add_conn user_id]
qc_set_instance_id
set property_label [qc_parameter_get propertyLabel $instance_id "org_accounts"]

set read_p [qc_permission_p $user_id "" $property_label read $instance_id]

if { $read_p } {

    set write_p [qc_permission_p $user_id "" $property_label write $instance_id]

    if { $write_p } {
	# Present form

    } else {
	# Present a view of form data

    }
}

