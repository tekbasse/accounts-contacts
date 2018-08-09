# accounts-contacts/www/tickets.tcl


set title "#accounts-contacts.contact#"
set context [list $title]


set content_html ""

set instance_id [qc_set_instance_id]
set user_id [ad_conn user_id]
# basic permission check to allow more precise permission error messages
set read_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege read]

#qc_permission_p user_id contact_id property_label privilege instance_id 
#set read_p \[qc_permission_p $user_id $contact_id non_assets read $instance_id\]
#set create_p \[qc_permission_p $user_id $contact_id non_assets create $instance_id\]
#set write_p \[qc_permission_p $user_id $contact_id non_assets write $instance_id\]
#set admin_p \[qc_permission_p $user_id $contact_id non_assets admin $instance_id\]
#set delete_p \[qc_permission_p  $user_id $contact_id non_assets delete $instance_id\]

set user_message_list [list ]


set contact_ids_list [qc_contact_ids_for_user $user_id $instance_id]

# This page displays a list of contacts, and
# accepts input to trash or delete one or more contacts.
