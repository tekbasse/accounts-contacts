set title "Contact'"
set context [list $title]

# This is the page for modifying and displaying a single contact.

# no contact_id implies new contact


set user_id [add_conn user_id]
qc_set_instance_id
set property_label [qc_parameter_get PropertyLabel $instance_id "org_accounts"]

set read_p [qc_permission_p $user_id "" $property_label read $instance_id]
		    
if { $read_p } {


    set write_p [qc_permission_p $user_id ""
