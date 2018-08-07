#accounts-contacts/tcl/cs-util-procs.tcl
ad_library {

    misc API for accounts-contacts
    @creation-date 7 Aug 2018
    @Copyright (c) 2018 Benjamin Brink
    @license GNU General Public License 2
    @project home: http://github.com/tekbasse/accounts-contacts
    
}

# qc_properties  returns list of properties (defined in accounts-ledger)

# accounts-contacts.contact_id references refer to accounts-ledeger.contact_id
# so that package can be used  with contacts, contacts, or vendors.

ad_proc -public qal_keys_by {
    keys_list
    {separator ""}
} {
    if { $separator ne ""} {
        set keys ""
        if { $separator eq ",:" } {
            # for db
            set keys ":"
        }
        append keys [join $keys_list $separator]
    } else {
        set keys $keys_list
    }
    return $keys
}

ad_proc -public qal_contact_tz {
    contact_id
} {
    Retuns the timezone of the contact. 
    If not known, will guess based on primary user_id or system default.
    If timezone exists, will use it instead.
} {
    set tz [qal_contact_id_read $contact_id [list timezone user_id]]
    if { $tz eq "" && [qf_is_natural_number $user_id] } {
        set tz [lang::user::timezone $user_id]
    }
    if { $tz eq "" } {
        set tz [lang::system::timezone]
    }
    return $tz
}

ad_proc -public qal_timestamp_to_tz {
    timestamp_any_tz
    {tz ""}
    {timestamp_format "%Y-%m-%d %H:%M:%S%z"}
} {
    Converts a timestamp to specified timezone. 
    If timezone (tz) is empty string, converts to connected users's timezone otherwise system's default.
    If timestamp_format is empty string, uses clock scan's default interpretation.
} {
    if { $timestamp_format eq "" } {
        # let clock scan do a best guess
        set cs_s [clock scan $timestamp_any_tz]
    } else {
        set cs_s [clock scan $timestamp_any_tz -format $timestamp_format]
    }
    set yyyymmdd_hhmmss_utc [clock format $cs_s -gmt true]
    #redundant:
    # if $tz eq "", set tz \lang::system::timezone 
    set timestamp_ltz [lc_time_utc_to_local $yyyymmdd_hhmmss_utc $tz]
    return $timestamp_ltz
}
