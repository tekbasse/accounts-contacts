#accounts-contacts/tcl/cs-view-procs.tcl
ad_library {

    views for accounts-contacts
    @creation-date 7 Aug 2018
    @Copyright (c) 2018 Benjamin Brink
    @license GNU General Public License 2
    @project home: http://github.com/tekbasse/accounts-contacts
    
}



ad_proc -private cs_contact_reps_of_cat {
    args
} {
    Returns user_ids of arg: contact_id that are associate with category as a list.
    <br/>
    contact_id is contact's contact_id from qal_contacts.
    <br/>
    <code>args</code> can be passed as name value list. Minimum required is contact_id and a category reference:
    <br/>
    Accepted cs_categories.names are: <code>category_id</code>, <code>parent_id</code>, and <code>label</code>.
    <br/>
    Privilege is one of read,write,create,delete,admin. Default is write.
    <br/>
    If there is an error, an empty list is returned.
} {
    upvar 1 instance_id instance_id
    # cs_contact_reps_of_cat and cs_support_reps_of_cat are separate, because
    # this is a place where one or the other may be modified,
    # and modification becomes more difficult if these use a single call point.
    set user_ids_list [list ]
    set assigned_uids_list [list ]
    set privilege "write"
    qf_nv_list_to_vars $args [list category_id parent_id label contact_id privilege]

    # if category_id not avail, try parent_id as cateogry_id
    # if that is not avail, try label.
    if { ![qf_is_natural_number $category_id] } {
        if { [qf_is_natural_number $parent_id ] } {
            set cat_id $parent_id
        } elseif { $label ne "" } {
            set cat_id [cs_cat_id_of_label $label]
        }
    } else {
        set cat_id $category_id
    }
    if { $cat_id ne "" } {
        set property_label [cs_cat_cc_property_label $cat_id]
        
        if { $property_label ne "" } {
            # convert to property_id
            set property_id [qc_property_id $property_label $instance_id]
            
            if { $property_id ne "" } {
                set role_ids_list [qc_roles_of_prop_priv $property_id $privilege]
                
                if { [llength $role_ids_list] > 0 } {
                    # get user_ids limited by hf_role_id in one query
                    set user_ids_list [qc_user_ids_of_contact_id $contact_id $role_ids_list]
                } else {
                    ns_log Notice "cs_contact_reps_of_cat: property_id '${property_id}' privilege '${privilege}'. no role_id found."

                }
            } else {
                ns_log Notice "cs_contact_reps_of_cat: property_label '${property_label}' not found. property_id is blank."
            }
        } else {
            ns_log Notice "cs_contact_reps_of_cat: cat_id '${cat_id}' not found. property_label is blank."
        }
    } else {
        ns_log Notice "cs_contact_reps_of_cat: category_id not found. category_id '${category_id} parent_id '${parent_id}' category label '${label}'"
    }
    # add user_ids from cs_cat_assignment_map
    set cc_uids_list [db_list cs_contact_rep_cat_map_read {select user_id from cs_contact_rep_cat_map 
        where category_id=:category_id 
        and instance_id=:instance_id}]
    set assigned_uids_list [set_union $user_ids_list $cc_uids_list]
    return $assigned_uids_list
}

