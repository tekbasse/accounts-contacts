# accounts-contacts/www/contacts.tcl


set title "#accounts-contacts.contacts#"
set context [list $title]


set content_html ""

set instance_id [qc_set_instance_id]
set user_id [ad_conn user_id]
# basic permission check to allow more precise permission error messages
set read_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege read]

if { !$read_p } {
    set title "#q-control.You_don_t_have_permission#"
    ad_return_exception_page 404 $title $title
    ad_script_abort
}

set contact_ids_list [qc_contact_ids_for_user $user_id $instance_id]

set sort_type_list ##code
set table_lists ##

qfo_sp_table_g2 \
    -nav_prev_links_html_varname nav_prev_html \
    -nav_current_pos_html_varname nav_current_html \
    -nav_next_links_html_varname nav_next_html \
    -table_lists_varname table_lists \
    -table_html_varname table_html \
    -titles_list_varname titles_list \
    -titles_reordered_html_list_varname titles_reordered_html \
    -sort_type_list $sort_type_list
    -s_varname input_array(s) \
    -p_varname input_array(p) 
