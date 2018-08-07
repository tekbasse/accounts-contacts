#accounts-contacts/tcl/cs-biz-procs.tcl
ad_library {

    business procs for accounts-contacts
    @creation-date 7 Aug 2018
    @Copyright (c) 2018 Benjamin Brink
    @license GNU General Public License 2
    @project home: http://github.com/tekbasse/accounts-contacts
    
}



ad_proc -public cs_ticket_create {
    args
} {
    Create a ticket. Returns ticket_id. 
    If ticket_ref_name is defined, assigns the variable name of ticket_ref_name to the ticket's external reference.
    <br/>
    args: 
    contact_id authenticated_by ticket_category_id current_tier_level subject message internal_notes ignore_reopen_p unscheduled_service_req_p scheduled_operation_p scheduled_maint_req_p priority ann_type ann_message ann_message_type
    <br/>
    See c_tickets table definition for usage. ann_message, and ann_message_type is from cs_announcements table: ann_type, message
    <br/>
    To open a ticket with an announcement about a scheduled event, set ann_type to "MEMO"
    
} {
    upvar 1 instance_id instance_id

    set p [list \
               ticket_ref_name \
               contact_id \
               authenticated_by \
               ticket_category_id \
               current_tier_level \
               subject \
               message \
               internal_notes \
               cs_open_p \
               privacy_level \
               ignore_reopen_p \
               unsecheduled_service_req_p \
               scheduled_operation_p \
               scheduled_maint_req_p \
               priority \
               ticket_ref_name \
               ann_type \
               ann_message \
               ann_message_type \
               begins \
               expiration \
               allow_html_p ]

    qf_nv_list_to_vars $args $p

    if { $ticket_ref_name ne "" && [hf_list_filter_by_alphanum [list $ticket_ref_name]] } {
        upvar 1 $ticket_ref_name ticket_ref
    }
    set success_p 1
    set trashed_p 0
    set privacy_level [cs_privacy_level $privacy_level ]
    if { $ignore_reopen_p eq "" } {
        set package_id [ad_conn package_id]
        set ignore_reopen_p [parameter::get -parameter ignoreReopenP -package_id $package_id]
    }               
    # init new ticket, open,
    set user_id [ad_conn user_id]
    set cs_opened_by $user_id
    
    # defaults to %Y-%m-%d %H:%M:%S
    set cs_time_opened [dt_systime]
    set user_open_p 1
    set user_time_opened $cs_time_opened
    set cs_reps_list [cs_support_reps_of_cat category_id $ticket_category_id]
    if { [llength $cs_reps_list > 0 ]} {
        set cc_reps_list [cs_contact_reps_of_cat contact_id $contact_id category_id $ticket_category_id]
        if { [llength $cc_reps_list > 0 || ] } {
            set ticket_id [cs_id_seq_nextval ticket_ref]
            #set ticket_ref  --corresponds to ticket_id
            ns_log Notice "cs_ticket_create ticket_id '${ticket_id}' by user_id '${user_id}'"
            
            if { $ann_type ne "" && [hf_list_filter_by_alphanum [list $ann_type]] } {
                set ann_type [string range $ann_type 0 7]
            } else {
                set ann_type ""
                ns_log Notice "cs_ticket_create: ann_type '${ann_type}' not valid. ignoring."
            }
            db_transaction {
                db_dml cs_tickets_cr {insert into cs_tickets
                    (ticket_id,instance_id,contact_id,authenticated_by,ticket_category_id,
                     current_tier_level,subject,cs_open_p,opened_by,cs_time_opened,
                     user_open_p,user_time_opened,privacy_level,trashed_p,
                     ignore_reopen_p,unscheduled_service_req_p,scheduled_operation_p,
                     scheduled_maint_req_p,priority)
                    values (:ticket_id,:instance_id,:contact_id,:authenticated_by,:ticket_category_id,
                            :current_tier_level,:subject,:cs_open_p,:opened_by,:cs_time_opened,
                            :user_open_p,:user_time_opened,:privacy_level,:trashed_p,
                            :ignore_reopen_p,:unscheduled_service_req_p,:scheduled_operation_p,
                        :scheduled_maint_req_p,:priority)
                }
                cs_ticket_subscribe_contact_rep $ticket_id $cc_reps_list
                cs_ticket_subscribe_support_rep $ticket_id $cs_reps_list
            }
            
            set message_ref [cs_ticket_message_create ticket_id $ticket_id contact_id $contact_id privacy_level $privacy_level subject $subject message $message internal_notes $internal_notes internal_p $internal_p]
            if { $message_ref eq "" } {
                set sucess_p 0
            }
            if { $success_p && $scheduled_maint_req_p && $scheduled_operations_p && $ann_type ne "" } {
                
                # Operation has been scheduled with ticket creation.
                # set any annoucements (and advanced notices ie scheduled messages) associated with scheduled event
                if { $ann_message eq "" } {
                    set ann_message $message
                }
                set success_p [cs_announcement_create $ann_message $ann_message_type $contact_id "" $begins $expiration $ticket_id $allow_html_p]
                
            }
        } else {
            ns_log Warning "cs_ticket_create.120: No contact reps found for ticket_category_id '${ticket_category_id}' instance_id '${instance_id}'"
        }
    } else {
        ns_log Warning "cs_ticket_create.123: No support reps found for ticket_category_id '${ticket_category_id}' instance_id '${instance_id}'"
    }
    if { $success_p } {
        set return_id $ticket_id
    }
    return $return_id
}

