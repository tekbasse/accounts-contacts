# accounts-contacts/www/contacts.tcl


set title "#accounts-contacts.Contacts#"
set context [list $title]


set content_html ""


set user_id [ad_conn user_id]
set instance_id [qc_set_instance_id]
# in accounts-contacts, differentiate org_contact_id from contact_id
set org_contact_id [qc_set_contact_id ]


# basic permission check to allow more precise permission error messages

set property_label [qc_parameter_get propertyLabel $instance_id "org_accounts"]

set read_p [qc_permission_p $user_id $org_contact_id $property_label read $instance_id]

if { !$read_p } {
    set title "#q-control.You_don_t_have_permission#"
    ad_return_exception_page 404 $title $title
    ad_script_abort
}

set input_array(s) "0"
set input_array(p) ""
set input_array(this_start_row) ""

set form_posted_p [qf_get_inputs_as_array input_array]

ns_log Notice "accounts-contacts/www/contacts.tcl instance_id ${instance_id} org_contact_id '${org_contact_id}' user_id '${user_id}' property_label '${property_label}'"

set contact_ids_list [qal_contact_ids ]

set contacts_lists [qal_contacts_read $contact_ids_list $org_contact_id]
ns_log Notice "accounts-contacts/www/contacts.tcl instance_id ${instance_id} contact_ids_list '${contact_ids_list}' contacts_lists '${contacts_lists}'"

# ordered list:
# id  rev_id  instance_id  parent_id  label  name  street_addrs_id  mailing_addrs_id  billing_addrs_id  vendor_id  customer_id  taxnumber  sic_code  iban  bic  language_code  currency  timezone  time_start  time_end  url  user_id  created  created_by  trashed_p  trashed_by  trashed_ts  notes

# extract just the columns for viewing, and create table_lists
set table_lists [list ]
foreach c_list $contacts_lists {
    lassign $c_list id rev_id instance_id parent_id label name street_addrs_id mailing_addrs_id billing_addrs_id vendor_id customer_id taxnumber sic_code iban bic language_code currency timezone time_start time_end url user_id created created_by trashed_p trashed_by trashed_ts notes
    set view_button [qf_button_form action contact name view value "#acs-kernel.common_View#" name contact_id value $id ]
    ns_log Notice "view_button '${view_button}'"
    set t_list [list $label $name $taxnumber $sic_code $iban $bic $language_code $currency $timezone $time_start $time_end $url $view_button ]
    lappend table_lists $t_list
}


set titles_list [list "#accounts-contacts.label#" "#accounts-contacts.name#" "#accounts-contacts.taxnumber#" "#accounts-contacts.sic_code#" "#accounts-contacts.iban#" "#accounts-contacts.bic#" "#accounts-contacts.language_code#" "#accounts-contacts.currency#" "#accounts-contacts.timezone#" "#accounts-contacts.time_start#" "#accounts-contacts.time_end#" "#accounts-contacts.url#" "#accounts-contacts.notes#" ]

set sort_type_list [list -ascii -ascii -ascii -ascii -ascii -ascii -ascii -ascii -ascii -ascii -ascii -ascii -ignore ]

qfo_sp_table_g2 \
    -nav_current_pos_html_varname nav_current_html \
    -nav_next_links_html_varname nav_next_html \
    -nav_prev_links_html_varname nav_prev_html \
    -p_varname input_array(p) \
    -s_varname input_array(s) \
    -sort_type_list $sort_type_list \
    -table_html_varname table_html \
    -table_lists_varname table_lists \
    -this_start_row $input_array(this_start_row) \
    -titles_list_varname titles_list \
    -titles_html_list_varname titles_html_list

append content_html $nav_prev_html "&nbsp;" $nav_current_html "&nbsp;" $nav_next_html
set br [qf_element tag br]
append content_html $br $br
append content_html {<a href="contacts">#acs-kernel.common_reset#</a>}
append content_html $br $br
append content_html $table_html
