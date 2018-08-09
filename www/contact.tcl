set title "Contact'"
set context [list $title]

# This is the page for modifying and displaying a single contact.

# no contact_id implies new contact


set user_id [add_conn user_id]
set instance_id [add_conn package_id]
set property_label [parameter::get \
			-package_id $instance_id \
			-parameter property_label \
			-default "org_accounts" ]
set read_p [qc_permission_p $user_id "" $property_label read $instance_id]
		    
